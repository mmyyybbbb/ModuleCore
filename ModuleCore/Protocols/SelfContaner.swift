//
//  SelfContaner.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 10/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public protocol SelfContaner: AnyObject, AssociatedStore {
    static var instanceOrInit: Self { get }
    static func release()
    init()
}

private var instanceKey = "instanceKey"

public extension SelfContaner {
    static var shared: Self { return instanceOrInit }
    
    static var instance: Self? { return objc_getAssociatedObject(self, &instanceKey) as? Self  }
    
    static var instanceOrInit: Self {
        if let instance = instance {
            return instance
        }
        
        let object = Self()
        objc_setAssociatedObject(self, &instanceKey, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return object
    }
    
    static func release() {
        guard let instance = instance else { return }
        objc_removeAssociatedObjects(instance)
    } 
}
