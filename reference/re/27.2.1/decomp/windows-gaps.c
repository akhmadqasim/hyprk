/*
 * windows-gaps.c: pseudocode reconstructed from disassembly of the macOS 27.2.1 (26B131) dyld shared cache.
 * Source: ~/Downloads/macos/dyld-27.2.1/dyld_shared_cache_arm64e, `ipsw dyld disass --vaddr A --demangle`
 * (raw listings in ~/Downloads/macos/re-work/gaps-windows/*.asm). Addresses are DSC addresses.
 * The extracted ~/Downloads/macos/re-work/ex/DesignLibrary.macho sits 0x1000 lower (DSC 0x195de9758 = file 0x195de8758).
 * Hand-written from the instructions; not compiler output. See GAPS-REA-windows.md for the marks.
 */

/* ---------------------------------------------------------------- 1. card fill */

/* DesignLibrary SeximalShapeStyle : ShapeStyle, resolve(in:) witness 0x195f89be4 (from the conformance
 * descriptor 0x195fb5704, 6 resilient witnesses, last one). */
Color SeximalShapeStyle_resolve(EnvironmentValues env) {
    Color c = Color.primary;                 /* bl j__$s7SwiftUI5ColorV7primaryACvgZ          0x195f89bfc */
    c = c._settingOpacity(0x3f9eb851eb851eb8 /* = 0.03 */);                          /* 0x195f89c04..18 */
    return c._adaptive;                      /* bl j__$s7SwiftUI5ColorVAAE9_adaptiveACvg      0x195f89c2c */
}

/* DesignLibrary MacGroupBox<Content> : View, body 0x195de9758 (witness 0x195de9c88 -> b 0x195de9758; REA/Ghidra
 * evidence ev_daed777e6e7d98ed7ccc3ffa825235c3b47c69bde0dc73967d6629e3ea02942e on the extracted file at 0x195de8758).
 * Background view type, decoded from the mangled name at 0x195fc7be4 (symbolic refs resolved through
 * __auth_ptr 0x1e3f20058 / 0x1e3f20060 / 0x1e3f20600 and SwiftUI descriptors):
 *   Optional<PositionStrokeShapeView<ContainerRelativeShape, ControlBorderShapeStyle,
 *                                    _ShapeView<ContainerRelativeShape, SeximalShapeStyle>>>          */
some View MacGroupBox_body(MacGroupBox self) {
    return self.content
        .padding(self.contentInsets)                                     /* 0x195de99a0 */
        .background(alignment: .center) {                                /* 0x195de9a3c */
            /* closure 0x195de9bf8: nil when flag byte +0x28 is set, else a stroke of width 1 */
            PositionStrokeShapeView(ContainerRelativeShape(),
                                    stroke: ControlBorderShapeStyle(),
                                    StrokeStyle(lineWidth: 1.0, miterLimit: 10),   /* 0x195de9c38 / 0x195de9c3c */
                                    fill: ContainerRelativeShape().fill(SeximalShapeStyle()))
        }
        .clipShape(ContainerRelativeShape())                             /* 0x195de9acc */
        .containerShape(RoundedRectangle(cornerRadius: env.groupBoxCornerRadius, style: .continuous)); /* 0x195de9afc */
}

/* SwiftUI MacIdiomGroupBoxStyle.makeContent 0x19a96cab4: inside a grouped Form the DesignLibrary GroupBox gets
 * contentInsets = EdgeInsets(0) (env Bool true, 0x19a96cd4c..5c), else nil. So the card itself adds no padding. */

/* SwiftUI GroupedFormBackgroundModifier.DefaultBackgroundStyle._apply(to:) 0x19adc1b70: the form (window content)
 * background. */
void DefaultBackgroundStyle_apply(ShapeStyle_Shape *shape) {
    if (env[ScrollContentBackgroundKey] == .hidden) { Color.clear._apply(shape); return; }   /* 0x19adc1e04 */
    switch (env[GroupedFormBackground.Key]) {                                                  /* 0x19adc1f5c */
    case 0: Material.contentFill; break;        /* 0x19adc1fa4  -> NSVisualEffectView .contentBackground  */
    case 1: Material.windowFill;  break;        /* 0x19adc1f80  -> .windowBackground                       */
    case 2: Color(.sRGBLinear, white: 0.9765625 /* 0x3fef400000000000 */, opacity: 1); break; /* 0x19adc2014 */
    }
}

