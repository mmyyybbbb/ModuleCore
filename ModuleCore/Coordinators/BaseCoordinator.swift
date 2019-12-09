//
//  BaseCoordinator.swift
//  ModuleCore
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxSwift

open class BaseCoordinator: DisposeBagHolder {
    weak private(set) var scene: Scene?
    
    open var disposeBag = DisposeBag()
    
    public var sceneOrFatal: Scene {
        guard let scene = self.scene else {
            fatalError()
        }
        return scene
    }
    
    required public init(scene:Scene) {
        self.scene = scene
    }
    
    public enum PresentType {
        case modally
        case inStack
    }
    
    public final func present(_ vcToPresent: UIViewController, type: PresentType = .inStack) {
        guard let scene = scene else { return }
        switch type {
        case .modally:
            scene.present(vcToPresent, animated: true, completion: nil)
        case .inStack:
            scene.navigationController?.pushViewController(vcToPresent, animated: true)
        }
    }
    
    public final func endEditing() {
        scene?.view.endEditing(true)
    }
}


extension BaseCoordinator : CoordinatorType {
    public final func show(_ style: UIAlertController.Style, title: String?, message: String, items: UIAlertAction...) {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: style)
        items.forEach(alertVc.addAction)
        scene?.present(alertVc, animated: true)
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        guard let scene = scene else { return }
        endEditing()
        scene.dismiss(animated: true, completion: completion)
    }
    
    public func pop() {
        guard let scene = scene else { return }
        
        scene.navigationController?.popViewController(animated: true)
    }
    
    public func close(completion: (() -> Void)? = nil) {
        guard let scene = scene else { return }
        
        endEditing()
        
        if let navController = scene.navigationController, navController.viewControllers.count > 1 {
            navController.pop(animated: true, completion: completion)
        } else {
            scene.dismiss(animated: true, completion: completion)
        }
    }
}


