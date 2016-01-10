
library(rgdal)
library(gsheet)

setwd("C:/amsantac/PhD/Research/dissertation/processing/landsat/geojson")

# read the geojson_links Google Spreadsheet containing the list of geojson files 
# with their corresponding file IDs and land cover classes. The Google Spreadsheet must be *shared*.

#training
url1 <- 'docs.google.com/spreadsheets/d/1l73KndWvCb92sLaOVoeEuZNkD1IMW8Fb4WrEWw94EO0'

#testing
#url1 <- 'https://docs.google.com/spreadsheets/d/1sPeW7DXFMGCFEYTAUfNyYiWaP0iLhx-NWaMGjX9G-eg/edit#gid=0'


gjson_list <- gsheet2tbl(url1)

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
(classStr <- sort(gjson_list$class))

# create list of spdfs, copy and paste result of paste0 line
paste0(sort(gjson_list$fileName), collapse = ", ")
spdfs <- c(acn_01, bn_01, bn_02, caot_01, caot_02, caot_03, csyp_01, h_01, h_02, p_03, p_04)

# create list of colors
gjson_table <- gsheet2tbl(url1, 1726447101)  # else gjson_table <- read.csv("geojson_links.csv", header = TRUE)
colors <- merge(gjson_list, gjson_table, by="class")$color

## classId <- 1:length(spdfs)
classId <- merge(gjson_list, gjson_table, by="class")$classId

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
# todos los SPDFs deben tener las mismas columnas, chequear si sale error
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

# export the SPDF as shp and KML (for FT)
writeOGR(training, "shps/training_15.shp", "training", driver="ESRI Shapefile")
writeOGR(training, "training_15.KML", "training", driver="KML")

# Next, upload the KML to GoogleDrive and create a Google Fusion Table with it
