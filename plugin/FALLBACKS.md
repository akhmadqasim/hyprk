# liquidglass fallbacks

User rule: if the glass cannot run, log once and fall back to plain Hyprland blur. Never crash the compositor.

| Case | Detection | What happens |
|---|---|---|
| Shader does not compile or link (driver, GLES < 3.0, broken `shader_path` file) | `CShader::createProgram(..., dynamic=true, silent=true)` returns false. The GL info log goes to `hyprland.log` (`CShader::logShaderError`). | One `ERR [liquidglass] glass disabled, using plain Hyprland blur: ...` line plus one desktop notification. Every glassed surface is then drawn with Hyprland's own blur (`renderRect` with `blur = true`) in the same rounded shape, tinted with the recipe fill (or a white lift from its black point). Changing `shader_path` gives one new attempt. |
| Custom shader lacks required uniforms (`tex`, `uvTopLeft`, `uvBottomRight`, `quadSize`, `glassBox`) | `glGetUniformLocation` < 0 | Same as above. |
| Renderer is not OpenGL (future Vulkan renderer) | `g_pHyprRenderer->type() != RT_GL` | Same as above (the fallback uses the renderer-neutral blur call). |
| Blur framebuffer missing for a frame | `blurMainFramebuffer()` returns null | That frame uses the plain-blur fallback. |
| `renderLayer` symbol not found or already hooked by another plugin (e.g. hyprglass) | `findFunctionsByName` / `CFunctionHook::hook()` | Plugin stays loaded but does nothing. One log line + notification. Hyprland's normal layer blur (layer rules / ext-background-effect) keeps working. |
| Plugin built for another Hyprland | API hash mismatch in `PLUGIN_INIT` | Load is refused with a notification (Hyprland unloads it cleanly). |
| `enabled = 0` | config | Plugin does not touch layers: Hyprland's blur rules apply as without the plugin. |
| Client sets no blur region | `m_blurRegion` empty | `require_region = 1` (default): the layer is left to Hyprland's normal blur rules. `0`: the whole layer box is the glass shape. |
| Monitor with rotation/transform | not handled | Glass is drawn in untransformed monitor space. Not tested. |
| Luminance readback not possible (FBO incomplete on a mip level, no PBO support) | `glCheckFramebufferStatus` | The glass stays on its light recipe (or the forced `appearance`). Nothing is logged per frame. |
| Partial damage | — | The plugin damages the whole glass when part of it is damaged (`claimDamage`). `full_damage = 1` remains as a debug switch. |

| Framebuffer copy for variable blur fails (current FB not a GL framebuffer, alloc fails) | `copySharp()` returns null | Hyprland's blurred texture stands in for the sharp one: the rim stays blurred, everything else works. |

Not handled (documented gaps): HDR "holding tone", the foreground content lensing pass, Apple's
luminance-weighted edge-bleed factor (`bleed_darken`, not recovered: we weight by depth only), and the
dark specular layer (not decoded). The shader runs in gamma space, Apple's in linear: decoded colour values
are applied as-is, which is why some recipes are tuned (README).
