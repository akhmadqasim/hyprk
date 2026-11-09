# hyprk dist: coba hyprk dengan mudah

hyprk = Hyprland yang tampilannya mirip macOS 27. Ada menu bar, Dock, Control Center, Spotlight,
Notification Center, Finder, dan System Settings. Semua buatan sendiri di folder `/mnt/code/hyprk`.
GNOME kamu tidak diubah. Semua tes jalan di dalam satu jendela GNOME (nested).

## 1. Coba di dalam jendela (aman, mulai dari sini)

Buka terminal di GNOME, lalu:

```sh
/mnt/code/hyprk/dist/try-nested.sh
```

- Jendela baru muncul. Isinya hyprk. Tunggu sekitar 5 detik sampai menu bar dan Dock muncul.
- Opsi: `--dark` (tema GTK/Qt gelap), `--sound` (nyalakan suara, default senyap), `--share-config`
  (app bisa lihat `~/.config` asli kamu, default tidak).
- Keluar: `Ctrl+Alt+Q`, atau menu Apple > Log Out, atau `Ctrl+C` di terminal tadi.
  Script otomatis mematikan semua proses miliknya sendiri (termasuk sisa proses Hyprland).
- Nested memakai D-Bus milik GNOME, tapi pengaturan GTK dibaca dari file keyfile pribadi (bukan dconf/portal GNOME). Jadi tema dan tombol kiri hanya berlaku di dalam jendela.
- Semua pengaturan tema, font, kursor, dan config ada di `~/.local/share/hyprk-try`.
  Ingin mulai bersih? Hapus folder itu. `~/.config` dan setting GNOME kamu tidak disentuh.

### Tombol (di jendela nested)

GNOME memakai tombol Super untuk dirinya sendiri, jadi di nested tombol Super mungkin tidak sampai.
Pakai tombol Ctrl+Alt ini (belum dites dengan keyboard asli, baru dites lewat perintah):

| Fungsi | Nested | Login session |
|---|---|---|
| Spotlight | Ctrl+Alt+S | Super+Space |
| Pindah app (Cmd+Tab) | Ctrl+Alt+W | Super+Tab |
| Launchpad | Ctrl+Alt+A | Super+A atau F4 |
| Notification Center | Ctrl+Alt+N | Super+N |
| Control Center | Ctrl+Alt+C | Super+Shift+C |
| Mission Control | Ctrl+Alt+M | Super+Up, Ctrl+Up, atau F3 |
| Buka terminal (ghostty) | Ctrl+Alt+Return | Super+Return |
| Keluar dari hyprk | Ctrl+Alt+Q | Super+Shift+Escape |

Tombol lain (ada di kedua mode, kecuali yang pakai Super):

- Super+Q atau Super+W: tutup jendela. Super+M: jendela mengambang atau tidak. Super+Ctrl+F: layar penuh.
- Super + tahan klik kiri: geser jendela. Super + tahan klik kanan: ubah ukuran.
- Ctrl+1 sampai Ctrl+9: pindah Space. Ctrl+Shift+1..9: kirim jendela ke Space itu. Ctrl+kiri/kanan: Space sebelum/sesudah.
- Super+Shift+3: screenshot layar penuh. Super+Shift+4: screenshot area (butuh `slurp`). Print juga bisa.
- Tombol volume dan brightness jalan di komputer yang punya tombol itu.
- Semua jendela mengambang dan muncul di tengah, seperti macOS.

Ukuran jendela nested ditentukan GNOME. Tarik pinggir jendela untuk mengubah, hyprk ikut.

### Buka app lain

- Finder: klik ikon di Dock, atau `/mnt/code/hyprk/finder/run.sh ~/Documents`
- System Settings: ikon roda gigi di Dock, atau `/mnt/code/hyprk/settings/run.sh`

## 2. Pasang sebagai pilihan login (GDM)

Ini baru dipakai kalau nested sudah terlihat bagus. Satu-satunya file di `/usr` adalah
`/usr/share/wayland-sessions/hyprk.desktop`. GNOME tetap ada.

