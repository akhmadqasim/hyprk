# Centre colour of glassBackground over a uniform backdrop, from the QuartzCore shader (glass_background_base) and
# CA::OGL::GlassBackgroundFilter::render uniform packing. Compares with probe captures (m/ramp/*.json + .png).
import json,glob,re,sys
import numpy as np
from PIL import Image
W709=np.array([.2126,.7152,.0722]); WB=np.array([.2125,.7154,.0721])
sat=lambda x: np.clip(x,0,1)
def ycc(c,black,white,s,fill=None):
    Y=c@W709; v=black+(white-black)*Y+s*(c-Y)
    if fill is not None and fill[3]>0: v=v*(1-fill[3])+np.array(fill[:3])*fill[3]
    return v
def model(c,g,hdr=0.0,bleed=True,boost=True,sdr=True):
    c=np.array(c,float)/255
    M=g['inputFaceColorMatrixMaxLuma']; Ms=g.get('inputFaceColorMatrixMaxLumaSDR',M)
    Me=Ms+(M-Ms)*hdr if sdr else M
    comp=1-min(max(Me,0),1)
    c1=c
    if comp>0:
        Y=c@W709; k=sat(1-Y*comp); c1=k*(Y+(1+(0.3*(1-k) if boost else 0))*(c-Y))
    f=ycc(c1,g['inputFaceColorMatrixBlack'],g['inputFaceColorMatrixWhite'],g['inputFaceColorMatrixSaturation'],g.get('inputFaceColorMatrixFillColor'))
    fo=min(max(g.get('inputFaceOpacity',1),0),1); f=c+(f-c)*fo
    bo=min(max(g.get('inputBleedOpacity',0),0),1)
    if bleed and bo>0:
        b=ycc(c,g.get('inputBleedColorMatrixBlack',0),g.get('inputBleedColorMatrixWhite',1),g.get('inputBleedColorMatrixSaturation',1))
        Yf=sat(f@WB); fac=Yf if g.get('inputBleedDarkenBlend') else 1-Yf
        w=(fac*fac*1.0)**2*bo
        f=f+(b-f)*w
    f=np.clip(f,-0.75,g.get('inputClamp',9) if g.get('inputClamp',0)>0 else 9)
    return np.clip(f,0,1)*255
if __name__=='__main__':
    rows=[]
    for fn in sorted(glob.glob('m/ramp/*.json')):
        m=re.match(r'm/ramp/([aL])([\d.]+)-ramp-(\d+)_(\d+)_(\d+)\.json',fn)
        if not m: continue
        p,a,r,gg,b=m.groups(); j=json.load(open(fn)); im=np.asarray(Image.open(fn[:-5]+'.png').convert('RGB')).astype(float)
        bgpx=im[6,6]
        for it in j['items']:
            x,y,w,h=[int(v) for v in it['rect']]; cx,cy=x+w//2,y+h//2
            reg=im[cy-10:cy+10,cx-30:cx+30].reshape(-1,3)
            g={('input'+k if not k.startswith('input') else k):v for k,v in it['glass'].items()}
            # flatness: point 12 pt inside the left edge, vertical centre (shadow/rim excluded)
            e=im[cy-6:cy+6,x+24-4:x+24+4].reshape(-1,3).mean(0)
            rows.append(dict(mode='dark' if p=='a' else 'light',a=a,name=it['name'],bg=[int(r),int(gg),int(b)],bgpx=[float(v) for v in bgpx],px=[float(v) for v in reg.mean(0)],sd=float(reg.std(0).max()),edge=[float(v) for v in e],g=g,scale=it['backdrop'].get('scale')))
    json.dump(rows,open('m/ramp-rows.json','w'))
    def stats(sel,**kw):
        e=[]
        for q in sel:
            mdl=model(q['bgpx'],q['g'],**kw); e.append(mdl-np.array(q['px']))
        e=np.array(e); return float(np.sqrt((e**2).mean())),float(np.abs(e).max())
    names=[]
    for q in rows:
        if q['name'] not in names: names.append(q['name'])
    out={}
    print('%-28s %-22s %-22s %s'%('item','shader model rms/max','no bleed','no SDR maxLuma + no chroma boost (old model)'))
    for mode in ['dark','light']:
        for n in names:
            for a in ['0','0.5','1']:
                sel=[q for q in rows if q['mode']==mode and q['name']==n and q['a']==a]
                if not sel: continue
                s1=stats(sel); s2=stats(sel,bleed=False); s3=stats(sel,bleed=False,boost=False,sdr=False)
                fl=max(np.abs(np.array(q['edge'])-np.array(q['px'])).max() for q in sel)
                out['%s %s a=%s'%(mode,n,a)]={'rms':round(s1[0],2),'max':round(s1[1],2),'rms_no_bleed':round(s2[0],2),'rms_old_model':round(s3[0],2),'max_old_model':round(s3[1],2),'n':len(sel),'edge_vs_centre_max':round(float(fl),2)}
                print('%-5s %-18s a=%-4s %5.2f / %5.2f   %5.2f / %5.2f   %5.2f / %5.2f   flat %.1f'%(mode,n,a,s1[0],s1[1],s2[0],s2[1],s3[0],s3[1],fl))
    json.dump(out,open('m/ramp-fit2.json','w'),indent=1)
