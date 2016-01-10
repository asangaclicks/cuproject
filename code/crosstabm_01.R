
#library(foreign)
#tabla <- read.dbf("C:/amsantac/PhD/Research/dissertation/processing/other/testing/testing_757_2000_v2.dbf")
#as.data.frame(table(tabla$cover, tabla$reference))


comparison <- "testing_757_2000_v3"

library(spgrass6)
mapa2 <- readVECT(comparison)

#cr1 <- table(tabla$cover, tabla$reference)
cr1 <- table(mapa2$class1, mapa2$reference)
#nrow(cross)
#ncol(cross)
#colnames(cross)
#rownames(cross)
#cross2 <- c(setdiff(colnames(cross), rownames(cross)), setdiff(rownames(cross), colnames(cross)))

percent = FALSE
population = NULL
uniquecr1 <- sort(unique(c(colnames(cr1), rownames(cr1))))

#if(length(setdiff(colnames(cross), rownames(cross))) > 0){}

#if(length(setdiff(rownames(cross), colnames(cross))) > 0){
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
#}
overallAccuracy <- 100 * sum(diag(SampleCount))/sum(SampleCount)
names(overallAccuracy) <- "overall"
categoryAccuracy <- 100 * diag(SampleCount)/colSums(SampleCount)
res <- c(categoryAccuracy, overallAccuracy)

