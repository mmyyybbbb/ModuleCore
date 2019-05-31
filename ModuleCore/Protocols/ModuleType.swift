//
//  Factory.swift
//  Alamofire
//
//  Created by alexej_ne on 04/02/2019.
//

import RxSwift

public protocol ModuleType: SelfContaner {
    associatedtype Factory
    associatedtype InputNotification
    associatedtype ModuleEvent
    var inputNotification: PublishSubject<InputNotification> { get }
    var moduleEvents: Observable<ModuleEvent> { get }
    var factory: Factory { get }
 
    func set(factory: Factory)
}

private var notificationKey = "notificationKey"

public struct NoNotification {}
public struct NoEvents {}
 
public extension ModuleType {
    var inputNotification: PublishSubject<InputNotification> {
        get { return self.associatedObject(forKey: &notificationKey, default: PublishSubject<InputNotification>()) }
    }
    
    func notify(_ notification: InputNotification) {
        inputNotification.onNext(notification)
    }
    
    var moduleEvents: Observable<ModuleEvent> { return .never() }
}

