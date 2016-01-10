library(RStoolbox)
library(raster)

setwd("C:/amsantac/PhD/Research/dissertation/data/landsat/images/2000/LE70040562000023EDC00")

img1 <- stack("L7004056_20000123_refl")
img1

ggRGB(img1)
ggRGB(img1, r=4, g=5, b=3)
ggRGB(img1)



plot(img2 > 0)

plot(is.na(img2))




system('python', args=(sprintf('"%1$s" "%2$s" -f "%3$s" "%4$s.shp"', 
                                pypath, rastpath, gdalformat, outshape)))

sprintf('"%1$s" "%2$s" -f "%3$s" "%4$s.shp"', pypath, rastpath, gdalformat, outshape)

# read the image
img2 <- raster("L7004056_20000123_raw", 2)

# reclassify the image
img3 <- img2 > 0

# write reclassified image to raster
system.time(writeRaster(img3, "footprint", "ENVI"))

#
owd <- getwd()

# write to shapefile
pypath <- Sys.which('gdal_polygonize.py')
polypath <- Sys.which('gdal_polygonize')
rastpath <- paste(owd, "footprint.envi", sep = "/")
gdalformat <- "ESRI Shapefile"
gdalformat <- "KML"
outshape <- paste(owd, "boundary1.kml", sep = "/")


on.exit(setwd(owd))
setwd(dirname(polypath))

system.time(system(paste(polypath, rastpath, "-f", gdalformat, outshape)))

