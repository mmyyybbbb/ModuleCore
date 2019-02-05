//
//  View+Button.swift
//  ModuleCore
//
//  Created by alexej_ne on 05/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

public extension SceneView {
    func enable(button: UIButton, when stateMap: @escaping (Reactor.State) -> Bool) {
        rctr.state.map(stateMap)
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
