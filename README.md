# react-native-image-cropping

Simple react-native image cropping library wrapper around [TimOliver/TOCropViewController](https://github.com/TimOliver/TOCropViewController)

![TOCropViewController](https://raw.githubusercontent.com/TimOliver/TOCropViewController/master/Images/screenshot.jpg)

## Installation

```sh
npm i https://github.com/vyoo/react-native-image-cropping
react-native link react-native-image-cropping
```

## Supported platforms

Supported only on iOS.

## Usage

### Import module

```javascript
import ReactNativeImageCropping from 'react-native-image-cropping';
```

### Crop the image

It is using RCTImageLoader so it should be able to crop any image that react knows how to load / display.

#### Without aspect ratio restriction:

```javascript
const originalImage = require('CrazyFlowers.jpg');

ReactNativeImageCropping.cropImageWithUrl(originalImage.uri).then(
	image => {
		//Image is saved in NSTemporaryDirectory!
		//image = {uri, width, height}
	},
	err => console.log(err)
);
```

#### Lock to specific aspect ratio:

Available aspect ratios:

```javascript
AspectRatioOriginal;
AspectRatioSquare;
AspectRatio3x2;
AspectRatio5x4;
AspectRatio4x3;
AspectRatio5x4;
AspectRatio7x5;
AspectRatio16x9;
```

Example:

```javascript
const aspectRatio = ReactNativeImageCropping.AspectRatioSquare;

ReactNativeImageCropping.cropImageWithUrlAndAspect(imageUrl, aspectRatio).then(
	image => {
		//Image is saved in NSTemporaryDirectory!
		//image = {uri, width, height}
	},
	err => console.log(err)
);
```
