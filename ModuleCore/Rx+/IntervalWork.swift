//
//  IntervalWork.swift
//  ModuleCore
//
//  Created by alexej_ne on 22/04/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift
import RxCocoa


public enum WorkCommand<R> {
    case completeWork(R)
    case continueWork
    case completeWith(error: Error)
}

public extension WorkCommand where R == Void {
    static var completeWork: WorkCommand<Void> { return .completeWork(()) }
}

public struct IntervalWork<T,R> {
    
    public var single: Single<R> { return observable.take(1).share().asSingle() }
    let observable: Observable<R>
    
    public init(interval: RxTimeInterval,
                maxCounts: Int = Int.max,
                work: Single<T>, onNext: @escaping (T) -> WorkCommand<R>) {
        
        let observable = Observable<Int64>
            .interval(interval, scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .startWith(0)
            .take(maxCounts)
            .mapToVoid()
            .flatMapLatest { work }
            .flatMap { (result: T) -> Observable<R> in
                switch onNext(result) {
                    case let .completeWork(val): return .just(val)
                    case .continueWork: return .empty()
                    case let .completeWith(err): throw err
                }
        }
        
        self.observable = observable
    }
}
