import numpy as np,sys
from PIL import Image
a=np.array(Image.open(sys.argv[1]).convert('RGB')).astype(int)[...,1]
m=abs(a-120)>2; ys,xs=np.where(m)
# largest row-span = the platter
rows=np.where(m.sum(1)>200)[0]; y0,y1=rows.min(),rows.max()+1
cols=np.where(m[y0:y1].sum(0)>(y1-y0)*0.5)[0]; x0,x1=cols.min(),cols.max()+1
print(200+x0/2,900+y0/2,200+x1/2,900+y1/2)
