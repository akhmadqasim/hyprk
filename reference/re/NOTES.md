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
  Likely reading (not confirmed): the second branch is the Siri orb, since it has no face, no blur and a ring
  shadow scaled by size / 105, which fits a round orb and not a wide field; spotlightField would then take the
  first branch. The modifier structs carry no field metadata, so confirming it needs the SiriRecipe builder traced.
  - Live check (2026-11-10, `probe ... variants2`): NSGlassEffectView `_variant` 24..40, alone and with
    `_subvariant` spotlightField / searchResults / listening, all resolve to plain Regular. So AppKit cannot reach
    the internal base `siri` (InternalConfiguration.Base index 23; `menu` 21 and `siriSnippet` 22 are reached
    through `_subvariant` strings instead), and Spotlight's values cannot be measured this way.
    Spotlight.app holds no glass code itself: it links SpotlightUIInternal, SpotlightUIShared and SearchUI
    (private frameworks); the caller that picks base `siri` + `.spotlightField` and its contentEffect is there.
    "spotlightField" as a string exists only in DesignLibrary.
  Open: which branch is spotlightField; ComposeModifier (0x195f2ebf4) and SiriHighlightsModifier (0x195f2ebfc) not read yet.
  - Update, condition identified (2026-11-10). The "idiom flag" and "variant byte" reading above is wrong:
    - Confirmed: the modifier structs are empty (SiriRecipe desc 0x195fc1924, SiriModifier desc 0x195fc1a20, 0 fields).
      The second argument of a Siri spec/params body is `GlassMaterialProvider.ParametersContext`: FUN_195ed0900
      is its metadata accessor (type descriptor 0x195fbe41c, 11 fields, field offsets at metadata + 0x10 + 4*i).
    - Confirmed: metadata + 0x20 is field 4 = `subvariant` (Subvariant, one field `kind`), metadata + 0x2c is
      field 7 = `contentEffect` (ResolvedContentEffect: none 0, clip 1, lense 2).
    - Confirmed: FUN_195e5f470 is `Subvariant.Kind ==`. Encoding is 3 bytes: tag byte 0 = `unsupported(id)`,
      tag byte 1 = an empty case with its index in the low 16 bits (53 empty cases in fields.txt order:
      default 0 ... listening 10, thinking 11, response 12, spotlightField 13, searchResults 14, compose 15).
      So 0x1000a = `.listening`, 0x1000f = `.compose` (ComposeCondition 0x195f2eb9c), 0x10000 = `.default`.
    - So branch B = `subvariant == .listening || contentEffect == .lense`. Inside branch B the ring shadow
      (0.4, size / 105) is set only for `.listening`; for `.lense` alone the ring shadow is 0. Size comes from
      `environment.dimensions` (Environment accessor FUN_195f3c68c, field 10), default 0.457 when nil.
      Branch B also writes Spec 0x608.. (0.25, -0.45, ...) after a check on field 9 `siriWaveOptions`
      (inferred, not traced in detail).
    - spotlightField and searchResults are not `.listening` and the code never compares against 13 or 14, so
      they take branch A (face 0.1 / 1.0 / 1.25, blur 8, ring shadow 0) unless the caller's contentEffect
      resolves to `.lense`. Confirmed for the subvariant part; the contentEffect that Spotlight passes, and what
      `.automatic` resolves to, were not traced (ParametersContext.contentEffect is a plain copy of
      ResolvedConfiguration.contentEffect, FUN_195ee1f88 around 0x195ee2044).
    - The first Double of the context is ParametersContext.environment.pixelLength (Environment's first field),
      inferred from field order. darkSpecular height = pixelLength * 1.6 below 0.5, else pixelLength.
    - SiriHighlightsModifier (body 0x195f2f530, params): does nothing unless subvariant == `.listening`
      (confirmed); then writes highlights (Parameters 0x1e8) and 0x670, sized by dimensions / 719 * 4.
    - ComposeModifier (body 0x195f312d4, spec, applied only for `.compose`): backdropScale 0.5, refraction
      inner 0.269 / -0.538, outer 0.065 / 0.269, blur and blurFill off, face opacity 0, edgeBleed 0, ring shadow 0,
      shadow opacity 0.18 radius 20 offset y 4, darkSpecular height pixelLength * 5, spread 1.309, amount 0.4,
      colorBias -0.3 / -0.25 (field names from annot.py, the shadow sub-fields not double-checked).
    - Caution: the probe table (live/glass-table-*.txt) shows `regular.spotlightField`, `.searchResults`,
      `.listening`, `.compose` identical to plain `regular` through NSGlassEffectView `_subvariant`, while
      `.menu` and `.siriSnippet` do change. So on the regular base these subvariants do not reach SiriRecipe;
      SiriRecipe is probably picked only for base `.siri` (not confirmed: no direct reference to the
      SiriRecipe metadata accessor 0x195f2eb54 was found).
- RegularBase.Base (0x195f1e860) builds the whole Spec in a stack temporary, so annot.py shows no field names for it.
