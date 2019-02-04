//
//  TestMyModule.swift
//  ModuleCoreTests
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
@testable import ModuleCore
import RxSwift
import ReactorKit
 
// Тестовая сцена
protocol MyCoorinatorType : CoordinatorType {}
final class MyCoordinator: BaseCoordinator, MyCoorinatorType {}

protocol MyInteractorType : InteractorType {}
final class MyInteractor: MyInteractorType {}

final class MyReactor: SceneReactor, Interactable, Coordinatable {
    typealias Coordinator = MyCoorinatorType
    typealias Interactor = MyInteractorType
    typealias Action = NoAction
    typealias Mutation = NoMutation
    struct State {}
    var initialState = State()
}

final class MyViewController: UIViewController, SceneView {
    var disposeBag =  DisposeBag()
    func bind(reactor: MyReactor) {}
}

// Фабрика
final class MyFactory : Factory {
    
    func myScene() -> Scene {
        let sv = MyViewController()
        let sr = MyReactor()
        configurate(vc: sv, reactor: sr)
        return sv
    }
}
