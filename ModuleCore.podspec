Pod::Spec.new do |s|
  s.name             = 'ModuleCore'
  s.version          = '2.3.1'
  s.summary          = 'Архитектура для создания модулей'
  s.homepage         = 'https://github.com/BCS-Broker/ModuleCore'
  s.author           = 'BCS-Broker'
  s.source           = { :git => 'https://github.com/BCS-Broker/ModuleCore.git', :tag => s.version.to_s }
  s.license      = { :type => 'MIT', :file => "LICENSE" }
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  s.module_name  = 'ModuleCore'  
  s.source_files  = 'ModuleCore/**/*.swift'
  s.dependency 'RxCocoa', '~> 6.0.0'
  s.dependency 'RxDataSources', '~> 5.0.0'
  s.dependency 'ReactorKit', '~> 3.0.0'
  s.dependency 'RxViewController', '~> 2.0.0'
end
