## set working directory: folder where the output csv files should be written
setwd("C:/amsantac/PhD/Research/dissertation/processing/landsat/CLASliteCSVs")

## function for creating csv files to use in CLASlite for stacking landsat imagery per path-row per year
## @path : folder path where the yearly folders are stored
## @years : years for which the list of folders will be recorded in the output csv file
## @output : name of the output csv file

stackLandsatCSV <- function(path, years, output){
  oldwd <- getwd()
  foldersList <- NULL
    for (year in years){
    path_y <- paste0(path, "/", year)
    setwd(path_y)
    foldersList <- c(foldersList, paste0(path_y, "/", list.files()))
  }
  foldersListDF <- data.frame("LANDSAT_Folder_Names" = foldersList)
  setwd(oldwd)
  write.csv(foldersListDF, output, row.names = FALSE, quote = FALSE)  
}

## parameters to run the function
path <- "C:/amsantac/PhD/Research/dissertation/data/landsat/images"
years <- 2000:2014
output <- "stack_2000_2014.csv"

# create the csv file for the given years
stackLandsatCSV(path, years, output)
