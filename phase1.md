---
title: "Course Project - The Exponential Distribution"
author: "Ali Santacruz"
date: "Friday, May 22, 2015"
output: pdf_document
---

### 1. Overview
In a few (2-3) sentences explain what is going to be reported on.

### 2. Simulations
Include English explanations of the simulations you ran, with the accompanying R code. Your explanations should make clear what the R code accomplishes.


```{r}
n <- 100
lambda <- 0.2
expSims <- NULL
nsims <- 1000
for (i in 1:nsims){ 
expSims <- rbind(expSims, rexp(n, 0.2))
}
meansVec <- apply(expSims, 1, mean)
```



```{r histoMeans, eval=FALSE}
hist(meansVec, breaks = 20, main="Sample Mean versus Theoretical Mean", xlab="")
abline(v=mean(meansVec), lwd=3, col="blue", lty=2)
abline(v=1/lambda, lwd=3, col="red", lty=5)
legend("topright", legend=c("Sample Mean", "Theoretical Mean"), lty=c(2,5), 
       col=c("blue", "red"), lwd=3, bty="n")
```


You can also embed plots, for example:

```{r men}
men <- runif(10)
```

```{r men}
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.

### 3. Sample Mean versus Theoretical Mean
The sample mean is equal to `r round(mean(meansVec), 2)`, while the theoretical mean, $1/\lambda$, is equal to `r 1/lambda`.

```{r histoMeans, echo = FALSE}
```

### 4. Sample Variance versus Theoretical Variance
Include figures (output from R) with titles. Highlight the variances you are comparing. Include text that explains your understanding of the differences of the variances.

### 5. Distribution
Via figures and text, explain how one can tell the distribution is approximately normal.




