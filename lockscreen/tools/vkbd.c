// vkbd: type into a TEST compositor with zwp_virtual_keyboard_v1 (US keymap), for lock screen tests.
// usage: WAYLAND_DISPLAY=<test socket> vkbd   then stdin lines:
//   t <text>      type ASCII text (letters, digits, space, a few symbols; Shift for capitals)
//   k <key>       tap one key: Return Escape BackSpace Caps_Lock Tab space
//   c <key>       Ctrl + key (key as above or a letter)
//   C <key>       Ctrl + Super + key (Ctrl+Cmd, e.g. C q = Lock Screen)
//   s <ms>        sleep
// Never point it at your real session: it types wherever the focus is.
#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/mman.h>
#include <wayland-client.h>
#include <xkbcommon/xkbcommon.h>
#include <linux/input-event-codes.h>
#include "vk.h"

static struct zwp_virtual_keyboard_manager_v1 *mgr;
static struct wl_seat *seat;
static struct wl_display *dpy;
static struct zwp_virtual_keyboard_v1 *kb;

static void reg(void *d, struct wl_registry *r, uint32_t n, const char *i, uint32_t v) {
    if (!strcmp(i, zwp_virtual_keyboard_manager_v1_interface.name)) mgr = wl_registry_bind(r, n, &zwp_virtual_keyboard_manager_v1_interface, 1);
    else if (!strcmp(i, wl_seat_interface.name) && !seat) seat = wl_registry_bind(r, n, &wl_seat_interface, 1);
}
static void rem(void *d, struct wl_registry *r, uint32_t n) {}
static const struct wl_registry_listener rl = {reg, rem};
static uint32_t ms(void) { struct timespec t; clock_gettime(CLOCK_MONOTONIC, &t); return t.tv_sec * 1000 + t.tv_nsec / 1000000; }
static void nap(int m) { struct timespec t = {m / 1000, (m % 1000) * 1000000L}; nanosleep(&t, NULL); }

static uint32_t mods;
// Lock (Caps) goes in the locked set, Shift and Control are held
static void setmods(uint32_t m) { mods = m; zwp_virtual_keyboard_v1_modifiers(kb, mods & ~2u, 0, mods & 2u, 0); }
static void key(int code, int down) { zwp_virtual_keyboard_v1_key(kb, ms(), code, down); wl_display_roundtrip(dpy); }
static void tap(int code) { key(code, 1); nap(12); key(code, 0); nap(12); }

// xkb modifier masks of the US keymap: Shift 1, Lock 2, Control 4
static int lookup(const char *name) {
    static const struct { const char *n; int c; } t[] = {
        {"Return", KEY_ENTER}, {"Escape", KEY_ESC}, {"BackSpace", KEY_BACKSPACE}, {"Caps_Lock", KEY_CAPSLOCK},
        {"Tab", KEY_TAB}, {"space", KEY_SPACE}, {"a", KEY_A}, {"u", KEY_U}, {NULL, 0}};
    for (int i = 0; t[i].n; i++) if (!strcmp(t[i].n, name)) return t[i].c;
    return -1;
}
static int ascii(char ch, int *shift) {
    static const char *lo = "abcdefghijklmnopqrstuvwxyz";
    static const int letters[] = {KEY_A, KEY_B, KEY_C, KEY_D, KEY_E, KEY_F, KEY_G, KEY_H, KEY_I, KEY_J, KEY_K, KEY_L, KEY_M,
                                  KEY_N, KEY_O, KEY_P, KEY_Q, KEY_R, KEY_S, KEY_T, KEY_U, KEY_V, KEY_W, KEY_X, KEY_Y, KEY_Z};
    static const int digits[] = {KEY_0, KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9};
    *shift = 0;
    const char *p;
    if (ch >= 'A' && ch <= 'Z') { *shift = 1; ch = ch - 'A' + 'a'; }
    if ((p = strchr(lo, ch)) && ch) return letters[p - lo];
    if (ch >= '0' && ch <= '9') return digits[ch - '0'];
    switch (ch) {
    case ' ': return KEY_SPACE; case '-': return KEY_MINUS; case '.': return KEY_DOT; case ',': return KEY_COMMA;
    case '_': *shift = 1; return KEY_MINUS; case '!': *shift = 1; return KEY_1;
    }
    return -1;
}

int main(void) {
    dpy = wl_display_connect(NULL);
    if (!dpy) { fprintf(stderr, "vkbd: no display\n"); return 1; }
    struct wl_registry *r = wl_display_get_registry(dpy);
    wl_registry_add_listener(r, &rl, NULL);
    wl_display_roundtrip(dpy);
    if (!mgr || !seat) { fprintf(stderr, "vkbd: no virtual keyboard manager\n"); return 1; }
    kb = zwp_virtual_keyboard_manager_v1_create_virtual_keyboard(mgr, seat);

    struct xkb_context *ctx = xkb_context_new(0);
    struct xkb_rule_names names = {.layout = "us"};
    struct xkb_keymap *km = xkb_keymap_new_from_names(ctx, &names, 0);
    char *s = xkb_keymap_get_as_string(km, XKB_KEYMAP_FORMAT_TEXT_V1);
    size_t len = strlen(s) + 1;
    int fd = memfd_create("vkbd-keymap", MFD_CLOEXEC);
    if (fd < 0 || ftruncate(fd, len) < 0) return 1;
    void *m = mmap(NULL, len, PROT_WRITE, MAP_SHARED, fd, 0);
    memcpy(m, s, len);
    munmap(m, len);
    zwp_virtual_keyboard_v1_keymap(kb, WL_KEYBOARD_KEYMAP_FORMAT_XKB_V1, fd, len);
    // a fresh state: Hyprland only forwards a change, so set and clear Lock to drop a stale Caps Lock
    setmods(2);
    setmods(0);
    wl_display_roundtrip(dpy);

    char line[512];
    while (fgets(line, sizeof line, stdin)) {
        line[strcspn(line, "\n")] = 0;
        if (line[0] == 't' && line[1] == ' ') {
            for (char *c = line + 2; *c; c++) {
                int sh, code = ascii(*c, &sh);
                if (code < 0) continue;
                if (sh) setmods(mods | 1);
                tap(code);
                if (sh) setmods(mods & ~1u);
            }
        } else if ((line[0] == 'k' || line[0] == 'c' || line[0] == 'C') && line[1] == ' ') {
            int code = lookup(line + 2), sh;
            if (code < 0) code = ascii(line[2], &sh);
            if (code < 0) { fprintf(stderr, "vkbd: unknown key %s\n", line + 2); continue; }
            if (line[0] != 'k') { key(KEY_LEFTCTRL, 1); setmods(mods | 4); }
            if (line[0] == 'C') { key(KEY_LEFTMETA, 1); setmods(mods | 64); }   // Mod4
            tap(code);
            if (line[0] == 'C') { key(KEY_LEFTMETA, 0); setmods(mods & ~64u); }
            if (line[0] != 'k') { key(KEY_LEFTCTRL, 0); setmods(mods & ~4u); }
            // Caps Lock toggles the Lock modifier; the compositor keeps its own xkb state as well
            if (code == KEY_CAPSLOCK) setmods(mods ^ 2u);
        } else if (line[0] == 's' && line[1] == ' ') {
            nap(atoi(line + 2));
        }
        wl_display_flush(dpy);
    }
    wl_display_roundtrip(dpy);
    return 0;
}
