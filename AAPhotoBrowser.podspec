Pod::Spec.new do |s|

s.name         = "AAPhotoBrowser"
s.version      = "1.2.2"
s.summary      = "iOS 类似微信朋友圈样式的图片浏览器"

s.homepage     = "https://github.com/Fxxxxxx/AAPhotoBrowser"
#s.screenshots  = "https://raw.githubusercontent.com/onevcat/Kingfisher/master/images/logo.png"

s.license      = { :type => "MIT", :file => "LICENSE" }

s.authors            = { "Aaron Feng" => "e2shao1993@163.com" }

s.swift_version = "5"

s.ios.deployment_target = "9.0"

s.source       = { :git => "https://github.com/Fxxxxxx/AAPhotoBrowser.git", :tag => s.version }

s.source_files  = "AAPhotoBrowser/Classes/*.swift"
s.resources  = "AAPhotoBrowser/Assets/*.xcassets"

s.requires_arc = true
s.framework = "UIKit"
s.dependency 'Kingfisher'
s.dependency 'AALRUCache'
s.dependency 'AAHUD'


end










