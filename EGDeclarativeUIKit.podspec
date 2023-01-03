#
# Be sure to run `pod lib lint DeclarativeUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'EGDeclarativeUIKit'
  s.version          = '0.1.0'
  s.summary          = 'Declarative UIKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Declarative UIKit with 200 line of code.
                       DESC

  s.homepage         = 'https://github.com/EkkoG/DeclarativeUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'EkkoG' => 'beijiu572@gmail.com' }
  s.source           = { :git => 'https://github.com/EkkoG/DeclarativeUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'


  s.subspec 'Core' do |cs|
    cs.source_files = 'DeclarativeUIKit/Classes/Core/**/*'
  end

  s.subspec 'Ext' do |cs|
    cs.source_files = 'DeclarativeUIKit/Classes/Ext/**/*'
    cs.dependency 'EGDeclarativeUIKit/Core'
  end

  s.subspec 'Rx' do |rs|
    rs.source_files = 'DeclarativeUIKit/Classes/Rx/**/*'
    rs.dependency 'RxSwift'
    rs.dependency 'RxCocoa'
    rs.dependency 'EGDeclarativeUIKit/Core'
  end

  s.subspec 'Combine' do |cs|
    cs.source_files = 'DeclarativeUIKit/Classes/Combine/**/*'
    cs.frameworks = 'Combine'
    cs.dependency 'EGDeclarativeUIKit/Core'
  end

  s.subspec 'SnapKit' do |ss|
    ss.source_files = 'DeclarativeUIKit/Classes/SnapKit/**/*'
    ss.dependency 'SnapKit'
    ss.dependency 'EGDeclarativeUIKit/Core'
    ss.dependency 'EGDeclarativeUIKit/Ext'
  end

  s.subspec 'Chainable' do |ss|
    ss.source_files = 'DeclarativeUIKit/Classes/Chainable/**/*'
    ss.dependency 'EGChainable'
    ss.dependency 'EGDeclarativeUIKit/Core'
  end

  s.default_subspec = 'Core', 'Ext' 

  # s.resource_bundles = {
  #   'DeclarativeUIKit' => ['DeclarativeUIKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
