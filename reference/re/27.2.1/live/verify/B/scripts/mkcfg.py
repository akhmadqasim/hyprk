import json,os
V=os.path.dirname(os.path.abspath(__file__))
OFF={"inputBlurRadius":0,"inputBlurOpacity0":0,"inputBlurOpacity1":0,"inputBlurOpacity2":0,"inputBlurOpacity3":0,"inputFaceOpacity":0,
     "inputBleedOpacity":0,"inputRefractionOpacity":0,"inputKeyFillHighlightHeight":0,"inputShadowOpacity":0,"inputRingShadowOpacity":0,
     "inputBlurFillLightenOpacity":0,"inputBlurFillDarkenOpacity":0,"inputBlurFillNormalOpacity":0,"inputInnerRefractionAmount":0,
     "inputOuterRefractionAmount":0,"inputSDRShadowOpacity":0}
def cfg(name,pattern,views,mode='dark',size=(1040,640),origin=(40,60),secs=3.2,**kw):
    c=dict(mode=mode,pattern=pattern,origin=list(origin),size=list(size),secs=secs,dump=f'{V}/cap/{name}.json',views=views,**kw)
    json.dump(c,open(f'{V}/cfg/{name}.json','w'),indent=1)
def ov(**k):
    d=dict(OFF); d.update({('input'+a if not a.startswith('input') else a):b for a,b in k.items()}); return d
# 0: no glass, pattern readback
cfg('p0','grad',[])
# E1 inner refraction isolated
cfg('e1','grad',[
 dict(frame=[30,30,300,200],radius=40,variant=0,hideHighlight=True,override=ov(InnerRefractionHeight=20,InnerRefractionAmount=-60)),
 dict(frame=[360,30,300,200],radius=40,variant=0,hideHighlight=True,override=ov(InnerRefractionHeight=40,InnerRefractionAmount=-30)),
 dict(frame=[690,30,300,200],radius=40,variant=0,hideHighlight=True,override=ov(InnerRefractionHeight=20,InnerRefractionAmount=40)),
 dict(frame=[30,260,200,60],radius=30,variant=0,hideHighlight=True,override=ov(InnerRefractionHeight=15,InnerRefractionAmount=-30)),
 dict(frame=[260,260,240,240],radius=120,variant=0,hideHighlight=True,override=ov(InnerRefractionHeight=30,InnerRefractionAmount=-50)),
 dict(frame=[530,260,300,200],radius=0,variant=0,hideHighlight=True,override=ov(InnerRefractionHeight=20,InnerRefractionAmount=-60)),
 dict(frame=[30,350,200,120],radius=20,variant=0,hideHighlight=True,override=ov()),
])
# E2 outer refraction isolated (wide threshold band so the mix can be measured)
cfg('e2','grad',[
 dict(frame=[30,30,300,200],radius=40,variant=0,hideHighlight=True,override=ov(RefractionOpacity=1,RefractionDistance0=-10,RefractionDistance1=0,OuterRefractionHeight=48,OuterRefractionAmount=60)),
 dict(frame=[360,30,300,200],radius=40,variant=0,hideHighlight=True,override=ov(RefractionOpacity=1,RefractionDistance0=-1,RefractionDistance1=0,OuterRefractionHeight=48,OuterRefractionAmount=60)),
 dict(frame=[690,30,300,200],radius=40,variant=0,hideHighlight=True,override=ov(RefractionOpacity=0.6,RefractionDistance0=-20,RefractionDistance1=-10,OuterRefractionHeight=30,OuterRefractionAmount=-40)),
])
# real recipes over the gradient (no overrides) + dumps
real=[dict(frame=[30,30,300,200],radius=40,variant=0),
 dict(frame=[360,30,300,200],radius=40,variant=0,clear=True),
 dict(frame=[690,30,300,200],radius=40,variant=3),
 dict(frame=[30,260,300,200],radius=40,variant=9),
 dict(frame=[360,260,300,200],radius=12,variant=0,subvariant='menu'),
 dict(frame=[690,260,200,60],radius=30,variant=0),
 dict(frame=[690,340,200,36],radius=18,variant=0),
 dict(frame=[690,400,64,64],radius=32,variant=9),
 dict(frame=[780,400,120,64],radius=32,variant=9),
 dict(frame=[30,490,600,66],radius=22,variant=3),
 dict(frame=[660,490,300,120],radius=26,variant=10),
]
for m in ('dark','light'):
    cfg(f'real-grad-{m}','grad',real,mode=m)
    cfg(f'real-chk-{m}','checker:8',real,mode=m)
    cfg(f'real-grid-{m}','grid:16',real,mode=m)
    cfg(f'real-vs-{m}','vstripes:6',real,mode=m)
    cfg(f'real-cols-{m}','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',
        [dict(frame=[20+i*173,30+j*150,133,110],radius=30,variant=v,**({'clear':True} if cl else {}),**({'subvariant':'menu'} if j==3 else {})) for i in range(6) for j,(v,cl) in enumerate([(0,0),(0,1),(3,0),(0,0)])],mode=m)
