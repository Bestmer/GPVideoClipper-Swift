Pod::Spec.new do |spec|

  spec.name         = "GPVideoClipper-Swift"
  spec.version      = "1.0.1"
  spec.summary      = "iOS long video clip tool, similar to WeChat moments and tiktok."
  spec.description  = <<-DESC
                   iOS long video clip tool, similar to WeChat moments select and edit videos larger than 15s from albums, 
                   and support saving as a local album.
                   DESC

  spec.homepage      = "https://github.com/Bestmer"
  spec.license       = "MIT"
  spec.platform       = :ios, "8.0"
  spec.author        = { "RocKwok" => "guopengios@163.com" }
  spec.source        = { :git => "https://github.com/Bestmer/GPVideoClipper-Swift.git", :tag => "#{spec.version}" }
  spec.source_files  = "GPVideoClipper/**/*.{swift}"
  spec.exclude_files = "GPVideoClipper/Exclude"
  spec.swift_version = '5.0'

end
