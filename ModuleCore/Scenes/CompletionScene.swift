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
    open let scene: Scene
    open let completion: Observable<T>
    
    // Сцена может предоставлять кастомную функцию для ее презентации
    open let customModalPresentatioin: CustomPresentationFunc?
    
    open init(_ scene: Scene, _ reactor: CompletableReactor<T>, customPresentation: CustomPresentationFunc? = nil) {
        self.scene = scene
        self.completion = reactor.onComplete
        self.customModalPresentatioin = customPresentation
    }
    
    open init(_ scene: Scene, completion: Observable<T>, customPresentation: CustomPresentationFunc? = nil) {
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
}
