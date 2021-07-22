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

public protocol UnitOfWorkType: AnyObject {
    associatedtype Result
    
    var onComplete: Single<Result> { get }
    var bag: DisposeBag { get }
    var navigator: UINavigationController { get }
}

open class UnitOfWork<Result>: UnitOfWorkType {
    
    private(set) public var bag = DisposeBag()
    
    public weak var firstScene: Scene? {
        didSet {
            firstScene?.associatedUoW = self
        }
    }
    
    public var navigator: UINavigationController {
        set { _navigator = newValue }
        get {
            guard let nav = _navigator else { fatalError() }
            return nav
        }
    }
    
    private weak var _navigator: UINavigationController?
    
    public var onComplete: Single<Result> { return _onComplete.asSingle() }
    private let _onComplete = PublishSubject<Result>()

    public func set(navigator: UINavigationController) {
        self.navigator = navigator
    }
    
    public func set(firstScene: Scene) {
        self.firstScene = firstScene
    }
    
    public func revertUoWStateToInit() {
        navigator.setViewControllers([], animated: false)
        self.firstScene = nil
    }
    
    public func completeUoW(_ result: Result) {
        firstScene?.associatedUoW = nil
        _onComplete.onNext(result)
        _onComplete.onCompleted()
    }
    
    public func interruptUoW(error: Error = InterruptedError()) {
        firstScene?.associatedUoW = nil
        _onComplete.onError(error)
    }
    
    public func popToFirstScene() {
        guard let firstScene = firstScene else {
            debugPrint("UoW firstScene не установлен")
            return
        }
        
        navigator.popToViewController(firstScene, animated: true)
    }
    
    public func dismissOrPopToRoot(completion: (() -> Void)? = nil) {
        guard let firstScene = firstScene else {
            debugPrint("UoW firstScene не установлен")
            return
        }
        
        guard let firstSceneStackIndex = navigator.viewControllers.firstIndex(of: firstScene) else { return  }
        
        if firstSceneStackIndex == 0 {
            navigator.dismiss(animated: true, completion: completion)
            release()
        } else {
            let indexTo = firstSceneStackIndex - 1
            let vc = navigator.viewControllers[indexTo]
            navigator.popToViewController(vc, animated: true, completion: completion)
        }
    }
    
    public func release() {
        _navigator = nil
        firstScene = nil
        bag = DisposeBag()
    }
    
    public init() {}
}

public extension UnitOfWork where Result == Void {
    func completeUoW() {
        completeUoW(())
    }
}

public extension UnitOfWorkType {
    
    func subscribeNext<T>(_ observer: Observable<T>, with classFunc: @escaping (Self) -> (T) -> Swift.Void) {
        observer.subscribeNext(self, with: classFunc, bag: bag)
    }
    
    func subscribeNext<T>(_ observer: Observable<T>, do classFunc: @escaping (Self) -> () -> Swift.Void) {
        observer.subscribeNext(self, do: classFunc, bag: bag)
    }
    
    func subscribe<T>(scene: CompletionScene<T>,
                 onComplete classFunc: @escaping (Self) -> (T) -> Swift.Void,
                 onInterrupt: ((Self) -> (Error?) -> Swift.Void)? = nil) {
        scene.completion
            .subscribe(onNext: { [weak self] arg in
                guard let instance = self else { return }
                let instanceFunction = classFunc(instance)
                instanceFunction(arg)
                }, onError: { [weak self] error in
                    guard let instance = self, let onInterrupt = onInterrupt else { return }
                    let instanceFunction = onInterrupt(instance)
                    instanceFunction(error)
            }).disposed(by: bag)
    }
    
    func subscribe(scene: CompletionScene<Void>,
              onComplete classFunc: @escaping (Self) -> () -> Swift.Void,
              onInterrupt: ((Self) -> (Error?) -> Swift.Void)? = nil ) {
        
        scene.completion
            .subscribe(onNext: { [weak self] in
                guard let instance = self else { return }
                let instanceFunction = classFunc(instance)
                instanceFunction()
                }, onError: { [weak self] error in
                    guard let instance = self, let onInterrupt = onInterrupt else { return }
                    let instanceFunction = onInterrupt(instance)
                    instanceFunction(error)
            }).disposed(by: bag)
    }
    
    func push<T>(_ completionScene: CompletionScene<T>,
                 onComplete classFunc: @escaping (Self) -> (T) -> Swift.Void,
                 onInterrupt: ((Self) -> (Error?) -> Swift.Void)? = nil,
                 animate: Bool = true) {
        navigator.pushViewController(completionScene.scene, animated: animate)
        subscribe(scene: completionScene, onComplete: classFunc, onInterrupt: onInterrupt)
    }
    
    func push(_ completionScene: CompletionScene<Void>,
              onComplete classFunc: @escaping (Self) -> () -> Swift.Void,
              onInterrupt: ((Self) -> (Error?) -> Swift.Void)? = nil,
              animate: Bool = true) {
        navigator.pushViewController(completionScene.scene, animated: animate)
        subscribe(scene: completionScene, onComplete: classFunc, onInterrupt: onInterrupt)
    }
}
