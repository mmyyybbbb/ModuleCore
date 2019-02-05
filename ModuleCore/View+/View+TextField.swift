//
//  View+UITextField.swift
//  ModuleCore
//
//  Created by alexej_ne on 05/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import ReactorKit
import RxSwift
import RxCocoa

public extension SceneView {
    func fire(_ action: @escaping (String?) -> Reactor.Action, onType textField: UITextField) {
        textField.rx.text
            .asObservable()
            .map(action)
            .bind(to: rctr.action)
            .disposed(by: disposeBag)
    }
}
