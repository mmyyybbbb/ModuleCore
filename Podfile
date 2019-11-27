platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def pods
  pod 'RxCocoa', '~> 5.0.1'
  pod 'RxDataSources', '~> 4.0.1'
  pod 'ReactorKit', '~> 2.0.1'
  pod 'RxViewController', '~> 1.0.0'
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

