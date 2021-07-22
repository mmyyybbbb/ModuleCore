//
//  Interacting.swift
//  ModuleCore
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public protocol Interactable: AnyObject, AssociatedStore  {
    associatedtype Interactor
    var interactor: Interactor { get } 
}

private var interactorKey = "interactor"
extension Interactable {
    
    public var interactor: Interactor {
        guard let interactor: Interactor = self.associatedObject(forKey: &interactorKey) else {
            fatalError("Интерактор не установлен \(self)")
        }
        return interactor
    }
    
    func set(interactor: Interactor) {
        self.setAssociatedObject(interactor, forKey: &interactorKey)
    } 
}
