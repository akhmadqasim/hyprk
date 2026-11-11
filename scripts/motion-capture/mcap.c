// mcap: per-frame screen capture for motion measurement (wlr-screencopy v3, copy_with_damage).
//
// Each capture request is answered by the compositor on the next rendered frame that has damage, and the
// `ready` event carries that frame's presentation time (CLOCK_MONOTONIC on Hyprland). Requests are chained
// back to back, so every rendered frame of an animation is captured as long as one shm copy of the region
// takes less than a refresh interval (a 600x400 pt region at 2x copies in about 1-2 ms). Timestamps are the
// compositor's, not the client's, so the time axis has no client jitter.
//
// Usage: mcap -o PREFIX -g X,Y,W,H [-O OUTPUT] [-k STEP] [-t SECONDS] [-p PRE] [-- trigger command...]
//   -g   region in output-local logical px (the buffer is in physical px)
//   -k   keep every STEP-th physical pixel in x and y (default 2 = 1 sample per logical px at 2x)
//   -t   stop SECONDS after the trigger (default 1.5)
//   -p   frames captured before the trigger runs (default 2; the first is the "before" reference)
//   the trigger is ONE string run through /bin/sh -c; its start time (CLOCK_MONOTONIC) is written as t0.
// Output: PREFIX.json {w,h,format,t0_ns,frames} and PREFIX.raw (frames of h rows x w px x 3 bytes RGB) and
//   PREFIX.csv (frame, present_ns, received_ns). Analyse with mcap.py.
#define _GNU_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <poll.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>
#include <wayland-client.h>

#include "wlr-screencopy-unstable-v1-client-protocol.h"

static struct wl_shm *shm;
static struct zwlr_screencopy_manager_v1 *mgr;
static struct wl_output *outputs[8];
static char *outnames[8];
static int noutputs;

static struct {
    uint32_t format, w, h, stride;
    struct wl_buffer *buf;
    void *data;
    size_t size;
    int done, failed, yinvert;
    uint64_t present;
} fr;

static int64_t now_ns(void) {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (int64_t)ts.tv_sec * 1000000000LL + ts.tv_nsec;
}

static void out_name(void *d, struct wl_output *o, const char *name) {
    for (int i = 0; i < noutputs; i++)
        if (outputs[i] == o) outnames[i] = strdup(name);
}
static void out_geom(void *d, struct wl_output *o, int32_t x, int32_t y, int32_t pw, int32_t ph, int32_t s,
                     const char *mk, const char *md, int32_t t) {}
static void out_mode(void *d, struct wl_output *o, uint32_t f, int32_t w, int32_t h, int32_t r) {}
static void out_done(void *d, struct wl_output *o) {}
static void out_scale(void *d, struct wl_output *o, int32_t s) {}
static void out_desc(void *d, struct wl_output *o, const char *s) {}
static const struct wl_output_listener out_l = {out_geom, out_mode, out_done, out_scale, out_name, out_desc};

static void reg_global(void *d, struct wl_registry *r, uint32_t name, const char *iface, uint32_t ver) {
    if (!strcmp(iface, wl_shm_interface.name))
        shm = wl_registry_bind(r, name, &wl_shm_interface, 1);
    else if (!strcmp(iface, zwlr_screencopy_manager_v1_interface.name))
        mgr = wl_registry_bind(r, name, &zwlr_screencopy_manager_v1_interface, ver < 3 ? ver : 3);
    else if (!strcmp(iface, wl_output_interface.name) && noutputs < 8 && ver >= 4) {
        outputs[noutputs] = wl_registry_bind(r, name, &wl_output_interface, 4);
        wl_output_add_listener(outputs[noutputs], &out_l, NULL);
        noutputs++;
    }
}
static void reg_remove(void *d, struct wl_registry *r, uint32_t n) {}
static const struct wl_registry_listener reg_l = {reg_global, reg_remove};

