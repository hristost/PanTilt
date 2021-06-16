# PanTilt

[![CI Status](https://img.shields.io/travis/hristost/PanTilt.svg?style=flat)](https://travis-ci.org/hristost/PanTilt)
[![Version](https://img.shields.io/cocoapods/v/PanTilt.svg?style=flat)](https://cocoapods.org/pods/PanTilt)
[![License](https://img.shields.io/cocoapods/l/PanTilt.svg?style=flat)](https://cocoapods.org/pods/PanTilt)
[![Platform](https://img.shields.io/cocoapods/p/PanTilt.svg?style=flat)](https://cocoapods.org/pods/PanTilt)

A structure for describing zoom and a `UIGestureRecognizer` that allows for modifying it.

* Can be used for any view with custom drawing code. Use this when you need to provide a zoom interaction but can't afford a `UIScrollView`
* Gives transformation matrices for converting between screen and context coordinates
* Two-finger gesture supports zoom, pan and tilt

Used in [Amaziograph](https://amaziograph.com).

## Example
![Example project running on simulator](https://github.com/hristost/PanTilt/raw/master/demo.gif)


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
* Swift 5.0
* UIKit

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
