//
//  View+.swift
//  ModuleCore
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import ReactorKit
import RxSwift
import RxCocoa
 
public extension SceneView {
    var rctr: Reactor {
        guard let vm = reactor else { fatalError() }
        return vm
    }
    
    func inject(_ sr: Reactor) {
        reactor = sr
    }
    
    func fire(action: Reactor.Action) {
        reactor?.action.onNext(action)
    }
    
    func fireActionCallBack(_ action: Reactor.Action) -> () -> () {
        return { [weak self] in self?.reactor?.action.onNext(action) }
    }
 
    func subscribeNext<T>(_ observer: Observable<T>, with classFunc: @escaping (Self) -> (T) -> Swift.Void) {
        observer.subscribeNext(self, with: classFunc, bag: disposeBag)
    }
    
    func subscribeNext<T>(_ observer: Observable<T>, do classFunc: @escaping (Self) -> () -> Swift.Void) {
        observer.subscribeNext(self, do: classFunc, bag: disposeBag)
    }
    
    func bindState<T,O>(_ key: KeyPath<Reactor.State, T>, to observer: O) where O: ObserverType, O.Element == T {
        rctr.state.map { $0[keyPath: key] }.bind(to: observer).disposed(by: disposeBag)
    }
}

