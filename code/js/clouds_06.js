
// load images 
var isr1 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040562000023EDC00');
var isr2 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040572000023EDC00');
var isr3 = ee.Image('LEDAPS/LE7_L1T_SR/LE70050552000046EDC00');
var isr4 = ee.Image('LEDAPS/LE7_L1T_SR/LE70050562000110AGS01');
var isr5 = ee.Image('LEDAPS/LT5_L1T_SR/LT50050572000278XXX02');
var isr6 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060552000005EDC00');
var isr7 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060562000005EDC00');
var isr8 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060572000005EDC00');
var isr9 = ee.Image('LEDAPS/LT5_L1T_SR/LT50060582000029XXX02');
var isr10 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070562000348EDC00');
var isr11 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070572000076EDC00');
var isr12 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070582000348EDC00');
var srColl = ee.ImageCollection.fromImages([isr1, isr2, isr3, isr4, isr5, isr6, isr7, isr8, isr9, 
                                                isr10, isr11, isr12]);

var ims7 = ['LE70040562000023EDC00', 'LE70040572000023EDC00', 'LE70050552000046EDC00', 'LE70050562000110AGS01', 
           'LE70060552000005EDC00', 'LE70060562000005EDC00', 'LE70060572000005EDC00', 'LE70070562000348EDC00', 
           'LE70070572000076EDC00', 'LE70070582000348EDC00'];  
var ims5 = ['LT50050572000278XXX02', 'LT50060582000029XXX02'];

var t7sr = 'LEDAPS/LE7_L1T_SR/';
var t5sr = 'LEDAPS/LT5_L1T_SR/';
var t7toa = 'LANDSAT/LE7_L1T_TOA/';
var t5toa = 'LANDSAT/LT5_L1T_TOA/';
var vizParams453 = {'min': 0, 'max': 4000, 'bands': ['B4', 'B5', 'B3']};

for (var i = 0; i < ims7.length; i++){ 
//  print(t7toa.concat(ims7[i]));
}

var res = t5toa.concat(ims5);
//print(res)

var start_date = '2000-01-01';
var end_date = '2000-12-31';

// Landsat individual scenes
var toaL5 = ee.ImageCollection('LANDSAT/LT5_L1T_TOA')
  .filterDate(start_date, end_date)
  .filterBounds(ee.Geometry.Rectangle(-73.96, 2.512, -67.34, 7.174));

// Landsat individual scenes
var toaL7 = ee.ImageCollection('LANDSAT/LE7_L1T_TOA')
  .filterDate(start_date, end_date)
  .filterBounds(ee.Geometry.Rectangle(-73.96, 2.512, -67.34, 7.174));

// Landsat individual scenes
var srL5 = ee.ImageCollection('LEDAPS/LT5_L1T_SR')
  .filterDate(start_date, end_date)
  .filterBounds(ee.Geometry.Rectangle(-73.96, 2.512, -67.34, 7.174));

// Landsat individual scenes
var srL7 = ee.ImageCollection('LEDAPS/LE7_L1T_SR')
  .filterDate(start_date, end_date)
  .filterBounds(ee.Geometry.Rectangle(-73.96, 2.512, -67.34, 7.174));  
  
// cloud masking function with arbitrary x% threshold
var cloudMask = function(image) {
  var clouds = ee.Algorithms.Landsat.simpleCloudScore(image)
    .select('cloud');
  //var mask = image.mask().and(clouds.lte(40));
  //return image.mask(mask);
  return image.addBands(clouds.lte(10));
};

// map the functions over the collection
/*var cloudMask = collection_toa.map(function(image) {
  return image.add(cloudMask(image));
});*/

var cloudTOAL7 = toaL7.map(function(image) {
  return cloudMask(image);
});
var cloudTOAL5 = toaL5.map(function(image) {
  return cloudMask(image);
});

//print(cloudTOAL7.getInfo());
//print(collection_toa.getInfo());



