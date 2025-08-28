
import pymmio.files as mmio


for fp in mmio.dirList('rain-gauges'):
    gag = fp.replace('rain-gauges\Monitoring Network_Real Time Monitoring_','')[:-len('_Download_1_17_2025 6_13_07 PM.csv')] #len('_1_17_2025 6_13_07 PM.csv')]
    print(gag)
