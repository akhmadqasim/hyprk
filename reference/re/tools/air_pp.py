import re,sys,struct
G="displacement_mat inner_refraction_amount inner_refraction_inv_height outer_refraction_amount outer_refraction_inv_height refraction_threshold0 refraction_threshold1 blur_radius edge_bleed_blur_radius edge_bleed_amount edge_bleed_inv_height shadow_amount shadow_inv_height shadow_offset shadow_blur_radius shadow_inv_radius face_cm0 face_cm1 face_cm2 bleed_cm0 bleed_cm1 bleed_cm2 shadow_cm0 shadow_cm1 shadow_cm2 shadow_contribution shadow_face_opacity blur_alpha0 blur_alpha1 blur_alpha2 blur_alpha3 blur_dist0 blur_dist1 blur_dist2 blur_dist3 edge_bleed_dist0 edge_bleed_dist1 edge_bleed_opacity face_opacity bleed_darken shadow_dist_offset shadow_opacity refraction_opacity holding_tone_opacity sdr_shadow_dist0 sdr_shadow_inv ring_shadow_offset ring_shadow_stroke_width ring_shadow_radius ring_shadow_opacity ring_shadow_mask key_fill_highlight_dir key_fill_highlight_height key_fill_highlight_spread key_fill_highlight_amount key_fill_highlight_effect_offset key_fill_highlight_color_bias blur_fill_blur_radius blur_fill_lighten_opacity blur_fill_darken_opacity blur_fill_normal_opacity aberration_amount aberration_dir".split()
E="inv_aberration_height aberration_offset sdr_white_value clamp_limit face_cm_max_luma_complement preserve_hue blur_fill_enabled stroke_mode highlight_extension wants_highlight_bias_correction".split()
SD="arg tr arg2".split()
def halfc(m):
    return '%.6g'%struct.unpack('<e',struct.pack('<H',int(m.group(1),16)))[0]
def fltc(m):
    return '%.7g'%struct.unpack('<d',struct.pack('<Q',int(m.group(1),16)))[0]
def clean(l):
    l=re.sub(r', !tbaa !\d+|, !range !\d+|, align \d+','',l)
    l=re.sub(r' #\d+$','',l)
    l=l.replace('ptr addrspace(2)','p2').replace('ptr addrspace(1)','p1').replace('tail call ','').replace('noundef ','').replace('fast ','').replace('readonly captures(none) ','')
    l=re.sub(r'0xH([0-9A-F]{4})',halfc,l)
    l=re.sub(r'0x([0-9A-F]{16})',fltc,l)
    l=re.sub(r'(\d\.\d+)e\+00',lambda m:'%g'%float(m.group(1)),l)
    l=re.sub(r'(\d\.\d+e[+-]\d+)',lambda m:'%g'%float(m.group(1)),l)
    l=re.sub(r'splat \((float|half) ([^)]+)\)',r'\2',l)
    return l
T=r'(?:<\d+ x (?:float|half|i32)>|float|half|i32|i1|i8|i64)'
def run(lines):
    names={}; uses={}; defs={}; out=[]
    body=[clean(l.rstrip('\n')) for l in lines]
    for l in body:
        for v in re.findall(r'%\d+',l.split('=',1)[1] if re.match(r'\s+%\d+ =',l) else l):
            uses[v]=uses.get(v,0)+1
    def sub(e):
        return re.sub(r'%\d+',lambda m:names.get(m.group(0),m.group(0)),e)
    for l in body:
        m=re.match(r'\s+(%\d+) = (.*)',l)
        if not m:
            out.append(sub(l)); continue
        v,rhs=m.groups()
        g=re.match(r'getelementptr inbounds %struct\.(\w+)\.\d+, p2 (%\d+), i64 0, i32 (\d+)',rhs)
        if g:
            st,base,i=g.groups(); i=int(i)
            nm={'GlassBackgroundUniforms':G,'GlassBackgroundUniformsExt':E,'SdfFragmentUniforms':SD}.get(st)
            names[v]='&'+(('u.' if st=='GlassBackgroundUniforms' else 'x.' if st.endswith('Ext') else 'sdf.')+nm[i] if nm else st+'.'+str(i)); continue
        g=re.match(r'load '+T+r', p2 (%\d+)',rhs)
        if g and names.get(g.group(1),'').startswith('&'):
            names[v]=names[g.group(1)][1:]; continue
        rhs=sub(rhs)
        rhs=re.sub(T+' ','',rhs)
        g=re.match(r'(fadd|fsub|fmul|fdiv|add|sub|mul|and|or|xor) (.+), ([^,]+)$',rhs)
        if g:
            op={'fadd':'+','fsub':'-','fmul':'*','fdiv':'/','add':'+','sub':'-','mul':'*','and':'&','or':'|','xor':'^'}[g.group(1)]
            e='(%s %s %s)'%(g.group(2),op,g.group(3))
        elif rhs.startswith('fneg '): e='(-%s)'%rhs[5:]
        elif re.match(r'fcmp (\w+) (.+), (.+)$',rhs):
            g=re.match(r'fcmp (\w+) (.+), (.+)$',rhs); e='(%s %s %s)'%(g.group(2),g.group(1),g.group(3))
        elif re.match(r'icmp (\w+) (.+), (.+)$',rhs):
            g=re.match(r'icmp (\w+) (.+), (.+)$',rhs); e='(%s i%s %s)'%(g.group(2),g.group(1),g.group(3))
        elif rhs.startswith('@air.'):
            g=re.match(r'@air\.([\w.]+)\((.*)\)$',rhs); fn=g.group(1)
            fn=re.sub(r'\.(v\d)?[fi]\d+$|\.v\d[fi]\d+$','',fn).replace('fast_','')
            e='%s(%s)'%(fn,g.group(2))
        elif rhs.startswith('extractelement'):
            g=re.match(r'extractelement (.+), (\d+)$',rhs); e='%s.%s'%(g.group(1),'xyzw'[int(g.group(2))])
        elif rhs.startswith('fpext') or rhs.startswith('fptrunc'):
            e=re.sub(r'^fp\w+ (.+) to \w+$',r'\1',rhs)
        else: e=rhs
        if uses.get(v,0)==1 and len(e)<140 and not e.startswith('phi') and 'sample_texture' not in e and 'compute_sdf' not in e:
            names[v]=e
        else:
            out.append('  %s = %s'%(v,e))
    return out
if __name__=='__main__':
    f=open(sys.argv[1]).read().split('\n'); a,b=int(sys.argv[2]),int(sys.argv[3])
    print('\n'.join(run(f[a-1:b])))
