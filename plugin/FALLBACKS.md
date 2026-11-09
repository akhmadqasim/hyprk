# liquidglass fallbacks

User rule: if the glass cannot run, log once and fall back to plain Hyprland blur. Never crash the compositor.

| Case | Detection | What happens |
|---|---|---|
| Shader does not compile or link (driver, GLES < 3.0, broken `shader_path` file) | `CShader::createProgram(..., dynamic=true, silent=true)` returns false. The GL info log goes to `hyprland.log` (`CShader::logShaderError`). | One `ERR [liquidglass] glass disabled, using plain Hyprland blur: ...` line plus one desktop notification. Every glassed surface is then drawn with Hyprland's own blur (`renderRect` with `blur = true`) in the same rounded shape, tinted with `tint_light` (`tint_dark` when `appearance = "dark"`). Changing `shader_path` gives one new attempt. |
| Custom shader lacks required uniforms (`tex`, `uvTopLeft`, `uvBottomRight`, `quadSize`, `glassBox`) | `glGetUniformLocation` < 0 | Same as above. |
| Renderer is not OpenGL (future Vulkan renderer) | `g_pHyprRenderer->type() != RT_GL` | Same as above (the fallback uses the renderer-neutral blur call). |
| Blur framebuffer missing for a frame | `blurMainFramebuffer()` returns null | That frame uses the plain-blur fallback. |
| `renderLayer` symbol not found or already hooked by another plugin (e.g. hyprglass) | `findFunctionsByName` / `CFunctionHook::hook()` | Plugin stays loaded but does nothing. One log line + notification. Hyprland's normal layer blur (layer rules / ext-background-effect) keeps working. |
| Plugin built for another Hyprland | API hash mismatch in `PLUGIN_INIT` | Load is refused with a notification (Hyprland unloads it cleanly). |
| `enabled = 0` | config | Plugin does not touch layers: Hyprland's blur rules apply as without the plugin. |
| Client sets no blur region | `m_blurRegion` empty | The whole layer box is the glass shape (radius from `radii` / `default_radius`). |
| Monitor with rotation/transform | not handled | Glass is drawn in untransformed monitor space. Not tested. |
| GPU cost (`full_damage = 1` redraws the whole output when glass is on screen) | config | Set `full_damage = 0` to keep Hyprland's partial damage. Edges may then show seams while something moves behind the glass. |

Not handled (documented gaps): Apple's hysteresis for light/dark switching (we use a smooth luminance band, no
memory), HDR "holding tone", the foreground content lensing pass, the tinted (non-black) drop shadow.