print('ok')
import math
# ---- batch 2 (active window) ----
for m in ('dark','light'):
    cfg(f'a-grad-{m}','grad',real,mode=m); cfg(f'a-chk-{m}','checker:8',real,mode=m); cfg(f'a-vs-{m}','vstripes:6',real,mode=m)
    cfg(f'a-cols-{m}','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',
        [dict(frame=[20+i*173,30+j*150,133,110],radius=30,variant=v,**({'clear':True} if cl else {}),**({'subvariant':'menu'} if j==3 else {})) for i in range(6) for j,(v,cl) in enumerate([(0,0),(0,1),(3,0),(0,0)])],mode=m)
    DS=dict(KeyFillHighlightHeight=0.5,KeyFillHighlightAmount=0.4,KeyFillHighlightColorBias=-0.25,KeyFillHighlightEffectOffset=-0.5,KeyFillHighlightSpread=1.309,KeyFillHighlightSpreadSDR=1.309,KeyFillHighlightAngle=1.5708,
            InnerRefractionAmount=-0.001)
    rows=[dict(override=ov(InnerRefractionAmount=-0.001)),                         # highlight layer only
          dict(hideHighlight=True,override=ov(**DS)),                               # dark specular only, recipe values
          dict(hideHighlight=True,override=ov(**{**DS,'KeyFillHighlightHeight':8,'KeyFillHighlightEffectOffset':0,'KeyFillHighlightColorBias':-0.5})),
          dict(hideHighlight=True,override=ov(**{**DS,'KeyFillHighlightHeight':8,'KeyFillHighlightEffectOffset':0,'KeyFillHighlightColorBias':0.5,'KeyFillHighlightAngle':0.5236,'KeyFillHighlightAmount':0}))]
    cfg(f'hl-{m}','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',
        [dict(frame=[20+i*173,20+j*152,132,132],radius=66,variant=0,**r) for i in range(6) for j,r in enumerate(rows)],mode=m)
    # highlight layer with a wide key height so the profile is measurable
    rows2=[dict(override=ov(InnerRefractionAmount=-0.001),effect=dict(keyHeight=8,fillHeight=8,diffuseHeightScale=0)),
           dict(override=ov(InnerRefractionAmount=-0.001),effect=dict(keyHeight=8,fillHeight=8,diffuseHeightScale=0,keyAmount=1,fillAmount=1)),
           dict(override=ov(InnerRefractionAmount=-0.001),effect=dict(keyHeight=8,fillHeight=8,diffuseHeightScale=0,keyAmount=0.2,fillAmount=0.2,curvature=0)),
           dict(override=ov(InnerRefractionAmount=-0.001),effect=dict(keyAngle=0.7854,keySpread=0.5236,fillSpread=0.5236,keyHeight=8,fillHeight=4,diffuseHeightScale=3))]
    cfg(f'hl2-{m}','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',
        [dict(frame=[20+i*173,20+j*152,132,132],radius=66,variant=0,**r) for i in range(6) for j,r in enumerate(rows2)],mode=m)
