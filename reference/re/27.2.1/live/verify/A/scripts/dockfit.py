import json,sys,numpy as np
f=sys.argv[1]; d=json.load(open(f)); t=np.array(d['t']); y=np.array(d['offset_pt']); e=np.array(d['ssd']); tile=d['tile']
L=d['launch']; t0=L['t0']; te=L['t_end']+0.017
# use full bounces after the first one (the first overlaps the tile insertion)
m=(t>=t0+0.7)&(t<=te+0.1)&(e<50)
tt=t[m]; yy=np.round(y[m]*2)/2
def par(tt,P,H,t0):
    u=np.mod(tt-t0,P)/P; return H*4*u*(1-u)
out={}
for name,Q in (('none',lambda v:v),('round_pt',np.round),('floor_pt',np.floor),('ceil_pt',np.ceil),('round_px',lambda v:np.round(v*2)/2)):
    best=None
    for P in np.arange(0.697,0.7031,0.0005):
        for H in np.arange(tile*0.2+3,tile*0.2+7.01,0.05):
            for s in np.arange(-0.03,0.0301,0.002):
                mod=Q(par(tt,P,H,t0+s)); mod=np.where(tt<=t0+s+P*np.round((te-t0)/P)+1e-6,mod,0)
                r=np.sqrt(np.mean((mod-yy)**2))
                if best is None or r<best[0]: best=(r,P,H,t0+s)
    out[name]={'rms_pt':round(float(best[0]),3),'period':round(float(best[1]),4),'H':round(float(best[2]),2)}
    print(name,out[name])
# range of H with rms within +0.02 of best for round_pt at P=0.7
for name,Q in (('round_pt',np.round),):
    rs=[]
    for H in np.arange(tile*0.2+3,tile*0.2+7.01,0.05):
        b=min(np.sqrt(np.mean((np.where(tt<=t0+s+0.7*np.round((te-t0)/0.7)+1e-6,Q(par(tt,0.7,H,t0+s)),0)-yy)**2)) for s in np.arange(-0.03,0.0301,0.002))
        rs.append((H,b))
    mn=min(b for H,b in rs); ok=[H for H,b in rs if b<=mn+0.02]
    print('P=0.7 round_pt: best rms %.3f, H range within +0.02: %.2f..%.2f'%(mn,min(ok),max(ok)))
    for R in (tile,tile+2,round(tile*1.0625),tile+4):
        H=(R-8)*0.2+6
        b=min(np.sqrt(np.mean((np.where(tt<=t0+s+0.7*np.round((te-t0)/0.7)+1e-6,Q(par(tt,0.7,H,t0+s)),0)-yy)**2)) for s in np.arange(-0.03,0.0301,0.002))
        print('  code with rectH=%g -> H=%.2f: rms %.3f pt'%(R,H,b))
    out['code_round']={'rms_best':round(float(mn),3),'H_lo':round(float(min(ok)),2),'H_hi':round(float(max(ok)),2)}
print('n frames',len(tt),'bounces fitted',round((te-t0)/0.7,2),'distinct offsets',sorted(set(yy.tolist())))
d['launch_fit_quantised']=out; json.dump(d,open(f,'w'))
