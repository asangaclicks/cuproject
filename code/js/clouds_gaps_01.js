
var start_date = '2004-01-01';
var end_date = '2004-12-31';

var llanos = ee.FeatureCollection('ft:1X_CeRfYiZ_4F-G9cu78pxjKTI_xD6yHeFiLvVOki');

// Landsat TOA collections
var toaL7 = ee.ImageCollection('LANDSAT/LE7_L1T_TOA')
  .filterDate(start_date, end_date)
  .filterBounds(llanos)
  .filter(ee.Filter.or(
  		ee.Filter.and(ee.Filter.eq('WRS_PATH', 5), ee.Filter.eq('WRS_ROW', 55)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 5), ee.Filter.eq('WRS_ROW', 56)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 6), ee.Filter.eq('WRS_ROW', 55)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 6), ee.Filter.eq('WRS_ROW', 56)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 6), ee.Filter.eq('WRS_ROW', 57)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 7), ee.Filter.eq('WRS_ROW', 56)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 7), ee.Filter.eq('WRS_ROW', 57)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 7), ee.Filter.eq('WRS_ROW', 58))));

var toaL5 = ee.ImageCollection('LANDSAT/LT5_L1T_TOA')
  .filterDate(start_date, end_date)
  .filterBounds(llanos)
  .filter(ee.Filter.or(
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 4), ee.Filter.eq('WRS_ROW', 56)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 4), ee.Filter.eq('WRS_ROW', 57)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 5), ee.Filter.eq('WRS_ROW', 57)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 6), ee.Filter.eq('WRS_ROW', 58))));  
  
// Landsat SR collections
var srL7 = ee.ImageCollection('LEDAPS/LE7_L1T_SR')
  .filterDate(start_date, end_date)
  .filterBounds(llanos)
  .filter(ee.Filter.or(
  		ee.Filter.and(ee.Filter.eq('WRS_PATH', 5), ee.Filter.eq('WRS_ROW', 55)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 5), ee.Filter.eq('WRS_ROW', 56)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 6), ee.Filter.eq('WRS_ROW', 55)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 6), ee.Filter.eq('WRS_ROW', 56)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 6), ee.Filter.eq('WRS_ROW', 57)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 7), ee.Filter.eq('WRS_ROW', 56)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 7), ee.Filter.eq('WRS_ROW', 57)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 7), ee.Filter.eq('WRS_ROW', 58))));

var srL5 = ee.ImageCollection('LEDAPS/LT5_L1T_SR')
  .filterDate(start_date, end_date)
  .filterBounds(llanos)
  .filter(ee.Filter.or(  
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 4), ee.Filter.eq('WRS_ROW', 56)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 4), ee.Filter.eq('WRS_ROW', 57)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 5), ee.Filter.eq('WRS_ROW', 57)),
		ee.Filter.and(ee.Filter.eq('WRS_PATH', 6), ee.Filter.eq('WRS_ROW', 58))));

print('toaL7', toaL7);
print('toaL5', toaL5);
print('srL7', srL7);
print('srL5', srL5);
		
//////////////////////////////////////////////////////////////////////////////////  
////                 FUNCTIONS DEFINITION
  
// cloud masking function with arbitrary x% threshold
var cloudBand = function(image) {
  var clouds = ee.Algorithms.Landsat.simpleCloudScore(image)
    .select('cloud');
  //var mask = image.mask().and(clouds.lte(40));
  //return image.mask(mask);
  return image.addBands(clouds.lte(40));
};

// Define an inner join.
var innerJoin = ee.Join.inner();

// Specify an equals filter for image timestamps.
var filterTimeEq = ee.Filter.equals({
  leftField: 'system:time_start',
  rightField: 'system:time_start'
});

// Concatenate the two images in each feature of the feature collection into a single image
var MergeBands = function(element) {
  return ee.Image.cat(element.get('primary'), element.get('secondary'));
};

