//
//  DataLoadReactor.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 14/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxSwift
import RxCocoa
import ReactorKit

public final class DataLoadReactor<T>: CompletableReactor<T>, SceneReactor {
    public enum Action {
        case load
        case interrupt
    }
    
    public enum Mutation {
        case inProgress(Bool)
    }
    
    public struct State {
        public let inProgress: Bool = false 
    }
    
    public var initialState = State()
    
    private let dataLoader: Single<T>
    
    public init(dataLoader: Single<T>) {
        self.dataLoader = dataLoader
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .load:
             interact(dataLoader,
                      complete: DataLoadReactor<T>.loaded,
                      error: DataLoadReactor<T>.error,
                      inProgress: Mutation.inProgress,
                      bag: disposeBag)
        case .interrupt:
            interruptByUser()
        }
        return .empty()
    }
    
    private func loaded(data: T) {
        complete(data)
    }
    
    private func error(error: Error) {
        interrupt(error)
    }
}
