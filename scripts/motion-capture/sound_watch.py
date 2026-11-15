"""Watch: stamps a file's first change on CLOCK_MONOTONIC (sound-timing.py, dock-drag-off.py: the sound log)."""
import os, threading, time


class Watch:
    """stamps (CLOCK_MONOTONIC ns) the first change of each file after start(): a spinning stat, about 5 us a turn"""

    def __init__(self, paths, seconds):
        self.paths, self.t, self.end = paths, {}, time.monotonic() + seconds
        self.sig = {k: self.read(p) for k, p in paths.items()}
        self.th = threading.Thread(target=self.run)
        self.th.start()

    @staticmethod
    def read(p):
        try:
            st = os.stat(p)
            return (st.st_ino, st.st_size, st.st_mtime_ns)
        except OSError:
            return None

    def run(self):
        while len(self.t) < len(self.paths) and time.monotonic() < self.end:
            for k, p in self.paths.items():
                if k not in self.t and self.read(p) != self.sig[k]:
                    self.t[k] = time.monotonic_ns()

    def done(self):
        self.th.join()
        return self.t
