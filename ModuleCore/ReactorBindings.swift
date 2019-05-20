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
    
    public let reactor: R
    public let disposeBag: DisposeBag
    
    public init(reactor: R, defaultDisposeBag: DisposeBag) {
        self.reactor = reactor
        self.disposeBag = defaultDisposeBag
    }
    
    public convenience init<S:SceneView>(_ sceneView: S) where S.Reactor == R {
        self.init(reactor: sceneView.reactor!, defaultDisposeBag: sceneView.disposeBag)
    }
    
    public func map<T,O>(_ stateKey: KeyPath<R.State, T>, to property: O) where O : ObserverType, T == O.E {
        reactor.state.map{ $0[keyPath: stateKey] }.bind(to: property).disposed(by: disposeBag) 
    }
    
    public func map<T>(state: @escaping (R.State) -> T, to property: Binder<T>) {
        reactor.state.map { state($0) }.bind(to: property).disposed(by: disposeBag)
    }
    
    public func map<T>(_ stateKey: KeyPath<R.State, T>, to property: Binder<T>) {
        reactor.state.map{ $0[keyPath: stateKey] }.bind(to: property).disposed(by: disposeBag)
    }
    
    public func map<T>(_ stateKey: KeyPath<R.State, T>, do handler: @escaping (T)->Void) {
        reactor.state.map{ $0[keyPath: stateKey] }.subscribeNext(handler).disposed(by: disposeBag)
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
    
    public func mapIgnoreNil<T>(_ stateKey: KeyPath<R.State, T?>, to property: Binder<T>) {
        reactor.state.map{ $0[keyPath: stateKey] }.ignoreNil().bind(to: property).disposed(by: disposeBag)
    }
    
    public func mapIgnoreNil<T>(_ stateKey: KeyPath<R.State, T?>, to property: Binder<T?>) {
        reactor.state.map{ $0[keyPath: stateKey] }.ignoreNil().bind(to: property).disposed(by: disposeBag)
    }
    
    public func bind<T>(to property: ControlProperty<T>,
                        action: @escaping   (T) -> R.Action,
                        state: ((R.State) -> T)? = nil) {
        property
            .asObservable()
            .map(action)
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        guard let state = state else { return }
        reactor.state.map(state)
            .observeOn(MainScheduler.asyncInstance)
            .bind(to: property)
            .disposed(by: disposeBag)
    }
    
}