//var index = cloudTOAL7.toList(220).indexOf(ee.Image('LANDSAT/LE7_L1T_TOA/LE70070582000348EDC00'));
//var img3 = ee.Image(cloudTOAL7.toList(220).get(index));
//var img3 = ee.Image(cloudTOAL5.toList(155).get(index));
//print(img3.getInfo());

//for (var i = 0; i < ims7.length; i++){ 

var addCloudL7 = function(image) {
  var index = toaL7.toList(220).indexOf(ee.Image(t7toa.concat(image.get('LANDSAT_SCENE_ID'))));
  //return index;
  var clouds = ee.Image(cloudTOAL7.toList(220).get(index)).select('cloud');
  
  //var clouds = ee.Algorithms.Landsat.simpleCloudScore(image)
  //  .select('cloud');
  //var mask = image.mask().and(clouds.lte(40));
  //return image.mask(mask);
  return image.addBands(clouds.lte(10));
};


var addedCloudSRL7 = srL7.map(function(image) {
  return addCloudL7(image);
});

print(addedCloudSRL7);

//print(isr1.get('LANDSAT_SCENE_ID'));
//print(addedCloudSRL7.getInfo());


//var index = toaL7.toList(220).indexOf(ee.Image(t7toa.concat(ims7[9])));
//print(index);


//var img4 = ee.Image(cloudTOAL7.toList(220).get(index)).select('cloud');

//}


var isr1 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040562000023EDC00').addBands(ee.Image(cloudTOAL7.toList(220).get(toaL7.toList(220).indexOf(ee.Image('LANDSAT/LE7_L1T_TOA/LE70040562000023EDC00')))).select('cloud'));
/*var isr2 = ee.Image('LEDAPS/LE7_L1T_SR/LE70040572000023EDC00');
var isr3 = ee.Image('LEDAPS/LE7_L1T_SR/LE70050552000046EDC00');
var isr4 = ee.Image('LEDAPS/LE7_L1T_SR/LE70050562000110AGS01');
var isr5 = ee.Image('LEDAPS/LT5_L1T_SR/LT50050572000278XXX02');
var isr6 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060552000005EDC00');
var isr7 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060562000005EDC00');
var isr8 = ee.Image('LEDAPS/LE7_L1T_SR/LE70060572000005EDC00');
var isr9 = ee.Image('LEDAPS/LT5_L1T_SR/LT50060582000029XXX02');
var isr10 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070562000348EDC00');
var isr11 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070572000076EDC00');
var isr12 = ee.Image('LEDAPS/LE7_L1T_SR/LE70070582000348EDC00');
var srColl = ee.ImageCollection.fromImages([isr1, isr2, isr3, isr4, isr5, isr6, isr7, isr8, isr9, 
                                                isr10, isr11, isr12]);*/


//for (var i = 0; i < ims5.length; i++){ 
//var index = toaL5.toList(155).indexOf(ee.Image(t5toa.concat(ims5[9])));
//print(index);


//var img4 = ee.Image(cloudTOAL5.toList(155).get(index)).select('cloud');

//}


Map.addLayer(srColl, vizParams453, 'SR');
Map.addLayer(toaL7.select(['B4','B5','B3']), {gamma:2.3}, 'true color');
//Map.addLayer(cloudTOAL7.select('cloud'), {}, 'mask');
//Map.addLayer(ee.Image('LANDSAT/LE7_L1T_TOA/LE70070582000348EDC00'), {gamma:2.3}, 'img3');
//Map.addLayer(img3, {'bands': ['B4', 'B5', 'B3']}, 'img3_m');
//Map.addLayer(img3, {'bands': ['cloud']}, 'clouds_m');
//Map.addLayer(img4, {}, 'cloud_b');
//Map.addLayer(isr1, vizParams453, 'isr1');
//Map.addLayer(isr1, {'bands': ['cloud']}, 'isr1_c');
Map.addLayer(addedCloudSRL7, vizParams453, 'addedClouds')
Map.addLayer(addedCloudSRL7, {'bands': ['cloud']}, 'addedClouds2')
Map.setCenter(-71.4, 4.4, 8);
