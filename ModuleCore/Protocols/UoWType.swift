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
    public weak var firstScene: Scene? {
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
    
    open func start(navigator: UINavigationController, animate: Bool) {
        self._navigator = navigator
    }
    
    public func completeUoW(_ result: Result) {
        firstScene?.associatedUoW = nil
        _onComplete.onNext(result)
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
}
