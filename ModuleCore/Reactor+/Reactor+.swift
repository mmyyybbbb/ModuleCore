//
//  Reactor+.swift
//  ModuleCore
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import ReactorKit
import RxSwift

public extension Reactor where Self: Coordinatable {
    func inject(_ coordinator: Coordinator) {
        set(coordinator: coordinator)
    }
}


public extension Reactor where Self: Interactable {
    func inject(_ interactor: Interactor) {
        set(interactor: interactor)
    }
}

private var mutationStreamKey = "mutationStream"
private var disposeBagKey = "disposeBag"

public extension Reactor {
    
    var mutationStream: PublishSubject<Mutation> {
        if let object = objc_getAssociatedObject(self, &mutationStreamKey) as? PublishSubject<Mutation> {
            return object
        }
        let object = PublishSubject<Mutation>()
        objc_setAssociatedObject(self, &mutationStreamKey, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return object
    }
    
    var disposeBag: DisposeBag {
        if let object = objc_getAssociatedObject(self, &disposeBagKey) as? DisposeBag {
            return object
        }
        let object = DisposeBag()
        objc_setAssociatedObject(self, &disposeBagKey, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return object
    }
   
    func transform(mutation: RxSwift.Observable<Self.Mutation>) -> RxSwift.Observable<Self.Mutation> {
        return Observable.merge(mutation, mutationStream)
    }
    
    func make(_ mutations: Mutation...) {
        mutations.forEach { [weak self] in self?.mutationStream.onNext($0) }
    }
}

public extension Reactor {
    func subscribeNext<T>(_ observer: Observable<T>, with classFunc: @escaping (Self) -> (T) -> Swift.Void) {
        observer.subscribeNext(self, with: classFunc, bag: disposeBag)
    }
    
    func subscribeNext<T>(_ observer: Observable<T>, do classFunc: @escaping (Self) -> () -> Swift.Void) {
        observer.subscribeNext(self, do: classFunc, bag: disposeBag)
    }
}