// add an NDVI band
var ndviAdd = function(image) {
  var ndvi = ee.Image(image).normalizedDifference(['B5', 'B4'])
    .select([0], ['NDVI']);
  return ee.Image(image).addBands(ndvi);
};

// apply cloud mask
var cloudMask = function(image) {
  var clouds = ee.Image(image).select('cloud');
  var mask = ee.Image(image).mask().and(clouds);
  return ee.Image(image).mask(mask);
};

var unmaski = function(image) {
  return image.unmask();
};

////                 END FUNCTIONS DEFINITION
//////////////////////////////////////////////////////////////////////////////////  


// Add cloud band
var cloudTOAL7 = toaL7.map(function(image) {
  return cloudBand(image);
});
var cloudTOAL5 = toaL5.map(function(image) {
  return cloudBand(image);
});

// Apply the join.
var innerJoinedL7 = innerJoin.apply(cloudTOAL7.select('cloud'), srL7, filterTimeEq)
                    .map(MergeBands)
                    .map(ndviAdd);
var innerJoinedL5 = innerJoin.apply(cloudTOAL5.select('cloud'), srL5, filterTimeEq)
                    .map(MergeBands)
                    .map(ndviAdd);
					
// Display the join result: a FeatureCollection.
print('Inner join output:', innerJoinedL7);

// Apply cloud mask
var maskedColl7 = innerJoinedL7.map(function(image) {
  return cloudMask(ee.Image(image));
});
var maskedColl5 = innerJoinedL5.map(function(image) {
  return cloudMask(ee.Image(image));
});
print('Masked collection:', maskedColl7);

// make a maximum (NDVI) value composite
// data in other bands comes from the time at which NDVI is maximized
var maxValueComposite7 = ee.ImageCollection(maskedColl7).qualityMosaic('NDVI');
var maxValueComposite5 = ee.ImageCollection(maskedColl5).qualityMosaic('NDVI');
var maxValueComposite = ee.ImageCollection.fromImages([maxValueComposite5, maxValueComposite7]).mosaic();

print('Composite:', maxValueComposite);

// load llanos images 
var llanos7 = ee.ImageCollection(maskedColl7).filter(ee.Filter.or(
		ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70050552004041EDC01'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70050562004041EDC01'),
		ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70060552004032EDC01'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70060562004032EDC01'),
		ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70060572004032EDC01'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70070562004359EDC00'), 
		ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70070572004039EDC02'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70070582004023ASN01') 
                                                                     ));
var llanos5 = ee.ImageCollection(maskedColl5).filter(ee.Filter.or(
		ee.Filter.eq('LANDSAT_SCENE_ID', 'LT50040562004026CUB00'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LT50040572004026CUB00'),
		ee.Filter.eq('LANDSAT_SCENE_ID', 'LT50050572004033CUB00'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LT50060582004040CUB00')
		));
		
var joinedICs = ee.ImageCollection(llanos5.merge(llanos7));
                                                
var mosaico = joinedICs.map(unmaski).mosaic();

//var mosaic7 = ee.Image.cat(maxValueComposite.select('cloud'), mosaico);

var nmosaico = mosaico.where(mosaico.eq(0), maxValueComposite);

////////////////////////////////////////////////////////////////////////////////// 
////                 IMAGE VISUALIZATION

var vizParams453 = {'min': 0, 'max': 4000, 'bands': ['B4', 'B5', 'B3']}; 

Map.addLayer(maxValueComposite, 
 {'min': 0, 'max': 4000, 'bands': ['B4', 'B5', 'B3']}, 'true color');

addToMap(llanos7, vizParams453, 'coll7');
addToMap(llanos5, vizParams453, 'coll5');
addToMap(mosaico.select('cloud'), {}, 'clouds');
addToMap(mosaico, vizParams453, 'mosaico');
addToMap(nmosaico, vizParams453, 'nmosaico');

Map.centerObject(llanos7, 7);

