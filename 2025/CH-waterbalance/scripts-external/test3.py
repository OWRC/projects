
import pandas as pd


fp = r"E:\OneDrive - Central Lake Ontario Conservation\@projects\2025\CH-waterbalance\delivery\model_future_climate_CSIRO-Mk3-6-0_RCP85\output\Raven2025_BETWEEN_SOIL[2]_AND_SURFACE_WATER_Monthly_Average_ByHRU.csv"
isaccumulated = True

df = pd.read_csv(fp, skiprows=1, parse_dates=['month'], date_format="%Y-%m")
df = df.iloc[:, :-1] # drop last column (..a Raven quirk)
df = df.drop(columns='time')

# change accumulation to discrete monthly values
if isaccumulated:
    df2 = df.diff()
    df2 = df2.fillna(df)
    df2['month'] = df['month']
    df = df2

dtCurrentBegin='1991-10-01'
dtCurrentEnd='2021-09-30'
dtFutureBegin='2041-10-01'
dtFutureEnd='2071-09-30'

dfcurrent = df[(df.month>=dtCurrentBegin) & (df.month<=dtCurrentEnd)]
dffuture =  df[(df.month>=dtFutureBegin) & (df.month<=dtFutureEnd)]

def reformat(df1):
    # rename columns
    cols = [w.replace('mean.','').replace('cumulsum.','') for w in list(df.columns)]
    cols[1] = '0'
    df1.columns = cols
    df1.index=df1['month']
    df1 = df1.drop(columns='month')



    # df1 = df1.mean().sum()/len(df)*12 # long-term mean
    return df1.mean(axis=0)*12 #{int(k)+1:v for k,v in df1.items()}

print(reformat(dfcurrent))
print(reformat(dffuture))