//
//  Factory.swift
//  Alamofire
//
//  Created by alexej_ne on 04/02/2019.
//

import RxSwift

public protocol ModuleType: SelfContaner {
    associatedtype Factory
    associatedtype Notification
    var notification: Observable<Notification> { get }
    var factory: Factory { get }
 
    func set(factory: Factory)
}

private var notificationKey = "notificationKey"
private var notificationPublisherKey = "notificationPublisherKey"

public struct NoNotification {}
 
public extension ModuleType {
    var notificationPublisher: PublishSubject<Notification> {
        get { return self.associatedObject(forKey: &notificationPublisherKey, default: PublishSubject<Notification>()) }
    }
    
    var notification: Observable<Notification> {
        get { return notificationPublisher.asObservable() }
    }
    
    func send(notification: Notification) {
        notificationPublisher.onNext(notification)
    }
}
