
import pandas as pd
import shapefile

sf = shapefile.Reader("shp/PDEM-South-D2013-OWRC23-60-HC-sws10-clip.shp")
fields = [x[0] for x in sf.fields][1:]
records = [y[:] for y in sf.records()]
df = pd.DataFrame(columns=fields, data=records)
# print(df)

for index, row in df.iterrows():
    url = 'https://fews.oakridgeswater.ca/dymetp/{}'.format(int(row['oid']))
    print(url)
    df = pd.read_json(url)
    print(df)
    break