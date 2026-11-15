# Destinations reachable from Wi-Fi, Network, Battery, Menu Bar, Spotlight, Wallpaper, Focus, Lock Screen, Privacy & Security (27.2.1)

Stills: `dest-<name>-{dark,light}.png`, AX: `ax-dest-<name>-{dark,light}.jsonl`. `<pane>` alone is the pane's own top. Level 2 = opened from inside a level-1 sub-pane.

| name | level | opens as | toolbar title | sheet size (pt) | trigger (AX role, size) |
|---|---|---|---|---|---|
| battery--options | 1 | sheet |  | 470x347 at window 135,139 | AXButton [82, 24] |
| lockScreen--accessibility-options | 1 | sheet |  | 470x479 at window 135,73 | AXButton [161, 24] |
| wifi--details | 1 | sheet |  | 670x425 at window 35,100 | AXButton [76, 24] |
| wifi--other | 1 | sheet |  | 400x325 at window 170,150 | AXButton [68, 24] |
| wifi--advanced | 1 | sheet |  | 470x532 at window 135,52 | AXButton [94.5, 24] |
| network--wi-fi | 1 | sub-pane | Wi-Fi |  | AXButton [468, 52] |
| network--wi-fi--details | 2 | sheet |  | 670x425 at window 35,100 | AXButton [76, 24] |
| network--wi-fi--other | 2 | sheet |  | 400x325 at window 170,150 | AXButton [68, 24] |
| network--wi-fi--advanced | 2 | sheet |  | 470x480 at window 135,72 | AXButton [94.5, 24] |
| network--vpn | 1 | sub-pane | VPN |  | AXButton [468, 52] |
| network--firewall | 1 | sub-pane | Firewall |  | AXButton [468, 52] |
| network--firewall--options | 2 | sheet |  | 500x532 at window 120,52 | AXButton [82, 24] |
| network--usb-10-100-1000-lan | 1 | sub-pane | USB 10/100/1000 LAN |  | AXButton [468, 52] |
| network--usb-10-100-1000-lan--details | 2 | sheet |  | 670x425 at window 35,100 | AXButton [76, 24] |
| network--usb-10-100-lan | 1 | sub-pane | USB 10/100 LAN |  | AXButton [468, 52] |
| network--usb-10-100-lan--details | 2 | sheet |  | 670x425 at window 35,100 | AXButton [76, 24] |
| network--ax88179a | 1 | sub-pane | AX88179A |  | AXButton [468, 52] |
| network--ax88179a--details | 2 | sheet |  | 670x425 at window 35,100 | AXButton [76, 24] |
| network--ax88179b | 1 | sub-pane | AX88179B |  | AXButton [468, 52] |
| network--ax88179b--details | 2 | sheet |  | 670x425 at window 35,100 | AXButton [76, 24] |
| network--thunderbolt-bridge | 1 | sub-pane | Thunderbolt Bridge |  | AXButton [468, 52] |
| network--thunderbolt-bridge--details | 2 | sheet |  | 670x425 at window 35,100 | AXButton [76, 24] |
| network--iphone-usb | 1 | sub-pane | iPhone USB |  | AXButton [468, 52] |
| network--iphone-usb--details | 2 | sheet |  | 670x425 at window 35,100 | AXButton [76, 24] |
| controlCenter--clock-options | 1 | sheet |  | 470x533 at window 135,52 | AXButton [120, 24] |
| controlCenter--battery-options | 1 | sheet |  | 470x210 at window 135,207 | AXButton [129.5, 24] |
| search--info | 1 | sheet |  | 500x533 at window 120,52 | AXButton [13, 13] |
| search--search-privacy | 1 | sheet |  | 470x375 at window 135,125 | AXButton [123.5, 24] |
| wallpaper--screen-saver | 1 | sheet |  | 500x548 at window 120,52 | AXButton [113.5, 24] |
| wallpaper--clock-appearance | 1 | popover |  | 430x188 window (visible bubble about 398x154) below the button, extends 126 pt past the window's right edge | AXButton [145.5, 24] |
| focus--do-not-disturb | 1 | sub-pane | Do Not Disturb |  | AXButton [468, 52] |
| focus--driving | 1 | sub-pane | Driving |  | AXButton [468, 52] |
| focus--mindfulness | 1 | sub-pane | Mindfulness |  | AXButton [468, 52] |
| focus--reduce-interruptions | 1 | sub-pane | Reduce Interruptions |  | AXButton [468, 52] |
| focus--sleep | 1 | sub-pane | Sleep |  | AXButton [468, 52] |
| focus--work | 1 | sub-pane | Work |  | AXButton [468, 52] |
| focus--focus-status | 1 | sub-pane | Focus Status |  | AXButton [468, 68] |
| privacyAndSecurity--location-services | 1 | sub-pane | Location Services |  | AXButton [468, 42] |
| privacyAndSecurity--location-services--details | 2 | sheet |  | 470x533 at window 135,52 | AXButton [76, 24] |
| privacyAndSecurity--calendars | 1 | sub-pane | Calendars |  | AXButton [468, 52] |
| privacyAndSecurity--contacts | 1 | sub-pane | Contacts |  | AXButton [468, 52] |
| privacyAndSecurity--files-folders | 1 | sub-pane | Files & Folders |  | AXButton [468, 52] |
| privacyAndSecurity--full-disk-access | 1 | sub-pane | Full Disk Access |  | AXButton [468, 52] |
| privacyAndSecurity--home | 1 | sub-pane | Home |  | AXButton [468, 52] |
| privacyAndSecurity--media-apple-music | 1 | sub-pane | Media & Apple Music |  | AXButton [468, 52] |
| privacyAndSecurity--passkeys-access-for-web-browsers | 1 | sub-pane | Passkeys Access for Web Browsers |  | AXButton [468, 52] |
| privacyAndSecurity--photos | 1 | sub-pane | Photos |  | AXButton [468, 52] |
| privacyAndSecurity--photos--options | 2 | sheet |  | 470x260 at window 135,182 | AXButton [82, 24] |
| privacyAndSecurity--reminders | 1 | sub-pane | Reminders |  | AXButton [468, 52] |
| privacyAndSecurity--app-management | 1 | sub-pane | App Management |  | AXButton [468, 42] |
| privacyAndSecurity--automation | 1 | sub-pane | Automation |  | AXButton [468, 42] |
| privacyAndSecurity--bluetooth | 1 | sub-pane | Bluetooth |  | AXButton [468, 42] |
| privacyAndSecurity--camera | 1 | sub-pane | Camera |  | AXButton [468, 42] |
| privacyAndSecurity--developer-tools | 1 | sub-pane | Developer Tools |  | AXButton [468, 42] |
| privacyAndSecurity--device-control-and-data-access | 1 | sub-pane | Device Control and Data Access |  | AXButton [468, 42] |
| privacyAndSecurity--focus | 1 | sub-pane | Focus |  | AXButton [468, 42] |
| privacyAndSecurity--input-monitoring | 1 | sub-pane | Input Monitoring |  | AXButton [468, 42] |
| privacyAndSecurity--local-network | 1 | sub-pane | Local Network |  | AXButton [468, 42] |
| privacyAndSecurity--microphone | 1 | sub-pane | Microphone |  | AXButton [468, 42] |
| privacyAndSecurity--motion-fitness | 1 | sub-pane | Motion & Fitness |  | AXButton [468, 42] |
| privacyAndSecurity--remote-desktop | 1 | sub-pane | Remote Desktop |  | AXButton [468, 42] |
| privacyAndSecurity--screen-system-audio-recording | 1 | sub-pane | Screen & System Audio Recording |  | AXButton [468, 42] |
| privacyAndSecurity--speech-recognition | 1 | sub-pane | Speech Recognition |  | AXButton [468, 42] |
| privacyAndSecurity--sensitive-content-warning | 1 | sub-pane | Sensitive Content Warning |  | AXButton [468, 42] |
| privacyAndSecurity--blocked-contacts | 1 | sub-pane | Blocked Contacts |  | AXButton [468, 42] |
| privacyAndSecurity--analytics-improvements | 1 | sub-pane | Analytics & Improvements |  | AXButton [468, 42] |
| privacyAndSecurity--apple-advertising | 1 | sub-pane | Apple Advertising |  | AXButton [468, 42] |
| privacyAndSecurity--apple-advertising--view-ad-targeting-information | 2 | sheet |  | 500x400 at window 120,112 | AXButton [217, 24] |
| privacyAndSecurity--apple-intelligence-report | 1 | sub-pane | Apple Intelligence Report |  | AXButton [468, 42] |
| privacyAndSecurity--filevault | 1 | sub-pane | FileVault |  | AXButton [468, 42] |
| privacyAndSecurity--accessories | 1 | sub-pane | Wired Accessories |  | AXButton [468, 42] |
| privacyAndSecurity--background-security-improvements | 1 | sub-pane | Background Security Improvements |  | AXButton [468, 42] |
| privacyAndSecurity--lockdown-mode | 1 | sub-pane | Lockdown Mode |  | AXButton [468, 42] |
| privacyAndSecurity--advanced | 1 | sheet |  | 470x199 at window 135,213 | AXButton [94.5, 24] |
