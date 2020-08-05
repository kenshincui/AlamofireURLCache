#
# Be sure to run `pod lib lint AlamofireURLCache.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'AlamofireURLCache'
    s.version          = '0.5.0'
    s.summary          = 'Alamofire network library URLCache-based cache extension'
    s.description      = <<-DESC
    AlamofireURLCache can cooperate with Alamofire to easily realize data request caching (based on URLCache) without modifying your code logic.
                         DESC
    s.homepage         = 'https://github.com/kenshincui/AlamofireURLCache.git'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'kenshincui' => 'kenshincui@hotmail.com' }
    s.source           = { :git => 'https://github.com/kenshincui/AlamofireURLCache.git', :tag => s.version.to_s }
    s.swift_version = '5.2'
    s.ios.deployment_target = '10.0'
    s.source_files = 'AlamofireURLCache/*.{h,swift}','Debugger/**/*.{h,swift}'
    s.dependency 'Alamofire','~> 5.2'
  end
  