static void f_buffer(void *d, struct zwlr_screencopy_frame_v1 *f, uint32_t fmt, uint32_t w, uint32_t h, uint32_t st) {
    if (fr.buf && fr.w == w && fr.h == h && fr.stride == st && fr.format == fmt) return;
    fr.format = fmt; fr.w = w; fr.h = h; fr.stride = st; fr.size = (size_t)st * h;
    int fd = memfd_create("mcap", MFD_CLOEXEC);
    if (fd < 0 || ftruncate(fd, fr.size) < 0) { perror("memfd"); exit(1); }
    fr.data = mmap(NULL, fr.size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    struct wl_shm_pool *pool = wl_shm_create_pool(shm, fd, fr.size);
    fr.buf = wl_shm_pool_create_buffer(pool, 0, w, h, st, fmt);
    wl_shm_pool_destroy(pool);
    close(fd);
}
static void f_flags(void *d, struct zwlr_screencopy_frame_v1 *f, uint32_t flags) { fr.yinvert = flags & 1; }
static void f_ready(void *d, struct zwlr_screencopy_frame_v1 *f, uint32_t hi, uint32_t lo, uint32_t ns) {
    fr.present = ((((uint64_t)hi) << 32) | lo) * 1000000000ULL + ns;
    fr.done = 1;
}
static void f_failed(void *d, struct zwlr_screencopy_frame_v1 *f) { fr.failed = 1; }
static void f_damage(void *d, struct zwlr_screencopy_frame_v1 *f, uint32_t x, uint32_t y, uint32_t w, uint32_t h) {}
static void f_dmabuf(void *d, struct zwlr_screencopy_frame_v1 *f, uint32_t fmt, uint32_t w, uint32_t h) {}
static int first_copy;
static void f_buffer_done(void *d, struct zwlr_screencopy_frame_v1 *f) {
    if (first_copy) zwlr_screencopy_frame_v1_copy(f, fr.buf);   // the reference frame: copy now, no damage wait
    else zwlr_screencopy_frame_v1_copy_with_damage(f, fr.buf);
}
static const struct zwlr_screencopy_frame_v1_listener frame_l = {f_buffer, f_flags, f_ready, f_failed,
                                                                 f_damage, f_dmabuf, f_buffer_done};

int main(int argc, char **argv) {
    const char *prefix = NULL, *oname = NULL;
    int gx = 0, gy = 0, gw = 0, gh = 0, step = 2, pre = 2;
    double secs = 1.5;
    int opt;
    while ((opt = getopt(argc, argv, "o:g:O:k:t:p:")) != -1) {
        if (opt == 'o') prefix = optarg;
        else if (opt == 'g') sscanf(optarg, "%d,%d,%d,%d", &gx, &gy, &gw, &gh);
        else if (opt == 'O') oname = optarg;
        else if (opt == 'k') step = atoi(optarg);
        else if (opt == 't') secs = atof(optarg);
        else if (opt == 'p') pre = atoi(optarg);
    }
    if (!prefix || gw <= 0 || gh <= 0 || step < 1) { fprintf(stderr, "usage: see header of mcap.c\n"); return 2; }
    struct wl_display *dpy = wl_display_connect(NULL);
    if (!dpy) { fprintf(stderr, "mcap: no wayland display\n"); return 1; }
    struct wl_registry *reg = wl_display_get_registry(dpy);
    wl_registry_add_listener(reg, &reg_l, NULL);
    wl_display_roundtrip(dpy);
    wl_display_roundtrip(dpy);
    if (!mgr || !shm || !noutputs) { fprintf(stderr, "mcap: no screencopy/shm/output\n"); return 1; }
    struct wl_output *out = outputs[0];
    for (int i = 0; oname && i < noutputs; i++)
        if (outnames[i] && !strcmp(outnames[i], oname)) out = outputs[i];

    char path[4096];
    snprintf(path, sizeof path, "%s.raw", prefix);
    FILE *raw = fopen(path, "wb");
    snprintf(path, sizeof path, "%s.csv", prefix);
    FILE *csv = fopen(path, "w");
    if (!raw || !csv) { perror("mcap: open"); return 1; }
    fprintf(csv, "frame,present_ns,received_ns\n");

    int ow = 0, oh = 0, n = 0;
    int64_t t0 = 0, stop = INT64_MAX;
    pid_t child = 0;
    uint8_t *row = NULL;
    for (;;) {
        fr.done = fr.failed = 0;
        first_copy = (n == 0);
        struct zwlr_screencopy_frame_v1 *f = zwlr_screencopy_manager_v1_capture_output_region(mgr, 0, out, gx, gy, gw, gh);
        zwlr_screencopy_frame_v1_add_listener(f, &frame_l, NULL);
        wl_display_flush(dpy);
        while (!fr.done && !fr.failed) {
            // wait for the frame, but give up when the capture window ends with no new damage
            while (wl_display_prepare_read(dpy) != 0) wl_display_dispatch_pending(dpy);
            wl_display_flush(dpy);
            int64_t left = stop == INT64_MAX ? 5000 : (stop - now_ns()) / 1000000;
            struct pollfd p = {wl_display_get_fd(dpy), POLLIN, 0};
            int r = left > 0 ? poll(&p, 1, (int)left) : 0;
            if (r > 0) wl_display_read_events(dpy); else wl_display_cancel_read(dpy);
            wl_display_dispatch_pending(dpy);
            if (r <= 0 && !fr.done) { fr.failed = 2; break; }
        }
        zwlr_screencopy_frame_v1_destroy(f);
        if (fr.failed == 2) break;
        if (fr.failed) { fprintf(stderr, "mcap: capture failed\n"); break; }
        int64_t got = now_ns();
        ow = (fr.w + step - 1) / step; oh = (fr.h + step - 1) / step;
        if (!row) row = malloc((size_t)ow * 3);
        for (int y = 0; y < oh; y++) {
            int sy = fr.yinvert ? (int)fr.h - 1 - y * step : y * step;
            const uint8_t *src = (const uint8_t *)fr.data + (size_t)sy * fr.stride;
            for (int x = 0; x < ow; x++) {
                const uint8_t *px = src + (size_t)x * step * 4;
                // wl_shm ARGB/XRGB8888 (0/1) and fourcc XR24/AR24 are B,G,R,X in memory; XB24/AB24 are R,G,B,X
                int rgbx = fr.format == 0x34324258 || fr.format == 0x34324241;
                row[x * 3 + 0] = rgbx ? px[0] : px[2];
                row[x * 3 + 1] = px[1];
                row[x * 3 + 2] = rgbx ? px[2] : px[0];
            }
            fwrite(row, 3, ow, raw);
        }
        fprintf(csv, "%d,%llu,%lld\n", n, (unsigned long long)fr.present, (long long)got);
        n++;
        if (n == pre && optind < argc && !child) {
            t0 = now_ns();
            stop = t0 + (int64_t)(secs * 1e9);
            child = fork();
            if (child == 0) {
                execl("/bin/sh", "sh", "-c", argv[optind], (char *)NULL);
                _exit(127);
            }
        } else if (n == pre && optind >= argc && stop == INT64_MAX) {
            t0 = now_ns();
            stop = t0 + (int64_t)(secs * 1e9);
        }
        if (now_ns() >= stop) break;
    }
    if (child > 0) waitpid(child, NULL, 0);
    fclose(raw);
    fclose(csv);
    snprintf(path, sizeof path, "%s.json", prefix);
    FILE *js = fopen(path, "w");
    fprintf(js, "{\"w\": %d, \"h\": %d, \"step\": %d, \"format\": %u, \"t0_ns\": %lld, \"frames\": %d, "
                "\"region\": [%d, %d, %d, %d]}\n", ow, oh, step, fr.format, (long long)t0, n, gx, gy, gw, gh);
    fclose(js);
    fprintf(stderr, "mcap: %d frames %dx%d\n", n, ow, oh);
    return 0;
}
