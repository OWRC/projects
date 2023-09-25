
# import numpy as np

# ccnt = np.fromfile("M:/OWRC-RDRR/build/dem/owrc20-50-noGreatLake-HC-observations-trim-FINAL-cascade_count.bil", np.int32).reshape(2500, 2, -1, 2).swapaxes(1,2).reshape(-1, 2*2)
# # 
# ccnt = np.array([max(a) for a in ccnt])
# print(ccnt)


from pyGrid import definition

gdYT3 = definition.GDEF("M:/model_archive/0018/10_operational_model/YT3ss.gdef")


gdTEGWFM18 = definition.GDEF("O:/internal/TRCA/TEGWFM18/TRCA_expansion.gdef")
c0 = int((gdTEGWFM18.xul-gdYT3.xul)/100)
r0 = -int((gdTEGWFM18.yul-gdYT3.yul)/100)

print(c0)
print(r0)
print(c0+gdTEGWFM18.ncol)
print(r0+gdTEGWFM18.nrow)