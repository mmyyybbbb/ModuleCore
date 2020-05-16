Pod::Spec.new do |s|
  s.name             = 'ModuleCore'
  s.version          = '2.1.12'
  s.summary          = 'Архитектура для создания модулей'
  s.homepage         = 'https://github.com/BCS-Broker/ModuleCore'
  s.author           = 'BCS-Broker'
  s.source           = { :git => 'https://github.com/BCS-Broker/ModuleCore.git', :tag => s.version.to_s }
  s.license      = { :type => 'MIT', :file => "LICENSE" }
  s.ios.deployment_target = '10.0'
  s.swift_version = '5.0'
  s.module_name  = 'ModuleCore'  
  s.source_files  = 'ModuleCore/**/*.swift'
  s.dependency 'RxCocoa', '~> 5.1.0'
  s.dependency 'RxDataSources', '~> 4.0.1'
  s.dependency 'ReactorKit', '~> 2.0.1'
  s.dependency 'RxViewController', '~> 1.0.0' 
end