cfg('e2b','grad',[
 dict(frame=[100,100,300,200],radius=40,variant=0,hideHighlight=True,layerKV=dict(marginWidth=84),override=ov(RefractionOpacity=1,RefractionDistance0=-10,RefractionDistance1=0,OuterRefractionHeight=48,OuterRefractionAmount=60,InnerRefractionAmount=-0.001)),
 dict(frame=[560,100,300,200],radius=40,variant=0,hideHighlight=True,layerKV=dict(marginWidth=84),override=ov(RefractionOpacity=0.6,RefractionDistance0=-1,RefractionDistance1=0,OuterRefractionHeight=48,OuterRefractionAmount=60,InnerRefractionAmount=-0.001)),
 dict(frame=[100,400,300,200],radius=40,variant=0,hideHighlight=True,override=ov(RefractionOpacity=1,RefractionDistance0=-10,RefractionDistance1=0,OuterRefractionHeight=48,OuterRefractionAmount=60,InnerRefractionAmount=-0.001)),
 dict(frame=[560,400,300,200],radius=40,variant=0),
])
# window position / inactive comparisons
cfg('pos-a','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',[dict(frame=[20+i*173,30,133,110],radius=30,variant=0) for i in range(6)]+[dict(frame=[40,180,960,60],radius=22,variant=3)],size=(1040,280),origin=(40,60))
cfg('pos-b','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',[dict(frame=[20+i*173,30,133,110],radius=30,variant=0) for i in range(6)]+[dict(frame=[40,180,960,60],radius=22,variant=3)],size=(1040,280),origin=(640,700))
cfg('pos-inactive','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',[dict(frame=[20+i*173,30,133,110],radius=30,variant=0) for i in range(6)]+[dict(frame=[40,180,960,60],radius=22,variant=3)],size=(1040,280),origin=(40,60),policy='accessory',activate=False)
print('ok2')
# ---- batch 3 ----
GEO=dict(BlurRadius=0,BlurOpacity0=0,BlurOpacity1=0,BlurOpacity2=0,BlurOpacity3=0,FaceOpacity=0,BleedOpacity=0,KeyFillHighlightHeight=0,ShadowOpacity=0,RingShadowOpacity=0,
         BlurFillLightenOpacity=0,BlurFillDarkenOpacity=0,BlurFillNormalOpacity=0,SDRShadowOpacity=0)
geo={('input'+k):v for k,v in GEO.items()}
rg=[dict(frame=[30,30,300,200],radius=40,variant=0),
    dict(frame=[360,30,300,200],radius=40,variant=0,clear=True),
    dict(frame=[690,30,300,200],radius=40,variant=3),
    dict(frame=[30,260,300,200],radius=40,variant=9),
    dict(frame=[360,260,200,60],radius=30,variant=0),
    dict(frame=[360,340,200,36],radius=18,variant=0),
    dict(frame=[360,400,200,24],radius=12,variant=0),
    dict(frame=[590,260,128,128],radius=64,variant=0),
    dict(frame=[750,260,96,96],radius=48,variant=0),
    dict(frame=[880,260,64,64],radius=32,variant=9),
    dict(frame=[30,490,600,66],radius=22,variant=3),
    dict(frame=[660,420,300,160],radius=26,variant=0,subvariant='menu')]
cfg('rg-dark','grad',[dict(v,hideHighlight=True,override=geo) for v in rg])
cfg('ptr','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',[dict(frame=[20+i*173,30,133,110],radius=30,variant=0) for i in range(6)]+[dict(frame=[40,180,960,60],radius=22,variant=3)],
    size=(1040,360),origin=(40,60),secs=11,
    controls=[dict(kind='glassButton',frame=[40,270,140,32],title='Glass'),dict(kind='switch',frame=[420,272,40,24],on=True),dict(kind='slider',frame=[560,272,200,24],value=0.5),
              dict(kind='glassButton',frame=[220,270,140,32],title='Glass 2')])
