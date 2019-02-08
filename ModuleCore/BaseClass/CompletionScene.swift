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
    public let onComplete: Observable<T>
    public let onInterrupt: Observable<Void>
    
    // Сцена может предоставлять кастомную функцию для ее презентации, (Так работает SmsVC)
    let customModalPresentatioin: CustomPresentationFunc?
    
    public init(_ scene: Scene, _ vm: CompletableReactor<T>, customPresentation: CustomPresentationFunc? = nil) {
        self.scene = scene
        self.onComplete = vm.onComplete
        self.onInterrupt = vm.onInterrupt
        self.customModalPresentatioin = customPresentation
    }
}
