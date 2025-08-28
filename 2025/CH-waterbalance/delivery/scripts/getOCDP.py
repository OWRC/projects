import os
import scipy
import numpy as np
import pandas as pd
import pickle
import requests
import matplotlib.pyplot as plt
from tqdm import tqdm


## Data source information
# https://lamps.math.yorku.ca/OntarioClimate/index_app_data.htm#/DailyPrDataOnGrid
# https://lamps.math.yorku.ca/OntarioClimate/DS_CMIP5/LAMPS_YorkU/OCDP/_build/html/introduction.html
#  CMIP5: Coupled Model Intercomparison Project Phase 5 (we are now at CMIP6) https://pcmdi.llnl.gov/mips/cmip5/
#  LAMPS: LAboratory of Mathematical Parallel Systems (LAMPS) of Department of Mathematics and Statistics, York University, Ontario, Canada.



rcp = 'RCP85' # select emission scenario (options: RCP26, RCP45, RCP60, RCP85)
outdir = 'E:/OneDrive - Central Lake Ontario Conservation/@projects/2025/CH-waterbalance/delivery/scripts/output/OCDP/'


# GCMs available as of 2024-11-46
mdls = ['NorESM1-M', 'MRI-ESM1', 'MRI-CGCM3', 'MPI-ESM-MR', 'MPI-ESM-LR', 'MIROC-ESM', 'MIROC-ESM-CHEM', 'MIROC5', 
        'IPSL-CM5B-LR', 'IPSL-CM5A-MR', 'IPSL-CM5A-LR', 'inmcm4', 'HadGEM2-ES', 'HadGEM2-CC', 
        'GFDL-ESM2M', 'GFDL-ESM2G', 'GFDL-CM3', 'FGOALS-g2', 'EC-EARTH', 'CSIRO-Mk3-6-0', 'CNRM-CM5', 
        'CMCC-CMS', 'CMCC-CM', 'CMCC-CESM', 'CESM1-BGC', 'CCSM4', 'CanESM2', 'BNU-ESM', 'bcc-csm1-1', 
        'bcc-csm1-1-m', 'ACCESS1-3', 'ACCESS1-0']




# STEP 1: download grid files from OCDP API
#  takes roughly 20 minutes and downloads ~20GB per emission scenario
if not os.path.exists(outdir): os.makedirs(outdir)
if not os.path.exists(outdir+rcp): os.makedirs(outdir+rcp)
for par in [('Tasmax','tasmax'), ('Tasmin','tasmin'), ('Pre','pr')]:
    print(' >> downloading '+par[0])
    pbar = tqdm(total=len(mdls))
    for mdl in mdls:
        pbar.update() 
        pbar.set_description(mdl)        
        fn = '/{}_LAMPS_{}_{}_8964X365X119.mat'.format(par[1],mdl,rcp) # "8964X365X119" refers to 8964 grid cells X 365 days X 119 years 1981-2099 inclusive; files are in matlab format (.mat)
        if not os.path.exists(outdir+rcp+fn):
            url = 'https://lamps.math.yorku.ca/OntarioClimate/DS_CMIP5/LAMPS_YorkU/Grids/{}/{}/{}'.format(par[0],rcp,fn)
            req = requests.get(url)
            open(outdir+rcp+fn,'wb').write(req.content)
    pbar.close()



# STEP 2: collect subset of grid points that cover study area and extract model projections (see ../GIS/OCDP/polygon9864-CH.shp)
#  takes roughly 5 minutes to process, converts data into python binaries (i.e., "pickles")
grdpnts = [8598,8599,8600,8601,8602,8642,8643,8644,8645,8646,8670,8671,8672,8673,8674,8696,8697,8698,8699] 

# build mask
msk = np.zeros(8964, dtype=bool)
msk[np.array(grdpnts)-1] = True

# collect OCDP-downloaded matlab grid file paths
fps = list()
for root, _, files in os.walk(outdir+rcp):
    for filename in files:
        if filename.lower().endswith('.mat'): fps.append(os.path.join(root, filename))
    
dtrng = pd.date_range(start="1981-01-01",end="2099-12-31")
dtrng = dtrng[~((dtrng.month == 2) & (dtrng.day == 29))] # ignore leap days (https://github.com/pandas-dev/pandas/issues/56968)
colnams = ["g"+str(i) for i in grdpnts]
prcol, txcol, tncol = list(), list(), list()
pbar = tqdm(total=len(fps))
for fp in fps:
    pbar.update()
    fn = os.path.basename(fp)
    pbar.set_description(fn)
    stp = fn.split("_")
    par = stp[0]
    mdl = stp[2]
    rcp = stp[3]

    try:
        mat = scipy.io.loadmat(fp)['outputData'][msk,:,:].astype(np.float32)
    except:
        continue

    mat/=10. # data are converted from integers to decimals
    mat = mat.transpose(0,2,1).reshape(len(grdpnts), -1)

    df = pd.DataFrame(mat.T, columns=colnams, index=dtrng)
    df.index.name='Date'
    df['model'] = mdl

    if par=='pr':
        prcol.append(df)
    elif par=='tasmin':
        tncol.append(df)
    elif par=='tasmax':
        txcol.append(df)

pbar.close()

# save grid subset as binaries
with open(outdir+rcp+'/pr-subset.pkl', 'wb') as f: pickle.dump(pd.concat(prcol), f, protocol=pickle.HIGHEST_PROTOCOL)
with open(outdir+rcp+'/tasmin-subset.pkl', 'wb') as f: pickle.dump(pd.concat(tncol), f, protocol=pickle.HIGHEST_PROTOCOL)
with open(outdir+rcp+'/tasmax-subset.pkl', 'wb') as f: pickle.dump(pd.concat(txcol), f, protocol=pickle.HIGHEST_PROTOCOL)



# # STEP 3: Compares model projections between 2 time periods and outputs to csv -- for scenario selection
# following: EBNFLO Environmental and AquaResource Inc., 2010. Guide for Assessment of Hydrologic Effects of Climate Change in Ontario. 234pp.
with open(outdir+rcp+'/pr-subset.pkl','rb') as f: prcol = pickle.load(f)
with open(outdir+rcp+'/tasmin-subset.pkl','rb') as f: tncol = pickle.load(f)
with open(outdir+rcp+'/tasmax-subset.pkl','rb') as f: txcol = pickle.load(f)

# function returns the average deviation from 2 time periods, on a per model basis
def getDelta(df, dtbaselineBegin='1991-10-01', dtbaselineEnd='2021-09-30', dtfutureBegin='2041-10-01', dtfutureEnd='2071-09-30'):
    dtbaseline = (df.index >= dtbaselineBegin) & (df.index <= dtbaselineEnd)
    dtfuture = (df.index >= dtfutureBegin) & (df.index <= dtfutureEnd)
    return df.loc[dtfuture].groupby('model').mean().mean(axis=1) - df.loc[dtbaseline].groupby('model').mean().mean(axis=1)

prdel = getDelta(prcol)*365.24
tndel = getDelta(tncol)
txdel = getDelta(txcol)
tmdel = (txdel+tndel)/2 # mean temperature

df = pd.DataFrame([prdel,tmdel]).T.rename(columns={0:'mean annual precipitation change (mm)', 1:'mean annual temperature change (°C)'})
df.plot.scatter(x='mean annual temperature change (°C)', y='mean annual precipitation change (mm)')
plt.show()
df.to_csv(outdir+rcp+'/model-deltas.csv')