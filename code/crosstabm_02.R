
comparison <- "testing_757_2000_v3"

library(spgrass6)
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
