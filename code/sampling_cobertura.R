library(rgdal)
setwd("C:/amsantac/PhD/Research/dissertation/data/ecosistemas")

# convert footprints voronoi to kml
setwd("C:/amsantac/PhD/Research/dissertation/data/shps/footprints/2000")
spdf <- readOGR("footprints_voronoi_2000_v4.shp", "footprints_voronoi_2000_v4")
writeOGR(spdf, "footprints_voronoi_2000_v4.kml", "footprints_voronoi_2000_v4", "KML")

# convert footprints voronoi to kml
setwd("C:/amsantac/PhD/Research/dissertation/data/shps/footprints/2000")
spdf <- readOGR("footprints_voronoi_2000_v4_loc.shp", "footprints_voronoi_2000_v4_loc")
writeOGR(spdf, "footprints_voronoi_2000_v4_loc.kml", "footprints_voronoi_2000_v4_loc", "KML")


spdf <- readOGR("footprints_voronoi_2013_v2.shp", "footprints_voronoi_2013_v2")
writeOGR(spdf, "footprints_voronoi_2013_v2.kml", "footprints_voronoi_2013_v2", "KML")

# convert training.shp to kml
setwd("C:/amsantac/PhD/Research/dissertation/data/shps/training")
spdf <- readOGR("training.shp", "training")
writeOGR(spdf, "training_01.kml", "training_01", "KML")

# 
setwd("C:/amsantac/PhD/Research/dissertation/processing/landsat/geojson")
file1 <- readOGR("footprints_2000.geojson", "OGRGeoJSON")
writeOGR(file1, "footprints_2000.kml", "footprints_2000", "KML")



sizes <- read.csv("C:/amsantac/PhD/Research/dissertation/processing/other/sampling_sizes.csv")

ecosistemas <- readOGR("ecosistemas_llanos_latlon_v3.shp", "ecosistemas_llanos_latlon_v3")
unique(ecosistemas$Cobertura2)

names <- gsub(" ", ".", unique(ecosistemas$Cobertura2))

for (i in 1:length(unique(ecosistemas$Cobertura2))){
  cover <- unique(ecosistemas$Cobertura2)[i]
  print(paste0("Processing ", cover, "..."))
  covermap <- subset(ecosistemas, Cobertura2 == cover)
  n <- sizes$training[which(sizes$landcover == cover)]
  assign(names[i], SpatialPointsDataFrame(assign(names[i], spsample(covermap, n, "random")), data = data.frame(cover = rep(cover, n), coverId = i)))
  cat("\n")
}

spdfs <- c(Bosques.naturales, Herbazales, Pastos, Vegetacion.secundaria, Cultivos.anuales.o.transitorios, 
           Aguas.continentales.naturales, Cultivos.semipermanentes.y.permanentes, Areas.agricolas.heterogeneas, 
           Hidrofitia.continental, Bosques.plantados, Arbustales, Areas.urbanas, Afloramientos.rocosos, 
           Zonas.desnudas.sin.o.con.poca.vegetacion)

# obtain list of SPDF
paste(names, collapse = ", ")


# verify lengths
unlist(lapply(spdfs, length))

# rbind SPDFs

rbinded <- spdfs[[1]]
for (l in 2:length(spdfs)){
  rbinded <- rbind(rbinded, spdfs[[l]])
}

writeOGR(rbinded, "training.shp", "training", "ESRI Shapefile")




assign(cover, SpatialPointsDataFrame(`Afloramientos rocosos`, data = data.frame(cover = rep("a", length(`Afloramientos rocosos`))))

assign(cover, SpatialPointsDataFrame(`Afloramientos rocosos`, data = data.frame(cover = rep("a", length(`Afloramientos rocosos`))))


bosquesNaturales <- subset(ecosistemas, Cobertura == "Bosques naturales")
afloramientosRocosos <- subset(ecosistemas, Cobertura == "Afloramientos rocosos")
plot(afloramientosRocosos)
points(spsample(afloramientosRocosos, 10, "random"), col = "red")
points(`Afloramientos rocosos`, col = "red")

for (cover in unique(ecosistemas$Cobertura2)){
  print(paste0("Processing ", cover, "..."))
  covermap <- subset(ecosistemas, Cobertura2 == cover)
  n <- sizes$training[which(sizes$landcover == cover)]
  
  assign(cover, SpatialPointsDataFrame(assign(cover, spsample(covermap, n, "random")), data = data.frame(cover = rep(cover, length(assign(cover, spsample(covermap, n, "random")))))))
  cat("\n")
}
