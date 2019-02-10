//
//  UoW.swift
//  MyBroker
//
//  Created by alexej_ne on 13.08.2018.
//  Copyright © 2018 BCS. All rights reserved.
//

import RxSwift

private var associatedUoWKey = "associatedUoWKey"

extension Scene {
    fileprivate var associatedUoW: Any? {
        get { return self.associatedObject(forKey: &associatedUoWKey, default: nil) }
        set { self.setAssociatedObject(newValue, forKey: &associatedUoWKey) }
    }
}

public protocol UnitOfWorkType: class {
    associatedtype Result
    
    var onComplete: Single<Result> { get }
    var bag: DisposeBag { get }
    var navigator: UINavigationController { get }
    
    func start(navigator: UINavigationController, animate: Bool)
}

open class UnitOfWork<Result>: UnitOfWorkType {
    
    private(set) public var bag = DisposeBag()
    weak var firstScene: Scene? {
        didSet {
            firstScene?.associatedUoW = self
        }
    }
    
    public var navigator: UINavigationController {
        guard let nav = _navigator else { fatalError() }
        return nav
    }
    
    private weak var _navigator: UINavigationController?
    
    public var onComplete: Single<Result> { return _onComplete.asSingle() }
    private let _onComplete = PublishSubject<Result>()
    
    public func start(navigator: UINavigationController, animate: Bool) {
        self._navigator = navigator
    }
    
    func completeUoW(_ result: Result) {
        firstScene?.associatedUoW = nil
        _onComplete.onNext(result)
    }
    
    func interruptUoW(error: Error = InterruptedError()) {
        firstScene?.associatedUoW = nil
        _onComplete.onError(error)
    }
    
    func popToFirstScene() {
        guard let firstScene = firstScene else {
            debugPrint("UoW firstScene не установлен")
            return
        }
        
        navigator.popToViewController(firstScene, animated: true)
    }
    
    public init() {}
}

extension UnitOfWork where Result == Void {
    func completeUoW() {
        completeUoW(())
    }
}

extension UnitOfWorkType {
    
    func subscribeNext<T>(_ observer: Observable<T>, with classFunc: @escaping (Self) -> (T) -> Swift.Void) {
        observer.subscribeNext(self, with: classFunc, bag: bag)
    }
    
    func subscribeNext<T>(_ observer: Observable<T>, do classFunc: @escaping (Self) -> () -> Swift.Void) {
        observer.subscribeNext(self, do: classFunc, bag: bag)
    }
//
//    //TODO: ----- проверить нужность ------
//    func push<T>(_ completionScene: CompletionScene<T>, onComplete classFunc: @escaping (Self) -> (T) -> Swift.Void,
//                 onInterrupt: ((Self) -> () -> Swift.Void)? = nil, animate: Bool = true) {
//        navigator.pushViewController(completionScene.scene, animated: animate)
//        subscribeNext(completionScene.onComplete.asObservable(), with: classFunc)
//        guard let onInterrupt = onInterrupt else { return }
//        subscribeNext(completionScene.onInterrupt.asObservable(), do: onInterrupt)
//    }
//
//    func push(_ completionScene: CompletionScene<Void>, onComplete classFunc: @escaping (Self) -> () -> Swift.Void,
//              onInterrupt: ((Self) -> () -> Swift.Void)? = nil, animate: Bool = true) {
//        navigator.pushViewController(completionScene.scene, animated: animate)
//        subscribeNext(completionScene.onComplete.asObservable(), do: classFunc)
//        guard let onInterrupt = onInterrupt else { return }
//        subscribeNext(completionScene.onInterrupt.asObservable(), do: onInterrupt)
//    }
//    //------------------------------
//
//    func push<T>(_ completionScene: CompletionScene<T>, onComplete classFunc: @escaping (Self) -> (T) -> Swift.Void, animate: Bool = true) {
//        navigator.pushViewController(completionScene.scene, animated: animate)
//        subscribeNext(completionScene.onComplete, with: classFunc)
//    }
//
//    func push(_ completionScene: CompletionScene<Void>, onComplete classFunc: @escaping (Self) -> () -> Swift.Void, animate: Bool = true) {
//        navigator.pushViewController(completionScene.scene, animated: animate)
//        subscribeNext(completionScene.onComplete, do: classFunc)
//    }
//
//    func push<T>(_ uow: UnitOfWork<T>, onComplete classFunc: @escaping (Self) -> (T) -> Swift.Void, animate: Bool = true) {
//        uow.start(navigator: navigator, animate: true)
//        subscribeNext(uow.onComplete, with: classFunc)
//    }
//    
//    func push(_ uow: UnitOfWork<Void>, onComplete classFunc: @escaping (Self) -> () -> Swift.Void, animate: Bool = true) {
//        uow.start(navigator: navigator, animate: true)
//        subscribeNext(uow.onComplete, do: classFunc)
//    }
}
