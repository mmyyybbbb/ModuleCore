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

public class CompletionScene<T> {
    public let scene: Scene
    public let completion: Single<T>
    
    // Сцена может предоставлять кастомную функцию для ее презентации
    let customModalPresentatioin: CustomPresentationFunc?
    
    public init(_ scene: Scene, _ reactor: CompletableReactor<T>, customPresentation: CustomPresentationFunc? = nil) {
        self.scene = scene
        self.completion = reactor.onComplete
        self.customModalPresentatioin = customPresentation
    }
    
    public init(_ scene: Scene, interact: Single<T>, customPresentation: CustomPresentationFunc? = nil) {
        self.scene = scene
        self.completion = interact
        self.customModalPresentatioin = customPresentation
    }
}
