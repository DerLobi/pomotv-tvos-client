Pod::Spec.new do |s|

  s.name         = "Alamofire-YamlSwift"
  s.version      = "1.0.0"
  s.summary      = "Add Yaml response serializer to Alamofire"
  s.homepage    = "https://github.com/phimage/Alamofire-YamlSwift"
  s.license     = { :type => "MIT" }
  s.author             = { "phimage" => "eric.marchand.n7@gmail.com" }
  s.osx.deployment_target = "10.9"
  s.ios.deployment_target = "8.0"
  s.tvos.deployment_target = "9.0"

  s.source = { :git => "https://github.com/phimage/Alamofire-YamlSwift.git", :tag => s.version }
  s.source_files = "Alamofire-YamlSwift/*.swift"

  s.dependency 'Alamofire', "~> 3.0"
  s.dependency 'YamlSwift'

end
