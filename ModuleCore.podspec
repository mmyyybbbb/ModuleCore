Pod::Spec.new do |s|
  s.name             = 'ModuleCore'
  s.version          = '2.0.0'
  s.summary          = 'Модуль ModuleCore'
  s.homepage         = 'https://gitlab.com/BCSBroker/iOS/modulecore'
  s.author           = 'BCS'
  s.source           = { :git => 'https://gitlab.com/BCSBroker/iOS/modulecore.git', :tag => s.version.to_s }
  s.license      = { :type => 'MIT', :file => "LICENSE" }
  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'
  s.module_name  = 'ModuleCore'  
  s.source_files  = 'ModuleCore/**/*.swift'
  s.dependency 'RxCocoa', '~> 5.0.1'
  s.dependency 'RxDataSources', '~> 4.0.1'
  s.dependency 'ReactorKit', '~> 2.0.1'
  s.dependency 'RxViewController', '~> 1.0.0' 
end
