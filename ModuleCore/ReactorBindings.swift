//
//  ReactorBindings.swift
//  ModuleCore
//
//  Created by alexej_ne on 12/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxSwift
import RxCocoa
import ReactorKit

public final class ReactorBindings<R: SceneReactor> {
    
    private let reactor: R
    private let disposeBag: DisposeBag
    
    public init(reactor: R, defaultDisposeBag: DisposeBag) {
        self.reactor = reactor
        self.disposeBag = defaultDisposeBag
    }
    
    public func map<T,O>(_ stateKey: KeyPath<R.State, T>, to property: O) where O : ObserverType, T == O.E {
        reactor.state.map{ $0[keyPath: stateKey] }.bind(to: property).disposed(by: disposeBag)
    }
    
    public func fire<T>(action: R.Action, on observable: Observable<T>) {
        mapFire(action: { _ in return action }, on: observable)
    }
    
    public func mapFire<T>(action: @escaping (T) -> R.Action, on observable: Observable<T>) {
        observable.map(action).bind(to: reactor.action).disposed(by: disposeBag)
    }
    
    public func onNext<T>(_ observable: Observable<T>, do handler: @escaping (T)->Void) {
        observable.subscribeNext(handler).disposed(by: disposeBag)
    }
}
