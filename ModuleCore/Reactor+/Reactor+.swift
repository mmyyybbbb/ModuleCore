//
//  Reactor+.swift
//  ModuleCore
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import ReactorKit
import RxSwift
import RxCocoa

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
 
    var disposeBag: DisposeBag {
        if let object = objc_getAssociatedObject(self, &disposeBagKey) as? DisposeBag {
            return object
        }
        let object = DisposeBag()
        objc_setAssociatedObject(self, &disposeBagKey, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return object
    }
 
    func subscribeNext<T>(_ observer: Observable<T>, with classFunc: @escaping (Self) -> (T) -> Swift.Void) {
        observer.subscribeNext(self, with: classFunc, bag: disposeBag)
    }
    
    func subscribeNext<T>(_ observer: Observable<T>, do classFunc: @escaping (Self) -> () -> Swift.Void) {
        observer.subscribeNext(self, do: classFunc, bag: disposeBag)
    }
    
    func mutation(_ mutation: Mutation) -> Observable<Mutation> {
        return .just(mutation)
    }
    
    func concat(_ mutations: Mutation...) -> Observable<Mutation> {
        return Observable.concat(mutations.map { just($0)})
    }
    
    func just(_ mutation: Mutation) -> Observable<Mutation>{
        return .just(mutation)
    }
    
    func concat(_ mutations: Mutation..., add obs: Observable<Mutation>) -> Observable<Mutation> {
        return Observable.concat(mutations.map { just($0)}).concat(obs)
    }
    
    func wrapWithDelay(_ mut: SharedSequence<DriverSharingStrategy, Mutation>, delay: RxTimeInterval = 0.1) -> Observable<Mutation> {
        return  mut.asObservable().delaySubscription(delay, scheduler: MainScheduler.instance)
    }
    
    func wrapWithDelay(_ mut: Observable<Mutation>, delay: RxTimeInterval = 0.1) -> Observable<Mutation> {
        return  mut.delaySubscription(delay, scheduler: MainScheduler.instance)
    }
}

