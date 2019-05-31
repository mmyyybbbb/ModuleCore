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
    associatedtype OutputNotification
    
    var input: PublishSubject<InputNotification> { get }
    var output: Observable<OutputNotification> { get }
    
    var factory: Factory { get }
 
    func set(factory: Factory)
}

private var inputKey = "input"
private var outputKey = "output"

public struct NoNotification {}

public typealias NoInputNotification = NoNotification
public typealias NoOutputNotification = NoNotification


public extension ModuleType {
    var input: PublishSubject<InputNotification> {
        get { return self.associatedObject(forKey: &inputKey, default: PublishSubject<InputNotification>()) }
    }
    
    var inputObservable: Observable<InputNotification> { return  input.asObservable() }
    
    var output: Observable<OutputNotification> { return .never() }
    
    var outputPublisher: PublishSubject<OutputNotification> {
        get { return self.associatedObject(forKey: &outputKey, default: PublishSubject<OutputNotification>()) }
    }
    
    func notify(_ notification: InputNotification) {
        input.onNext(notification)
    }
}

