platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

def pods
  pod 'RxSwift', '~> 4.4.0'
  pod 'RxCocoa', '~> 4.4.0'
  pod 'RxDataSources', '~> 3.1.0'
  pod 'ReactorKit', '~> 1.2.1'
end

target :ModuleCore do
  pods
  
  target :ModuleCoreTests do
    inherit! :search_paths
    pods
    pod 'RxBlocking', '4.4'
  end
end
