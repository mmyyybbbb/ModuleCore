//
//  CompletionScene.swift
//  ModuleCore
//
//  Created by alexej_ne on 06/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift
public typealias Presenter = UIViewController
public typealias Next = Void
public typealias CustomPresentationFunc = (Presenter) -> Void

open class CompletionScene<T> {
    public let scene: Scene
    public let completion: Observable<T>
    
    // Сцена может предоставлять кастомную функцию для ее презентации
    public let customModalPresentatioin: CustomPresentationFunc?
    
    public init(_ scene: Scene, _ reactor: CompletableReactor<T>, customPresentation: CustomPresentationFunc? = nil) {
        self.scene = scene
        self.completion = reactor.onComplete
        self.customModalPresentatioin = customPresentation
    }
    
    public init(_ scene: Scene, completion: Observable<T>, customPresentation: CustomPresentationFunc? = nil) {
        self.scene = scene
        self.completion = completion
        self.customModalPresentatioin = customPresentation
    }
    
    open func present(by presenter: UIViewController) {
        if let custom = customModalPresentatioin {
            custom(presenter)
        } else {
            presenter.present(scene, animated: true, completion: nil)
        }
    }
     
    @discardableResult
    public func dismissOnComplete() -> Self {
        guard let disposHolderScene = scene as? DisposeBagHolder else { return self }
        
        completion.subscribeNext { [weak scene] _  in
            scene?.dismiss(animated: true, completion: nil) }
            .disposed(by: disposHolderScene.disposeBag)
        return self
    }
}
