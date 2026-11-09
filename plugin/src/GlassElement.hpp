#pragma once

#include "Config.hpp"
#include "Shape.hpp"

#include <hyprland/src/render/pass/PassElement.hpp>
#include <hyprland/src/render/Shader.hpp>

#include <memory>
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
        const char*  failure() const { return m_failure.c_str(); }
        void         destroy();

        struct SUniforms {
            int tex, uvTopLeft, uvBottomRight, quadSize, glassBox, radius, roundingPower, alpha;
            int blurLod, edgeBlurLod, blurEdgeDistance, refraction, refractionHeight, aberration;
            int saturation, tintLight, tintDark, brightnessLight, brightnessDark, appearance, adaptThreshold, adaptSoftness;
            int lightDir, highlight, highlightWidth, highlightSpread, rim, innerShadow, innerShadowSize;
            int shadowOpacity, shadowRadius, shadowOffset, ringOpacity, ringWidth;
        } u{};

      private:
        void        fail(std::string why);
        SP<CShader> m_shader;
        eState      m_state = eState::UNTRIED;
        std::string m_failure;
        std::string m_loadedPath;
    };

    CGlassProgram& glassProgram();

    // One pass element per glassed surface: draws the material for all its shapes
    // right before Hyprland draws the surface itself.
    class CGlassElement : public IPassElement {
      public:
        struct SData {
            std::vector<SGlassShape> shapes; // monitor-local logical px
            float                    alpha = 1.f;
            std::shared_ptr<SParams> params;
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
        static double margin(const SParams& p);

      private:
        void  drawFallback(Render::CRenderContext& ctx);
        bool  drawGlass(Render::CRenderContext& ctx);
        SData m_data;
    };
}
