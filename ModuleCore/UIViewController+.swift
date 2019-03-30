//
//  UIViewController+.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 30/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public extension UIViewController {
    
    func embed(scene: EmbeddedScene, to view: UIView) {
        let sceneVC = scene.scene
        addChild(sceneVC)
        
        view.addSubview(sceneVC.view)
        view.isHidden = false
        
        sceneVC.didMove(toParent: self)
    }
}
