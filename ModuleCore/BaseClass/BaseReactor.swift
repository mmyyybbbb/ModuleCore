//
//  BaseReactor.swift
//  ModuleCore
//
//  Created by alexej_ne on 08/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import ReactorKit
import RxSwift

open class BaseReactor {
    public init() {}
}

private var mutationStreamKey = "mutationStream"

extension BaseReactor: AssociatedStore {}

public extension Reactor where Self: BaseReactor {
    
    var mutationStream: PublishSubject<Mutation> { return self.associatedObject(forKey: &mutationStreamKey, default: PublishSubject<Mutation>()) }
    
    func transform(mutation: RxSwift.Observable<Self.Mutation>) -> RxSwift.Observable<Self.Mutation> {
        return Observable.merge(mutation, mutationStream)
    }
    
    func make(_ mutations: Mutation...) {
        mutations.forEach { [weak self] in self?.mutationStream.onNext($0) }
    }
}
