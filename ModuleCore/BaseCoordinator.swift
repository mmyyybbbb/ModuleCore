//
//  BaseCoordinator.swift
//  ModuleCore
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

open class BaseCoordinator: CoordinatorType {
    weak private(set) var scene: Scene?
    
    required public init(scene:Scene) {
        self.scene = scene
    } 
}
