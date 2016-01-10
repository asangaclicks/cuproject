library(genalg)

Wi <- c(0.007186, 0.030385, 0.207735, 0.019092, 0.582405, 0.153197) 
Ui <- c(0.9, 0.95, 0.9, 0.85, 0.85, 0.85)
N <- c(2900)
string <- c(rep(483, 6))
string <- c(20, 88, 602, 55, 1688, 444)

evaluate <- function(string=c()){
  returnVal = NA
  
  se <- sqrt(sum((Wi^2) * Ui * (1 - Ui) / (c(string[1],string[2],string[3],string[4],string[5],string[6])-1)))
  returnVal = abs((N - sum(string)) * se)

returnVal 
}

rbga(stringMin=c(rep(1, 6)), stringMax=c(rep(N, 6)),
     popSize=200, iters=1000,
     evalFunc=evaluate)


 
