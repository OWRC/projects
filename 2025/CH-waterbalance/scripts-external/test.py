
import pandas as pd

def readRaven(fp, isaccumulated, warmup=24):
    # load data
    df = pd.read_csv(fp, skiprows=1, parse_dates=['month'], date_format="%Y-%m")
    df = df.iloc[warmup:, :-1] # drop warmup period and drop last column (..a Raven quirk)

    df['month'] = pd.to_datetime(df['month'])
    mdays = df['month'].dt.days_in_month
    df['month'] = df['month'].dt.month

    # drop columns
    df = df.drop(columns='time')
        
    # rename columns
    cols = [w.replace('mean.','').replace('cumulsum.','') for w in list(df.columns)]
    cols[1] = '0'
    df.columns = cols

    # change accumulation to discrete monthly values
    if isaccumulated:
        df2 = df.diff()
        df2 = df2.fillna(df)
        df2['month'] = df['month']
        df = df2
    # else:
    #     df.iloc[:,1:] = df.iloc[:,1:].multiply(mdays, axis="index")

    return df.groupby(['month']).mean().sum() # long-term mean


# def readRaven(fp, isaccumulated, warmup=24):
#     # load data
#     df = pd.read_csv(fp, skiprows=1, parse_dates=['month'], date_format="%Y-%m")
#     df = df.iloc[:, :-1] # drop warmup period and drop last column (..a Raven quirk)

#     df['month'] = pd.to_datetime(df['month'])
#     mdays = df['month'].dt.days_in_month
#     df['month'] = df['month'].dt.month

#     # drop columns
#     df = df.drop(columns='time')
        
#     # rename columns
#     cols = [w.replace('mean.','') for w in list(df.columns)]
#     cols[1] = '0'
#     df.columns = cols

#     # change accumulation to discrete monthly values
#     if isaccumulated:
#         df2 = df.diff()
#         df2 = df2.fillna(df)
#         df2['month'] = df['month']
#         df = df2
#     else:
#         df.iloc[:,1:] = df.iloc[:,1:].multiply(mdays, axis="index")
        
#     ddf = df.groupby(['month']).mean().sum().to_dict() # long-term mean
#     return {int(k)+1:v for k,v in ddf.items()}


prfx = 'M:\CH\Raven\Raven2025\output\Raven2025_'
dprecip = readRaven(prfx+'PRECIP_Monthly_CumulSum_ByHRU.csv',False)          # precipitation
daet = readRaven(prfx+'AET_Monthly_CumulSum_ByHRU.csv',False)                # evapotranspiration
dimpro = readRaven(prfx+'BETWEEN_PONDED_WATER_AND_SURFACE_WATER_Monthly_Average_ByHRU.csv',True) # impervious runoff
dprvro = readRaven(prfx+'TO_CONVOLUTION[0]_Monthly_CumulSum_ByHRU.csv',False) # pervious runoff
ddlyro = readRaven(prfx+'TO_CONVOLUTION[1]_Monthly_CumulSum_ByHRU.csv',False) # delayed runoff
dintflw = readRaven(prfx+'BETWEEN_SOIL[0]_AND_SURFACE_WATER_Monthly_Average_ByHRU.csv',True) # interflow
dbasflw = readRaven(prfx+'BETWEEN_SOIL[1]_AND_SURFACE_WATER_Monthly_Average_ByHRU.csv',True) # baseflow
drecharge = readRaven(prfx+'TO_SOIL[1]_Monthly_Average_ByHRU.csv',True)     # recharge

dconv0 = readRaven(prfx+'CONVOLUTION[0]_Monthly_Average_ByHRU.csv',False)
dconv1 = readRaven(prfx+'CONVOLUTION[1]_Monthly_Average_ByHRU.csv',False)
dsoil0 = readRaven(prfx+'SOIL[0]_Monthly_Average_ByHRU.csv',False)
dsoil1 = readRaven(prfx+'SOIL[1]_Monthly_Average_ByHRU.csv',False)




# print(dsoil0)

# print(dprecip)
# # print(daet)

wbal = dprecip-(daet+dimpro+dimpro+dprvro+ddlyro+dintflw+dbasflw)
# wbal['month']=dprecip['month']
sto = dconv0+dconv1+dsoil0+dsoil1
print(wbal)
print(sto)
# print(wbal+sto)


# for i,p in dprecip.items():
#     wbal = p - (daet[i]+drunoff[i]+drecharge[i])
#     sto = dconv0[i]+dconv1[i]+dsoil0[i]+dsoil1[i]
#     print(i, wbal, sto)


