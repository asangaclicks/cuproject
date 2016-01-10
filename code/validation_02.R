# start GRASS (optionally from QGIS)
# start R from GRASS
# C:\PROGRA~1\R\R-3.2.1\bin\R

# source this file
# source("C:/amsantac/PhD/Research/dissertation/code/validation_02.R")
# comparison <- "testing_757_2000_v3"



# change the working directory
setwd("C:/amsantac/PhD/Research/dissertation/processing/landsat/geojson/tests")

# define names for reference and comparison maps
reference <- "testing_757_2000_v3"
tmpgrassdb <- "C:/amsantac/PhD/Research/dissertation/processing/grass/database/llanos_latlon/PERMANENT/.tmp"

# load packages
library(rgdal)
library(gsheet)
library(spgrass6)
library(RJSONIO)


# read the geojson_links Google Spreadsheet containing the list of geojson files 
# with their corresponding file IDs. The Google Spreadsheet must be *shared*. 

# read table from testing files url
url1 <- 'https://docs.google.com/spreadsheets/d/1sPeW7DXFMGCFEYTAUfNyYiWaP0iLhx-NWaMGjX9G-eg/edit#gid=0'
gjson_list <- gsheet2tbl(url1)

# extract the IDs
ids <- c(gjson_list$fileID)

# download the geojson files from GoogleDrive
setInternet2(TRUE)
for (i in 1:length(ids)){ 
  url <- paste0("https://drive.google.com/uc?export=download&id=", ids[i])
  download.file(url, destfile = gjson_list$file[i])
}

gfiles <- list.files(pattern = ".geojson")

# extract dataframe and convert to SpatialPointsDataFrame

for (i in 1:length(gfiles)){
  
document <- fromJSON(gfiles[i])

comparison <- strsplit(gfiles[i], '.', fixed = TRUE)[[1]][1]

class1 <- document$features[[1]]$properties[[1]]
long1 <- document$features[[1]]$properties[[3]]
lat1 <- document$features[[1]]$properties[[2]]

for (j in 2:length(document$features)){
  class1 <- c(class1, document$features[[j]]$properties[[1]])
  long1 <- c(long1, document$features[[j]]$properties[[3]])
  lat1 <- c(lat1, document$features[[j]]$properties[[2]])
}
result <- as.data.frame(cbind(long1, lat1, class1))

coordinates(result) <- ~long1 + lat1

writeVECT(result, comparison, v.in.ogr_flags = c("o"))

execGRASS("v.db.addcol", map=comparison, columns="reference INT") 
execGRASS("v.distance", from=comparison, to=reference, upload="to_attr", column="reference", 
          to_column="landcover_")

file.remove(paste0(tmpgrassdb, "/", list.files(tmpgrassdb, pattern = c(".dbf", ".shp", ".shx"))))

deletedshp <- lapply(c(".dbf", ".shp", ".shx", ".prj", ".0"), 
       function(x){file.remove(paste0(tmpgrassdb, "/", list.files(tmpgrassdb, pattern = x)))})
            
cat('\n', 'Reading ', comparison, ' from GRASS database...', '\n\n', sep = '')

mapa <- readVECT(comparison)

cr1 <- table(mapa$class1, mapa$reference)

percent = FALSE
population = NULL
uniquecr1 <- sort(unique(c(colnames(cr1), rownames(cr1))))

SampleCount <- matrix(0, nrow = length(uniquecr1), ncol = length(uniquecr1))
colnames(SampleCount) <- uniquecr1
rownames(SampleCount) <- uniquecr1
for (i in 1:nrow(cr1)) {
  for (j in 1:ncol(cr1)){
    xi <- which(rownames(SampleCount) == rownames(cr1)[i])
    ji <- which(colnames(SampleCount) == colnames(cr1)[j])
    SampleCount[xi, ji] <- as.numeric(cr1[i, j])
  }
}
if (percent == TRUE) {
  SampleCount <- SampleCount/sum(SampleCount) * 100
}

if(!is.null(population)){
  SampleCount <- sample2pop(SampleCount, population)
  if(percent == TRUE)
    SampleCount <- SampleCount/sum(SampleCount) * 100
}

overallAccuracy <- 100 * sum(diag(SampleCount))/sum(SampleCount)
names(overallAccuracy) <- "overall"
categoryAccuracy <- 100 * diag(SampleCount)/colSums(SampleCount)
result <- c(categoryAccuracy, overallAccuracy)

write.csv(result, paste0(comparison, ".csv"))

}

#write.csv(res, "res.csv")
#document$features[[1]]$properties[2]