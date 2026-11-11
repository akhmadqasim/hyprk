// Prints the plugin's resolved glass inputs (resolveMaterial) as JSON, named like Apple's glassBackground filter inputs,
// for every material x light/dark x D x slider value of tools/check_model.py's grid.
#include "Material.hpp"

#include <cstdio>

using namespace lg;

int main() {
    const char*  mats[] = {"regular", "menu", "notificationcenter", "clear", "dock", "controlcenter"};
    const double Ds[] = {20, 24, 32, 64, 96, 200, 500}, As[] = {0, 0.25, 0.5, 0.75, 1};
    bool         first = true;
    std::printf("[");
    for (const char* m : mats)
        for (const bool dark : {false, true})
            for (const double D : Ds)
                for (const double a : As) {
                    const auto& r   = recipeByName(m);
                    const auto  x   = resolveMaterial(r, D, dark, a);
                                        std::printf("%s\n{\"material\":\"%s\",\"dark\":%s,\"D\":%g,\"a\":%g,\"inputs\":{", first ? "" : ",", m, dark ? "true" : "false", D, a);
                    first = false;
                    std::printf("\"InnerRefractionAmount\":%g,\"InnerRefractionHeight\":%g,\"OuterRefractionAmount\":%g,\"OuterRefractionHeight\":%g,"
                                "\"RefractionOpacity\":%g,",
                                x.refractionAmount, x.refractionHeight, x.outerAmount, x.outerHeight, x.outerOpacity);
                    std::printf("\"BlurFillLightenOpacity\":%g,\"BlurFillDarkenOpacity\":%g,\"BlurFillNormalOpacity\":%g,\"BlurRadius\":%g,\"BlurOpacity0\":%g,"
                                "\"BlurOpacity1\":%g,\"BlurOpacity2\":%g,\"BlurDistance0\":%g,",
                                x.blurFill.lighten, x.blurFill.darken, x.blurFill.normal, x.blurRadius, x.blurAlpha[0], x.blurAlpha[1], x.blurAlpha[2], x.blurDist0);
                    std::printf("\"FaceColorMatrixBlack\":%g,\"FaceColorMatrixWhite\":%g,\"FaceColorMatrixSaturation\":%g,\"Fill\":[%g,%g,%g,%g],\"MaxLuma\":%g,",
                                x.ycc.black, x.ycc.white, x.ycc.saturation, x.fill.r, x.fill.g, x.fill.b, x.fill.a, x.maxLuma);
                    std::printf("\"BleedOpacity\":%g,\"BleedAmount\":%g,\"BleedHeight\":%g,\"BleedColorMatrixBlack\":%g,\"BleedColorMatrixWhite\":%g,"
                                "\"BleedColorMatrixSaturation\":%g,\"BleedDarkenBlend\":%s,\"BackdropScale\":%g,",
                                x.bleedOpacity, x.bleedAmount, x.bleedHeight, x.bleed.black, x.bleed.white, x.bleed.saturation, x.bleedLighten ? "true" : "false",
                                x.backdropScale);
                    std::printf("\"KeyFillHighlightColorBias\":%g,\"KeyFillHighlightSpreadDeg\":%g,\"KeySpreadDeg\":%g,\"KeyAmount\":%g,\"DiffuseAmount\":%g,"
                                "\"KeyScale\":%g,\"KeyYcc\":[%g,%g,%g],\"ShadowOpacity\":%g,\"ShadowRadius\":%g,\"ShadowOffset\":%g,\"RingShadowOpacity\":%g}}",
                                x.darkBias, x.darkSpread, x.keySpread, x.keyAmount, x.diffuseAmount, x.keyScale, x.keyYcc.black, x.keyYcc.white, x.keyYcc.saturation, x.shadowOpacity, x.shadowRadius, x.shadowOffsetY,
                                hasShadow(r) || r.ringOpacity > 0 ? r.ringOpacity : 0.f);
                }
    std::printf("]\n");
}
