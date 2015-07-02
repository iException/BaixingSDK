#
# Be sure to run `pod lib lint BaixingSDK.podspec' to ensure this is a
# valid spec and remove all comments before submitting the spec.
#
# Any lines starting with a # are optional, but encouraged
#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "BaixingSDK"
  s.version          = "1.0.1"
  s.summary          = "It is a baixing base library."
  s.description      = "It is a baixing base library. Join us:shaozhengxingok@126.com"
  s.homepage         = "https://github.com/iException/BaixingSDK"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "phoebus" => "shaozhengxingok@126.com" }
  s.source           = { :git => "https://github.com/iException/BaixingSDK.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'BaixingSDK' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.library = 'sqlite3'
  s.dependency 'AFNetworking', '2.5.4'
  s.dependency 'FMDB', '2.5'
end
