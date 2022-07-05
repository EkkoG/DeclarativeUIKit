#
# Be sure to run `pod lib lint DeclarativeUIKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DeclarativeUIKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of DeclarativeUIKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/3138493/DeclarativeUIKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '3138493' => 'beijiu572@gmail.com' }
  s.source           = { :git => 'https://github.com/3138493/DeclarativeUIKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.3'


  s.subspec 'Core' do |cs|
    cs.source_files = 'DeclarativeUIKit/Classes/Core/**/*'
  end

  s.subspec 'Rx' do |rs|
    rs.source_files = 'DeclarativeUIKit/Classes/Rx/**/*'
    rs.dependency 'RxSwift'
    rs.dependency 'RxCocoa'
  end

  s.subspec 'Combine' do |cs|
    cs.source_files = 'DeclarativeUIKit/Classes/Combine/**/*'
    cs.frameworks = 'Combine'
  end

  s.subspec 'ApplyStyleKit' do |as|
    as.source_files = 'DeclarativeUIKit/Classes/ApplyStyleKit/**/*'
    as.dependency 'ApplyStyleKit'
  end

  s.default_subspec = 'Core' 

  # s.resource_bundles = {
  #   'DeclarativeUIKit' => ['DeclarativeUIKit/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
