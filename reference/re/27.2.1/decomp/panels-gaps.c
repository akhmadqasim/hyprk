// GAPS-REA-panels (2026-11-14). macOS 27.2.1 (26B131). Static RE only, not original source.
// Tools: Ghidra 12.2 headless (own project ~/Downloads/macos/re-work/gh-panels-gaps), DumpRange / DumpAt / StrXref
// scripts, llvm-objdump, ipsw dyld disass (symbolised with the cache .a2s), tools/fields.py (Swift reflection).
// Binaries:
//   NC  = NotificationCenter.app arm64e slice (copy of re-work/r2/NotificationCenter, sha256 25a5e778...4ce)
//   CCF = /System/Library/PrivateFrameworks/ControlCenter.framework, extracted from the dyld cache with Ghidra's
//         dyldcachev1 file system (scripts/ExtractDsc.java), cache addresses unchanged
//   CUK = CalendarUIKit.framework, CWF = CalendarWidget.framework, same extraction
// Type names come from __swift5_fieldmd / __swift5_types (types-NC.json, fields.py). Mangled type refs were
// resolved through their GOT slots with `ipsw macho info --fixups`.

// =====================================================================================================
// Q1. NC section heading row: ExpandedHistoryHeaderView { _controller, __confirmsClearAll: LazyState<Bool> }
//     (type descriptor 0x10030a454, metadata accessor 0x10003aef8)
// =====================================================================================================
// body FUN_10003b0c8 (NC):
HStack(alignment: .center, spacing: nil) { FUN_10003b288(...) }
    .padding(.top, 10)          // fmov d0, #10 @0x10003b1c4
    .padding(.bottom, 8)        // fmov d0, #8 @0x10003b1fc
    .padding(.horizontal, 16);  // fmov d0, #16 @0x10003b224

// content FUN_10003b288 (NC). Tuple type (mangled @0x1002ce7f0) =
//   (ModifiedContent<ModifiedContent<ModifiedContent<ModifiedContent<Text, PrimaryShadowTextModifier>,
//      _PaddingLayout>, _FrameLayout>, AccessibilityAttachmentModifier>, Spacer, NotificationsConfirmCloseButton)
Text("Notification Center" /*0x13 chars @0x1002f7830*/)
    .font(DAT_1003c13d0)        // swift_once FUN_100190e98 (fmov d0, #18 @0x100190ea0) -> FUN_100190eb8 = Font.system(size: 18, weight: .semibold)
    .modifier(PrimaryShadowTextModifier())   // descriptor 0x10030f6cc
    .padding(.leading, 1)       // fmov d0, #1 @0x10003b544
    .frame(height: 20)          // mov x2, #0x4034.. (20) @0x10003b5b8
    .accessibilityAddTraits(.isHeader);
Spacer();
NotificationsConfirmCloseButton(confirms: $confirmsClearAll,          // LazyState projectedValue
                                label: Text("Clear All" /*"Clear Al"+"l" inline*/),
                                closeAction: FUN_10003bd84);          // -> FUN_10003b884 -> FUN_1001d451c(4)

// NotificationsConfirmCloseButton { _confirms, label, closeAction } (descriptor 0x10030d194)
// convenience init FUN_10014831c: the non-confirm label is FUN_100148454:
Image(systemName: "xmark")                          // 0x6b72616d78 small string @0x100148470
    .font(DAT_1003c13b0)                            // FUN_100190e48 (fmov d0, #10 @0x100190e50) -> FUN_100190eb8 = .system(size: 10, weight: .semibold)
    .frame(width: 20);                              // mov x0, #0x4034.. (20) @0x1001484e4
// label = ZStack(alignment: .center) { confirms ? Text(label) : xmarkImage }   FUN_100147b20 / FUN_100147bcc
// body FUN_100147278:
Button(action: FUN_100148060, label: FUN_100148078)
    .buttonStyle(NotificationButtonStyle(height: 20,        // mov x8, #0x4034.. @0x100147710
                                         width: nil,        // x8[1] = 0, x8[2] (Optional tag) = 1
                                         cornerRadius: 10,  // mov x8, #0x4024.. @0x100147718
                                         padding: flag ? 10 : 0,   // x8[4] (fmov d1, #10 @0x100147728); flag = byte self+0x38 (FUN_10014831c stores !binding there)
                                         glass: _Glass.regular))
    .onHover(FUN_100148084)                 // easeInOut, FUN_100147d34
    .accessibilityRepresentation(FUN_100148110);
