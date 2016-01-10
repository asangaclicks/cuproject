library(raster)
library(diffeR)

setwd("C:/amsantac/PhD/Research/dissertation/processing/other/testing/geojson")

shp <- shapefile("test_01_v2.shp")
table(shp$classifica, shp$reference)

tab <- read.csv("borrar1.csv", header = TRUE)
tab2 <- read.csv("borrar2.csv", header = FALSE)
colnames(tab2) <- c(0, 1, 2, 3, 5, 6, 7)
rownames(tab2) <- c(0, 1, 2, 3, 5, 6, 7)

# load packages
library(rgdal)
library(gsheet)
library(jsonlite)

setwd("C:/amsantac/PhD/Research/dissertation/processing/landsat/geojson/tests")

# read the geojson_links Google Spreadsheet containing the list of geojson files 
# with their corresponding file IDs. The Google Spreadsheet must be *shared*. 

# read table from testing files url
url1 <- 'https://docs.google.com/spreadsheets/d/1sPeW7DXFMGCFEYTAUfNyYiWaP0iLhx-NWaMGjX9G-eg/edit#gid=0'
gjson_list <- gsheet2tbl(url1)

# extract the IDs
ids <- c(gjson_list$fileID)

# download the geojson files from GoogleDrive
for (i in 1:length(ids)){ 
  url <- paste0("https://drive.google.com/uc?export=download&id=", ids[i])
  download.file(url, destfile = gjson_list$file[i])
}

# extract dataframe and convert to SpatialPointsDataFrame
doc <- fromJSON(txt=list.files(pattern = ".geojson"))$features

library(RJSONIO)
options(digits=16)
document <- RJSONIO::fromJSON(list.files(pattern = ".geojson"))
document$features[[1]]$properties[2]

length(document$features)

head(document$features)

class1 <- document$features[[1]]$properties[[1]]
long1 <- document$features[[1]]$properties[[3]]
lat1 <- document$features[[1]]$properties[[2]]

for (j in 2:length(document$features)){
  class1 <- c(class1, document$features[[j]]$properties[[1]])
  long1 <- c(long1, document$features[[j]]$properties[[3]])
  lat1 <- c(lat1, document$features[[j]]$properties[[2]])
}
res <- cbind(long1, lat1, class1)
write.csv(res, "res.csv", digits=16)
