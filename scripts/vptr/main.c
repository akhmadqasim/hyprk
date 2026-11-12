// vptr: drive the pointer of a wlroots-style compositor with zwlr_virtual_pointer_v1.
// usage: vptr W H  then lines on stdin: "x y delay_ms" (absolute, global logical px in a W x H layout box);
//        "b" = left click, "d" / "u" = left press / release
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <stdlib.h>
#include <wayland-client.h>
#include <linux/input-event-codes.h>
#include "vp.h"
static struct zwlr_virtual_pointer_manager_v1 *mgr; static struct wl_seat *seat;
static void reg(void *d, struct wl_registry *r, uint32_t n, const char *i, uint32_t v) {
    if (!strcmp(i, zwlr_virtual_pointer_manager_v1_interface.name)) mgr = wl_registry_bind(r, n, &zwlr_virtual_pointer_manager_v1_interface, 1);
    else if (!strcmp(i, wl_seat_interface.name)) seat = wl_registry_bind(r, n, &wl_seat_interface, 1);
}
static void rem(void *d, struct wl_registry *r, uint32_t n) {}
static const struct wl_registry_listener rl = {reg, rem};
static uint32_t ms(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1000 + t.tv_nsec / 1000000; }
int main(int argc, char **argv) {
    unsigned W = 1280, H = 720; if (argc > 2) { W = atoi(argv[1]); H = atoi(argv[2]); }
    struct wl_display *dpy = wl_display_connect(NULL); if (!dpy) return 1;
    struct wl_registry *r = wl_display_get_registry(dpy); wl_registry_add_listener(r, &rl, NULL); wl_display_roundtrip(dpy);
    if (!mgr) { fprintf(stderr, "no virtual pointer\n"); return 1; }
    struct zwlr_virtual_pointer_v1 *p = zwlr_virtual_pointer_manager_v1_create_virtual_pointer(mgr, seat);
    char line[128]; double x, y; int d;
    while (fgets(line, sizeof line, stdin)) {
        if (line[0] == 'b') { zwlr_virtual_pointer_v1_button(p, ms(), BTN_LEFT, 1); zwlr_virtual_pointer_v1_frame(p); wl_display_flush(dpy);
            zwlr_virtual_pointer_v1_button(p, ms(), BTN_LEFT, 0); zwlr_virtual_pointer_v1_frame(p); wl_display_roundtrip(dpy); continue; }
        if (line[0] == 'r') { zwlr_virtual_pointer_v1_button(p, ms(), BTN_RIGHT, 1); zwlr_virtual_pointer_v1_frame(p); wl_display_flush(dpy);
            zwlr_virtual_pointer_v1_button(p, ms(), BTN_RIGHT, 0); zwlr_virtual_pointer_v1_frame(p); wl_display_roundtrip(dpy); continue; }
        if (line[0] == 'd' || line[0] == 'u') { zwlr_virtual_pointer_v1_button(p, ms(), BTN_LEFT, line[0] == 'd'); zwlr_virtual_pointer_v1_frame(p); wl_display_roundtrip(dpy); continue; }
        if (sscanf(line, "%lf %lf %d", &x, &y, &d) != 3) continue;
        zwlr_virtual_pointer_v1_motion_absolute(p, ms(), (uint32_t)x, (uint32_t)y, W, H);
        zwlr_virtual_pointer_v1_frame(p); wl_display_flush(dpy);
        if (d > 0) { struct timespec ts = {0, d * 1000000L}; nanosleep(&ts, NULL); }
    }
    wl_display_roundtrip(dpy); zwlr_virtual_pointer_v1_destroy(p); wl_display_roundtrip(dpy);
    return 0;
}
