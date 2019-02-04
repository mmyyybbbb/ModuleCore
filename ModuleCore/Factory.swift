//
//  Module.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 03/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import ReactorKit

open class Factory {
    
    fileprivate var interactors: [String : InteractorType.Type] = [:]
    fileprivate var coordinators: [String : CoordinatorType.Type] = [:]
    
    public func register<SceneInteractorProtocol, SceneInteractor: InteractorType>(for type: SceneInteractorProtocol.Type, resolve: SceneInteractor.Type) {
        let key = "\(SceneInteractorProtocol.self)"
        interactors[key] = resolve
         
    }
    
    public func register<SceneCoordinatorProtocol, ScenCoordinator: CoordinatorType>(for type: SceneCoordinatorProtocol.Type, resolve: ScenCoordinator.Type) {
        let key = "\(SceneCoordinatorProtocol.self)"
        coordinators[key] = resolve
    }
    
    func configurate<T:View>(vc: T, reactor: T.Reactor) {
        vc.reactor = reactor
    }
    
    func configurate<T: View>(vc: T, reactor: T.Reactor) where T.Reactor: Interactable {
        vc.reactor = reactor
        configurateInteractor(reactor: reactor)
    }
    
    func configurate<T: View>(vc: T, reactor: T.Reactor) where T: UIViewController, T.Reactor: Coordinatable {
        vc.reactor = reactor
        configurateCoordinator(vc: vc, reactor: reactor)
    }
    
    func configurate<T: View>(vc: T, reactor: T.Reactor) where T: UIViewController, T.Reactor: Coordinatable & Interactable {
        vc.reactor = reactor
        configurateInteractor(reactor: reactor)
        configurateCoordinator(vc: vc, reactor: reactor)
    }
}


fileprivate extension ModuleFactory {
    
    func configurateInteractor<T: Reactor & Interactable>(reactor: T) {
        let key = "\(T.Interactor.self)"
        
        guard let interactorType = interactors[key]  else {
            fatalError("Не найден интерактор для типа \(key)")
        }
        let interactor = interactorType.init() as! T.Interactor
        reactor.set(interactor: interactor)
    }
    
    func configurateCoordinator<T: Reactor & Coordinatable>(vc: UIViewController, reactor: T) {
        let key = "\(T.Coordinator.self)"
        
        guard let coordinatorType = coordinators[key]  else {
            fatalError("Не найден координатор для типа \(key)")
        }
        let coordinator = coordinatorType.init(scene: vc) as! T.Coordinator
        reactor.set(coordinator: coordinator)
    }
}
