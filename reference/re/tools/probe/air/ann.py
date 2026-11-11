# ann.py <file.ll>: replace GlassBackgroundUniforms field indices by names and drop noise -> <file>.ann.ll
import re,sys
names="displacement_mat inner_refraction_amount inner_refraction_inv_height outer_refraction_amount outer_refraction_inv_height refraction_threshold0 refraction_threshold1 blur_radius edge_bleed_blur_radius edge_bleed_amount edge_bleed_inv_height shadow_amount shadow_inv_height shadow_offset shadow_blur_radius shadow_inv_radius face_cm0 face_cm1 face_cm2 bleed_cm0 bleed_cm1 bleed_cm2 shadow_cm0 shadow_cm1 shadow_cm2 shadow_contribution shadow_face_opacity blur_alpha0 blur_alpha1 blur_alpha2 blur_alpha3 blur_dist0 blur_dist1 blur_dist2 blur_dist3 edge_bleed_dist0 edge_bleed_dist1 edge_bleed_opacity face_opacity bleed_darken shadow_dist_offset shadow_opacity refraction_opacity holding_tone_opacity sdr_shadow_dist0 sdr_shadow_inv ring_shadow_offset ring_shadow_stroke_width ring_shadow_radius ring_shadow_opacity ring_shadow_mask key_fill_highlight_dir key_fill_highlight_height key_fill_highlight_spread key_fill_highlight_amount key_fill_highlight_effect_offset key_fill_highlight_color_bias blur_fill_blur_radius blur_fill_lighten_opacity blur_fill_darken_opacity blur_fill_normal_opacity aberration_amount aberration_dir".split()
ext="inv_aberration_height aberration_offset sdr_white_value clamp_limit face_color_matrix_max_luma_complement preserve_hue blur_fill_enabled stroke_mode highlight_extension wants_highlight_bias_correction".split()
t=open(sys.argv[1]).read()
def r1(m): return 'GEP U.%s <%s>'%(names[int(m.group(2))],m.group(1))
t=re.sub(r'getelementptr inbounds(?: nuw)? %struct\.GlassBackgroundUniforms\.[\d.]+, ptr addrspace\(2\) (%\d+), i64 0, i32 (\d+)',r1,t)
def r2(m): return 'GEP X.%s <%s>'%(ext[int(m.group(2))],m.group(1))
t=re.sub(r'getelementptr inbounds(?: nuw)? %struct\.GlassBackgroundUniformsExt\.[\d.]+, ptr addrspace\(2\) (%\d+), i64 0, i32 (\d+)',r2,t)
# byte-offset GEPs
t=re.sub(r', !tbaa !\d+|, !noalias !\d+|, !alias\.scope !\d+|, align \d+|noundef |nnan ninf nsz arcp contract afn reassoc |fast |tail ','',t)
t=re.sub(r'ptr addrspace\(\d\) ','',t)
open(sys.argv[1][:-3]+'.ann.ll','w').write(t)
