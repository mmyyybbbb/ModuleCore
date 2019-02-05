//
//  View+Gesture.swift
//  ModuleCore
//
//  Created by alexej_ne on 05/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import ReactorKit
import RxSwift
import RxCocoa

public extension SceneView {
    func fire(_ action: Reactor.Action, onTapGestureIn view: UIView) {
        let tapGestureRecognizer = UITapGestureRecognizer()
        view.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer.rx.event
            .map { _ in action }
            .bind(to: rctr.action)
            .disposed(by: disposeBag)
    }
}
