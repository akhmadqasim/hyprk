#include "GlassElement.hpp"
#include "Log.hpp"
#include "Readback.hpp"
#include "Shaders.hpp"
#include "Stats.hpp"

#include <hyprland/src/render/OpenGL.hpp>
#include <hyprland/src/render/Renderer.hpp>
#include <hyprland/src/render/Texture.hpp>
#include <hyprland/src/render/gl/GLFramebuffer.hpp>

#include <GLES3/gl32.h>

#include <chrono>
#include <cmath>
#include <cstring>
#include <array>
#include <map>
#include <fstream>
#include <sstream>

using namespace Render::GL;

namespace lg {

    // ── program ─────────────────────────────────────────────────────────────

    CGlassProgram& glassProgram() {
        static CGlassProgram program;
        return program;
    }

    void CGlassProgram::fail(const std::string& why) {
        m_state = eState::FAILED;
        m_shader.reset();
        logOnce(std::format("glass disabled, using plain Hyprland blur: {}", why));
    }

    bool CGlassProgram::ensure(const std::string& overridePath) {
        // a new shader_path gets one fresh attempt
        if (m_state != eState::UNTRIED && overridePath != m_loadedPath) {
            destroy();
            resetLogOnce();
        }
        if (m_state != eState::UNTRIED)
            return m_state == eState::READY;

        m_loadedPath = overridePath;

        if (!g_pHyprRenderer || g_pHyprRenderer->type() != Render::IHyprRenderer::RT_GL || !g_pHyprOpenGL || !g_pHyprOpenGL->m_shaders) {
            fail("renderer is not OpenGL ES");
            return false;
        }

        std::string frag = LIQUIDGLASS_FRAG;
        if (!overridePath.empty()) {
            std::ifstream f(overridePath);
            if (!f) {
                fail(std::format("cannot read shader_path {}", overridePath));
                return false;
            }
            std::stringstream ss;
            ss << f.rdbuf();
            frag = ss.str();
        }

        m_shader = makeShared<CShader>();
        // dynamic + silent: a compile error returns false instead of aborting, and we log it ourselves
        if (!m_shader->createProgram(g_pHyprOpenGL->m_shaders->TEXVERTSRC, frag, true, true) || !m_shader->program()) {
            fail("shader failed to compile or link (see hyprland.log for the GL info log)");
            return false;
        }

        const GLuint prog = m_shader->program();
        auto         loc  = [prog](const char* name) { return glGetUniformLocation(prog, name); };
        u = SUniforms{
            .tex              = loc("tex"),
            .linearLight      = loc("linearLight"),
            .uvTopLeft        = loc("uvTopLeft"),
            .uvBottomRight    = loc("uvBottomRight"),
            .quadSize         = loc("quadSize"),
            .shapeCount       = loc("shapeCount"),
            .shapeBox         = loc("shapeBox"),
            .shapeInfo        = loc("shapeInfo"),
            .smoothK          = loc("smoothK"),
            .appearBlur       = loc("appearBlur"),
            .roundingPower    = loc("roundingPower"),
            .alpha            = loc("alpha"),
            .blurRadius       = loc("blurRadius"),
            .blurK            = loc("blurK"),
            .baseLevel        = loc("baseLevel"),
            .maxLevel         = loc("maxLevel"),
            .underlay         = loc("underlay"),
            .refraction       = loc("refraction"),
            .refractionHeight = loc("refractionHeight"),
            .aberration       = loc("aberration"),
            .faceYcc          = loc("faceYcc"),
            .blurAlpha        = loc("blurAlpha"),
            .blurDist         = loc("blurDist"),
            .outerAmount      = loc("outerAmount"),
            .outerHeight      = loc("outerHeight"),
            .outerOpacity     = loc("outerOpacity"),
            .outerThreshold   = loc("outerThreshold"),
            .blurFill         = loc("blurFill"),
            .bleedOpacity     = loc("bleedOpacity"),
            .bleedHeight      = loc("bleedHeight"),
            .bleedAmount      = loc("bleedAmount"),
            .bleedLod         = loc("bleedLod"),
            .bleedYcc         = loc("bleedYcc"),
            .faceFill         = loc("faceFill"),
            .fillAmount       = loc("fillAmount"),
            .pxPerPt          = loc("pxPerPt"),
            .keyYcc           = loc("keyYcc"),
            .keySpread        = loc("keySpread"),
            .highlight        = loc("highlight"),
            .darkSpec         = loc("darkSpec"),
            .shadowOpacity    = loc("shadowOpacity"),
            .shadowRadius     = loc("shadowRadius"),
            .shadowOffset     = loc("shadowOffset"),
            .shadowTint       = loc("shadowTint"),
            .shadowSaturation = loc("shadowSaturation"),
            .ringOpacity      = loc("ringOpacity"),
            .ringOffset       = loc("ringOffset"),
            .ringStroke       = loc("ringStroke"),
            .ringRadius       = loc("ringRadius"),
        };
        // the sampler and the quad mapping are the minimum a custom shader must keep
        if (u.tex < 0 || u.uvTopLeft < 0 || u.uvBottomRight < 0 || u.quadSize < 0 || u.shapeCount < 0 || u.shapeBox < 0) {
            fail("shader lacks the required uniforms tex/uvTopLeft/uvBottomRight/quadSize/shapeCount/shapeBox");
            return false;
        }

        m_state = eState::READY;
        logInfo("glass shader ready");
        return true;
    }

    void CGlassProgram::destroy() {
        m_shader.reset();
        m_state = eState::UNTRIED;
    }

    // ── backdrop luminance (light/dark with hysteresis) ─────────────────────
    //
    // One pixel of a high mip level of the blurred backdrop is read back per glass shape
    // through a PBO; the result is used one frame later, so the GPU never stalls.

    namespace {
        struct SLuma {
            bool           valid = false, dark = false;
            CAsyncReadback read;
            uint64_t       seen = 0, requested = 0;
            double         w = 0, h = 0; // shape size the state belongs to
        };
        constexpr uint64_t LUMA_INTERVAL = 6; // monitor frames between readbacks per shape
        std::map<std::pair<uintptr_t, size_t>, SLuma> g_luma;
        GLuint                                         g_readFbo = 0;
        uint64_t                                       g_frame   = 0;

