platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def pods
  pod 'RxSwift', '4.5'
  pod 'RxCocoa', '4.5'
  pod 'RxDataSources', '3.1.0'
  pod 'ReactorKit', '1.2.1'
  pod 'RxViewController', '0.4.1'
end

target :ModuleCore do
  pods
  
  target :ModuleCoreTests do
    inherit! :search_paths
    pods
    pod 'RxBlocking', '4.5'
  end
end

post_install do |installer|
  
  installer.pods_project.targets.each do |target|
    
    if ['Differentiator', 'RxBlocking', 'RxSwift', 'RxCocoa', 'RxDataSources', 'ReactorKit', 'RxViewController'].include? target.name
      target.build_configurations.each do |config|
        config.build_settings['SWIFT_VERSION'] = '5.0'
      end
    end
    
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
    end
  end
  
end