/* SwiftUI EmphasizedGroupBackgroundColorProvider.resolve 0x19add6414 (used for the pressed full-row button,
 * GroupedFormFullRowButtonStyle 0x19add11dc; not the card). */
Color.Resolved EmphasizedGroupBackground_resolve(env) {
    if (env.colorScheme == .light)
        return Color.Resolved(white: 0, opacity: env.contrast == .standard ? 0.03 /*0x3cf5c28f*/ : 0.05 /*0x3d4ccccd*/);
    else /* dark */
        return Color.Resolved(white: 1, opacity: env.contrast == .standard ? 0.05 : 0.10 /*0x3dcccccd*/);
}

/* ---------------------------------------------------------------- 2. rows */

/* SwiftUI GroupedFormMetrics.init(sizeVariant:) 0x19add26d4 (field names from __swift5_fieldmd 0x19bc2be34). */
GroupedFormMetrics GroupedFormMetrics_init(uint8_t sizeVariant) {
    GroupedFormMetrics m;
    m.defaultFormInsets            = EdgeInsets(all: 20);                       /* 0x19add26f8 */
    m.seamlessFormInsetsWithHeader = { .top = 4, .leading = 20, .bottom = 20, .trailing = 20 };   /* 0x19add2744 */
    m.seamlessFormInsetsNoHeader   = { .top = 0, .leading = 20, .bottom = 20, .trailing = q4.lo };
    m.rootSectionHeaderPadding     = q4.hi;                                     /* q4 = (20, 20) */
    m.headerToContentSpacing       = 10;                                        /* 0x19add2738 */
    if (sizeVariant == 2) {           /* the small variant */
        /* insets 10, headerToContentSpacing 6, q4 from 0x19baa5af0 */
    }
    return m;
}

/* SwiftUI FormCell<Content>.body 0x19adca230 (type from its symbol at 0x19adca8f0):
 *   VStack(alignment: .center, spacing: 0) {
 *       HStack { label; Spacer(); accessories; FormInfoButton? }
 *           .padding(rowInsets)                       // FormRowInsetsTraitKey, default (0,0,0,0)+tag 2 -> 10 all
 *           .frame(...)
 *           .background(AnyShapeStyle, in: Rectangle())  // row background (pressed / hover)
 *           .modifier(FormCellTapRevealReporter)
 *       Optional(Divider().padding(dividerInsets))    // Optional: the row may have no divider
 *   }
 */
EdgeInsets FormCell_rowInsets(traits) {                 /* 0x19adca698..0x19adca708 */
    FormRowInsets ri = traits[FormRowInsetsTraitKey];    /* default 0x19add0664: zeros, tag byte 2 */
    EdgeInsets e = (ri.tag == 2) ? EdgeInsets(10, 10, 10, 10) : ri.insets;
    e.leading += 31.0 * traits[FormRowIndentationKey];   /* fmov d1, #31 at 0x19adca6e8 */
    return e;
}

/* ViewTraitCollection.preferredSeparatorInsets 0x19adc96d8: 0 when the row has a FormRowBackground, else
 * horizontal (leading 10 + 31 * indentation, trailing 10), same default-10 rule as above. */

/* FormCell.dividerInsets 0x19adcbd80: this row's separator insets, and when a next row exists the smaller of
 * this row's and the next row's leading / trailing (fcmp + fcsel mi at 0x19adcbe08..14). So the divider is drawn
 * at the bottom of a row, between it and the next one. */

/* GroupedFormFullRowButtonStyle.makeBody 0x19add1170: rowInsets EdgeInsets(all: 10) (0x19add11b0); the label is
 * outset by -10 (0x19add10b8) so the pressed fill covers the whole row. */

/* ---------------------------------------------------------------- 4. toolbar text effect (CoreUI) */

/* Aqua.car / DarkAqua.car, element 216 part 179, "Toolbar State Transform Text" (CSI 'XFTC' effect preset,
 * parsed with gaps-windows/scripts/fx2.py; param 0 = RGB bytes, 2 = opacity, 7 = blend):
 *   active (no presentation key):        Fade(1.0)  SOpc(1.0)
 *   inactive (presentation state 1):     Fade(0.5)  Colr(color (0,0,0), opacity 1.0, blend 'sat ')  SOpc(1.0)
 *   (identical in Aqua and DarkAqua)
 * i.e. inactive toolbar text = fully desaturated, then drawn at 50 % opacity. */
