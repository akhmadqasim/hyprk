.pragma library
// Privacy & Security: the 33 rows that push a sub-pane on macOS 27.2.1 (MAC-ANSWERS-13.md R13.1, live/settings-r13/
// DESTINATIONS.md, dest-privacyAndSecurity--*.png and their AX dumps), in the Mac's order and cards.
// kind: "empty" (the centred line of a class no application has asked for), "table" (an AppKit list with a + / −
// strip), or file: the sub-pane's own page in panes/privacy/.
// The Mac's application lists are blurred on the stills and `[redacted]` in the dumps, in round 13 and in round 14,
// so no application is listed here (hyprk has no TCC either): a class the Mac shows with applications shows what the
// Mac shows for one without, the "empty" line of that class (SecurityPrivacyExtension.appex Localizable.loctable, en:
// *_EMPTY_APP_LIST), and a "table" class its line and the + / − strip. The root rows show the Mac's own wording for
// none: "None" under a data class (Calendars on the capture), "0" at the end of the others (Motion & Fitness on the
// capture). Location Services' count is the Mac's own (22) and is left out (settings/FALLBACKS.md).
// value: what the root row shows (data classes: under the name; the others: at the row's end).
const groups = [
    [{ id: "location", title: "Location Services", file: "Location", icon: "privacy-location" }],
    [
        { id: "calendars", title: "Calendars", app: "Calendar", sub: "None", kind: "empty", head: "Applications that have requested access to your calendars will appear here." },
        { id: "contacts", title: "Contacts", app: "Contacts", sub: "None", kind: "empty", head: "Applications that have requested access to your contacts will appear here." },
        { id: "files", title: "Files & Folders", sub: "None", kind: "empty", head: "Apps that have requested access to files, folders, and other app data will appear here.", icon: "privacy-files" },
        { id: "fulldisk", title: "Full Disk Access", sub: "None", kind: "table", head: "Allow the applications below to access data like Mail, Messages, Safari, Home, Time Machine backups and certain administrative settings for all users on this Mac.", icon: "privacy-fulldisk" },
        { id: "home", title: "Home", app: "Home", sub: "None", kind: "empty", head: "Apps that have requested access to Home information will appear here." },
        { id: "media", title: "Media & Apple Music", app: "Music", sub: "None", kind: "table", head: "Allow the applications below to access Apple Music, your music and video activity, and your media library." },
        { id: "passkeys", title: "Passkeys Access for Web Browsers", sub: "None", kind: "empty", head: "Applications that have requested access to see which websites and apps you have saved passkeys for will appear here.", icon: "privacy-passkeys" },
        { id: "photos", title: "Photos", app: "Photos", sub: "None", kind: "empty", head: "Applications that have requested access to your photos will appear here." },
        { id: "reminders", title: "Reminders", app: "Reminders", sub: "None", kind: "empty", head: "Applications that have requested access to your reminders will appear here." }
    ],
    [
        { id: "appmanagement", title: "App Management", value: "0", kind: "table", head: "Allow the applications below to update or delete other applications.", icon: "privacy-appmanagement" },
        { id: "automation", title: "Automation", value: "0", kind: "empty", head: "Applications that have requested access to control other applications will appear here.", icon: "privacy-automation" },
        { id: "bluetooth", title: "Bluetooth", value: "0", kind: "table", head: "Allow the applications below to use Bluetooth.", icon: "privacy-bluetooth" },
        { id: "camera", title: "Camera", value: "0", kind: "empty", head: "Applications that have requested access to your camera will appear here.", icon: "privacy-camera" },
        { id: "developertools", title: "Developer Tools", value: "0", kind: "table", head: "Allow the applications below to run software locally that does not meet the system’s security policy.", icon: "privacy-developertools" },
        { id: "devicecontrol", title: "Device Control and Data Access", value: "0", kind: "table", head: "Apps with this access can view and send email, edit contacts and photos, monitor your keyboard, track websites, record your screen, control any app on your Mac, and more.", icon: "privacy-devicecontrol" },
        { id: "focus", title: "Focus", value: "0", kind: "empty", head: "Applications that have requested the ability to see and share your Focus status will appear here.", icon: "privacy-focus" },
        { id: "inputmonitoring", title: "Input Monitoring", value: "0", kind: "table", head: "Allow the applications below to monitor input from your keyboard even while using other applications.", icon: "privacy-inputmonitoring" },
        { id: "localnetwork", title: "Local Network", value: "0", kind: "table", head: "Allow the applications below to find and communicate with devices on your local network.", icon: "privacy-localnetwork" },
        { id: "microphone", title: "Microphone", value: "0", kind: "empty", head: "Applications that have requested access to your microphone will appear here.", icon: "privacy-microphone" },
        { id: "motion", title: "Motion & Fitness", value: "0", kind: "empty", head: "Applications that have requested access to your motion and fitness activity will appear here.", icon: "privacy-motion" },
        { id: "remotedesktop", title: "Remote Desktop", value: "0", kind: "empty", head: "Applications that have requested Remote Desktop access to the contents of your screen and audio will appear here.", icon: "privacy-remotedesktop" },
        { id: "screenrecording", title: "Screen & System Audio Recording", value: "0", file: "ScreenRecording", icon: "privacy-screenrecording" },
        { id: "speech", title: "Speech Recognition", value: "0", kind: "empty", head: "Applications that have requested access to speech recognition will appear here. Speech recognition sends recorded voice to Apple to process your requests.", icon: "privacy-speech" }
    ],
    [{ id: "sensitive", title: "Sensitive Content Warning", value: "Off", file: "SensitiveContent", icon: "privacy-sensitive" }],
    [{ id: "blocked", title: "Blocked Contacts", file: "BlockedContacts", icon: "privacy-blocked" }],
    [
        { id: "analytics", title: "Analytics & Improvements", file: "Analytics", icon: "privacy-analytics" },
        { id: "advertising", title: "Apple Advertising", file: "Advertising", icon: "privacy-advertising" }
    ],
    [{ id: "aireport", title: "Apple Intelligence Report", icon: "privacy-aireport", value: "On", file: "IntelligenceReport" }]
];
// Security's rows (after "Allow applications from"); the toolbar title of Accessories is "Wired Accessories"
const security = [
    { id: "filevault", title: "FileVault", value: "On", file: "FileVault", icon: "privacy-filevault" },
    { id: "accessories", title: "Wired Accessories", label: "Accessories", value: "Ask", file: "Accessories", icon: "privacy-accessories" },
    { id: "background", title: "Background Security Improvements", file: "BackgroundSecurity", icon: "privacy-background" }
];
const lockdown = { id: "lockdown", title: "Lockdown Mode", value: "Off", file: "Lockdown", icon: "privacy" };
function all() { let out = []; for (const g of groups) out = out.concat(g); return out.concat(security, [lockdown]); }
function find(id) { return all().find(c => c.id === id) || null; }
