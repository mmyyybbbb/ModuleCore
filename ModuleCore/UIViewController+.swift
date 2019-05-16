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
    
    func embed(scene: EmbeddedScene, to view: UIView) {
        let sceneVC = scene.scene
        addChild(sceneVC)
        
        view.addSubview(sceneVC.view)
        view.isHidden = false
        
        sceneVC.didMove(toParent: self)
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