```sh
/mnt/code/hyprk/dist/install-session.sh --dry-run   # lihat dulu apa yang akan terjadi
/mnt/code/hyprk/dist/install-session.sh             # pasang (minta password sudo)
```

Lalu log out. Di layar login klik namamu, lalu ikon roda gigi di kanan bawah, pilih `hyprk`.
Mau kembali ke GNOME: log out, pilih `Ubuntu` di ikon roda gigi.

Di session asli, config app kamu tetap kelihatan (browser, JetBrains, dan lain-lain). Hanya GTK, Qt,
Ghostty, font, dan kursor yang dibuat khusus hyprk di `~/.local/share/hyprk-session`. Skala layar 1.5 (sama dengan
GNOME sekarang). Mau tema gelap? `echo dark > ~/.local/share/hyprk-session/theme`. Log: `~/.local/share/hyprk-session/state/session.log`.

Kalau layar hitam atau balik ke login: tekan Ctrl+Alt+F3, login, baca log di atas.
Pilih `Ubuntu` untuk masuk lagi. `/mnt/code` harus sudah ter-mount saat login.

## 3. Hapus

```sh
/mnt/code/hyprk/dist/install-session.sh --uninstall     # hapus hyprk.desktop dari /usr
rm -rf ~/.local/share/hyprk-try ~/.local/share/hyprk-session   # data pribadi hyprk (opsional)
```

## Yang perlu kamu lakukan sendiri (dari PROGRESS.md)

1. Matikan 4 proses Hyprland sisa dari tes awal (aman, kecil, sekitar 13 MB masing-masing):
   `ps -o pid,cmd -p 573829,574275,576400,577560` (pastikan semuanya `Hyprland --config .../hyprk/...`), lalu
   `kill -9 573829 574275 576400 577560`.
2. Di PROGRESS.md ada catatan: tes awal (sekitar 03:00 sampai 03:10) pernah menjalankan `pkill -x python3`.
   Kalau ada proses python3 milikmu yang tiba-tiba mati di jam itu, itu penyebabnya.
3. Opsional: `sudo apt install qt6-style-kvantum` untuk menu Qt yang membulat (qt6ct sudah terpasang, tema Qt sudah aktif).

## Batas yang sudah diketahui

- Nested di layar 4K skala 150% terlihat agak buram karena GNOME memperbesar gambarnya. Login session tajam.
- Login session belum pernah dicoba (script-nya tidak dijalankan). Nested sudah dites beberapa kali (start, screenshot, keluar).
- Hyprland 0.57.2 crash (segfault) saat keluar. Tidak berbahaya, script tetap membersihkan. Lihat `ISSUES.md`.
- Tampilan kira-kira 65 sampai 85 persen mirip macOS per bagian (glass material sekitar 68 persen).
- Tema GTK3 masih kurang rapi dibanding GTK4. App Qt tidak punya title bar macOS (butuh plugin hyprbars, belum ada).
- Ghostty menaruh tombol jendela di kanan (urutan kuning, hijau, merah) walau tema minta kiri. App libadwaita lain (tes `reference/ours/dist-try-adw.png`) sudah di kiri.
- Lock memakai hyprlock buatan hyprk (sudah ada di prefix). Di login session menu Lock lewat `lockscreen/hyprk-lock.sh` (wallpaper terbaru).
- Sleep, Restart, Shut Down, dan Lock hanya bekerja di login session. Di nested hanya dicatat di log.
- Belum ada: share layar (tanpa xdg-desktop-portal-hyprland), drag and drop di Finder, Quick Look di jendela sendiri.
- Wi-Fi, Bluetooth, dan baterai disembunyikan atau diredupkan kalau komputer tidak punya. Itu memang disengaja.
- Dua monitor: belum dicek bagaimana menu bar dan Dock muncul di monitor kedua.
- Suara senyap di nested supaya tidak mengganggu GNOME. Pakai `--sound` untuk menyalakan.
