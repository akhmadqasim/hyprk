// fscroll: trackpad-like (finger source) scrolls for a nested test session, through zwlr_virtual_pointer_v1.
// Hyprland 0.57 forwards a virtual pointer's axis as a mouse wheel (axis_source 0, axis_value120, axis 0) unless
// axis_source comes AFTER axis in the frame; in that order clients get axis_source finger and the axis value, and
// Qt 6.10 turns it into ScrollBegin / ScrollUpdate (pixelDelta) / ScrollEnd on axis_stop, like a real touchpad.
// usage: fscroll W H, then stdin lines (global logical px in a W x H layout box):
//   "m x y"  move the pointer      "v dy" / "h dx"  one finger scroll frame (surface px, + = content up / left)
//   "s"      fingers lifted (axis_stop on both axes)      "z ms"  sleep
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <wayland-client.h>
#include "wlr-virtual-pointer-unstable-v1-client-protocol.h"
static struct zwlr_virtual_pointer_manager_v1 *mgr;
static struct wl_seat *seat;
static void reg(void *d, struct wl_registry *r, uint32_t n, const char *i, uint32_t v) {
    if (!strcmp(i, zwlr_virtual_pointer_manager_v1_interface.name)) mgr = wl_registry_bind(r, n, &zwlr_virtual_pointer_manager_v1_interface, 1);
    else if (!strcmp(i, wl_seat_interface.name)) seat = wl_registry_bind(r, n, &wl_seat_interface, 1);
}
static void rem(void *d, struct wl_registry *r, uint32_t n) {}
static const struct wl_registry_listener rl = {reg, rem};
static uint32_t ms(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1000 + t.tv_nsec / 1000000; }
int main(int argc, char **argv) {
    unsigned W = argc > 2 ? atoi(argv[1]) : 1280, H = argc > 2 ? atoi(argv[2]) : 832;
    struct wl_display *dpy = wl_display_connect(NULL);
    if (!dpy) return 1;
    struct wl_registry *r = wl_display_get_registry(dpy);
    wl_registry_add_listener(r, &rl, NULL);
    wl_display_roundtrip(dpy);
    if (!mgr) { fprintf(stderr, "no virtual pointer\n"); return 1; }
    struct zwlr_virtual_pointer_v1 *p = zwlr_virtual_pointer_manager_v1_create_virtual_pointer(mgr, seat);
    char line[128];
    double a, b;
    while (fgets(line, sizeof line, stdin)) {
        if (line[0] == 'm' && sscanf(line + 1, "%lf %lf", &a, &b) == 2)
            zwlr_virtual_pointer_v1_motion_absolute(p, ms(), (uint32_t)a, (uint32_t)b, W, H);
        else if ((line[0] == 'v' || line[0] == 'h') && sscanf(line + 1, "%lf", &a) == 1) {
            zwlr_virtual_pointer_v1_axis(p, ms(), line[0] == 'v' ? WL_POINTER_AXIS_VERTICAL_SCROLL : WL_POINTER_AXIS_HORIZONTAL_SCROLL,
                                         wl_fixed_from_double(a));
            zwlr_virtual_pointer_v1_axis_source(p, WL_POINTER_AXIS_SOURCE_FINGER);
        } else if (line[0] == 's') {
            zwlr_virtual_pointer_v1_axis_source(p, WL_POINTER_AXIS_SOURCE_FINGER);
            zwlr_virtual_pointer_v1_axis_stop(p, ms(), WL_POINTER_AXIS_VERTICAL_SCROLL);
            zwlr_virtual_pointer_v1_axis_stop(p, ms(), WL_POINTER_AXIS_HORIZONTAL_SCROLL);
        } else if (line[0] == 'z' && sscanf(line + 1, "%lf", &a) == 1) {
            struct timespec ts = {(time_t)(a / 1000), (long)(fmod(a, 1000) * 1e6)};
            nanosleep(&ts, NULL);
            continue;
        } else continue;
        zwlr_virtual_pointer_v1_frame(p);
        wl_display_flush(dpy);
    }
    wl_display_roundtrip(dpy);
    zwlr_virtual_pointer_v1_destroy(p);
    wl_display_roundtrip(dpy);
    return 0;
}
