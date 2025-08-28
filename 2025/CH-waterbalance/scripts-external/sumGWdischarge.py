
import numpy as np
import shapefile
from simpledbf import Dbf5
import flopy.utils.binaryfile as bf
from shapely.geometry import Polygon


# # import MODFLOW model cell to CH sub-basin cross-reference
# df = Dbf5("M:/@projects/2025/CH-waterbalance/delivery/GIS/SHModel-CH_310_centroids.dbf").to_dataframe().dropna().astype('int32')
# dsws = dict(zip(df['CellID'], df['SubId']))
# for i in range(885*890):
#     if i in dsws: continue
#     dsws[i]=-9999
# dsws = dict(sorted(dsws.items()))
# sws = np.array(list(dsws.values()),dtype=np.int16).reshape((885,890))
# # sws.tofile("..GIS/SHModel-CH_310_SubId.bil")
# # print(sws)


# import sws areas
sf = shapefile.Reader("M:/@projects/2025/CH-waterbalance/delivery/GIS/CH_Subwatershed_select.shp")
geom = sf.shapes()
attr = sf.records()
for i in range(len(geom)):
    plgn = Polygon(geom[i].points)
    print(plgn.area/attr[i]['BasArea'])
pass


# # Load MODFLOW output steady-state fluxes
# flx = bf.CellBudgetFile("M:/CH/MODFLOW/SHModel-CH_310/SHModel-CH_310.flx")
# print(flx.headers)

# rdrn = flx.get_data(kstpkper=(0,0), text='DRAINS', full3D=True)
# adrn = np.sum(np.array(rdrn[0]), axis=0)
# rriv = flx.get_data(kstpkper=(0,0), text='RIVER LEAKAGE', full3D=True)
# ariv = np.sum(np.array(rriv[0]), axis=0)

# a = -(adrn+ariv)*365.24
# # a.tofile("M:/CH/MODFLOW/SHModel-CH_310/SHModel-CH_310.flx.bil")

# for sid in set(dsws.values()):
#     if sid==-9999: continue
#     print(sid, np.sum(a[sws==sid]))






# # OLD
# import numpy as np
# import pandas as pd
# import shapefile

# gwdfp = "M:/CH/MODFLOW/SHModel-CH_310-NWT/SHModel-CH_310-NWT.flx-RIVDRNSFRUZF.bil"
# swsfp = "M:/@projects/2025/CH-waterbalance/shp/gauged-watersheds.shp"
# swsTocid = "M:/@projects/2025/CH-waterbalance/shp/gauged-watersheds_To_SHModel-CH_310-cellID.xlsx"

# gwd = np.fromfile(gwdfp,np.float32).reshape((885,890))
# idx = np.arange(885*890).reshape(gwd.shape)
# swssf = shapefile.Reader(swsfp)


# # print(swssf.fields)
# geom = swssf.shapes()
# attr = swssf.records()
# darea = dict()
# for i in range(len(geom)): darea[attr[i].layer] = attr[i].area

# for gauge,area in darea.items():
#     cxy = list(pd.read_excel(open(swsTocid, 'rb'),sheet_name=gauge).CellID)
#     msk = np.isin(idx, cxy)
#     gmsk = gwd[msk]
#     print(gauge, np.sum(gmsk[gmsk>0])*86.4*365.24/area)

