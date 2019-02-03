//
//  Module.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 03/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

open class Module<Factory> {
    
    private var interactors: [String : InteractorType.Type] = [:]
    private var coordinators: [String : CoordinatorType.Type] = [:]
    
    public func register<SceneInteractorProtocol, SceneInteractor: InteractorType>(for type: SceneInteractorProtocol.Type, resolve: SceneInteractor.Type) {
        let key = "\(SceneInteractorProtocol.self)"
        interactors[key] = resolve
    }
    
    public func register<SceneCoordinatorProtocol, ScenCoordinator: CoordinatorType>(for type: SceneCoordinatorProtocol.Type, resolve: ScenCoordinator.Type) {
        let key = "\(SceneCoordinatorProtocol.self)"
        coordinators[key] = resolve
    }
    
    public func resolve<C: CoordinatorType>() -> C {
        
    }
}

protocol MyInteractor: InteractorType{}

final class AInteractor : MyInteractor {
    init() {}
}

final class MyModule: Module<Int> {
   
    func a() {
        let b = MyModule()
        b.register(for: MyInteractor.self, resolve: AInteractor.self)
    }
}



