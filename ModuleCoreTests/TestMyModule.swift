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

protocol MyInteractorType {}
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

public protocol FactoryType {}
// Фабрика
final class MyFactory : FactoryType {
    
    func myScene() -> Scene {
        let sv = MyViewController()
        let sr = MyReactor()
        sv.inject(sr)
        return sv
    }
}
