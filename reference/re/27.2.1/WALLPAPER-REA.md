# Wallpaper and Aerial downloads REA, macOS 27.2.1 (26B131)

Static reverse engineering of the IPSW plus a few live checks of the public catalog URLs (14 Nov 2026, 09:13 to
09:20 UTC, from the PC, plain curl, no cookies). Nothing was run on a Mac. No wallpaper image, video or archive over
5 MB was downloaded: sizes below come from `Content-Length` of HEAD requests.

Headline: macOS 27.2.1 uses three separate download paths, none of them is idleassetsd.

| Kind | Who fetches | Catalog | Files |
|---|---|---|---|
| Still and dynamic `.heic` pictures (Big Sur, Catalina, hello, Radial, ...) | WallpaperImage/DynamicExtension through WallpaperFoundation `MobileAssetManager`, then `mobileassetd` | MobileAsset type `com.apple.MobileAsset.DesktopPicture`, XML catalog `https://mesu.apple.com/assets/macos/com_apple_MobileAsset_DesktopPicture/com_apple_MobileAsset_DesktopPicture.xml` (Pallas `https://gdmf.apple.com/v2/assets` is the other MobileAsset server, use for this type not checked) | 71 zips on `updates.cdn-apple.com`, 1.94 GB in total |
| Aerials (wallpaper and screen saver) | WallpaperAerialsExtension / WallpaperAgent (code module `WallpaperAerialsCore`) | `https://configuration.apple.com/configurations/internetservices/aerials/resources-config-27-2.plist` -> `resources-url` -> `resources-*.tar` (`entries.json` + `TVIdleScreenStrings.bundle`) | 164 `.mov` on `sylvan.apple.com`, HEVC 4K SDR 240 fps |
| Tahoe (the 26/27 default, "NeptuneOne") motion version | NeptuneOneWallpaper.appex | bundled `manifest.json` (4 URLs, no remote catalog) | 4 `.mov` on `sylvan.apple.com`, 30 to 45 MB each |

Live status on 14 Nov 2026: the DesktopPicture XML is up (200, 75,194 bytes). The 27.2 Aerial config URL is **404**.
`resources-config-27-0.plist` is up and points to `resources-27-0-1.tar`, which holds the same 164 assets as the
`entries.json` bundled in 27.2.1 (bundled `version` 2 vs remote `version` 1, one asset URL differs). So a 27.2.1 Mac
today runs on the bundled manifest (inferred from the "Loading fallback manifest" / `bundledManifest` strings, not
observed on a Mac).

## Method (PC, Linux)

- System volume `~/Downloads/macos/work-27.2.1/26B131__Mac14,2/141-12228-174.dmg` (APFS "Macintosh HD") listed with
  `7z l` (517,292 entries, list in the scratch dir) and selected files extracted with `7z x -i@list` into the agent
  scratch dir. Also listed: `141-12293-176.dmg` (System Cryptex) and `141-12233-179.dmg`.
- Fat binaries thinned to arm64e with a small Python slicer. Hashes (sha256): `WallpaperAerialsExtension.arm64e`
  `35952408...6cd6`, `WallpaperAgent.arm64e` `aaca1545...82da`.
