platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

target :ModuleCore do
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'ReactorKit'
  
  target :ModuleCoreTests do
    inherit! :search_paths
    pod 'RxSwift'
  	pod 'RxCocoa'
  	pod 'ReactorKit'
    pod 'RxBlocking'
  end
end
