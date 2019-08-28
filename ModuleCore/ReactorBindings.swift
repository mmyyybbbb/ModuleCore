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
        reactor.state.map { $0[keyPath: stateKey] }.bind(to: property).disposed(by: disposeBag) 
    }
    
    public func map<T,O>(state: @escaping (R.State) -> T, to property: O) where O : ObserverType, T == O.E {
        reactor.state.map { state($0) }.bind(to: property).disposed(by: disposeBag)
    }
    
    public func map<T>(state: @escaping (R.State) -> T, to property: Binder<T>) {
        reactor.state.map { state($0) }.bind(to: property).disposed(by: disposeBag)
    }
    
    public func map<T>(state: @escaping (R.State) -> T, do handler: @escaping (T) -> Void) {
        reactor.state.map { state($0) }.subscribeNext(handler).disposed(by: disposeBag)
    }

    public func mapIgnoreNil<T>(state: @escaping (R.State) -> T?, do handler: @escaping (T) -> Void) {
        reactor.state.map { state($0) }.ignoreNil().subscribeNext(handler).disposed(by: disposeBag)
    }
    
    public func mapIgnoreNil<T>(state: @escaping (R.State) -> T?, do handler: @escaping (T?) -> Void) {
        reactor.state.map { state($0) }.ignoreNil().subscribeNext(handler).disposed(by: disposeBag)
    }
    
    public func mapIgnoreNil<T>(state: @escaping (R.State) -> T?, to property: Binder<T>) {
        reactor.state.map { state($0) }.ignoreNil().bind(to: property).disposed(by: disposeBag)
    }
    
    public func mapIgnoreNil<T>(state: @escaping (R.State) -> T?, to property: Binder<T?>) {
        reactor.state.map { state($0) }.ignoreNil().bind(to: property).disposed(by: disposeBag)
    }
    
    public func map<T>(_ stateKey: KeyPath<R.State, T>, to property: Binder<T>) {
        reactor.state.map{ $0[keyPath: stateKey] }.bind(to: property).disposed(by: disposeBag)
    }

    public func map<T>(_ stateKey: KeyPath<R.State, T>, to property: ControlProperty<T?>) {
        reactor.state.map{ $0[keyPath: stateKey] }.bind(to: property).disposed(by: disposeBag)
    }
    
    public func map<T>(_ stateKey: KeyPath<R.State, T>, do handler: @escaping (T) -> Void) {
        reactor.state.map{ $0[keyPath: stateKey] }.subscribeNext(handler).disposed(by: disposeBag)
    }
    
    public func fire<T>(action: R.Action, on observable: Observable<T>) {
        mapFire(action: { _ in return action }, on: observable)
    }
    
    public func mapFire<T>(action: @escaping (T) -> R.Action, on observable: Observable<T>) {
        observable.map(action).bind(to: reactor.action).disposed(by: disposeBag)
    }
    
    public func onNext<T>(_ observable: Observable<T>, do handler: @escaping (T) -> Void) {
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
    
    
    // методы с transform
    public func mapFireTransform<T, E>(action: @escaping (T) -> R.Action,
                                       on observable: Observable<E>,
                                       transform: @escaping (E) -> T = { $0 as! T }) {
        
        mapFire(action: action, on: observable.map(transform))
    }
    
    public func mapTransform<T, E>(state: @escaping (R.State) -> T,
                                   transform: @escaping (T) -> E = { $0 as! E },
                                   to property: ControlProperty<E>) {
        
        reactor.state.map { state($0) }.map(transform).bind(to: property).disposed(by: disposeBag)
    }
    
    public func mapTransform<T, E>(_ stateKey: KeyPath<R.State, T>,
                                   transform: @escaping (T) -> E = { $0 as! E },
                                   to property: ControlProperty<E>) {
        
        reactor.state.map { $0[keyPath: stateKey] }.map(transform).bind(to: property).disposed(by: disposeBag)
    }
    
    public func bindTransform<T, E>(action: @escaping (T) -> R.Action,
                                    to property: ControlProperty<E>,
                                    state: ((R.State) -> T)? = nil) {
        
        mapFireTransform(action: action, on: property.asObservable())
        
        guard let state = state else { return }
        mapTransform(state: state, to: property)
    }
    
    public func bindTransform<T, E>(action: @escaping (T) -> R.Action,
                                    to property: ControlProperty<E>,
                                    stateKey: KeyPath<R.State, T>? = nil) {
        
        mapFireTransform(action: action, on: property.asObservable())
        
        guard let stateKey = stateKey else { return }
        mapTransform(stateKey, to: property)
    }
    
    
}
