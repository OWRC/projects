

import pickle
import numpy as np
from pyproj import Transformer
from pyGrid.definition import GDEF
from tqdm import tqdm



# gdFrom = GDEF("M:/CH/Raven/Raven2025.gdef")
# gdTo = GDEF("M:/CH/MODFLOW/SHModel-CH_310/SHModel-CH_310.gdef")
# ofp = "E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/scripts/supp/Raven2025_to_SHModel-CH_310_map.pkl"
# transformer = Transformer.from_crs("EPSG:26917","EPSG:3161")

gdFrom = GDEF("M:/CH/MODFLOW/SHModel-CH_310/SHModel-CH_310.gdef")
gdTo = GDEF("M:/CH/Raven/Raven2025.gdef")
ofp = "E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/scripts/supp/SHModel-CH_310_to_Raven2025_map.pkl"
transformer = Transformer.from_crs("EPSG:3161","EPSG:26917")


dens = 5. # this brute-force algorithm creates a set of dens^2 points within the "From" cell and uses those points to intersect with the "To" cells.



def getToCell(x,y): return gdFrom.pointToCellID([x,y])
vgetToCell = np.vectorize(getToCell)
def collectToFrom():
    # xFrom, yFrom, cTo, cFrom, sc = list(), list(), list(), list(), 0
    toFrom = dict()
    with tqdm(total=len(gdTo.crc)) as pbar:
        for cid, rc in gdTo.crc.items():
            pbar.update()
            cl = gdTo.CellLeft(rc[0],rc[1])
            cr = gdTo.CellRight(rc[0],rc[1])
            ct = gdTo.CellTop(rc[0],rc[1])
            cb = gdTo.CellBottom(rc[0],rc[1])
            nx = int((cr-cl)*0.999/dens)
            ny = int((ct-cb)*0.999/dens)
            x0 = ((cr-cl) - nx*dens)/2
            y0 = ((ct-cb) - ny*dens)/2
            ax = np.repeat(np.arange(0,nx+1,1)*dens+x0+cl,ny+1)
            ay = np.tile(np.arange(0,ny+1,1)*dens+y0+cb,nx+1)
            ax, ay = transformer.transform(ax, ay)
            cidFrom = vgetToCell(ax, ay)
            rows, counts = np.unique(cidFrom, axis=0, return_counts=True)
            toFrom[cid] = dict(zip(rows.astype(np.int32), (counts/np.sum(counts)).astype(np.float32)))     

    #         xFrom.extend(ax)
    #         yFrom.extend(ay)
    #         cTo.extend([cid]*len(cidFrom))
    #         cFrom.extend(list(cidFrom))
    #         sc+=1
    #         if sc>10: break

    # with open(ofp+"-scatter.csv","w") as f:
    #     f.write("cidFrom,cidTo,x,y\n")
    #     for i, cf in enumerate(cFrom):
    #         f.write("{},{},{},{}\n".format(cf,cTo[i],xFrom[i],yFrom[i]))  
    
    return toFrom

ft = collectToFrom()
with open(ofp, 'wb') as f: pickle.dump(ft, f, protocol=pickle.HIGHEST_PROTOCOL)