# Liquid Glass RE on the Mac (macOS 27.2.1, build 26B131)

All of this lives in the repo so it can be used from the Ubuntu PC and the MacBook.

## Files
- `27.2.1/DesignLibrary`, `QuartzCore`, `CoreMaterial`: extracted from the dyld shared cache (`tools/dsc.c`, macOS only).
- `27.2.1/fields.txt`: every Swift struct/enum field name and type (`tools/fields.py <binary> <regex>`).
- `27.2.1/witness-tables.txt`: Swift conformances with witness-table entries (`tools/wt.py`).
- `27.2.1/recipe-bodies.txt`: `address kind name` for 152 GlassRecipes modifiers (kind = spec or params).
  Function names are stripped, so these come from the `Schema` witness tables.
- `27.2.1/decomp/DesignLibrary-recipes.c`: Ghidra 12.1.4 pseudocode, 1897 functions, 0x195ee8000-0x195f3d000
  (`tools/DumpRange.java` with analyzeHeadless).
- `27.2.1/recipes-annotated.c`: the named modifiers with `param_1` offsets replaced by field names.
- `tools/layout.py`: field-offset maps for `GlassMaterialProvider.Spec` and `.Parameters`.
  `tools/annot.py <dump> spec|params <addr>` annotates one function (follows thunks).

## Layout facts (verified against decompiled writes)
- Pointers in the extracted dylib are packed: target = 0x180000000 + (value & 0x3ffffffff).
- YCC = black, white, saturation (Float) + normalFill, dodgeFill, burnFill (Optional of 4 Floats, tag byte after). 0x48 stride.
- ParameterScale<CGFloat,Float> is 0x2a bytes, <CGFloat,CGFloat> 0x3a; a constant sits in the first word, rest zero.
- Spec anchors: shadow.opacity 0x28, shadow.shadowRadius 0x58, shadow.offset 0x98, blur 0x130, refraction 0x1a0,
  edgeBleed 0x208, faceEffect 0x2a0, highlights 0x2f8, blurFill 0x48c, ringShadow 0x4a0, darkSpecular 0x4c8.
- Parameters anchors: shadow 0x18, blur 0xac, refraction 0xd8, faceEffects 0x110, edgeBleed 0x168, tinting 0x1d4,
  highlights 0x1e8, blurFill 0x2f8, ringShadow 0x310, darkSpecular 0x340 (nil flag 0x378).
- Not mapped yet: Spec after darkSpecular (intelligence, lensing, controlDisplacement, adaptivity, sdrAdjustment;
  SiriModifier writes 0x608-0x648 there) and Parameters after darkSpecular.

## Findings
- GlassWindowActiveShadow (0x195f126bc, spec): opacity 0.6 / 0.7 (0.7 / 0.8 under a second flag), shadowRadius 24, offset y 10.
  Same as SPEC 9.5 from 27.2.
- InactiveDarkSpecular (0x195f2599c, params): colorBias x 0.75, amount 0.5, spread = spreadSDR = 2.0944 rad (120 deg).
- Spotlight is a Siri variant. `GlassMaterialProvider.Variant` has listening, thinking, response, spotlightField,
  searchResults, compose; SiriRecipe serves them. SiriRecipe.SiriModifier (0x195f30b54, spec) sets:
  - backdropScale constant 0.5
  - refraction inner height 0.4 D, inner amount -0.72 D, outer height 0.4 D, outer amount 0.4 D, outer opacity 1.0
  - blur radius 8 (constant), opacities (0.75, 0, 0.75, 1.0), distances fixed (-60, -1, 0, 0), no outer-refraction blur
  - face YCC black 0.1, white 1.0, saturation 1.25, no fills, maxLuminance 1 / 1
  - edgeBleed opacity 0, shadow opacity 0
  - darkSpecular: height = input (x 1.6 when input < 0.5), spread 1.309 rad (75 deg), amount 0.4, effectOffset 0,
    colorBias -0.3 (-0.25 when input >= 0.5)
  - blurFill darken 0.75, normal 0.5
  - then, under one condition (idiom flag 0x1000a set, or a variant byte == 2; not identified yet): backdropScale 0.99,
    blur opacity 0, blurFill lighten/normal 0, face opacity 0 with identity YCC; ringShadow opacity 0.4 with
    verticalOffset 32 s, strokeWidth 12 s, blurRadius 12 s, s = size / 105 (default 0.457). Otherwise ringShadow opacity 0.
  Open: which branch is spotlightField; ComposeModifier (0x195f2ebf4) and SiriHighlightsModifier (0x195f2ebfc) not read yet.
- RegularBase.Base (0x195f1e860) builds the whole Spec in a stack temporary, so annot.py shows no field names for it.
