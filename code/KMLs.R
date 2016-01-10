library(rgdal)

setwd("C:/amsantac/PhD/Research/dissertation/data/shps")
shp <- readOGR("llanos_wrs2_desc_nonoverlap.shp", "llanos_wrs2_desc_nonoverlap")
writeOGR(shp, "kml/llanos_wrs2_desc_nonoverlap.KML", "llanos_wrs2_desc_nonoverlap", driver="KML")

setwd("C:/amsantac/PhD/Research/dissertation/processing/other/testing")
shp <- readOGR("testing_757_2000.shp", "testing_757_2000")
writeOGR(shp, "kmls/testing_757_2000_v1.KML", "testing_757_2000_v1", driver="KML")

setwd("C:/amsantac/PhD/Research/dissertation/processing/other/testing")
shp <- readOGR("testing_757_2000_v2_longlat.shp", "testing_757_2000_v2_longlat")
writeOGR(shp, "kmls/testing_757_2000_v2.KML", "testing_757_2000_v2", driver="KML")

setwd("C:/amsantac/PhD/Research/dissertation/processing/other/testing")
shp <- readOGR("testing_757_2000_v2.shp", "testing_757_2000_v2")
writeOGR(shp, "kmls/testing_757_2000_v3.KML", "testing_757_2000_v3", driver="KML")
