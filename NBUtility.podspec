Pod::Spec.new do |s|
  s.name             = 'NBUtility'
  s.version          = '0.0.2'
  s.summary          = 'Utility files for multiple purposes'

  s.description      = <<-DESC
Utility files for multiple purposes…
                       DESC

  s.homepage         = 'https://github.com/fahidattique55/NBUtility'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Fahid Attique' => 'fahidattique55@gmail.com' }
  s.source           = { :git => 'https://github.com/fahidattique55/NBUtility.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'NBUtility/Classes/**/*.{swift}'

  s.dependency  "Alamofire"
  s.dependency  "ObjectMapper"
  s.dependency  "AlamofireObjectMapper"
  s.dependency  "QorumLogs"

end