        // Box-sized backdrop copies per element (owner, monitor) and role, so the mip chain covers the glass
        // and its footprint instead of the whole output (README Performance)
        enum eRole { SHARP, PANEL };
        struct SBoxFB {
            SP<Render::IFramebuffer> fb;
            uint64_t                 frame = 0;
        };
        std::map<std::tuple<uintptr_t, MONITORID, int>, SBoxFB> g_boxes;

        // collect a finished readback, if any
        void collectLuma(SLuma& l, const SParams& p) {
            const auto px = l.read.poll();
            if (!px)
                return;
            const float L = luma((*px)[0], (*px)[1], (*px)[2]) / std::max((*px)[3], 1e-4f);
            l.dark        = l.valid ? hysteresisDark(l.dark, L, p.adaptLow, p.adaptHigh) : L < (p.adaptLow + p.adaptHigh) / 2;
            l.valid       = true;
        }

        // queue a 1-pixel read of `tex` at mip `level`, texel (x, y)
        void requestLuma(SLuma& l, GLuint tex, int level, int x, int y) {
            // previous read still in flight, or one taken recently: luminance changes slowly
            if (l.read.unsupported() || l.read.pending() || (l.requested && g_frame - l.requested < LUMA_INTERVAL))
                return;
            if (!g_readFbo)
                glGenFramebuffers(1, &g_readFbo);

            CFramebufferBindingGuard guard{g_pHyprRenderer->glBackend()}; // restores the read binding
            g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, g_readFbo);
            glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, level);
            if (glCheckFramebufferStatus(GL_READ_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE)
                l.read.request(x, y, 1, 1); // unsupported formats: stays on the light recipe
            glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
            l.requested = g_frame;
        }
    }

    static bool touches(CRegion& damage, const CBox& box) {
        // cheap reject on the extents before the exact region test
        return !box.intersection(damage.getExtents()).empty() && !CRegion{damage}.intersect(box).empty();
    }

    namespace {
        // glass boxes claimed this frame; bool = damaged (added to the frame damage) while building
        std::vector<std::pair<CBox, bool>> g_claims;
    }

    void onFrame() {
        g_claims.clear();
        if (++g_frame % 60)
            return;
        // forget surfaces not drawn for ~10 s at 60 Hz
        std::erase_if(g_luma, [](const auto& kv) { return g_frame - kv.second.seen >= 600; });
        std::erase_if(g_boxes, [](const auto& kv) { return g_frame - kv.second.frame >= 600; });
    }

    void forgetOwner(uintptr_t owner) {
        std::erase_if(g_luma, [owner](const auto& kv) { return kv.first.first == owner; });
        std::erase_if(g_boxes, [owner](const auto& kv) { return std::get<0>(kv.first) == owner; });
    }

    // ── unblurred backdrop copy (variable blur, edge bleed) ──────────────────

    namespace {
        constexpr int MAX_LEVELS   = 7; // deepest pyramid level (128 px texels): wide edge-bleed blurs of big panels
        constexpr int SHADOW_LEVEL = 6; // the drop shadow's tint reads a wide blur of the backdrop

        // Apple's variable-blur downsampler (QuartzCore variable_blur_downsample_frag, MAC-ANSWERS C3 2): level i + 1 is
        // level i through 13 bilinear taps, halved. One attribute-less triangle per level into the copy's own texture.
        constexpr const char* DOWN_VERT = R"(#version 300 es
void main() {
    vec2 p = vec2(float((gl_VertexID << 1) & 2), float(gl_VertexID & 2));
    gl_Position = vec4(p * 2.0 - 1.0, 0.0, 1.0);
})";
        constexpr const char* DOWN_FRAG = R"(#version 300 es