// confirm toggle FUN_100147a2c flips the binding; withAnimation(.spring(response: 0.5, dampingFraction: DAT_1002cda98 /*0.85*/))
// FUN_1001479a0.

// NotificationButtonStyle { height, width, cornerRadius, padding, glass } makeBody FUN_10006ba4c (NC).
// Modifier chain (mangled type names @0x1002dc1e0 .. 0x1002d0198):
configuration.label
    .font(DAT_1003c13c8)                    // FUN_100190e78: Font.subheadline
    .foregroundStyle(DAT_1003c13c0)         // FUN_100190e58: HierarchicalShapeStyle.secondary
    .lineLimit(1)                           // keypath 0x1002d01e8, value 1
    .padding(.horizontal, padding)          // EdgeInsets(_all: self[4])
    .frame(width: width, height: height)    // _FrameLayout(self[1], self[2] tag, self[0])
    .clipShape(Rectangle())                 // _ClipEffect<Rectangle>
    .contentShape(RoundedRectangle(cornerRadius: r, style: .continuous)
                      .inset(by: -4))       // RoundedRectangle._Inset amount: mov x8, #0xc010.. (-4.0) @0x10006bf14
    .background(RoundedRectangle(cornerRadius: r, style: .continuous)
                  .fill(isPressed ? .quaternary : Color.clear))   // _OverlayShapeModifier<AnyShapeStyle, RoundedRectangle>
    ._glassEffect(glass, in: RoundedRectangle(cornerRadius: r, style: .continuous))
    ._glassEffectZIndex(1)
    .glassEffectTransition(.identity);

// =====================================================================================================
// Q3. Spotlight status item: SpotlightPreferences (CCF, class _TtC13ControlCenter20SpotlightPreferences)
// =====================================================================================================
// init 0x20a52ede8 (ipsw dyld disass, symbolised):
//   0x20a52ee00  add x8, x8, #0          ; "com.apple.Spotlight" (0x13 chars, large Swift literal)
//   0x20a52ee0c  ldr x8, [x8, #0x650]    ; _ptr._kCFPreferencesCurrentUser
//   0x20a52ee18  ldr x8, [x8, #0x648]    ; _ptr._kCFPreferencesCurrentHost
//   0x20a52ee40  bl  String._bridgeToObjectiveC()
//   0x20a52ee48  x3 = __StaticArrayStorage (empty defaults array, inferred)
//   -> Preferences(domain: "com.apple.Spotlight", user: CurrentUser, host: CurrentHost)   // ByHost domain
//
// Bool read helper 0x20a588c80:
//   v = self.vtable[0xd0](key)            // value(forKey:) -> AnyObject?
//   if v == nil return 2                  // Optional<Bool>.none
//   return Bool._conditionallyBridgeFromObjectiveC(v as NSNumber)
//
// 0x20a52ef64  menuItemHidden(): return helper("MenuItemHidden") & 1      // 0x654d.. "MenuItem", 0x6948.. "Hidden"
//                                                                        // nil (2) & 1 = false
// 0x20a52efa0  statusItemEnabled.get:  return 1 & ~menuItemHidden()     // export 0x20a52f25c -> b 0x20a52efa0
// 0x20a52efc4  statusItemEnabled.set:  setBool(!newValue, "MenuItemHidden") (0x20a588d04)
//              log "Setting SpotlightPreferences.statusItemEnabled to %{bool,public}d"
// 0x20a52f0cc  "MenuItemOrder" read (0x20a588f5c), returns 0 when absent.
//
// ControlCenter.app reader (re-work/r2/CC.ann), FUN around 0x100064d7c:
//   0x100064f44 SiriPreferences.shared.statusItemEnabled      -> entry ("Siri", enabled), enum case 2
//   0x100064fb4 SpotlightPreferences.shared.statusItemEnabled -> entry ("Spotlight", enabled), enum case 2
//   0x100065030 TimeMachinePreferences.shared.statusItemEnabled -> entry ("TimeMachine"...), enum case 2
// SystemItemMenuBarPreferences.showSpotlight (CCF export 0x20a53b884) is a stored Bool read under
// swift_beginAccess (field offset @0x2712d6308), not a defaults key; its initial value was not traced.

