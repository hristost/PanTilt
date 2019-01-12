#
# Be sure to run `pod lib lint PanTilt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PanTilt'
  s.version          = '0.2.1'
  s.summary          = 'A structure for describing zoom and a gesture recognizer that allows for modifying it'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
A structure for describing zoom and a gesture recognizer that allows for modifying it
* Can be incorporated into any view used for displaying a photo, drawing canvas, etc.
* Gives transformation matrices for converting between screen and context coordinates
* Two-finger gesture supports zoom, pan and tilt
                       DESC

  s.homepage         = 'https://github.com/hristost/PanTilt'
  # s.screenshots     = 'https://github.com/hristost/PanTilt/blob/master/demo.gif?raw=true'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hristost' => 'hristo.staykov@gmail.com' }
  s.source           = { :git => 'https://github.com/hristost/PanTilt.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'

  s.source_files = 'PanTilt/Classes/**/*'
  
  # s.resource_bundles = {
  #   'PanTilt' => ['PanTilt/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'SwifterSwift/CoreGraphics'

end