print('ok3')
# ---- batch 4 ----
KEEP_DS={k:v for k,v in geo.items() if k!='inputKeyFillHighlightHeight'}
for m in ('dark','light'):
    cfg(f'ds-{m}','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',
        [dict(frame=[20+i*173,20+j*152,132,132],radius=66,variant=v,hideHighlight=True,override=KEEP_DS,**({'clear':True} if cl else {})) for i in range(6) for j,(v,cl) in enumerate([(0,0),(3,0),(9,0),(0,1)])],mode=m)
    cfg(f'knob-{m}','cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220',[],mode=m,size=(1040,200),origin=(40,60),secs=9.5,dumpAt=[1.0,3.2,6.2],
        controls=[dict(kind='switch',frame=[400,40,54,24],on=False),dict(kind='switch',frame=[400,100,54,24],on=True),dict(kind='slider',frame=[560,40,300,24],value=0.5),
                  dict(kind='slider',frame=[40,40,300,24],value=0.3),dict(kind='switch',frame=[230,100,54,24],on=True),dict(kind='glassButton',frame=[40,120,140,32],title='Glass')])
ctl=[dict(frame=[30,30,128,80],radius=40,variant=20),dict(frame=[190,30,64,40],radius=20,variant=20),dict(frame=[290,30,38,24],radius=12,variant=20),
     dict(frame=[360,30,128,80],radius=40,variant=22),dict(frame=[520,30,64,40],radius=20,variant=22),dict(frame=[620,30,38,24],radius=12,variant=22),
     dict(frame=[690,30,128,80],radius=40,variant=21),dict(frame=[850,30,64,40],radius=20,variant=21),
     dict(frame=[30,150,256,160],radius=80,variant=20),dict(frame=[320,150,256,160],radius=80,variant=22),dict(frame=[610,150,256,160],radius=80,variant=21),
     dict(frame=[30,340,256,160],radius=80,variant=15),dict(frame=[320,340,256,160],radius=80,variant=14)]
cfg('ctl-grad','grad',ctl); cfg('ctl-chk','checker:4',ctl); cfg('ctl-vs','vstripes:3',ctl)
cfg('ctl-geo','grad',[dict(v,hideHighlight=True,override=geo) for v in ctl])
print('ok4')
# ---- batch 5: knob lens isolated over ramps ----
for pat in ('gradx','grady','cols:128,128,128','checker:2'):
    nm='lens-'+pat.split(':')[0]
    iso = pat.startswith('grad') or pat.startswith('checker')
    cfg(nm,pat,[],size=(700,160),origin=(40,60),secs=8.5,dumpAt=[3.0,5.5],
        controls=[dict(kind='switch',frame=[100,60,54,24],on=False,isolateLens=iso),dict(kind='slider',frame=[300,60,300,24],value=0.5,isolateLens=iso)])
print('ok5')
for pat in ('gradx','grady'):
    cfg('flat-'+pat,pat,[],size=(700,160),origin=(40,60),secs=8.5,dumpAt=[3.0,5.5],flatLens=True,
        controls=[dict(kind='switch',frame=[60,60,54,24],on=False,isolateLens=True),dict(kind='slider',frame=[300,60,300,24],value=0.5,isolateLens=True)])
# ---- batch 6: system UI over patterns ----
COLS='cols:0,0,0:64,64,64:128,128,128:255,255,255:200,60,40:40,90,220'
for pat,nm in (('grad','grad'),(COLS,'cols'),('solid:128,128,128','grey'),('solid:255,255,255','white')):
    cfg('sysdock-'+nm,pat,[],size=(830,147),origin=(440,960),secs=6.0,level='floating',policy='accessory',activate=False)
    cfg('syscc-'+nm,pat,[],size=(510,700),origin=(1200,34),secs=7.0,level='floating',policy='accessory',activate=False)
    cfg('sysmenu-'+nm,pat,[],size=(500,420),origin=(40,60),secs=4.5,popupMenu=[120,60])
    cfg('sysspot-'+nm,pat if nm!='grad' else 'vstripes:6',[],size=(900,400),origin=(400,150),secs=9.0,level='floating',policy='accessory',activate=False)
print('ok6')
