//
//  UIViewController+.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 30/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxSwift
import ReactorKit

public extension UIViewController {
    
    func embed(scene embeddedScene: EmbeddedScene, to view: UIView) {
        self.embed(scene: embeddedScene.scene, to: view)
    }
    
    func exclude(scene embeddedScene: EmbeddedScene, to view: UIView) {
        self.exclude(scene: embeddedScene.scene, to: view)
    }
    
    func embed(scene: Scene, to view: UIView) {
        addChild(scene)
        view.addSubview(scene.view)
        view.isHidden = false
        scene.didMove(toParent: self)
    }
    
    func exclude(scene: Scene, to view: UIView, shouldHiddenView: Bool = true) {
        view.isHidden = shouldHiddenView
        scene.view.removeFromSuperview()
        scene.removeFromParent()
    }
    
    func subscribeShow(alert: UIAlertController, on obs: Observable<Void>, disposeBag: DisposeBag) {
        obs.subscribe(onNext: { [weak self] in
            self?.present(alert, animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    func dismiss<R: Reactor>(animated: Bool, reactor: R, onCompleteAction action: R.Action) {
        self.dismiss(animated: animated) { [weak reactor] in
            reactor?.action.onNext(action)
        }
    }
    
    final func endEditing() {
        view.endEditing(true)
    }
    
    func close(completion: (() -> Void)? = nil) {
        endEditing()
        
        if let navController = navigationController, navController.viewControllers.count > 1 {
            navController.pop(animated: true, completion: completion)
        } else {
            dismiss(animated: true, completion: completion)
        }
    }
}

public extension DisposeBagHolder where Self: UIViewController {
    
    func subscribeShow(alert: UIAlertController, on obs: Observable<Void>) {
        subscribeShow(alert: alert, on: obs, disposeBag: disposeBag)
    }
}


public extension SceneView where Self: UIViewController {
    
    func subscribeShow(alert: UIAlertController, on obs: Observable<Void>) {
        subscribeShow(alert: alert, on: obs, disposeBag: disposeBag)
    }
}
