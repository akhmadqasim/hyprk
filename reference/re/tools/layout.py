# Field-offset maps for GlassMaterialProvider.Spec and .Parameters (macOS 27.2.1), computed from
# __swift5_fieldmd field order + Swift layout rules, anchored on decompiled writes (see NOTES.md).
F=('f',4,4); D=('d',8,8); B=('b',1,1)
def S(*fields, xi=False):   # struct; xi: has extra inhabitants (Optional adds no tag byte)
    return ('s',fields,xi)
def Opt(t): return ('o',t)
def size_align(t):
    if t[0] in 'fdb': return t[1],t[2]
    if t[0]=='raw': return t[1],t[2]
    if t[0]=='o':
        s,a=size_align(t[1]); return (s if has_xi(t[1]) else s+1),a
    off=0;al=1
    for n,ft in t[1]:
        s,a=size_align(ft); off=(off+a-1)//a*a+s; al=max(al,a)
    return off,al
def has_xi(t):
    if t[0]=='b': return True
    if t[0]=='raw': return t[3]
    if t[0]=='s': return t[2] or any(has_xi(ft) for n,ft in t[1])
    return False
def flat(t,base=0,prefix='',out=None):
    out={} if out is None else out
    if t[0]=='o':
        flat(t[1],base,prefix,out)
        if not has_xi(t[1]): out[base+size_align(t[1])[0]]=prefix+'?nil'
        return out
    if t[0]!='s': out[base]=prefix; return out
    off=0
    for n,ft in t[1]:
        s,a=size_align(ft); off=(off+a-1)//a*a
        flat(ft,base+off,(prefix+'.' if prefix else '')+n,out); off+=s
    return out
def raw(s,a,xi=False): return ('raw',s,a,xi)
FILL=S(('r',F),('g',F),('b',F),('a',F))
YCC=S(('black',F),('white',F),('saturation',F),('normalFill',Opt(FILL)),('dodgeFill',Opt(FILL)),('burnFill',Opt(FILL)))
def tup(n,t): return S(*[(str(i),t) for i in range(n)])
PSF=raw(0x2a,8)   # ParameterScale<CGFloat,Float>: 5 words + 2 tag bytes; constant = value in word 0
PSD=raw(0x3a,8)   # ParameterScale<CGFloat,CGFloat>
RANGE=S(('lo',D),('hi',D))
DIST=S(('v',F),('kind',B))   # Spec.Blur.Distance enum: float payload + case byte (0 fixed,1 inset,2 outset)
P_SPEC=S(('height',D),('opacity',F),('spread',D),('curvature',D),('amount',D),('ycc',YCC),('offset',D))
P_FACE=S(('opacity',F),('ycc',YCC),('maxLuminance',F),('maxLuminanceSDR',F))
P_LENS=S(('refractionHeight',F),('refractionAmount',F),('refractionInset',F),('aberrationHeight',F),('aberrationAmount',F),('aberrationInset',F),('aberrationAngle',D),('edgeDistances',tup(2,F)),('edgeOpacities',tup(2,F)))
P_SDR=S(('headroomTransitionPoint',F),('shadowOpacityShift',F),('faceDimming',S(('whitePointShift',F),('distances',tup(2,D)))))
PARAMS=S(('backdropScale',F),('updateRate',D),('platterOpacity',F),('contentOpacity',F),
 ('shadow',Opt(S(('offset',tup(2,D)),('amount',D),('height',D),('inset',D),('blurRadius',D),('shadowRadius',D),('ycc',YCC),('opacity',F),('vibrancyContribution',D)))),
 ('blur',Opt(S(('radius',F),('distances',tup(4,F)),('opacities',tup(4,F)),('opacity',F)))),
 ('refraction',Opt(S(('innerHeight',D),('innerAmount',D),('outerHeight',D),('outerAmount',D),('outerDistances',tup(2,D)),('outerOpacity',F)))),
 ('faceEffects',Opt(P_FACE)),
 ('edgeBleed',Opt(S(('amount',D),('height',D),('blurRadius',D),('opacity',F),('distances',tup(2,F)),('ycc',YCC),('useDarkenBlending',B)))),
 ('tinting',Opt(S(('opacity',F),('distances',tup(3,F))))),
 ('highlights',Opt(S(('hdr',F),('inset',D),('key',P_SPEC),('fill',P_SPEC),('diffuse',S(('heightScale',F),('spreadScale',F),('amountScale',F))),('blend',B)))),
 ('blurFill',Opt(S(('blurRadius',F),('lightenOpacity',F),('darkenOpacity',F),('normalOpacity',F)))),
 ('ringShadow',Opt(S(('verticalOffset',D),('strokeWidth',D),('blurRadius',D),('opacity',F),('maskAmount',D)))),
 ('darkSpecular',Opt(S(('height',D),('angle',D),('spread',D),('spreadSDR',D),('amount',D),('effectOffset',D),('colorBias',D)))),
)
SPEC=S(('backdropScale',raw(0x10,8)),
 ('shadow',S(('normalizedHeight',D),('normalizedAmount',D),('blurRadius',D),('opacity',PSF),('shadowRadius',PSD),('offset',tup(2,D)),('ycc',YCC),('vibrancyContribution',PSD))),
 ('blur',S(('opacity',F),('opacities',tup(4,F)),('distances',tup(4,DIST)),('blurRadius',PSF),('outerRefractionBlurRadius',Opt(F)))),
 ('refraction',S(('normalizedInnerHeight',D),('innerHeightRange',RANGE),('normalizedInnerAmount',D),('innerAmountRange',RANGE),('normalizedOuterHeight',D),('outerHeightRange',RANGE),('normalizedOuterAmount',D),('outerAmountRange',RANGE),('outerOpacity',F))),
 ('edgeBleed',S(('opacity',PSF),('normalizedHeight',D),('normalizedAmount',D),('normalizedBlurRadius',D),('maxBlurRadius',D),('ycc',YCC))),
 ('faceEffect',P_FACE),
 ('highlights',S(('inset',D),('white',F),('keyOpacity',F),('fillOpacity',F),('keyHeight',PSD),('fillHeight',PSD),('keyYCC',YCC),('fillYCC',YCC),('keyOffset',D),('fillOffset',D),('spread',PSD),('amount',D),('curvature',D),('diffuseHeightScale',F),('diffuseSpreadScale',F),('diffuseAmountScale',F))),
 ('blurFill',S(('blurRadius',F),('lightenOpacity',F),('darkenOpacity',F),('normalOpacity',F))),
 ('ringShadow',S(('verticalOffset',D),('strokeWidth',D),('blurRadius',D),('opacity',F),('maskAmount',D))),
 ('darkSpecular',S(('height',D),('spread',D),('spreadSDR',D),('amount',D),('effectOffset',D),('colorBias',D))),
)
MAPS={'spec':flat(SPEC),'params':flat(PARAMS)}
if __name__=='__main__':
    import sys
    for o,n in sorted(MAPS[sys.argv[1]].items()): print(hex(o),n)
