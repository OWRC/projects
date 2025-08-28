
import numpy as np
import pandas as pd
from functools import reduce
from datetime import datetime
from pymmio import files, ascii


# d = "climate/DataCurrent/rain-gauges"
# d = "climate/DataCurrent/snow"
d = "climate/DataCurrent/weather"


d = '2025/CH-waterbalance/dat/' + d

allpars = set()
dtbs, dtes = list(), list()
dcoll = dict()
for fp in files.dirList(d,".csv"):
    if d+"\\merged_" in fp: continue
    if "-reorg.csv" in fp: continue
    lns = ascii.readLines(fp)
    gag = fp[len(d)+len('\\Monitoring Network_Real Time Monitoring_'):-len('_Download_1_17_2025 5_38_43 PM.csv')]
    print(gag)
    print(fp)
    dtb = datetime.strptime(lns[4].split(',')[1], '%Y-%m-%d %H:%M:%S')
    dte = datetime.strptime(lns[5].split(',')[1], '%Y-%m-%d %H:%M:%S')
    print('  ',dtb, dte)
    dtbs.append(dtb)
    dtes.append(dte)
    pars = [' '.join(x.strip().replace('Â°','°').split()) for x in lns[9].split(',') if len(x)>0][1:]
    allpars.update(pars)
    print('  ',pars)
    for p in pars:
        if not p in dcoll: dcoll[p]=list()
    for i,p in enumerate(pars):
        dts, vls = list(), list()
        for j,ln in enumerate(lns):
            if j<11: continue
            sp = lns[j].split(',')
            dt = pd.to_datetime(sp[i*2])
            if pd.isnull(dt): continue
            dts.append(dt)
            svl = sp[i*2+1]
            if len(svl)==0: svl=np.nan 
            vls.append(float(svl))
        df = pd.DataFrame.from_dict({'Date':dts, 'station':gag, p:vls}).set_index('Date')
        dcoll[p].append(df)


for par, lst in dcoll.items():
    if 'Voltage' in par: continue
    if 'Battery' in par: continue
    if 'Pump' in par: continue
    print(par)
    # df = reduce(lambda df1,df2: pd.merge(df1,df2,how='outer',on='Date'), lst) # station by column
    df = pd.concat(lst, axis=0)
    print(d+'/merged_'+par+'.csv')
    df.to_csv(d+'/merged_'+par+'.csv')


print('\nSummary:')
print(' >> all parameters collected: ',list(allpars))
print(' >> date range {} to {}'.format(min(dtbs),max(dtes)))