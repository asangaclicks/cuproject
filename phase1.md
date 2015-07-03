## **Phase 1: Spatial dynamics and drivers of land-cover change**

The first phase of this research is the analysis of the spatial dynamic and drivers of land-cover change. The following sections are shown below:

1. [Data sources](#data-sources)
2. [Methods](#methods)
3. [Results](#results)
4. [References](#references)

### Data sources 
* Landsat 5 TM, Landsat 7 ETM+ and Landsat 8 OLI/TIRS imagery from [USGS](http://landsat.usgs.gov/index.php).
* [WRS-2 descending grid](http://landsat.usgs.gov/tools_wrs-2_shapefile.php). 

### Methods 

#### *Image selection*
* Landsat imagery was selected for 12 tiles for the time period between 2000 and 2016. One Landsat image was selected for each tile for each year, for a total of 204 Landsat scenes. Landsat 5 and Landsat 7 imagery was selected for years 2000 to 2011. Landsat 8 images were used for years 2013 to 2016.
* Landsat scenes with low or none cloud cover over the [study area](index.html#study-area) were preferred. Landsat 5 and Landsat 7 SLC-on scenes were preferred over Landsat 7 SLC-off scenes. Images taken during the dry season (January-March) were preferred over images taken in other months over the year.
* Landsat 5 and Landsat 7 imagery was selected using the [USGS EarthExplorer](http://earthexplorer.usgs.gov/). Landsat 8 imagery was selected using the [Libra browser](https://libra.developmentseed.org/). All the imagery was downloaded using the [Landsat Data Bulk Download utility](http://earthexplorer.usgs.gov/bulk).
* The complete list of the selected Landsat imagery can be seen <a href="https://docs.google.com/spreadsheets/d/1HMtOeW7eo_KRrg6BND2eItIp7VS1p0e_YWS3_YHaYEM/edit?usp=sharing" target="_blank">here</a>. This list also shows cloud cover, acquisition date and progress in image processing as well as a link to each scene thumbnail.

#### *Image preparation*
* Landsat images were stacked and preprocessed using the [CLASlite](http://claslite.carnegiescience.edu/en/) software (reference to claslite). An [R script](https://github.com/amsantac/cuproject/blob/gh-pages/code/stackLandsatCSV.R) was used to create the [csv](https://github.com/amsantac/cuproject/blob/gh-pages/other/processing/landsat/CLASliteCSVs/stack_2000_2014.csv) file required for stacking the Landsat images through batch processing in CLASlite.
* Landsat images were preprocessed using the batch processing utility in CLASlite. Radiometric calibration and atmospheric correction were conducted on every Landsat image. CLASlite uses conversion factors (aka gains) to convert units of digital numbers into units of radiance. Then CLASlite uses the 6S radiative transfer model to simulate the Earth's atmospheric atmosphere in each satellite image and to covert the radiance values to surface reflectance. The batch processing utility in CLASlite was used to conduct image calibration.  An [R script]() was used to create the [csv]() file required for image calibration through batch processing in CLASlite.    

### Results 
* In progress.

### References 
* In progress.
