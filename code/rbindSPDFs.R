
# CRS must be the same for all the SPDFs

# rbind the SPDFs as one single SPDF
rbindSPDFs <- function(spdfs = c(), idcol = NULL){

  ni <- 1
  for (n in 1:length(spdfs)){
    row.names(spdfs[[n]]@data) <- as.character(ni:(ni - 1 + length(spdfs[[n]])))
    if(!is.null(idcol)){
    spdfs[[n]][[idcol]] <- as.character(ni:(ni - 1 + length(spdfs[[n]]))) # just for consistency with row.names
    }
    for (i in 1:length(spdfs[[n]])){ 
      spdfs[[n]]@polygons[[i]]@ID <- as.character(ni)
      ni <- ni + 1
    }
  }
  
  rbinded <- spdfs[[1]]
  for (l in 2:length(spdfs)){
    rbinded <- rbind(rbinded, spdfs[[l]])
  }
  
  return(rbinded)
}

