Pod::Spec.new do |s|

  s.name         = "WSMoveToPhotos"
  s.version      = "0.0.1"
  s.summary      = “拖懂显示图片"

  s.description  = <<-DESC
       拖懂显示图片
                   DESC

  s.homepage     = "http://EXAMPLE/WSMoveToPhotos"
  s.license      = "MIT"
  s.author       = { "water" => “water869219@163.com" }
  s.platform     = :ios,'6.0'

   s.source       = { :git => "http://EXAMPLE/WSMoveToPhotos.git", :tag => "#{s.version}" }
  s.source_files = "WSMoveToPhotos/Classes/*.{h,m}"
  s.framework    = "UIKit"
  s.requires_arc = true
end