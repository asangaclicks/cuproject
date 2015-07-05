setwd("C:/amsantac/other/git/cuproject")

library(XML)

insertTables <- function(htmlFile, tablesFile){
  
  tabLines <- readLines(tablesFile)
  
  doc <- htmlTreeParse(tablesFile)
  rootNode <- xmlRoot(doc)
  
  for (i in 1:length(rootNode[[1]])){
    htmlLines <- readLines(htmlFile)
    id_i <- xmlAttrs(rootNode[[1]][[i]])[[1]]
    z <- gsub(paste0("<p>", id_i, "</p>"), grep(id_i, tabLines, value = TRUE), htmlLines)
    cat(z, file=htmlFile, sep="\n")
  }  
}

suppressWarnings(insertTables("phase1.html", "iframeTables.txt"))