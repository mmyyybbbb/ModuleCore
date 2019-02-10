//
//  BaseCoordinator.swift
//  ModuleCore
//
//  Created by alexej_ne on 04/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

open class BaseCoordinator {
    weak private(set) var scene: Scene?
    
    required public init(scene:Scene) {
        self.scene = scene
    }
    
    public enum PresentType {
        case modally
        case inStack
    }
    
    public final func present(_ vcToPresent: UIViewController, type: PresentType = .inStack ) {
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
    
    public final func showAlert(title: String?, message: String, items: UIAlertAction...) {
        let alertVc = UIAlertController(title: title, message: message, preferredStyle: .alert)
        items.forEach(alertVc.addAction)
        scene?.present(alertVc, animated: true)
    }
}
