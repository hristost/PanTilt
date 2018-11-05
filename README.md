# PanTilt

[![CI Status](https://img.shields.io/travis/hristost/PanTilt.svg?style=flat)](https://travis-ci.org/hristost/PanTilt)
[![Version](https://img.shields.io/cocoapods/v/PanTilt.svg?style=flat)](https://cocoapods.org/pods/PanTilt)
[![License](https://img.shields.io/cocoapods/l/PanTilt.svg?style=flat)](https://cocoapods.org/pods/PanTilt)
[![Platform](https://img.shields.io/cocoapods/p/PanTilt.svg?style=flat)](https://cocoapods.org/pods/PanTilt)

A structure for describing zoom and a gesture recognizer that allows for modifying it
* Can be incorporated into any view used for displaying a photo, drawing canvas, etc.
* Gives transformation matrices for converting between screen and context coordinates
* Two-finger gesture supports zoom, pan and tilt

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Implementation

1. Make your view conform to `ZoomableView`
2. At each drawing pass, use the `canvasToView()` function of the `zoom` property to get a matrix for drawing your content
3. Initialise and attach a  `PanTiltGestureRecognizer` to your view
4. (Optional) You can make the gesture delegate conform to `PanTiltGestureRecognizerDelegate` if you want to handle events such 
as start or update of zoom gesture. 
5. (Optional) You can restrict the zoom range by creating an object implementing the `PanTiltGestureRecognizerZoomDelegate` and 
attaching it to the `zoomSnap` property of the gesture. You can see how this is done in the example project.

## Requirements
* Swift 4.2

This is an iOS project, but is should be easy to adapt it for macOS too if needed.

## Installation

PanTilt is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'PanTilt'
```

## Author

hristost, hristo.staykov@gmail.com

## License

PanTilt is available under the MIT license. See the LICENSE file for more info.
