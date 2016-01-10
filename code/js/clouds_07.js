
var start_date = '2000-01-01';
var end_date = '2000-12-31';

var llanos = ee.FeatureCollection('ft:1X_CeRfYiZ_4F-G9cu78pxjKTI_xD6yHeFiLvVOki');

// Landsat TOA collection
var toaL7 = ee.ImageCollection('LANDSAT/LE7_L1T_TOA')
  .filterDate(start_date, end_date)
  //.filterBounds(ee.Geometry.Rectangle(-72.96, 2.512, -68.34, 7.174));
  .filterBounds(llanos)
  .filterBounds(ee.Geometry.Rectangle(-72.96, 2.512, -68.34, 7.174));
  
  // cloud masking function with arbitrary x% threshold
var cloudMask = function(image) {
  var clouds = ee.Algorithms.Landsat.simpleCloudScore(image)
    .select('cloud');
  //var mask = image.mask().and(clouds.lte(40));
  //return image.mask(mask);
  return image.addBands(clouds.lte(40));
};

var cloudTOAL7 = toaL7.map(function(image) {
  return cloudMask(image);
});
  
// Landsat SR collection
var srL7 = ee.ImageCollection('LEDAPS/LE7_L1T_SR')
  .filterDate(start_date, end_date)
  .filterBounds(ee.Geometry.Rectangle(-73.96, 2.512, -67.34, 7.174));

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

// Apply the join.
var innerJoinedL7 = innerJoin.apply(cloudTOAL7.select('cloud'), srL7, filterTimeEq)
                    .map(MergeBands)
                    .map(ndviAdd);

// Display the join result: a FeatureCollection.
print('Inner join output:', innerJoinedL7);

// map the functions over the collection
var maskedCollection = innerJoinedL7.map(function(image) {
  return cloudMask(ee.Image(image));
});
print('Masked collection:', maskedCollection);

// make a maximum (NDVI) value composite
// data in other bands comes from the time at which NDVI is maximized
var maxValueComposite = ee.ImageCollection(maskedCollection).qualityMosaic('NDVI');
print('Composite:', maxValueComposite);

var maskedLl = maskedCollection;
/*
var GenerateGappedDataset = function(image) {
  var MOD = ee.Image(image).select('remapped');
  var MYD = ee.Image(image).select('remapped_1');
  var NewBand = MOD.where(MOD.eq(200).and(MYD.neq(200)), MYD);        // Fill in missing values in Terra series with Aqua data          
  var NewBands = ee.Image(image).where(ee.Image(image).select('cloud').eq(1), )
  return ee.Image(image).addBands(NewBand);
};*/

//var image1 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040562000023EDC00').add;

Map.addLayer(maxValueComposite, 
 {'min': 0, 'max': 4000, 'bands': ['B4', 'B5', 'B3']}, 'true color');
//Map.addLayer(collection1, vizParams453, 'collection1');  
//Map.setCenter(-71.4, 4.4, 7);

// Filter to get only larger continental US watersheds.
//var filt = innerJoinedL7.filter(ee.Filter.eq('version', 1449778279450000));

//print('Filtered: ', filt);


// load images 
var image1 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040562000023EDC00');
var image2 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040572000023EDC00');
var image3 = ee.Image('LEDAPS/LE7_L1T_SR/LE70050552000046EDC00');
var image4 = ee.Image('LEDAPS/LE7_L1T_SR/LE70050562000110AGS01');
var image5 = ee.Image('LEDAPS/LT5_L1T_SR/LT50050572000278XXX02');
var image6 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060552000005EDC00');
var image7 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060562000005EDC00');
var image8 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060572000005EDC00');
var image9 = ee.Image('LEDAPS/LT5_L1T_SR/LT50060582000029XXX02');
var image10 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070562000348EDC00');
var image11 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070572000076EDC00');
var image12 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070582000348EDC00');
var collection = ee.ImageCollection.fromImages([image1, image2, image3, image4, image5, image6, image7, image8, image9, 
                                                image10, image11, image12]);
                                                
var vizParams453 = {'min': 0, 'max': 4000, 'bands': ['B4', 'B5', 'B3']}; 

var mosaico = collection.mosaic();

var merged = ee.Image.cat(maxValueComposite.select('cloud'), mosaico.addBands(mosaico.normalizedDifference(['B5', 'B4']).select([0], ['NDVI'])));
print('merged:', merged)

var NewBand = merged.where(merged.select('cloud').eq(1), maxValueComposite);
print('newband', NewBand);

addToMap(collection, vizParams453, 'collection');
addToMap(NewBand, vizParams453, 'newband');
Map.centerObject(collection, 7);

var images = ee.ImageCollection(maskedCollection).filter(ee.Filter.or(
             ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70040562000023EDC00'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70040572000023EDC00'),
	         ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70050552000046EDC00'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70050562000110AGS01'),
			 ee.Filter.eq('LANDSAT_SCENE_ID', 'LT50050572000278XXX02'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70060552000005EDC00'),
			 ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70060562000005EDC00'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70060572000005EDC00'),
			 ee.Filter.eq('LANDSAT_SCENE_ID', 'LT50060582000029XXX02'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70070562000348EDC00'),
			 ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70070572000076EDC00'), ee.Filter.eq('LANDSAT_SCENE_ID', 'LE70070582000348EDC00')
                                                                     );
