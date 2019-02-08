//
//  CompletableScene.swift
//  ModuleCore
//
//  Created by alexej_ne on 06/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift
import RxCocoa

public class CompletableReactor<T>  {
    
    private let _onComplete = PublishSubject<T>()
    public lazy var onComplete: Observable<T> = { return _onComplete.asObserver() }()
    
    private let _onInterrupt = PublishSubject<Void>()
    public lazy var onInterrupt: Observable<Void> = { return _onInterrupt.asObserver() }()
    
    public func complete(_ result: T) {
        _onComplete.onNext(result)
    }
    
    public func interrupt() {
        _onInterrupt.onNext(())
    }
}

extension CompletableReactor where T == Void {
    public func complete() {
        complete(())
    }
}
