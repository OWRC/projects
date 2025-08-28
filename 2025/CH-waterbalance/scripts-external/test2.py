import os
import numpy as np
import scipy
import pandas as pd
from tqdm import tqdm


rcp = 'RCP85' # select emission scenario (options: RCP26, RCP45, RCP60, RCP85)
# grdpnts = [8598,8599,8600,8601,8602,8642,8643,8644,8645,8646,8670,8671,8672,8673,8674,8696,8697,8698,8699] # see ../GIS/OCDP/polygon9864-CH.shp

# # build mask
# msk = np.zeros(8964, dtype=bool)
# msk[np.array(grdpnts)-1] = True

# # collect OCDP-downloaded grid file paths
# fps = list()
# for root, _, files in os.walk('E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/scripts/output/OCDP/RCP85'):
#     for filename in files:
#         if filename.lower().endswith('.mat'): fps.append(os.path.join(root, filename))
    
# dtrng = pd.date_range(start="1981-01-01",end="2099-12-31")
# dtrng = dtrng[~((dtrng.month == 2) & (dtrng.day == 29))] # ignore leap days (https://github.com/pandas-dev/pandas/issues/56968)
# colnams = ["g"+str(i) for i in grdpnts]
# prcol, txcol, tncol = list(), list(), list()
# pbar = tqdm(total=len(fps))
# for fp in fps:
#     pbar.update()
#     fn = os.path.basename(fp)
#     pbar.set_description(fn)
#     stp = fn.split("_")
#     par = stp[0]
#     mdl = stp[2]
#     rcp = stp[3]

#     try:
#         mat = scipy.io.loadmat(fp)['outputData'][msk,:,:].astype(np.float32)
#     except:
#         continue

#     mat/=10.
#     mat = mat.transpose(0,2,1).reshape(len(grdpnts), -1)

#     df = pd.DataFrame(mat.T, columns=colnams, index=dtrng)
#     df.index.name='Date'

#     if par=='pr':
#         prcol.append(df)
#     elif par=='tasmin':
#         tncol.append(df)
#     elif par=='tasmax':
#         txcol.append(df)

# pbar.close()



import pickle
# with open('prcol.pkl', 'wb') as f: pickle.dump(prcol, f, protocol=pickle.HIGHEST_PROTOCOL)
# with open('tncol.pkl', 'wb') as f: pickle.dump(tncol, f, protocol=pickle.HIGHEST_PROTOCOL)
# with open('txcol.pkl', 'wb') as f: pickle.dump(txcol, f, protocol=pickle.HIGHEST_PROTOCOL)


with open('prcol.pkl','rb') as f: prcol = pickle.load(f)
with open('tncol.pkl','rb') as f: tncol = pickle.load(f)
with open('txcol.pkl','rb') as f: txcol = pickle.load(f)




# take the median projection and export to csv
def concatEnsemble(dfs): return pd.concat(dfs).groupby('Date').mean()

concatEnsemble(prcol).to_csv('E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/model_future_climate/dat/pr-median_'+rcp+".csv")
concatEnsemble(tncol).to_csv('E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/model_future_climate/dat/tasmin-median_'+rcp+".csv")
concatEnsemble(txcol).to_csv('E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/model_future_climate/dat/tasmax-median_'+rcp+".csv")


# print(len(prcol))
# print(type(prcol))
# print(prcol[0])

# df = (pd.concat(prcol)
#         .groupby('model')
#         .median()
#      )

# print(type(df))

# df = ensemble(prcol)
# df.to_csv('E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/model_future_climate/dat/precipitation_'+rcp+".csv")
# df = ensemble(tncol)
# df.to_csv('E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/model_future_climate/dat/tmin_'+rcp+".csv")
# df = ensemble(txcol)
# df.to_csv('E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/model_future_climate/dat/tmax_'+rcp+".csv")