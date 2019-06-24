require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = 'ReactNativeImageCropping'
  s.version      = package['version']
  s.summary      = package['description']

  s.authors      = 'vyoo'
  s.homepage     = 'https://github.com/Vyoo/react-native-image-cropping'
  s.license      = 'MIT'
  s.platform     = :ios, "8.0"

  s.source       = { :git => 'https://github.com/Vyoo/react-native-image-cropping' }
  s.source_files = '*.{h,m}'

  s.dependency 'React'
  s.dependency 'TOCropViewController'

end