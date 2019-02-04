Pod::Spec.new do |s|
  s.name             = 'BCSBroker/ModuleCore'
  s.version          = '1.0'
  s.summary          = 'Модуль ModuleCore'
  s.homepage         = 'https://gitlab.com/BCSBroker/iOS/modulecore'
  s.author           = 'BCS'
  s.source           = { :git => 'https://gitlab.com/BCSBroker/iOS/modulecore.git', :tag => s.version.to_s }
  s.license      = { :type => 'MIT', :file => "LICENSE" }
  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'
  s.module_name  = 'ModuleCore'  
  s.source_files  = 'ModuleCore/**/*.swift' 
  s.dependency 'RxCocoa'
  s.dependency 'RxSwift'
  s.dependency 'ReactorKit'
end
