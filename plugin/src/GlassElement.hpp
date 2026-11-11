#pragma once

#include "Config.hpp"
#include "Material.hpp"
#include "Shape.hpp"

#include <hyprland/src/render/pass/PassElement.hpp>
#include <hyprland/src/render/Shader.hpp>
#include <hyprland/src/render/Texture.hpp>

#include <cstdint>

#include <memory>
#include <optional>
#include <string>
#include <vector>

namespace lg {

    // Compiles and owns the glass program. State is sticky: one failure logs once
    // and every later draw takes the plain-blur fallback until the plugin reloads
    // or shader_path changes.
    class CGlassProgram {
      public:
        enum class eState { UNTRIED, READY, FAILED };

        // compiles lazily (needs the GL context), returns true when usable
        bool         ensure(const std::string& overridePath);
        SP<CShader>  shader() const { return m_shader; }
        eState       state() const { return m_state; }
        void         destroy();

        struct SUniforms {
            int tex, linearLight, uvTopLeft, uvBottomRight, quadSize, shapeCount, shapeBox, shapeInfo, smoothK, appearBlur, roundingPower, alpha, ditherAmount;
            int blurRadius, blurK, baseLevel, maxLevel, underlay, refraction, refractionHeight, aberration, faceYcc;
            int blurAlpha, blurDist, outerAmount, outerHeight, outerOpacity, outerThreshold;
            int blurFill, bleedOpacity, bleedHeight, bleedAmount, bleedLod, bleedYcc, faceFill, pointerFill, fillAmount;
            int pxPerPt, keyYcc, keySpread, highlight, darkSpec;
            int shadowOpacity, shadowRadius, shadowOffset, shadowTint, shadowSaturation;
            int ringOpacity, ringOffset, ringStroke, ringRadius;
            int aux, maskRect, maskLighten, maskHighlights, sdfRect, sdfRange;
        } u{};

      private:
        void        fail(const std::string& why);
        SP<CShader> m_shader;
        eState      m_state = eState::UNTRIED;
        std::string m_loadedPath;
    };

    CGlassProgram& glassProgram();

    // glass shapes of a client's ext-background-effect region (surface-local), moved by (ox, oy).
    // With `opacity`, the opacity marker (takeOpacityMarker) of a surface of `size` is read into it.
    std::vector<SGlassShape> shapesFromRegion(const CRegion& region, double ox, double oy, double* opacity = nullptr, const Vector2D& size = {});

    // once per monitor frame: ages the per-surface light/dark state
    void onFrame();
    // a layer or window went away: drop its light/dark state (its address may be reused)
    void forgetOwner(uintptr_t owner);
    // frees the plugin's GL objects (PLUGIN_EXIT, GL context current)
    void releaseGlState();

    // One pass element per glassed surface: draws the material for all its shapes
    // right before Hyprland draws the surface itself.
    class CGlassElement : public IPassElement {
      public:
        struct SData {
            std::vector<SGlassShape>       shapes; // monitor-local logical px
            double                         smoothK = 0;          // smooth-union reach (logical px), 0 = no merging
            double                         underlay = 0;         // Apple blur radius (pt) of a layer under the glass on the Mac (CC panel)
            double                         panel    = 0;         // Apple blur radius (pt) of a panel blur drawn first, around the shapes
            float                          alpha = 1.f;
            std::shared_ptr<const SParams> params;
            const SRecipe*                 recipe = &recipeByName("regular");
            uintptr_t                      owner  = 0;    // layer/window identity, keys the light/dark state
            bool                           shadow = true; // windows draw their own
            std::optional<float>           roundingPower; // override params->roundingPower
            // a texture the client hands over as a layer surface of its own (README "Textures from the shell")
            enum class eAux { NONE, MASKS, SDF };
            eAux                           auxKind = eAux::NONE;
            SP<Render::ITexture>           aux;            // MASKS: the icons' clear-mode masks; SDF: the element's shape
            SRect                          auxBox;         // its layer's box, monitor-local logical px
            double                         sdfRange = 0;   // SDF: logical px between the values 0.5 and 1
            std::vector<SGlassGroup>       groups;        // filled by claimDamage()/the ctor
            std::vector<SGlassShape>       fills;         // fill-marker shapes, moved out of `shapes` there
            std::vector<SResolved>         resolved;      // per group, from its lead shape
        };

        explicit CGlassElement(SData data);
        virtual ~CGlassElement() = default;

        std::vector<UP<IPassElement>> draw(Render::CRenderContext& ctx) override;
        bool                          needsLiveBlur(Render::CRenderContext& ctx) override;
        bool                          needsPrecomputeBlur(Render::CRenderContext& ctx) override;
        const char*                   passName() override;
        ePassElementType              type() override;
        std::optional<CBox>           boundingBox(Render::CRenderContext& ctx) override;
        bool                          requiresFullDamage(Render::CRenderContext& ctx) override;
        bool                          disableSimplification(Render::CRenderContext& ctx) override;

        // logical px the effect reaches outside the glass box (shadow)
        static double margin(const SData& data);

        // Damage the whole glass (plus what it reads) when any part of it is damaged:
        // refraction and the luminance probe read far from the damaged pixels. Call while
        // the pass is built, before CRenderPass::render() consumes ctx.m_data.damage.
        static void claimDamage(Render::CRenderContext& ctx, SData& data);

        // physical px the glass of `data` draws into and reads (after claimDamage, which resolves the groups)
        static CRegion readRegionOf(const PHLMONITOR& mon, const SData& data);

      private:
        void  drawFallback(Render::CRenderContext& ctx);
        bool  drawGlass(Render::CRenderContext& ctx);
        bool  drawPanel(Render::CRenderContext& ctx, const CRegion& readRegion, int levels);
        void  drawFills(Render::CRenderContext& ctx);
        SData m_data;
    };
}
