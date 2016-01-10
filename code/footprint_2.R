library(raster)
setwd("/home/user/shared/images/2000")
setwd("/home/user/shared/images/2013")
dir.create("shps")
filelist1 <- list.files(pattern = 'raw', full.name = TRUE, recursive = TRUE)
filelist2 <- grep(pattern = 'raw.hdr', filelist1, invert = TRUE, value = TRUE)

for (img in filelist2){
  
  print(paste0("Processing image ", strsplit(img, "/")[[1]][3]))
  
# read the image
img1 <- raster(img, 4)

# reclassify the image
img2 <- img1 > 0

# write reclassified image to raster
writeRaster(img2, "footprint", "ENVI", overwrite = TRUE)

# write to shapefile
pypath <- Sys.which('gdal_polygonize.py')

system(paste(pypath, "footprint.envi -f KML boundary.kml"))

# read kml to subset only the footprint polygon
spdf <- readOGR("boundary.kml", "out")

spdf2 <- subset(spdf, Name == 1)

# save the polygon as shp
writeOGR(spdf2, paste0("shps/", strsplit(img, "/")[[1]][3], ".shp"), "boundary", "ESRI Shapefile")

# remove kml to avoid overwriting issues
file.remove(list.files(pattern = "kml"))
cat("\n") 
}

# remove footprint files
file.remove(list.files(pattern = "footprint"))

# merge shapefiles
setwd("shps")

# create list of shapefiles to merge
shpslist <- list.files(pattern = 'shp', recursive = TRUE)

# read every shp and assign each of them to its corresponding name
for (i in 1:length(shpslist)){
  assign(shpslist[i], readOGR(shpslist[i], strsplit(shpslist[i], ".", fixed = TRUE)[[1]][1]))
}

# rbind the SPDFs as one single SPDF
rbindSPDFs <- function(spdfs = c(), idcol){
  ni <- 1
  for (n in 1:length(spdfs)){
    row.names(spdfs[[n]]@data) <- as.character(ni:(ni - 1 + length(spdfs[[n]])))
    spdfs[[n]][[idcol]] <- as.character(ni:(ni - 1 + length(spdfs[[n]]))) # just for consistency with row.names
    for (i in 1:length(spdfs[[n]])){ 
      spdfs[[n]]@polygons[[i]]@ID <- as.character(ni)
      ni <- ni + 1
    }
  }
  
  rbinded <- spdfs[[1]]
  for (l in 2:length(spdfs)){
    rbinded <- rbind(rbinded, spdfs[[l]])
  }
  
  return(rbinded)
}


## use this to create list of spdfs
paste(shpslist, collapse = ", ")
##

# verify that the list is in the correct order
spdfs <- c(L7004056_20000123_raw.shp, L7004057_20000123_raw.shp, L7005055_20000215_raw.shp, L7005056_20000419_raw.shp, 
           L5005057_20001004_raw.shp, L7006055_20000105_raw.shp, L7006056_20000105_raw.shp, L7006057_20000105_raw.shp, 
           L5006058_20000129_raw.shp, L7007056_20001213_raw.shp, L7007057_20000316_raw.shp, L7007058_20001213_raw.shp)

spdfs <- c(L8004056_20131220_raw.shp, L8004057_20131220_raw.shp, L8005055_20131227_raw.shp, L8005056_20131024_raw.shp, 
           L8005057_20131024_raw.shp, L8006055_20130609_raw.shp, L8006056_20130913_raw.shp, L8006057_20130913_raw.shp, 
           L8006058_20130913_raw.shp, L8007056_20131006_raw.shp, L8007057_20130616_raw.shp, L8007058_20130616_raw.shp)

shps <- rbindSPDFs(spdfs, idcol = "Name")

#
writeOGR(shps, "footprints.shp", "footprints", "ESRI Shapefile")

# edit the shp in qgis to extract non-overlaped areas
# read the edit shp and export it as kml
shp <- readOGR("footprints_2000.shp", "footprints_2000")
writeOGR(shp, "footprints_2000.kml", "footprints_2000", "KML")

shp <- readOGR("footprints_2013.shp", "footprints_2013")
writeOGR(shp, "footprints_2013.kml", "footprints_2013", "KML")