precision highp float;
uniform sampler2D src;   // level i only (base = max = i)
uniform vec2 texel;      // 1 / size of level i
out vec4 fragColor;
void main() {
    vec2 uv = gl_FragCoord.xy * 2.0 * texel; // centre of the destination texel in level i
    vec2 a = 1.960085 * texel, b = 3.920676 * texel;
    vec4 c = 0.105497 * texture(src, uv);
    c += 0.090186 * (texture(src, uv + vec2(a.x, 0.0)) + texture(src, uv - vec2(a.x, 0.0)) + texture(src, uv + vec2(0.0, a.y)) + texture(src, uv - vec2(0.0, a.y)));
    c += 0.077098 * (texture(src, uv + a) + texture(src, uv - a) + texture(src, uv + vec2(a.x, -a.y)) + texture(src, uv + vec2(-a.x, a.y)));
    c += 0.056341 * (texture(src, uv + vec2(b.x, 0.0)) + texture(src, uv - vec2(b.x, 0.0)) + texture(src, uv + vec2(0.0, b.y)) + texture(src, uv - vec2(0.0, b.y)));
    fragColor = c;
})";

        struct SDownsampler {
            GLuint prog = 0, vao = 0, fbo = 0;
            GLint  texel = -1;
            bool   failed = false;

            static GLuint compile(GLenum type, const char* src) {
                const GLuint sh = glCreateShader(type);
                glShaderSource(sh, 1, &src, nullptr);
                glCompileShader(sh);
                GLint ok = 0;
                glGetShaderiv(sh, GL_COMPILE_STATUS, &ok);
                if (!ok) {
                    glDeleteShader(sh);
                    return 0;
                }
                return sh;
            }

            bool ensure() {
                if (prog || failed)
                    return prog != 0;
                const GLuint vs = compile(GL_VERTEX_SHADER, DOWN_VERT), fs = compile(GL_FRAGMENT_SHADER, DOWN_FRAG);
                GLint        ok = 0;
                if (vs && fs) {
                    prog = glCreateProgram();
                    glAttachShader(prog, vs);
                    glAttachShader(prog, fs);
                    glLinkProgram(prog);
                    glGetProgramiv(prog, GL_LINK_STATUS, &ok);
                }
                if (vs)
                    glDeleteShader(vs);
                if (fs)
                    glDeleteShader(fs);
                if (!ok) {
                    if (prog)
                        glDeleteProgram(prog);
                    prog   = 0;
                    failed = true;
                    logOnce("blur pyramid shader failed, box mips instead");
                    return false;
                }
                texel = glGetUniformLocation(prog, "texel");
                GLint prev = 0;
                glGetIntegerv(GL_CURRENT_PROGRAM, &prev);
                glUseProgram(prog);
                glUniform1i(glGetUniformLocation(prog, "src"), 1); // the copy sits on unit 1 while it is built
                glUseProgram(prev);
                glGenVertexArrays(1, &vao);
                glGenFramebuffers(1, &fbo);
                return true;
            }

            void release() {
                if (prog)
                    glDeleteProgram(prog);
                if (vao)
                    glDeleteVertexArrays(1, &vao);
                if (fbo) {
                    g_pHyprOpenGL->onFramebufferDeleted(fbo);
                    glDeleteFramebuffers(1, &fbo);
                }
                *this = {};
            }
        };
        SDownsampler g_down;

        // Levels 2..levels of the texture bound on unit 1 (size w x h at level 0) from level 1 by Apple's downsampler;
        // level 1 stays the 2x2 box glGenerateMipmap made (Apple's backdrop at scale 0.5)
        void buildPyramid(GLuint tex, int w, int h, int levels) {
            if (levels < 2 || !g_down.ensure())
                return;
            CFramebufferBindingGuard guard{g_pHyprRenderer->glBackend()};
            GLint prevProg = 0, prevVao = 0;
            glGetIntegerv(GL_CURRENT_PROGRAM, &prevProg);
            glGetIntegerv(GL_VERTEX_ARRAY_BINDING, &prevVao);
            const bool blend = g_pHyprOpenGL->blendEnabled();
            g_pHyprOpenGL->blend(false);
            g_pHyprOpenGL->bindFramebuffer(GL_DRAW_FRAMEBUFFER, g_down.fbo);
            glUseProgram(g_down.prog);
            glBindVertexArray(g_down.vao);
            for (int l = 2; l <= levels; ++l) {
                const int sw = std::max(1, w >> (l - 1)), shh = std::max(1, h >> (l - 1));
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, l - 1);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, l - 1);
                glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, tex, l);
                g_pHyprOpenGL->setViewport(0, 0, std::max(1, w >> l), std::max(1, h >> l));
                glUniform2f(g_down.texel, 1.f / sw, 1.f / shh);
                glDrawArrays(GL_TRIANGLES, 0, 3);
            }
            glFramebufferTexture2D(GL_DRAW_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, 0, 0);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, levels);
            glBindVertexArray(prevVao);
            glUseProgram(prevProg);
            g_pHyprOpenGL->blend(blend);
        }

        // the area to refresh so that reads in `read` up to mip `level` see no texel of an older frame
        CRegion footprintOf(const CRegion& read, int level, const Vector2D& size) {
            CRegion out;
            for (const auto& r : read.getRects()) {
                const auto f = mipFootprint({double(r.x1), double(r.y1), double(r.x2 - r.x1), double(r.y2 - r.y1)}, level, size.x, size.y);
                out.add(CBox{f.x, f.y, f.w, f.h});
            }
            return out;
        }

        // A texture holding part of a monitor-sized buffer: `box` is where it sits on the monitor (physical px)
        struct STexView {
            SP<Render::ITexture> tex;
            CBox                 box;
        };


        // Copies the rects of `copy` (whole level-`levels` texels, see footprintOf) from `src` into a texture the
        // size of their extents, at the same offsets, and rebuilds its mips 0..levels. The extents start on the
        // level grid, so every texel equals the one a mip chain of the whole output would hold.
        // Texels between the rects are never read. Null `tex` when the copy is not possible.
        STexView copyBox(uintptr_t owner, MONITORID mon, eRole role, const SP<CGLFramebuffer>& src, const CRegion& copy, int levels) {
            const CBox box = CRegion{copy}.getExtents();
            if (!src || box.w < 1 || box.h < 1)
                return {};
            auto& slot = g_boxes[{owner, mon, role}];
            slot.frame = g_frame;
            if (!slot.fb)
                slot.fb = g_pHyprRenderer->createFB("liquidglass-backdrop");
            auto& fb = slot.fb;
            // same format as the source: a blit between float and unorm buffers is invalid
            if ((fb->m_size != box.size() || fb->m_drmFormat != src->m_drmFormat || !fb->isAllocated()) && !fb->alloc(box.w, box.h, src->m_drmFormat))
                return {};
            const auto dst = dynamicPointerCast<CGLFramebuffer>(fb);
            const auto tex = fb->getTexture();
            if (!dst || !tex)
                return {};
            {
                CFramebufferBindingGuard guard{g_pHyprRenderer->glBackend()};
                // a blit is clipped by the scissor test: whatever rect the last draw left would be all
                // that gets copied, and the rest of the copy keeps an older backdrop
                g_pHyprOpenGL->disableScissor();
                g_pHyprOpenGL->bindFramebuffer(GL_READ_FRAMEBUFFER, src->getFBID());
                g_pHyprOpenGL->bindFramebuffer(GL_DRAW_FRAMEBUFFER, dst->getFBID());
                const int ox = box.x, oy = box.y;
                // texel rows follow the top-down box space of the uvs
                CRegion{copy}.forEachRect([ox, oy](const auto& r) {
                    glBlitFramebuffer(r.x1, r.y1, r.x2, r.y2, r.x1 - ox, r.y1 - oy, r.x2 - ox, r.y2 - oy, GL_COLOR_BUFFER_BIT, GL_NEAREST);
                });
                if (glGetError() != GL_NO_ERROR) {
                    fb.reset(); // reallocate next time
                    return {};
                }
            }
            g_pHyprOpenGL->setActiveTexture(GL_TEXTURE1);
            tex->bind();
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, levels);
            glGenerateMipmap(GL_TEXTURE_2D); // every level exists; 2.. are replaced by Apple's downsampler
            tex->setTexParameter(GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            tex->setTexParameter(GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            tex->setTexParameter(GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            buildPyramid(tex->m_texID, int(box.w), int(box.h), levels);
            tex->unbind();
            g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
            return {tex, box};
        }

        // The backdrop of one glass element as Apple's blur pyramid, copied from what Hyprland blurs (the backdrop
        // capture when a scope is open, else the framebuffer being rendered). Per element, at its own turn in the
        // pass: a copy shared across the frame showed stale pixels in the real shell (the framebuffer
        // under a later layer is not final at an earlier element's turn), see README Performance. The whole extents
        // are copied (one rect), so the downsampler's taps never reach texels of an older frame; past them the
        // texture clamps to its edge (Apple's capture has a 16 pt margin and clamps too).
        STexView backdropPyramid(Render::CRenderContext& ctx, uintptr_t owner, const Vector2D& size, const CRegion& read, int levels, eRole role = SHARP) {
            const auto  mon      = ctx.m_data.pMonitor.lock();
            const auto& captures = ctx.m_backdropCaptures;
            const auto  source   = !captures.empty() && captures.back().framebuffer ? captures.back().framebuffer : ctx.m_data.currentFB;
            if (!mon)
                return {};
            return copyBox(owner, mon->m_id, role, dynamicPointerCast<CGLFramebuffer>(source), CRegion{footprintOf(read, levels, size).getExtents()}, levels);
        }
    }

    void releaseGlState() {
        g_down.release();
        g_boxes.clear();
        g_luma.clear();
        if (g_readFbo)
            glDeleteFramebuffers(1, &g_readFbo);
        g_readFbo = 0;
    }

    std::vector<SGlassShape> shapesFromRegion(const CRegion& region, double ox, double oy, double* opacity, const Vector2D& size) {
        std::vector<SRect> rects;
        for (const auto& r : region.getRects())
            rects.push_back({double(r.x1), double(r.y1), double(r.x2 - r.x1), double(r.y2 - r.y1)});
        if (opacity)
            *opacity = takeOpacityMarker(rects, size.x, size.y);
        auto shapes = clusterRegion(rects);
        for (auto& s : shapes) {
            s.box.x += ox;
            s.box.y += oy;
        }
        return shapes;
    }

    // ── element ─────────────────────────────────────────────────────────────

    // the material of group `gi` (its lead shape sets D), light or dark, at Liquid Glass slider `tint`
    static SResolved resolveGroup(const CGlassElement::SData& data, size_t gi, bool dark, float tint) {
        const auto&  lead = data.shapes[data.groups[gi].lead];
        const double D    = std::min(lead.box.w, lead.box.h);
        auto         res  = resolveMaterial(*data.recipe, D, dark, tint);
        // shadow marker (SGlassShape::regularShadow): Regular's shadow for this size instead of the layer's; a recipe with
        // a size class has one size, so its own shadow stays (Notification Center cards)
        if (lead.regularShadow && hasShadow(*data.recipe) && data.recipe->sizeD <= 0) {
            const auto reg    = resolveMaterial(recipeByName("regular"), D, dark, tint);
            res.shadowOpacity = reg.shadowOpacity;
            res.shadowRadius  = reg.shadowRadius;
            res.shadowOffsetY = reg.shadowOffsetY;
        }
        return res;
    }

    // groups and their geometry (reach, damage, mip levels: the same light and dark, the slider only lowers the blur)
    static void resolveShapes(CGlassElement::SData& data) {
        if (!data.groups.empty() || data.shapes.empty())
            return;
        for (auto& s : data.shapes)
            if (s.fill != 0)
                data.fills.push_back(s);
        std::erase_if(data.shapes, [](const SGlassShape& s) { return s.fill != 0; });
        if (data.shapes.empty())
            return;
        data.groups = groupShapes(data.shapes, data.smoothK);
        data.resolved.clear();
        for (size_t gi = 0; gi < data.groups.size(); ++gi)
            data.resolved.push_back(resolveGroup(data, gi, false, 0.5f));
    }

    CGlassElement::CGlassElement(SData data) : m_data(std::move(data)) {
        resolveShapes(m_data);
    }

    double CGlassElement::margin(const SData& data) {
        const auto& r = *data.recipe;
        return (data.shadow && hasShadow(r) ? 2.0 * r.shadowRadius + std::abs(r.shadowOffsetY) : 0.0) + 2.0;
    }

    // physical-px box the glass draws into plus what its shader reads
    static CBox readBox(const SRect& b, double margin, double reach, float scale) {
        return CBox{b.x - margin - reach, b.y - margin - reach, b.w + 2 * (margin + reach), b.h + 2 * (margin + reach)}.scale(scale).round();
    }

    // Control Center panel blur (panel_blur): the box of the layer's shapes grown by PANEL_OUT, its blur radius ramping from 0
    // at that edge to the full radius PANEL_RAMP inside (linear in radius, as Apple's BlurOpacity). Both fitted to the Mac's
    // gap row over 4 pt stripes where it leaves the tile column (C2 cc-real-stripes, 140 px: rms 2.8 levels, 11.2 without
    // the ramp); the radius itself to the gap between the tiles (rms 0.47). REFRACTION.md "Panel blur".
    constexpr double PANEL_OUT = 44.8, PANEL_RAMP = 72.0;

    static SRect panelBoxOf(const CGlassElement::SData& data) {
        double x1 = 1e9, y1 = 1e9, x2 = -1e9, y2 = -1e9;
        for (const auto& s : data.shapes) {
            x1 = std::min(x1, s.box.x);
            y1 = std::min(y1, s.box.y);
            x2 = std::max(x2, s.box.right());
            y2 = std::max(y2, s.box.bottom());
        }
        return {x1 - PANEL_OUT, y1 - PANEL_OUT, x2 - x1 + 2 * PANEL_OUT, y2 - y1 + 2 * PANEL_OUT};
    }

    // Apple's lod of a filter radius in backdrop texels (glass_background_base): max(0, log2(R < 2 ? R / 2 + 1 : R))
    static float appleLod(float R) {
        return std::max(0.f, std::log2(R < 2 ? R * 0.5f + 1 : R));
    }

    // pyramid level of the backdrop at Apple's scale s (level log2(1 / s): our level 1 is the 2x2 box of the output)
    static float baseLevelOf(const SResolved& res) {
        return std::log2(1.f / std::max(res.backdropScale, 0.0625f));
    }

    // level of the edge-bleed sample: radius 0.5 x BleedBlurRadius = 0.175 D (C3 3)
    static float bleedLevelOf(const SResolved& res, float scale) {
        return baseLevelOf(res) + appleLod(1.6f * 0.5f * res.bleedAmount * scale * res.backdropScale);
    }

    // level whose texel covers about half the shape: the light/dark readback reads one texel of it at the centre
    static int lumaLevel(const CBox& box) {
        return std::max(0, int(std::floor(std::log2(std::max(1.0, std::min(box.w, box.h) * 0.5)))));
    }

    // shader blurLevel(): level of radius r read through a backdrop already blurred with radius `under`
    static float blurLevelOf(const SResolved& res, float r, float under, float scale) {
        const float k = 1.6f * scale * res.backdropScale;
        float       L = appleLod(k * r);
        if (under > 0)
            L = 0.5f * std::log2(std::exp2(2 * L) + std::exp2(2 * appleLod(k * under)) - 1);
        return baseLevelOf(res) + L;
    }

    // deepest level the shader reads for this material: the face blur (radius x opacity <= 1, with the underlay), the blur
    // fill (radius 8), the bleed, the shadow tint (a trilinear read at L touches floor(L) and ceil(L))
    static int levelsFor(const SResolved& res, double underlay, bool shadow, float scale) {
        const bool bf  = res.blurFill.lighten > 0 || res.blurFill.darken > 0 || res.blurFill.normal > 0;
        float      lvl = blurLevelOf(res, res.blurRadius, float(underlay), scale);
        if (bf)
            lvl = std::max(lvl, blurLevelOf(res, 8.f, float(underlay), scale));
        if (res.bleedOpacity > 0)
            lvl = std::max(lvl, bleedLevelOf(res, scale));
        if (shadow)
            lvl = std::max(lvl, float(SHADOW_LEVEL));
        return std::clamp(int(std::ceil(lvl)), 2, MAX_LEVELS);
    }

    static double reachOf(const SParams& p, const SResolved& res) {
        const double shift = std::max({std::abs(res.refractionAmount), res.outerOpacity > 0 ? std::abs(res.outerAmount) : 0.f, res.bleedAmount}) * std::abs(p.refractionScale);
        return shift + p.aberration + 8.0;
    }

    void CGlassElement::claimDamage(Render::CRenderContext& ctx, SData& data) {
        const auto mon = ctx.m_data.pMonitor.lock();
        if (!mon || !data.params)
            return;
        resolveShapes(data);
        const double m = margin(data);
        if (data.params->fullDamage)
            return; // everything is redrawn anyway
        for (size_t i = 0; i < data.groups.size(); ++i)
            g_claims.emplace_back(readBox(data.groups[i].box, m, reachOf(*data.params, data.resolved[i]), mon->m_scale), false);
        if (data.panel > 0 && !data.shapes.empty())
            g_claims.emplace_back(readBox(panelBoxOf(data), 0, 8, mon->m_scale), false);

        // a box added now can touch glass claimed earlier this frame: repeat until stable
        for (bool grew = true; grew;) {
            grew = false;
            for (auto& [box, added] : g_claims) {
                if (added || !touches(ctx.m_data.damage, box))
                    continue;
                ctx.m_data.damage.add(box);
                added = grew = true;
            }
        }
    }

    bool CGlassElement::needsLiveBlur(Render::CRenderContext&) {
        return true;
    }

    bool CGlassElement::needsPrecomputeBlur(Render::CRenderContext&) {
        return false;
    }

    const char* CGlassElement::passName() {
        return "CLiquidGlassElement";
    }

    ePassElementType CGlassElement::type() {
        return EK_CUSTOM;
    }

    bool CGlassElement::requiresFullDamage(Render::CRenderContext&) {
        // opt-in: claimDamage() normally redraws just the glass that was touched
        return m_data.params->fullDamage && glassProgram().state() != CGlassProgram::eState::FAILED;
    }

    bool CGlassElement::disableSimplification(Render::CRenderContext&) {
        return false;
    }

    std::optional<CBox> CGlassElement::boundingBox(Render::CRenderContext&) {
        if (m_data.shapes.empty() && m_data.fills.empty())
            return std::nullopt;
        const double m  = margin(m_data);
        double       x1 = 1e9, y1 = 1e9, x2 = -1e9, y2 = -1e9;
        for (const auto& s : m_data.fills) {
            x1 = std::min(x1, s.box.x);
            y1 = std::min(y1, s.box.y);
            x2 = std::max(x2, s.box.right());
            y2 = std::max(y2, s.box.bottom());
        }
        for (const auto& s : m_data.shapes) {
            x1 = std::min(x1, s.box.x - m);
            y1 = std::min(y1, s.box.y - m);
            x2 = std::max(x2, s.box.right() + m);
            y2 = std::max(y2, s.box.bottom() + m);
        }
        return CBox{x1, y1, x2 - x1, y2 - y1};
    }

    std::vector<UP<IPassElement>> CGlassElement::draw(Render::CRenderContext& ctx) {
        if (!ctx.m_data.pMonitor || (m_data.shapes.empty() && m_data.fills.empty()) || m_data.alpha <= 0.001f)
            return {};

        stats::begin(stats::GLASS);
        if (!glassProgram().ensure(m_data.params->shaderPath) || !drawGlass(ctx))
            drawFallback(ctx);
        else
            drawFills(ctx);
        stats::end(stats::GLASS);
        return {};
    }

    // Plain Hyprland blur in the same rounded shape: what the user gets without the shader.
    void CGlassElement::drawFallback(Render::CRenderContext& ctx) {
        if (!g_pHyprOpenGL)
            return;
        const auto  mon   = ctx.m_data.pMonitor.lock();
        const float scale = mon ? mon->m_scale : 1.f;
        const auto& p     = *m_data.params;
        for (size_t gi = 0; gi < m_data.groups.size(); ++gi)
            for (const size_t i : m_data.groups[gi].members) {
                const auto& s    = m_data.shapes[i];
                const auto  it   = g_luma.find({m_data.owner, gi}); // light/dark state is kept per group
                const bool  dark = p.appearance == 2 || (p.appearance == 0 && it != g_luma.end() && it->second.dark);
                const auto& face = dark ? m_data.recipe->dark : m_data.recipe->light;
                // rough stand-in for the face effect: the recipe fill, or half its black point as a white lift
                const auto tint = face.fill.a > 0 ? face.fill : SRgba{1, 1, 1, face.ycc.black * 0.5f};
                CBox box = CBox{s.box.x, s.box.y, s.box.w, s.box.h}.scale(scale).round();
                const float a = m_data.alpha * float(s.materialize);
                if (box.w < 1 || box.h < 1 || a <= 0.001f)
                    continue;
                g_pHyprOpenGL->renderRect(ctx, box, CHyprColor{tint.r, tint.g, tint.b, tint.a * a},
                                          {.round = sc<int>(std::round(s.radius * scale)), .roundingPower = m_data.roundingPower.value_or(p.roundingPower), .blur = true,
                                           .blurA = a});
            }
    }

    bool CGlassElement::drawGlass(Render::CRenderContext& ctx) {
        const auto mon = ctx.m_data.pMonitor.lock();
        if (!mon)
            return false;

        auto&          prog  = glassProgram();
        const auto&    p     = *m_data.params;
        const SRecipe& r     = *m_data.recipe;
        const auto&    u     = prog.u;
        const float    scale = mon->m_scale;
        const double   m     = margin(m_data);

        // quads to draw (physical px) and the region the shader may read
        struct SQuad {
            size_t    index;
            CBox      box;
            CRegion   damage;
            SResolved res;
        };
        std::vector<SQuad> quads;
        CRegion            readRegion;
        int                levels = 2;
        for (size_t i = 0; i < m_data.groups.size(); ++i) {
            const auto& g    = m_data.groups[i];
            const CBox  quad = readBox(g.box, m, 0, scale);
            if (quad.w < 1 || quad.h < 1)
                continue;
            CRegion damage{ctx.m_data.damage};
            damage.intersect(quad);
            if (damage.empty())
                continue;
            quads.push_back({i, quad, std::move(damage), m_data.resolved[i]});
            readRegion.add(readBox(g.box, m, reachOf(p, m_data.resolved[i]), scale));
            levels = std::max(levels, levelsFor(resolveGroup(m_data, i, false, p.tintAmount), m_data.underlay, m_data.shadow && hasShadow(r), scale));
            if (p.appearance == 0) // the light/dark readback averages the whole shape: one texel of a level about its size
                levels = std::max(levels, std::min(lumaLevel(quad), MAX_LEVELS));
        }
        if (quads.empty())
            return true;
        readRegion.intersect(CBox{{}, mon->m_transformedSize});

        // the panel blur goes into the framebuffer first, so the shapes' own copy below samples it (the Mac's tiles sample the
        // panel's blur); without it (a backdrop capture is open, or it failed) the underlay stands in
        const bool panelDrawn = m_data.panel > 0 && drawPanel(ctx, readRegion, levels);

        // the backdrop under every shape as Apple's blur pyramid (before binding the glass shader: the build uses its own
        // program); without it there is no glass, the fallback draws Hyprland's blur
        const auto pyr = backdropPyramid(ctx, m_data.owner, mon->m_transformedSize, readRegion, levels);
        if (!pyr.tex)
            return false;
        const auto& tex = pyr.tex;

        const auto shader = g_pHyprOpenGL->useShader(prog.shader());
        if (!shader)
            return false;

        // light/dark per shape: forced, or the hysteresis state from earlier readbacks
        std::vector<bool> dark(quads.size(), p.appearance == 2);
        if (p.appearance == 0) {
            for (size_t q = 0; q < quads.size(); ++q) {
                auto&       l = g_luma[{m_data.owner, quads[q].index}];
                const auto& s = m_data.groups[quads[q].index];
                // a shape index taken over by a differently sized shape starts fresh
                if (std::abs(l.w - s.box.w) > 2 || std::abs(l.h - s.box.h) > 2) {
                    l.valid = false;
                    l.w     = s.box.w;
                    l.h     = s.box.h;
                }
                l.seen = g_frame;
                collectLuma(l, p);
                const int   level = std::min(lumaLevel(quads[q].box), levels);
                requestLuma(l, tex->m_texID, level, int((s.box.x + s.box.w / 2) * scale - pyr.box.x) >> level, int((s.box.y + s.box.h / 2) * scale - pyr.box.y) >> level);
                dark[q] = l.dark;
            }
        }

        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->bind();

        // per-element uniforms
        glUniform1i(u.tex, 0);
        glUniform1f(u.maxLevel, float(levels));
        glUniform1i(u.linearLight, p.linearLight ? 1 : 0);
        // the outer layer fades in over the outermost 1 pt (RefractionDistance0 / 1 = -1 / 0)
        glUniform2f(u.outerThreshold, -1.f * scale, 0.f);
        glUniform1f(u.roundingPower, m_data.roundingPower.value_or(p.roundingPower));
        glUniform1f(u.alpha, m_data.alpha);
        glUniform1f(u.aberration, p.aberration * scale);
        glUniform1f(u.pxPerPt, scale);
        glUniform1f(u.shadowTint, p.shadowTint);
        glUniform1f(u.shadowSaturation, r.shadowSaturation);
        glUniform1f(u.ringOpacity, r.ringOpacity * p.ringScale);
        glUniform2f(u.ringOffset, 0.f, r.ringOffsetY * scale);
        glUniform1f(u.ringStroke, r.ringStroke * scale);
        glUniform1f(u.ringRadius, r.ringRadius * scale);

        glUniform1f(u.appearBlur, 10.f * scale); // SwiftUI materialize AppearanceSettings.blurRadius
        glUniform1f(u.fillAmount, 0.f);

        g_pHyprOpenGL->blend(true);
        g_pHyprOpenGL->blendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glBindVertexArray(shader->getUniformLocation(SHADER_SHADER_VAO));

        for (size_t q = 0; q < quads.size(); ++q) {
            const auto& [index, quad, damage, geo] = quads[q];
            const auto& g                          = m_data.groups[index];
            const auto  res                        = resolveGroup(m_data, index, dark[q], p.tintAmount);

            shader->setUniformMatrix3fv(SHADER_PROJ, 1, GL_TRUE, g_pHyprRenderer->projectBoxToTarget(ctx, quad).getMatrix());
            // quad corners in the copy's uv (it holds a part of the output)
            glUniform2f(u.uvTopLeft, (quad.x - pyr.box.x) / pyr.box.w, (quad.y - pyr.box.y) / pyr.box.h);
            glUniform2f(u.uvBottomRight, (quad.x + quad.w - pyr.box.x) / pyr.box.w, (quad.y + quad.h - pyr.box.y) / pyr.box.h);
            glUniform2f(u.quadSize, quad.w, quad.h);
            std::array<float, 4 * MAX_GROUP> boxes{};
            std::array<float, 2 * MAX_GROUP> info{};
            for (size_t k = 0; k < g.members.size(); ++k) {
                const auto& s   = m_data.shapes[g.members[k]];
                boxes[4 * k]     = (s.box.x + s.box.w / 2) * scale - quad.x;
                boxes[4 * k + 1] = (s.box.y + s.box.h / 2) * scale - quad.y;
                // a pointer: half its square's side, and a negative radius tells the shader to turn it by 45 deg
                boxes[4 * k + 2] = (s.pointer ? POINTER_SIDE : s.box.w) * scale / 2;
                boxes[4 * k + 3] = (s.pointer ? POINTER_SIDE : s.box.h) * scale / 2;
                info[2 * k]      = (s.pointer ? -POINTER_RADIUS : s.radius) * scale;
                info[2 * k + 1]  = s.materialize;
            }
            glUniform1f(u.smoothK, float(g.smoothK) * scale);
            glUniform1i(u.shapeCount, int(g.members.size()));
            glUniform4fv(u.shapeBox, GLsizei(g.members.size()), boxes.data());
            glUniform2fv(u.shapeInfo, GLsizei(g.members.size()), info.data());
            // Apple's blur (C3 2): R = 1.6 x radius x backdrop texels per pt, level log2(1 / scale) + lod(R)
            glUniform1f(u.blurRadius, res.blurRadius);
            glUniform1f(u.blurK, 1.6f * scale * res.backdropScale);
            glUniform1f(u.baseLevel, baseLevelOf(res));
            glUniform1f(u.underlay, panelDrawn ? 0.f : float(m_data.underlay));
            glUniform1f(u.refraction, res.refractionAmount * p.refractionScale * scale);
            glUniform1f(u.refractionHeight, res.refractionHeight * scale);
            glUniform2f(u.blurDist, res.blurDist0 * scale, r.blurDist1 * scale);
            glUniform1f(u.outerOpacity, res.outerOpacity);
            glUniform1f(u.outerAmount, res.outerAmount * p.refractionScale * scale);
            glUniform1f(u.outerHeight, res.outerHeight * scale);
            glUniform3f(u.blurFill, res.blurFill.lighten, res.blurFill.darken, res.blurFill.normal);
            glUniform1f(u.bleedOpacity, res.bleedOpacity);
            glUniform1f(u.bleedHeight, res.bleedHeight * scale);
            glUniform1f(u.bleedAmount, res.bleedAmount * p.refractionScale * scale);
            // the bleed sample is blurred with radius 0.175 D (MAC-ANSWERS PC #67 C3 3), capped by the levels the copy has
            glUniform1f(u.bleedLod, std::min(bleedLevelOf(res, scale), float(levels)));
            glUniform4f(u.bleedYcc, res.bleed.black, res.bleed.white, res.bleed.saturation, res.bleedLighten ? 1.f : 0.f);
            glUniform4f(u.faceYcc, res.ycc.black, res.ycc.white, res.ycc.saturation, res.maxLuma);
            glUniform3f(u.blurAlpha, res.blurAlpha[0], res.blurAlpha[1], res.blurAlpha[2]);
            glUniform4f(u.faceFill, res.fill.r, res.fill.g, res.fill.b, res.fill.a);
            glUniform3f(u.keyYcc, res.keyYcc.black, res.keyYcc.white, res.keyYcc.saturation);
            const float keyRad = res.keySpread * float(M_PI / 180.0);
            glUniform2f(u.keySpread, std::cos(keyRad), std::cos(0.65f * keyRad)); // diffuse: 0.65 x the spread
            glUniform3f(u.highlight, p.highlight * res.keyScale, res.keyAmount, res.diffuseAmount);
            glUniform2f(u.darkSpec, res.darkBias, std::cos(res.darkSpread * float(M_PI / 180.0)));
            glUniform1f(u.shadowOpacity, m_data.shadow ? res.shadowOpacity * p.shadowScale : 0.f);
            glUniform1f(u.shadowRadius, res.shadowRadius * scale);
            glUniform2f(u.shadowOffset, 0.f, res.shadowOffsetY * scale);

            damage.forEachRect([&ctx](const auto& rect) {
                g_pHyprOpenGL->scissor(ctx, &rect, ctx.m_data.transformDamage);
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            });
        }

        glBindVertexArray(0);
        g_pHyprOpenGL->disableScissor();
        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        tex->setTexParameter(GL_TEXTURE_MIN_FILTER, tex->minFilter);
        tex->unbind();
        return true;
    }

    bool CGlassElement::drawPanel(Render::CRenderContext& ctx, const CRegion& readRegion, int levels) {
        const auto mon = ctx.m_data.pMonitor.lock();
        if (!mon || !ctx.m_backdropCaptures.empty() || m_data.shapes.empty())
            return false;
        auto&       prog  = glassProgram();
        const auto& u     = prog.u;
        const auto& p     = *m_data.params;
        const float scale = mon->m_scale;
        const SRect pb    = panelBoxOf(m_data);
        const CBox  quad  = readBox(pb, 0, 0, scale);
        CRegion     damage{ctx.m_data.damage};
        damage.intersect(quad);
        if (damage.empty() || quad.w < 1 || quad.h < 1)
            return true; // the framebuffer still holds it from the last frame

        // materialize: the panel comes and goes with its glass
        float mat = 0;
        for (const auto& s : m_data.shapes)
            mat = std::max(mat, float(s.materialize));

        // a full-resolution read (backdrop scale 1: the ramp's edge reads level 0, the backdrop itself, so it has no seam);
        // at the full radius the level equals Apple's at scale 0.5 (lod(R) = log2 R for R >= 2)
        const float blurK = 1.6f * scale;
        const int   lv    = std::clamp(std::max(levels, int(std::ceil(appleLod(blurK * float(m_data.panel))))), 2, MAX_LEVELS);
        CRegion     read{readRegion};
        read.add(readBox(pb, 0, 8, scale));
        read.intersect(CBox{{}, mon->m_transformedSize});
        const auto pyr = backdropPyramid(ctx, m_data.owner, mon->m_transformedSize, read, lv, PANEL);
        if (!pyr.tex)
            return false;
        const auto shader = g_pHyprOpenGL->useShader(prog.shader());
        if (!shader)
            return false;

        g_pHyprOpenGL->setActiveTexture(GL_TEXTURE0);
        pyr.tex->bind();
        glUniform1i(u.tex, 0);
        glUniform1f(u.maxLevel, float(lv));
        glUniform1i(u.linearLight, p.linearLight ? 1 : 0);
        glUniform2f(u.outerThreshold, -1.f * scale, 0.f);
        glUniform1f(u.roundingPower, 2.f); // the grown box's corners are the offset curve of its shapes' box: circles
        glUniform1f(u.alpha, m_data.alpha);
        glUniform1f(u.aberration, 0.f);
        glUniform1f(u.pxPerPt, scale);
        glUniform1f(u.shadowTint, 0.f);
        glUniform1f(u.shadowSaturation, 1.f);
        glUniform1f(u.ringOpacity, 0.f);
        glUniform2f(u.ringOffset, 0.f, 0.f);
        glUniform1f(u.ringStroke, 0.f);
        glUniform1f(u.ringRadius, 1.f);
        glUniform1f(u.smoothK, 0.f);
        glUniform1f(u.appearBlur, 0.f);
        glUniform1f(u.fillAmount, 0.f);

        shader->setUniformMatrix3fv(SHADER_PROJ, 1, GL_TRUE, g_pHyprRenderer->projectBoxToTarget(ctx, quad).getMatrix());
        glUniform2f(u.uvTopLeft, (quad.x - pyr.box.x) / pyr.box.w, (quad.y - pyr.box.y) / pyr.box.h);
        glUniform2f(u.uvBottomRight, (quad.x + quad.w - pyr.box.x) / pyr.box.w, (quad.y + quad.h - pyr.box.y) / pyr.box.h);
        glUniform2f(u.quadSize, quad.w, quad.h);
        // the shape is 1 pt larger than the quad, so every drawn pixel is fully covered and the ramp starts at the quad's edge
        const float hw = float(quad.w) / 2.f, hh = float(quad.h) / 2.f;
        const float box[4]  = {hw, hh, hw + scale, hh + scale};
        const float info[2] = {float((PANEL_OUT + 1) * scale), mat};
        glUniform1i(u.shapeCount, 1);
        glUniform4fv(u.shapeBox, 1, box);
        glUniform2fv(u.shapeInfo, 1, info);
        glUniform1f(u.blurRadius, float(m_data.panel));
        glUniform1f(u.blurK, blurK);
        glUniform1f(u.baseLevel, 0.f);
        glUniform1f(u.underlay, 0.f);
        glUniform1f(u.refraction, 0.f);
        glUniform1f(u.refractionHeight, 1.f);
        // opacity 0 at d = -1 pt (the quad's edge) to 1 at PANEL_RAMP inside it
        glUniform2f(u.blurDist, -float(PANEL_RAMP + 1) * scale, -1.f * scale);
        glUniform3f(u.blurAlpha, 1.f, 0.f, 0.f);
        glUniform1f(u.outerOpacity, 0.f);
        glUniform1f(u.outerAmount, 0.f);
        glUniform1f(u.outerHeight, 0.f);
        glUniform3f(u.blurFill, 0.f, 0.f, 0.f);
        glUniform1f(u.bleedOpacity, 0.f);
        glUniform1f(u.bleedHeight, 0.f);
        glUniform1f(u.bleedAmount, 0.f);
        glUniform1f(u.bleedLod, 0.f);
        glUniform4f(u.bleedYcc, 0.f, 1.f, 1.f, 0.f);
        glUniform4f(u.faceYcc, 0.f, 1.f, 1.f, 1.f); // identity face: blur only
        glUniform4f(u.faceFill, 0.f, 0.f, 0.f, 0.f);
        glUniform3f(u.keyYcc, 0.f, 1.f, 1.f);
        glUniform2f(u.keySpread, 1.f, 1.f);
        glUniform3f(u.highlight, 0.f, 0.f, 0.f);
        glUniform2f(u.darkSpec, 0.f, 1.f);
        glUniform1f(u.shadowOpacity, 0.f);
        glUniform1f(u.shadowRadius, 1.f);
        glUniform2f(u.shadowOffset, 0.f, 0.f);

        g_pHyprOpenGL->blend(true);
        g_pHyprOpenGL->blendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glBindVertexArray(shader->getUniformLocation(SHADER_SHADER_VAO));
        damage.forEachRect([&ctx](const auto& rect) {
            g_pHyprOpenGL->scissor(ctx, &rect, ctx.m_data.transformDamage);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        });
        glBindVertexArray(0);
        g_pHyprOpenGL->disableScissor();
        pyr.tex->setTexParameter(GL_TEXTURE_MIN_FILTER, pyr.tex->minFilter);
        pyr.tex->unbind();
        return true;
    }

    // plus-lighter / plus-darker fills (Shape.hpp SGlassShape::fill) over what the glass drew: the glass shader's fill mode
    // outputs amount x coverage, added to or subtracted from the framebuffer by the blend equation
    void CGlassElement::drawFills(Render::CRenderContext& ctx) {
        const auto mon = ctx.m_data.pMonitor.lock();
        if (!mon || m_data.fills.empty())
            return;
        auto&       prog  = glassProgram();
        const auto& u     = prog.u;
        const float scale = mon->m_scale;
        const auto  shader = g_pHyprOpenGL->useShader(prog.shader());
        if (!shader || u.fillAmount < 0)
            return;
        glUniform1f(u.roundingPower, m_data.roundingPower.value_or(m_data.params->roundingPower));
        glUniform1f(u.alpha, m_data.alpha);
        glUniform1f(u.smoothK, 0.f);
        glUniform1f(u.appearBlur, 10.f * scale);
        glUniform1i(u.shapeCount, 1);
        glBindVertexArray(shader->getUniformLocation(SHADER_SHADER_VAO));
        g_pHyprOpenGL->blend(true);
        for (const auto& f : m_data.fills) {
            const CBox quad = CBox{f.box.x, f.box.y, f.box.w, f.box.h}.scale(scale).round();
            CRegion    damage{ctx.m_data.damage};
            damage.intersect(quad);
            if (damage.empty() || quad.w < 1 || quad.h < 1)
                continue;
            shader->setUniformMatrix3fv(SHADER_PROJ, 1, GL_TRUE, g_pHyprRenderer->projectBoxToTarget(ctx, quad).getMatrix());
            glUniform2f(u.quadSize, quad.w, quad.h);
            const float box[4]  = {float(quad.w) / 2.f, float(quad.h) / 2.f, float(quad.w) / 2.f, float(quad.h) / 2.f};
            const float info[2] = {float(f.radius * scale), float(f.materialize)};
            glUniform4fv(u.shapeBox, 1, box);
            glUniform2fv(u.shapeInfo, 1, info);
            glUniform1f(u.fillAmount, float(f.fill > 0 ? FILL_LIGHTER : FILL_DARKER));
            glBlendEquation(f.fill > 0 ? GL_FUNC_ADD : GL_FUNC_REVERSE_SUBTRACT);
            g_pHyprOpenGL->blendFunc(GL_ONE, GL_ONE);
            damage.forEachRect([&ctx](const auto& rect) {
                g_pHyprOpenGL->scissor(ctx, &rect, ctx.m_data.transformDamage);
                glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            });
        }
        glBlendEquation(GL_FUNC_ADD);
        g_pHyprOpenGL->blendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glBindVertexArray(0);
        g_pHyprOpenGL->disableScissor();
    }
}
