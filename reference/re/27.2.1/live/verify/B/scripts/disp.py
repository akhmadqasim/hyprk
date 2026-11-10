import numpy as np
from PIL import Image
def load(p): return np.array(Image.open(p).convert('RGB')).astype(float)
def dispfield(im):
    H,W,_=im.shape
    ys,xs=np.mgrid[0:H,0:W]
    dx=((im[...,0]-(xs&255)+128)%256)-128
    dy=((im[...,1]-(ys&255)+128)%256)-128
    return dx,dy
def model(depth_pt,h,A):
    t=np.clip(depth_pt/h,0,1)
    return A*(1-np.sqrt(np.clip((2-t)*t,0,1)))
