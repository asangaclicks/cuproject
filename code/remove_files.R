## Use with caution! Files are NOT moved to the Recycle Bin

## delete _refl files in folder for year 2000
fPath <- "C:/amsantac/PhD/Research/dissertation/data/landsat/images/2000"
list.files(fPath, pattern = "_refl", recursive = TRUE)
file.remove(paste0(fPath, "/", list.files(fPath, pattern = "_refl", recursive = TRUE)))

