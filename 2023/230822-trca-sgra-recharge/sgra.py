


import numpy as np
from pyGrid import definition, real


gdTEGWFM18 = definition.GDEF("O:/internal/TRCA/TEGWFM18/TRCA_expansion.gdef")

def readasc(fp):
    header_rows = 6 # six rows for header information
    header = {} # store header information including ncols, nrows, xllcorner, yllcorner, cellsize, NODATA_value
    row_ite = 1
    with open(fp, 'rt') as file_h:
        for line in file_h:
            if row_ite <= header_rows:
                line = line.split(" ", 1)
                header[line[0]] = float(line[1])
            else:
                break
            row_ite = row_ite+1
    # read data array
    return(np.asarray(np.loadtxt(fp, skiprows=header_rows, dtype='float64')))


rch = readasc("O:/internal/TRCA/TEGWFM18/input_MFNWT/TRCA_expansion_RCH.asc")
# rch *= 365.25*1000.

msk = np.fromfile("raster/TRCA-mask.bil",dtype=np.int32).reshape(rch.shape)


meanrch = np.mean(rch[np.logical_and(rch>0, msk>0)])
print(meanrch)

sgra = np.zeros(rch.shape, dtype=np.int32)
sgra[np.logical_and(rch>meanrch, msk>0)]=1

sgra.tofile("raster/TEGWFM18_sgra.bil")
gdTEGWFM18.saveBitmap("img/TEGWFM18_sgra.png", sgra.reshape(gdTEGWFM18.shape()))