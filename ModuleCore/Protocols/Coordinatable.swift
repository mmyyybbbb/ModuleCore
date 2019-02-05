//
//  Coordinating.swift
//  ModuleCore
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public protocol Coordinatable: class, AssociatedStore {
    associatedtype Coordinator: BaseCoordinator
    var coordinator: Coordinator { get }
}

private var coordinatorKey = "coordinator" 
extension Coordinatable {
    
    public var coordinator: Coordinator {
        guard let coord: Coordinator =  self.associatedObject(forKey: &coordinatorKey) else {
            fatalError("Кординатор не установлен \(self)")
        }
        return coord
    }
    
    func set(coordinator: Coordinator) {
        self.setAssociatedObject(coordinator, forKey: &coordinatorKey)
    }
}

