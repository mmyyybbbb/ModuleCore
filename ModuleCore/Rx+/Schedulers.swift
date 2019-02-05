//
//  SchedulerType+.swift
//  YandexInvestition
//
//  Created by alexej_ne on 13/12/2018.
//  Copyright © 2018 BCS. All rights reserved.
//

import RxSwift

public struct Schedulers {
    static var background: ConcurrentDispatchQueueScheduler  {
        return ConcurrentDispatchQueueScheduler(qos: .background)
    }
    
    static var userInitiated: ConcurrentDispatchQueueScheduler  {
        return ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    }
    
    static var main: SerialDispatchQueueScheduler  {
        return MainScheduler.asyncInstance
    }
}

