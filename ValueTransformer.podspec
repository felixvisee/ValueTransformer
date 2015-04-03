Pod::Spec.new do |s|
  s.name         = "ValueTransformer"
  s.version      = "1.0.2"
  s.summary      = "Type-safe value transformers with error handling"
  s.homepage     = "https://github.com/felixjendrusch/ValueTransformer"
  s.license      = "MIT"
  s.author       = { "Felix Jendrusch" => "felix@felixjendrusch.is" }
  s.social_media_url = "http://twitter.com/felixjendrusch"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.source       = { :git => "https://github.com/felixjendrusch/ValueTransformer.git", :tag => s.version }
  s.source_files = "ValueTransformer/*.swift"
  s.dependency     "LlamaKit", "~> 0.5.0"
end
