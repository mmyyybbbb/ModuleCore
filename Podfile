platform :ios, '12.0'
use_frameworks!
inhibit_all_warnings!
install! 'cocoapods', :warn_for_unused_master_specs_repo => false

def pods
  pod 'RxCocoa', '~> 6.0.0'
  pod 'RxDataSources', '~> 5.0.0'
  pod 'ReactorKit', '~> 3.0.0'
  pod 'RxViewController', '~> 2.0.0'
end

target :ModuleCore do
  pods
  
  target :ModuleCoreTests do
    inherit! :search_paths
    pods
    pod 'RxBlocking'
  end
end

post_install do |installer|
  
  installer.pods_project.targets.each do |target|
    
    if ['Differentiator', 'RxBlocking', 'RxSwift', 'RxCocoa', 'RxDataSources', 'ReactorKit', 'RxViewController'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.3'
      end
    end
    
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
  
end