- Ghidra 12.1.4 headless, own project in the scratch dir, scripts `StrXrefDecomp.java` and `AdrpScan.java` (Swift string
  literals are `adrp`+`add` to `string - 0x20`, OR'd with bit 63, so plain Ghidra xrefs miss them, `AdrpScan` finds them).
- REA CLI `rea decompile <thin> <addr> --provider ghidra --snapshot ... --json` (Ghidra 12.1.4) for the `ev_` IDs below.
- dyld cache `~/Downloads/macos/dyld-27.2.1/dyld_shared_cache_arm64e`: `ipsw dyld str`, `ipsw dyld macho --strings`,
  `ipsw dyld xref -i <image>`, `ipsw dyld disass`. `ipsw dyld extract` fails on these images ("failed to remap symbol
  _objc_msgSend$DebugSharedWallpaperRemovalDelay"), so the dyld images were read by disassembly only. REA cannot open
  dyld images, so those addresses have no `ev_` ID.
- `strings -a` for entitlements (the embedded entitlements plist) and plain plist/JSON reads.
- Local media probes (`ffprobe`, `exiftool`) only on files already in the repo (`themes/wallpapers/`).

## Process chain

```
System Settings > Wallpaper            Wallpaper.appex (com.apple.Wallpaper-Settings.extension, point com.apple.Settings.extension.ui)
        |  XPC com.apple.wallpaper
        v
WallpaperAgent (LaunchAgent com.apple.wallpaper.agent, /System/Library/CoreServices/WallpaperAgent.app)
        |  hosts ExtensionKit point com.apple.wallpaper (entitlement com.apple.extensionkit.host.extension-point-identifiers)
        +--> WallpaperImageExtension / WallpaperDynamicExtension
        |        WallpaperFoundation.MobileAssetManager("com.apple.MobileAsset.DesktopPicture", key "DesktopPictureID")
        |        -> MobileAsset.framework -> mobileassetd (LaunchDaemon com.apple.mobileassetd)
        |           catalog: mesu XML (or Pallas gdmf) -> zip from updates.cdn-apple.com
        |           -> /System/Library/AssetsV2/com_apple_MobileAsset_DesktopPicture/...
        |        -> copied to ~/Library/Application Support/com.apple.mobileAssetDesktop/
        +--> WallpaperAerialsExtension (network.client)  [WallpaperAgent links the same WallpaperAerialsCore code]
        |        GET resources-config-27-2.plist -> resources-url -> .tar -> libarchive "manifest-compress"
        |        -> /Library/Application Support/com.apple.idleassetsd/Customer/ (entries.json, videos)
        |        videos: entries.json "url-4K-SDR-240FPS" on sylvan.apple.com
        +--> NeptuneOneWallpaper.appex (Tahoe): manifest.json -> 4 sylvan .mov (DownloadHandler)
        +--> Sonoma / Sequoia / Ventura / Monterey / Macintosh / Gradient / Legacy extensions: all local, no URLs
wallpaperexportd (LaunchDaemon com.apple.wallpaper.export, root): /var/db/Wallpapers, marks idle assets purgeable
```

idleassetsd is gone: no path containing `idleassets` exists in any of the three IPSW volumes (full listings). Only
the name survives: the storage dir `/Library/Application Support/com.apple.idleassetsd/`, the WallpaperAgent
entitlement `com.apple.idleassetsd.screen-saver-service`, and `wallpaperexportd`'s `markIdleAssetsAsPurgeable`.

WallpaperAgent is sandboxed without `com.apple.security.network.client`. WallpaperAerialsExtension and
NeptuneOneWallpaper have it. So the network fetch for Aerials most likely runs in the extension, but which process
issues the request at runtime is not observed (belum dicek on a Mac).

## 1. Still and dynamic pictures: MobileAsset `com.apple.MobileAsset.DesktopPicture`

### Placeholders in the OS

`/System/Library/Desktop Pictures/*.madesktop` (63 files, about 500 bytes each) are XML plists that stand for a
picture that is not on disk yet:

```xml
<key>mobileAssetID</key>      <string>Big Sur</string>
<key>thumbnailPath</key>      <string>/System/Library/Desktop Pictures/.thumbnails/Big Sur.heic</string>
<key>isDynamic</key> <true/>  <key>isSolar</key> <true/>
<key>width</key> <real>6016.0</real>  <key>height</key> <real>6016.0</real>
```

Flags across the 63: 33 still (`isDynamic` false), 21 light/dark dynamic (`isDynamic` true, `isSolar` false),
9 solar (`isDynamic` and `isSolar` true, `Solar Gradients` also has `canSelectAppearance` false). The thumbnail
ships in `.thumbnails/`, the full picture is downloaded when picked.

### How the query is built

WallpaperFoundation (dyld image) `sub_1bf6e0a10` is the lazy global initializer for the picture asset manager:

```
0x1bf6e0a28  add x8, x8, #0x8d0   ; "com.apple.MobileAsset.DesktopPicture"   (36 chars, x19 = addr - 0x20)
0x1bf6e0a34  add x8, x8, #0x900   ; "DesktopPictureID"                      (16 chars)
0x1bf6e0a40  bl  WallpaperFoundation.MobileAssetManager metadata accessor
0x1bf6e0a70  bl  0x1bf70bfb4      ; MobileAssetManager.init(assetType:, idKey:) (name inferred), stored at 0x1ec834a10
```

So the asset query is: asset type `com.apple.MobileAsset.DesktopPicture`, attribute `DesktopPictureID` ==
the `.madesktop` `mobileAssetID`. Log strings in the same image: "Asset Metadata Query", "Asset Download",
"[%s] Starting asset download", "[%s] Asset already installed", "Could not copy asset (" + ") locally after download"
(`sub_1bf6e1498+0x3c`). The two extensions that can see the type carry the entitlement
`com.apple.private.assets.accessible-asset-types = [com.apple.MobileAsset.DesktopPicture]`
(WallpaperImageExtension, WallpaperDynamicExtension). Safari's dyld image also names the type (0x1b8c92240, probably for start page backgrounds, not followed).

### Catalog URL

`mobileassetd`'s logic lives in the dyld image MobileAssetDaemon. Relevant strings:

| String | Address |
|---|---|
| `https://mesu.apple.com/assets/macos/` (XML server base) | 0x242416c52 |
| `.xml` | 0x24240c733 |
| `com_apple_MobileAsset_ASSETNAME` (normalized type template) | 0x2423f1435 |
| `https://gdmf.apple.com/v2/assets` (Pallas, POST JSON with `AssetAudience`) | 0x24240e5f2 |
| `AllowXmlFallback`, `LegacyXmlUrl`, "Falling back to XML: %@ after failure before pallas response ..." | 0x24240ebc4, 0x24240f055 |
| `%@/%@/%@%@.asset` (on-disk asset dir) | 0x242410d6b |

Built URL (the composition of base + normalized type + "/" + normalized type + ".xml" is inferred from these pieces,
the function joining them was not decompiled):

```
https://mesu.apple.com/assets/macos/com_apple_MobileAsset_DesktopPicture/com_apple_MobileAsset_DesktopPicture.xml
```

Confirmed live 2026-11-14 09:18 UTC: `200`, `text/xml`, `Content-Length: 75194`,
`Last-Modified: Tue, 21 Jan 2025 19:16:45 GMT` (sha256 of the body `957829e0...ecc4`). Standard TLS, no auth.

Whether 27.2.1 asks Pallas first for this type is not settled: Pallas needs a POST with device fields, which was out of
scope. The XML is complete either way (every `.madesktop` ID is in it).

### Catalog format (real excerpt)

Signed plist: top keys `AssetType` (`DesktopPicture`), `Assets` (71 dicts), `Certificate`, `FormatVersion` (1),
`Signature`, `SigningKey` (`AssetManifestSigning`).

```xml
<dict>
  <key>Build</key>                  <string>10M8877</string>
  <key>DesktopPictureID</key>       <string>Studio Color</string>
  <key>_CompatibilityVersion</key>  <integer>1</integer>
  <key>_CompressionAlgorithm</key>  <string>zip</string>
  <key>_ContentVersion</key>        <integer>1</integer>
  <key>_DownloadSize</key>          <integer>10188474</integer>
  <key>_IsZipStreamable</key>       <true/>
  <key>_MasteredVersion</key>       <string>8877</string>
  <key>_Measurement</key>           <data>Bge6r3dinDDSKYGf8lxOIXkVz+s=</data>
  <key>_MeasurementAlgorithm</key>  <string>SHA-1</string>
  <key>_UnarchivedSize</key>        <integer>10207232</integer>
  <key>__BaseURL</key>              <string>https://updates.cdn-apple.com/2025/mobileassets/072-29818/74AF556A-DC02-429B-894B-23AB61E2A5F9/</string>
  <key>__CanUseLocalCacheServer</key> <true/>
  <key>__RelativePath</key>         <string>com_apple_MobileAsset_DesktopPicture/0830ece064a9b3ac731d75e63ba0bacccd9c199e.zip</string>
  <key>__RequiredByOS</key>         <false/>
</dict>
```

Versioning: one entry per `DesktopPictureID`, all `_CompatibilityVersion` 1 and `_ContentVersion` 1, all on one
release folder (`2025/mobileassets/072-29818/<uuid>/`). A new release would change `__BaseURL` and the versions. The
zip name is not the `_Measurement` (0 of 71 match), so it is an opaque content id.

One picture URL = `__BaseURL` + `__RelativePath`, for example Big Sur (solar dynamic, 138,805,013 bytes):
`https://updates.cdn-apple.com/2025/mobileassets/072-29818/74AF556A-DC02-429B-894B-23AB61E2A5F9/com_apple_MobileAsset_DesktopPicture/e9ff802c97332d002b37836419590a2b1ff3bcc9.zip`.
HEAD of the Studio Color zip: `200`, `binary/octet-stream`, `Content-Length: 10188474` (equals `_DownloadSize`).

The 71 IDs = the 63 `.madesktop` IDs + 8 that already ship as `.heic` (`Sonoma`, `iMac Blue/Green/Orange/Pink/Purple/
Silver/Yellow`). Sum of all `_DownloadSize`: 1,938,592,206 bytes. Largest: Big Sur 139 MB, Catalina 125 MB, Monterey
Graphic 98 MB, The Lake 81 MB, Solar Gradients 81 MB. Smallest: Light Stream Green 1.9 MB.

### Formats

- `.heic`, 6016 x 6016 for the Mac wallpapers (`iMac Blue.heic`, `Sonoma.heic`, `TahoeLight.heic` in the repo).
- Dynamic pictures are multi-image HEIC with XMP in the `apple_desktop` namespace. WallpaperFoundation names three
  kinds: `apple_desktop:solar` (0x1bf728440, `SolarDesktop.swift`), `apple_desktop:h24` (0x1bf728480,
  `HourDesktop.swift`), `apple_desktop:apr` (0x1bf728460, `AppearanceDesktop.swift`). Example: `Sonoma.heic` carries
  `apple_desktop:apr` = base64 bplist `{l: 0, d: 1}` (light = image 0, dark = image 1). It holds 2 images, each a
  6016 x 6016 HEIF tile grid of 36 HEVC tiles (1024 x 1024), per `ffprobe` stream groups.
- Inside the zip: not checked (no zip was downloaded).

### Where the files land

- `/System/Library/AssetsV2/com_apple_MobileAsset_DesktopPicture/<id>.asset/AssetData/` (MobileAsset V2 store:
  `/System/Library/AssetsV2` at MobileAsset 0x18fdf9ed7, `AssetData` at 0x18fdf9f16, `%@/%@/%@%@.asset`). Exact
  `<id>` and file names inside: not observed.
- Then copied to `~/Library/Application Support/com.apple.mobileAssetDesktop/`: WallpaperFoundation `sub_1bf6e3f48`
  calls `NSSearchPathForDirectoriesInDomains`, appends `"com.apple.mobileAssetDesktop"` (0x1bf7289a0, ref at
  0x1bf6e3ffc) and builds a file URL. WallpaperImage/DynamicExtension have the matching home-relative read-write
  sandbox exception for `/Library/Application Support/com.apple.mobileAssetDesktop/`.
- Also scanned: `/System/Library/Desktop Pictures` (0x1bf728a00) and `/Library/Desktop Pictures` (0x1bf7289c0).

## 2. Aerials

### Config, manifest and URLs

| Item | Value | Evidence |
|---|---|---|
| Config URL (hard-coded, one string per OS release) | `https://configuration.apple.com/configurations/internetservices/aerials/resources-config-27-2.plist` | Aerials ext 0x100084870, Agent 0x1001dd7d0. `URL(string:)` with that 99-char literal in the manifest manager init `FUN_10001f5b8` (ev_5316dbf7) |
| Override defaults (domain probably `com.apple.wallpaper.aerial`, the shared-preference exception, not decoded) | `AerialManifestURLOverride`, `AerialManifestLocalPathOverride`, `AerialManifestForceLocal` | 0x100084570, os_log "Loading fallback manifest (AerialManifestLocalPathOverride: %{public}s)" 0x100083560 |
| Cached state keys | `remoteResourceURL`, `remoteResourceExpirationDate`, `LastAerialDownloadDate` | 0x1000845b0, 0x1000845d0 |
| Config plist body | `<dict><key>resources-url</key><string>https://sylvan.apple.com/itunes-assets/Aerials126/v4/82/2e/34/822e344c-f5d2-878c-3d56-508d5b09ed61/resources-27-0-1.tar</string></dict>` | live GET of `resources-config-27-0.plist` |
| Manifest archive | `resources-<os>-<rev>.tar`: `entries.json` + `TVIdleScreenStrings.bundle/Contents/Resources/Localizable.nocache.loctable` | live, see below. Decompressed with libarchive (`manifest-compress`, "Unable to decompress archive" 0x1000847d0) |
| Bundled fallback | `WallpaperAerialsExtension.appex/Contents/Resources/entries.json` (194,264 bytes, sha256 `eec0c1d0...657c`) + `TVIdleScreenStrings.bundle` | strings `bundledManifest`, "Force Local manifest set, skipping remote resource url lookup" |
| Refresh | background activity `com.apple.wallpaper.aerials.background-activity`, `scheduledUpdateDate` | Agent strings |

Live checks (2026-11-14 09:14 UTC, edge `sgsin4`):

| URL | Result |
|---|---|
| `.../resources-config-27-2.plist` | 404 (HEAD and GET) |
| `.../resources-config-27-1.plist`, `-26-4.plist` | 404 |
| `.../resources-config-27-0.plist` | 200, 352 bytes, -> `resources-27-0-1.tar` |
| `.../resources-config-26-0.plist` | 200, -> `resources-26-4-1.tar` |
| `.../resources-config-15-0.plist` | 200, -> `resources-15-0-2.tar` |
| `resources-27-0-1.tar` | 200, `application/octet-stream`, 2,095,104 bytes, `Last-Modified: Wed, 02 Sep 2026` (fetched, under 5 MB) |
| `resources-26-4-1.tar` | 200, 2,071,552 bytes (HEAD) |

TLS: `sylvan.apple.com` is signed by "Apple Server Authentication CA", which is not in the Linux trust store. curl
works with `--cacert` set to Apple Root CA (from `https://www.apple.com/appleca/AppleIncRootCertificate.cer`, sha256
fingerprint `B0:B1:73:0E:CB:C7:FF:45:05:14:2C:49:F1:29:5E:6E:DA:6B:CA:ED:7E:2C:68:C5:BE:91:B5:A1:10:01:F0:24`).
`configuration.apple.com`, `mesu.apple.com` and `updates.cdn-apple.com` verify with the system store.

Remote 27-0-1 vs bundled 27.2.1 `entries.json`: same 164 ids and categories. Differences: `version` 1 vs 2, and asset
`4207734D-...` (Golden Gate Sunset) has a newer preview and video in the bundled copy
(`GG_A_Sunset_MarshallsBeach_c28_v8_24comp_HFR.mov` vs `..._v7_24comp_HFR_16Mbps.mov`).

### entries.json format

Top level: `version` (2), `localizationVersion` (`22L-1`), `initialAssetCount` (4), `categories` (6), `assets` (164).
The decoder's CodingKeys (switch in `FUN_100069504`, ev_ba57545d): `id`, `shotID`, `localizedNameKey`,
`accessibilityLabel`, `previewImage`, `preferredOrder`, `includeInShuffle`, `showInTopLevel`, `categories`,
`subcategories`, `pointsOfInterest`, `variant`, `group`, `videoGravity`, and case 0xe = `url-4K-SDR-240FPS`
(literal at 0x100084d90). It is the only video key: no HDR, 1080p or H.264 key exists in this build.

```json
{
  "accessibilityLabel": "Cazadero",
  "categories": ["A33A55D9-EDEA-4596-A850-6C10B54FBBB5"],
  "group": "21J-1",
  "id": "FE876489-CBD5-479B-A8F0-1B67F0741CEA",
  "includeInShuffle": true,
  "localizedNameKey": "W010_C003_F01_NAME",
  "pointsOfInterest": {"0": "W010_C003_0"},
  "preferredOrder": 3,
  "previewImage": "https://sylvan.apple.com/itunes-assets/Aerials126/v4/51/ff/08/51ff0824-8da5-78f0-e218-9e61264965bb/Landscape_Sonoma_01@2x_W010_C003_V52.png",
  "shotID": "W010_C003_F01",
  "showInTopLevel": true,
  "subcategories": ["3CC63110-FF0E-4443-9A2D-63CD0795954E"],
  "url-4K-SDR-240FPS": "https://sylvan.apple.com/itunes-assets/Aerials116/v4/cb/5b/50/cb5b5035-6701-619f-9065-3d7d0e5fbef4/W010_C003_V52_FRC_sdr_4k_qp25_240p_t2160_grover401_tsa.mov"
}
```

Categories (each has `id`, `localizedNameKey`, `localizedDescriptionKey`, `preferredOrder`, `previewImage`,
`representativeAssetID`, `subcategories[]` with the same fields): Dynamic 4 (`dynamic-aerials`, the four
`GG_LM_H/GG_LM_V/GG_DM_H/GG_DM_V` light/dark x landscape/portrait variants with `variant` and `videoGravity: resize`),
Landscapes 83, Cities 30, Underwater 21, Space 22, Mac 4 (`MAC_WP_BLU/PNK/PPL/YLW`, the animated Mac Blue/Pink/Purple/
Yellow). 65 subcategories in total.

Video URL pattern: no template, every asset carries its full URL. Hosts seen: 146 videos under
`https://sylvan.apple.com/itunes-assets/Aerials116/v4/cb/5b/50/cb5b5035-6701-619f-9065-3d7d0e5fbef4/`, 18 under
`.../Aerials126/v4/...`. Previews: 233 `.png` under `.../Aerials126/v4/51/ff/08/51ff0824-.../`, one `.jpg` under
`https://sylvan.apple.com/Aerials/jjGqDwCNrOsVJ4of6uSVr/snapshots/`, one `.png` under
`https://screensavers.scv.apple.com/JkStvVNMIqeZ/cheerD/thumbnails/`. 156 of the 164 previews also ship as
`<asset id>.png` in the extension's Resources.

Sizes (HEAD): Cazadero `W010_C003...tsa.mov` 615,615,478 bytes, dynamic `GG_LM_H_v063_240fps-TSA.mov` 179,368,714
bytes, preview png 47,657 bytes. Codec, from the copy that ships in the OS (`/System/Library/Wallpapers/.default/
Golden Gate.mov`, same as `themes/wallpapers/heic/Golden Gate.mov`): HEVC Main 10 (`hvc1`), 3840 x 2160,
240/1 fps, BT.709 primaries and transfer (SDR), 60 s, 12.8 Mbit/s. File names suggest per-shot variation
(`qp25`, `rate10000`, `16Mbps`, one portrait file is named `_40fps`), not verified per file.

### Localisation

`TVIdleScreenStrings.bundle/Contents/Resources/Localizable.nocache.loctable`: binary plist, 45 locales, 712 keys in
`en`. Keys are the `localizedNameKey`, `pointsOfInterest` values and category keys, for example
`W010_C003_F01_NAME` = "Sonoma Horizon", `W010_C003_0` = "Heading north through Sonoma, California",
`AerialCategoryLandscapes` = "Landscape", `DYNAMIC_LIGHT_KEY` = "Light" (`id`: "Terang"). The extension's own
`Localizable.loctable` holds UI strings such as `SHUFFLE_OPTION_12H`, `ROTATES_THROUGH_%d_AERIALS`.

### Where the files land

- `/Library/Application Support/com.apple.idleassetsd/Customer/`: literal (60 chars) passed to
  `URL(fileURLWithPath:)` in `FUN_1000595f0` (ev_af9357c7), also at Agent 0x1001dd950. Both the extension and the
  agent have an absolute read-write sandbox exception for `/Library/Application Support/com.apple.idleassetsd/`.
- Sub-paths under `Customer/` (Sonoma used `4KSDR240FPS/<id>.mov` and `entries.json` there) were not decoded in this
  build: the join happens in an async continuation after `FUN_1000595f0`. Belum dicek.
- Settings and choices: `~/Library/Application Support/com.apple.wallpaper/` (home-relative read-write exception on
  agent and extension) and defaults `com.apple.wallpaper`, `com.apple.wallpaper.aerial`.
- Purge: CacheDelete ids `com.apple.wallpaper.aerials.delete` (Aerials ext 0x100084840, passed in the manifest manager
  init), `com.apple.wallpaper.idleassets.delete` (wallpaperexportd).
- Ships in the OS: `/System/Library/Wallpapers/.default/Golden Gate.mov` (96 MB, the default Aerial, literal at
  Aerials ext 0x1000851d0. Probably asset 4207734D "Golden Gate Sunset", whose id is also a literal in the agent, not
  proven),
  `DefaultAerial.heic`/`.jpg` (3840 x 2160 still), and `/System/Library/CoreServices/DefaultDesktop.heic`, a symlink
  to `/System/Library/Wallpapers/.default/DefaultAerial.heic`.

## 3. Tahoe (NeptuneOneWallpaper.appex)

`com.apple.NeptuneOneExtension`, `LSMinimumSystemVersion` 27.2. Ships `TahoeLight.heic` (24.6 MB), `TahoeDark.heic`
(23.9 MB), `thumbnail.heic` and `manifest.json`:

```json
{ "version": 1, "identifier": "Tahoe",
  "lightLandscapeRemoteURL": "https://sylvan.apple.com/itunes-assets/Aerials116/v4/cb/5b/50/cb5b5035-6701-619f-9065-3d7d0e5fbef4/tahoe-light-landscape.mov",
  "darkLandscapeRemoteURL":  ".../tahoe-dark-landscape.mov",
  "lightPortraitRemoteURL":  ".../tahoe-light-portrait.mov",
  "darkPortraitRemoteURL":   ".../tahoe-dark-portrait.mov" }
```

HEAD (with Apple Root CA): light-landscape 45,172,491, dark-landscape 44,769,128, light-portrait 30,231,309,
dark-portrait 37,775,925 bytes, all `Last-Modified: Fri, 18 Jul 2025`. The binary has `SystemWallpaperManifest`,
`fallbackManifestLocalURL`, `downloadPart(remoteURL:localURL:parentProgress:)` and local names
`" Light Landscape.mov"` etc., but no remote manifest URL: the 4 URLs come only from the bundled `manifest.json`.
Where the downloaded videos are stored: not found in strings (sandboxed, so probably its container). Belum dicek.

## 4. Other desktop assets (short)

- Screen savers: ExtensionKit appexes (`Album Artwork`, `Arabesque`, `Drift`, `Flurry`, `Hello`, `Monterey`, `Shell`,
  `Ventura`, `Word of the Day`) plus `Random.saver` and `FloatingMessage.saver`. No URL strings in the five checked
  (Hello, Monterey, Drift, Album Artwork, Word of the Day). They all ship. The only downloaded screen saver content is
  Aerials. `Default Collections/4 - Colors` holds tiny 48 to 59 byte PNGs.
- Sonoma (`.wallpapers/Sonoma/*.mov`, 4 x 56 to 82 MB, the Light Landscape copy probes as HEVC Main 10 4K 240 fps
  90 s), Sonoma Horizon, Sequoia (USD meshes,
  EXR lighting, Metal), Ventura, Monterey, Macintosh (Mac OS 1984 emulation resources), Gradient, Legacy: all local.
- Solid colours: `/System/Library/Desktop Pictures/Solid Colors/*.png`, local.
- Fonts use the same MobileAsset system but different types (`com.apple.MobileAsset.Font`, descriptor
  `/System/Library/AssetTypeDescriptors/com.apple.MobileAsset.AssetTypeDescriptor.Font*.plist`), not part of the
  wallpaper flow. Not followed further.
- `/var/db/Wallpapers` (wallpaperexportd): export for the login window. Contents not checked.

## Ships vs downloads

| Ships in 27.2.1 | Downloaded on demand |
|---|---|
| Tahoe Light/Dark `.heic` (default) | Tahoe motion `.mov` x 4 (manifest.json) |
| `Sonoma.heic`, `Sonoma Horizon.heic`, `Sonoma Graphic *.mov` x 4 | 63 `.madesktop` pictures: Big Sur x 11, Catalina x 8, The Beach/Cliffs/Desert/Lake, Solar Gradients, Grid, Chroma, Motion, hello x 7, Hello Metallic x 7, Radial Blue/Green/Purple/Yellow, Light Stream x 4, Peak, Tree, Valley, Dome, Iridescence, Pro Black, Studio Color, Monterey Graphic, Ventura Graphic |
| `Mac Blue/Pink/Purple/Yellow.heic`, `iMac * .heic` x 7, `Radial Sky Blue.heic` | |
| Solid Colors PNGs, all `.thumbnails/*.heic` | |
| Default Aerial `Golden Gate.mov` + `DefaultAerial.heic/.jpg` | the other 163 Aerial videos (Landscapes, Cities, Underwater, Space, Dynamic, Mac) |
| 156 Aerial preview PNGs, bundled `entries.json` + strings | remote manifest tar (when the config URL exists) |
| Procedural: Sequoia, Ventura, Monterey, Macintosh, Gradient | |

## What this means for hyprk (no implementation)

Today `themes/wallpapers/` holds files pulled from the IPSW and tracked in git (42 files: `heic/` 20 incl.
`Golden Gate.mov` and `NeptuneOne-Tahoe-manifest.json`, `png/` 18 conversions, `dynamic-sonoma/` 4 `.mov`, about
1.4 GB). `packaging/install.sh` (`SHIP_WALLPAPERS`), the PKGBUILD, the spec and the flake copy only
`TahoeLight.png`, `TahoeDark.png`, `DefaultAerial.png`, downscaled to 3840 px. `shell/scripts/wallpaper.sh` and
`settings/panes/Wallpaper.qml` scan `themes/wallpapers` (+ `png/`).

With the URLs above:
- The 63 pictures hyprk does not have (the `.madesktop` set) are reachable from one public, unauthenticated XML. A
  Wallpaper pane could list them from the catalog (or from the 63 `.madesktop` + `.thumbnails` files) and fetch one
  zip on click, like macOS. Total 1.94 GB if all are fetched.
- Aerials: 164 videos, 180 to 615 MB each, HEVC Main 10 4K at 240 fps. Fetching needs the Apple Root CA for TLS, and
  playback at 240 fps 10-bit is heavy, a transcode or frame drop would be needed. The manifest to use on 27.2.1 is the
  bundled `entries.json` (the 27.2 config is 404). Names come from the loctable.
- Tahoe motion: 4 small videos (30 to 45 MB), the cheapest motion wallpaper to add.
- The content is Apple's. Same caveat as the existing note in `packaging/install.sh` (for the user's own machine only,
  never redistributed). Fetching at runtime from Apple keeps the files out of the repo and the packages.

## Evidence

| # | Claim | Source |
|---|---|---|
| 1 | `.madesktop` = placeholder with `mobileAssetID` | `/System/Library/Desktop Pictures/*.madesktop` (63), keys `mobileAssetID`, `thumbnailPath`, `isDynamic`, `isSolar`, `canSelectAppearance`, `width`, `height` |
| 2 | Asset type and id key | WallpaperFoundation `sub_1bf6e0a10`, refs 0x1bf6e0a28 -> 0x1bf7288d0, 0x1bf6e0a34 -> 0x1bf728900 (ipsw xref + disass) |
| 3 | Type entitlement | WallpaperImageExtension and WallpaperDynamicExtension entitlements `com.apple.private.assets.accessible-asset-types` |
| 4 | mesu / Pallas servers | MobileAssetDaemon 0x242416c52, 0x24240e5f2, 0x24240c733, 0x2423f1435, 0x24240ebc4 |
| 5 | DesktopPicture XML live | GET 2026-11-14 09:18 UTC, 200, 75,194 B, sha256 `957829e0abf3e39cb0c0034c63a2b455cea3a684cb6ac9df513f79bc4296ecc4` |
| 6 | Zip URL = `__BaseURL` + `__RelativePath` | XML excerpt, HEAD Studio Color zip 200 10,188,474 B |
| 7 | Copy to `~/Library/Application Support/com.apple.mobileAssetDesktop/` | WallpaperFoundation `sub_1bf6e3f48` (+0xb4 ref 0x1bf7289a0, `NSSearchPathForDirectoriesInDomains`, `URL(fileURLWithPath:)`), `sub_1bf6e1498` "Could not copy asset (", extension sandbox exception |
| 8 | Dynamic HEIC metadata kinds | WallpaperFoundation 0x1bf728440 / 0x1bf728480 / 0x1bf728460, `Sonoma.heic` XMP `apple_desktop:apr` |
| 9 | Aerial config URL in code | WallpaperAerialsExtension `FUN_10001f5b8` `URL(string:)` len 0x63 ptr 0x100084850+0x20, ev_5316dbf7cff2f6d635e6d66eac2e92356a959627fa41002b26984503ee9badf2 |
| 10 | Aerial asset schema, `url-4K-SDR-240FPS` | `FUN_100069504` case 0xe -> 0x100084d90, ev_ba57545d064f26980709055de230602243b18e508d2e600b6a19e55050e53d3a |
| 11 | Aerial storage dir | `FUN_1000595f0` `URL(fileURLWithPath:)` len 0x3c ptr 0x1000849d0+0x20, ev_af9357c7de1a1ad92b6587d7e8d9f4ce311ceca00e4bc808263682cedc319f3d |
| 12 | Same code in the agent | WallpaperAgent arm64e strings 0x1001dd7d0 (config URL), 0x1001dd950 (Customer/), 0x1001ddcf0 (`url-4K-SDR-240FPS`) |
| 13 | Config 27-2 404, 27-0 200 | live GET 2026-11-14 09:14 UTC, body of 27-0 sha256 `bcba72d9b6d57cb19ebac5f1d712cc6893f15dc6759b3a766e3f3e609e001233` |
| 14 | tar contents | `resources-27-0-1.tar` sha256 `d88f4a20c8d2a072484ded4370aefc9298f9b4a756a0dd0ff3c0918bcff7f8f3`, `tar -t` |
| 15 | Network entitlement split | Aerials ext and NeptuneOne have `com.apple.security.network.client`, WallpaperAgent does not |
| 16 | No idleassetsd | full `7z l` listings of 141-12228-174, 141-12293-176, 141-12233-179: no `idleassets` path |
| 17 | Tahoe remote videos | `NeptuneOneWallpaper.appex/Contents/Resources/manifest.json` (sha256 `6c0d746a...5794`), HEADs |
| 18 | Aerial codec | `ffprobe` of the shipped `Golden Gate.mov` (repo copy) |
| 19 | Default desktop symlink | `/System/Library/CoreServices/DefaultDesktop.heic` -> `/System/Library/Wallpapers/.default/DefaultAerial.heic` |

## Open questions

1. Does `mobileassetd` ask Pallas (`gdmf.apple.com/v2/assets`) for `DesktopPicture` first, with which `AssetAudience`?
   Needs a POST or a Mac `log stream --predicate 'subsystem == "com.apple.mobileasset"'` capture.
2. Exact layout under `/Library/Application Support/com.apple.idleassetsd/Customer/` and under
   `/System/Library/AssetsV2/com_apple_MobileAsset_DesktopPicture/` on 27.2.1. A Mac `ls -R` of both after picking
   one Aerial and one `.madesktop` picture would settle it (Mac session = capture only).
3. Which process makes the Aerial request at runtime (agent vs extension).
4. What is inside a DesktopPicture zip (file name, one `.heic` or more).
5. Where NeptuneOne stores the downloaded Tahoe videos.
6. Will Apple publish `resources-config-27-2.plist` later? Recheck before relying on the bundled manifest.
