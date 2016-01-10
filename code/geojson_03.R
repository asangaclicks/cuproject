
library(rgdal)
#library(maptools)
library(gsheet)

setwd("C:/amsantac/PhD/Research/dissertation/processing/landsat/geojson")

# read the geojson_links Google Spreadsheet containing the list of geojson files 
# with their corresponding file IDs and land cover classes
url <- 'docs.google.com/spreadsheets/d/1l73KndWvCb92sLaOVoeEuZNkD1IMW8Fb4WrEWw94EO0'
gjson_list <- gsheet2tbl(url)

# extract the IDs and the classes
ids <- c(gjson_list$fileID)
classes <- c(gjson_list$class)

# download the geojson files from GoogleDrive
for (i in 1:length(ids)){ 
url <- paste0("https://drive.google.com/uc?export=download&id=", ids[i])
download.file(url, destfile = gjson_list$file[i])
}

# read into R the geojson files as SpatialPolygonsDataFrames
for (i in 1:length(ids)){ 
  assign(gjson_list$fileName[i], readOGR(gjson_list$file[i], "OGRGeoJSON"))
}

#######################################
## STOP:
## IMPORTANT: here create list of SPDFs to data-edit and rbind 
#######################################

# check that the order of spdfs, colors and classIds correspond to classStr

#classStr <- c("grass", "forest", "water")
(classStr <- gjson_list$class)

#spdfs <- c(bn_01, h_01, p_01, caot_01, csyp_01, acn_01, aah_01)
#colors <- c("#33A02C", "#1CEABA", "#E84CCE", "#976EDE", "#CE6C2F", "#4C51DE", "#1DDF16")

spdfs <- c(p_01, h_01, csyp_01, caot_01, bn_01, acn_01)
colors <- c("#E84CCE", "#1CEABA", "#CE6C2F", "#976EDE", "#33A02C", "#4C51DE")


## classId <- 1:length(spdfs)
classId <- c(3, 2, 7, 5, 1, 6)

# read the function for adding data columns with land cover class id, land cover class name and color
# for each class
addClassSPDFs <- function(spdfs = c(), classId, classStr, colors){
  
  for (n in 1:length(spdfs)){
    spdfs[[n]][["class"]] <- classId[n] 
    spdfs[[n]][["classStr"]] <- classStr[n] 
    spdfs[[n]][["color"]] <- colors[n]
  }
  return(spdfs)
}


spdfs <- addClassSPDFs(spdfs, classId, classStr, colors)

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

training <- rbindSPDFs(spdfs, idcol = "FID")

# export the SPDF as KML
writeOGR(training, "training.KML", "training", driver="KML")

# Next, upload the KML to GoogleDrive and create a Google Fusion Table with it
