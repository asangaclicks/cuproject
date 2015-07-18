## function to create csv files to be input for batch processing in CLASlite to convert raw images to reflectance
## @path : folder path where the yearly folders are stored
## @year : year for which the images and parameters will be listed in the output csv file

reflectanceImgTable4csv <- function(path, year, GeoTIFF = 0, Reduce_masking = 0, no_masking = 0, fmask = 0, 
                              cldpix = 3, sdpix = 3, snpix = 0, cldprob = 22.5){
  
  foldersList <- list.files(paste0(path, "/", year))
  
  outDF <- data.frame(matrix(data = NA, nrow = length(foldersList), ncol = 18))
  colnames(outDF) <- c("Input_FileName", "Date", "Time", "Gain_Settings", "Satellite", "Lead_File", "Therm_File",
                       "QA_File", "Output_File", "GeoTIFF", "Proc_sys", "Reduce_masking", "no_masking", "fmask", 
                       "cldpix", "sdpix", "snpix", "cldprob")
  outDF[, "GeoTIFF"] <- GeoTIFF
  outDF[, 12:18] <- t(apply(outDF[, 12:18], 1, function(x){c(Reduce_masking, no_masking, fmask, cldpix, sdpix, snpix,
                                                             cldprob)}))
  i <- 1
  
  for (folder in foldersList){
    
    rawImg1 <- grep("raw", list.files(paste0(path, "/", year, "/", folder)), value = TRUE)[1] 
    rawImg2 <- paste0(path, "/", year, "/", folder, "/", rawImg1)
    outDF[i, "Input_FileName"] <- gsub("/", "\\", rawImg2, fixed = TRUE)
    
    mtlTxt <- grep("MTL.txt", list.files(paste0(path, "/", year, "/", folder)), value = TRUE)  
    mtl <- readLines(paste0(path, "/", year, "/", folder, "/", mtlTxt))
    
    ## extract acquisition date
    date1 <- strsplit(mtl[grep("DATE_ACQUIRED", mtl)], "= ")[[1]][2]
    outDF[i, "Date"] <- format(as.Date(date1), "%d%m%Y")
    
    ## extract acquisition time
    time1 <- strsplit(mtl[grep("SCENE_CENTER_TIME", mtl)], "= ")[[1]][2]
    time2 <- paste(unlist(strsplit(time1, ":"))[1:2], collapse = "")
    outDF[i, "Time"] <- gsub("\"", "", time2)

    ## extract satellite id
    sid1 <- strsplit(mtl[grep("SPACECRAFT_ID", mtl)], "= ")[[1]][2]
    sid2 <- gsub("\"", "", sid1)
    if(sid2 == "LANDSAT_8") Satellitei <- 0
    if(sid2 == "LANDSAT_7") Satellitei <- 1
    if(sid2 == "LANDSAT_5") Satellitei <- 2
    if(sid2 == "LANDSAT_4") Satellitei <- 3
    if(sid2 == "ALI") Satellitei <- 4
    if(sid2 == "ASTER") Satellitei <- 5
    if(sid2 == "SPOT4") Satellitei <- 6
    if(sid2 == "SPOT5") Satellitei <- 7
    outDF[i, "Satellite"] <- Satellitei
    
    ## extract gains
    gains <- NULL
    
    ## for Landsat 4, 5, 7
    if (Satellitei == 1){
      for (band in c(1:5, 7)){
        bandGain_1 <- strsplit(mtl[grep(paste0(" GAIN_BAND_", band), mtl)], "= ")[[1]][2]
        bandGain_2 <- gsub("\"", "", bandGain_1)
        gains <- c(gains, bandGain_2)
      }
      outDF[i, "Gain_Settings"] <- paste(gains, collapse="")
    }
    
    ## extract processing system
    sys1 <- strsplit(mtl[grep("PROCESSING_SOFTWARE_VERSION", mtl)], "= ")[[1]][2]
    sys2 <- strsplit(gsub("\"", "", sys1), "_")[[1]][1]
    if(sys2 == "LPGS") outDF[i, "Proc_sys"] <- 0
    if(sys2 == "NLAPS") outDF[i, "Proc_sys"] <- 1
    
    ## extract thermal file name
    ThermImg1 <- grep("therm", list.files(paste0(path, "/", year, "/", folder)), value = TRUE)[1]
    ThermImg2 <- paste0(path, "/", year, "/", folder, "/", ThermImg1)
    outDF[i, "Therm_File"] <- gsub("/", "\\", ThermImg2, fixed = TRUE)
    
    ## extract quality image file
    ## for Landsat 8
    if (Satellitei == 0){
      QAImg1 <- grep("_QA", list.files(paste0(path, "/", year, "/", folder)), value = TRUE)[1]
      QAImg2 <- paste0(path, "/", year, "/", folder, "/", QAImg1)
      outDF[i, "QA_File"] <- gsub("/", "\\", QAImg2, fixed = TRUE)
    }
    
    ## output file name
    outDF[i, "Output_File"] <- sub("_therm", "_refl", outDF[i, "Therm_File"])
    
    i <- i + 1
    
  }
  outDF[is.na(outDF)] <- ""
  return(outDF)
}

## set working directory: folder where the output csv files should be written
setwd("C:/amsantac/PhD/Research/dissertation/processing/landsat/CLASliteCSVs")

## parameters to run the function
path <- "C:/amsantac/PhD/Research/dissertation/data/landsat/images"
years <- 2000:2014

## create the csv file for the given years
for (year in years){
  outDF <- reflectanceImgTable4csv(path, year)
  write.table(outDF, paste0("reflectance_", year, ".csv"), row.names = FALSE, quote = FALSE, sep = ", ") 
}
