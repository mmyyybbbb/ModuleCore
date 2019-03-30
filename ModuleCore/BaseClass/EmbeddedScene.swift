//
//  EmbeddedScene.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 30/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxSwift
import ReactorKit

public final class EmbeddedScene {
    private let bag = DisposeBag()
    public fileprivate(set) var state = DataState.none
 
    public let scene: Scene
    public let isLoading: Observable<Bool>
    public let loadData = PublishSubject<Void>()
    public let dataState: Observable<DataState>
    
    public private(set) var wasFirstLoading: Bool = false
    
    public func reloadData() {
        loadData.onNext(())
    }
    
    fileprivate init(scene: Scene,
                     isLoading: Observable<Bool>,
                     dataState: Observable<DataState>,
                     loadData: PublishSubject<Void>) {
        self.scene = scene
        self.isLoading  = isLoading
        self.dataState = dataState
        
        self.dataState.subscribeNext(self, with: EmbeddedScene.dataStateChanged, bag: bag)
    }
    
    private func dataStateChanged(state: DataState) {
        self.state = state
        self.wasFirstLoading = true 
    }
}

public extension SceneReactor {
    
    func buildEmbeddedScene(for scene: Scene,
                                   loadDataAction: Action,
                                   isLoadingKey: KeyPath<State, Bool>,
                                   dataStateKey: KeyPath<State, DataState>) -> EmbeddedScene {
        let isLoadingObservable = self.state.map { $0[keyPath: isLoadingKey]}
        let dataStateObservable = self.state.map { $0[keyPath: dataStateKey]}
        
        let loadData = PublishSubject<Void>()
        
        loadData.asObservable().map { loadDataAction }.bind(to: self.action).disposed(by: disposeBag)
 
        return EmbeddedScene(scene: scene,
                             isLoading: isLoadingObservable,
                             dataState: dataStateObservable,
                             loadData: loadData)
    }
}