// =====================================================================================================
// Q2. NC Calendar widget month grid
// =====================================================================================================
// CUIKMonthView.Styling (CUK, Swift fields from fields.py; struct 0xb0 bytes, offsets read from use sites):
//   +0x00 fullColor Bool, +0x08 gridFontSize, +0x10 gridRowHeight, +0x18 todayCircleSize, +0x20 dateLabelFont,
//   +0x28 dateLabelPadding, +0x30 allowKashida, +0x31 showHeader, +0x32 showOutOfMonthDays, +0x38 dividerPadding,
//   +0x40 dividerHeight, +0x48 altCalendarUnderlineWidth, altCalendarID, altCalendarFont, hideAltCalendarLabel,
//   monthNameFormat, dimmingMode, (colors)
// Styling.init export 0x1d148ece4 (CUK). Both widget call sites, CWF (ipsw dyld disass shows the j__ stub name):
//   CalendarMonthWidget.WidgetView body FUN_247078628 ("CalendarWidget/CalendarMonthWidget.swift"), call 0x247078cfc:
//   MediumListContentView                FUN_2470eeedc ("CalendarWidget/MediumListContentView.swift"), call 0x2470efb80:
//     fmov d0,#10  gridFontSize            fmov d1,#14  gridRowHeight         fmov d2,#18  todayCircleSize
//     fmov d3,#5   dateLabelPadding        fmov d4,#4   dividerPadding        fmov d5,#10  dividerHeight
//     fmov d6,#14  altCalendarUnderlineWidth
//     w2 allowKashida (1 month widget / 0 medium list), w3 showHeader = 1, w4 showOutOfMonthDays = 0
//     monthNameFormat = "MMMM" (0x4d4d4d4d, len 4) unless an alt calendar is set ("MMM"); medium: "MMMM"
// Month widget content then gets .padding(viewMetrics.widgetMargins + viewMetrics.horizontalMonthViewMarginDelta)
//   (FUN_247071d38 reads the ViewMetrics environment value; fields +0x10 and +0x28 added, getter 0x2470ec004
//   `horizontalMonthViewMargins` = ldr d0,[x20,#0x10]; ldr d1,[x20,#0x28]; fadd). Values: not found.
//
// Row pitch, FUN_1d148f418 (CUK), called from FUN_1d1491594 with the GeometryReader height when gridRowHeight >= 1:
double rowExtra(double H /*available height*/, Styling *s) {
    Range weeks = calendar.range(of: weekOfMonth, in: month)   // func_0x1d810b370 on two components
    double n = (weeks.upper - weeks.lower) + 1.0;              // weeks shown
    double header = s->showHeader /*+0x31*/ ? measuredHeaderHeight /*State read, local_88*/ : 0;
    double extra = H - (n * s->gridRowHeight /*+0x10*/ + header);
    if (extra < 0) extra = 0;
    return extra / n;                                          // added per row: pitch = gridRowHeight + extra
}
// Day cell (CUIKWeekRow cell builder FUN_1d148c63c): _FlexFrameLayout(..., maxWidth: +inf (0x7ff0..), ...)
//   @call func_0x1d81152c0(…,0,1,0,1,0x7ff0000000000000,0,0,1): each of the 7 cells takes maxWidth .infinity
//   (argument order read as the SwiftUI frame(minWidth:idealWidth:maxWidth:minHeight:...) layout, inferred).
// FUN_1d1490c0c: usable width = (W - 1) - 2*dividerPadding(+0x38) - 2*dateLabelPadding(+0x28), split between two
//   parts in proportion w1 / (w1 + w2) (seen, purpose not traced).
