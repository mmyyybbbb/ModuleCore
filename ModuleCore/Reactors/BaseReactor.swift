//
//  BaseReactor.swift
//  ModuleCore
//
//  Created by alexej_ne on 08/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import ReactorKit
import RxSwift
import RxCocoa

open class BaseReactor {
    public init() {} 
}

private var mutationStreamKey = "mutationStream"

extension BaseReactor: AssociatedStore {  }

public extension Reactor where Self: BaseReactor {
    
    var mutationStream: PublishSubject<Mutation> { return self.associatedObject(forKey: &mutationStreamKey, default: PublishSubject<Mutation>()) }
    
    func transform(mutation: RxSwift.Observable<Self.Mutation>) -> RxSwift.Observable<Self.Mutation> {
        return Observable.merge(mutation, mutationStream)
    }
    
    func make(_ mutations: Mutation...) {
        mutations.forEach { [weak self] in self?.mutationStream.onNext($0) }
    }
    
    func interact<T>(_ observable: Single<T>,
                     skipIfTrue: Bool = false,
                     complete: @escaping (Self) -> (T) -> Void,
                     error: ((Self) -> (Error) -> Void)? = nil,
                     inProgress: ((Bool) -> Mutation)? = nil,
                     bag: DisposeBag? = nil) {
        guard skipIfTrue == false else { return }
        
        var obs = observable
        
        if let inProgress = inProgress {
            make(inProgress(true))
            obs = observable.do(onSuccess: { [weak self] _ in self?.make(inProgress(false)) },
                                onError: { [weak self] _ in self?.make(inProgress(false)) })
        }
        
        subscribe(obs, complete: complete, error: error, bag: bag)
    }

    func interact<T>(_ observable: Single<T>,
                     skipIfTrue: Bool = false,
                     complete: @escaping (Self) -> () -> Void,
                     error: ((Self) -> (Error) -> Void)? = nil,
                     inProgress: ((Bool) -> Mutation)? = nil,
                     bag: DisposeBag? = nil) {
        guard skipIfTrue == false else { return }

        var obs = observable

        if let inProgress = inProgress {
            make(inProgress(true))
            obs = observable.do(onSuccess: { [weak self] _ in self?.make(inProgress(false)) },
                                onError: { [weak self] _ in self?.make(inProgress(false)) })
        }

        subscribe(obs, complete: complete, error: error, bag: bag)
    }
 
    func subscribeNext<T>(_ observer: Observable<T>, makeMutation: @escaping (T) -> Mutation) {
        observer.subscribe(onNext: { [weak self] (data) in
            let mutatation = makeMutation(data)
            self?.make(mutatation)
        }).disposed(by: disposeBag)
    }
    
    func interact<T>(_ observer: Single<T>,
                     makeMutation: @escaping (T) -> Mutation,
                     inProgress: ((Bool) -> Mutation)? = nil,
                     onError: ((Self) -> (Error) -> Void)? = nil) {
        
        var obs = observer

        if let inProgress = inProgress {
            make(inProgress(true))
            obs = observer.do(onSuccess: { [weak self] _ in self?.make(inProgress(false)) },
                                onError: { [weak self] _ in self?.make(inProgress(false)) })
        }

        
        obs.subscribe(onSuccess: { [weak self] (data) in
            let mutatation = makeMutation(data)
            self?.make(mutatation)
            }, onError: { [weak self] error in
                guard let instance = self, let errClassFunc = onError else { return }
                let instanceFunction = errClassFunc(instance)
                instanceFunction(error)
        }).disposed(by: disposeBag)
    }
    
}
