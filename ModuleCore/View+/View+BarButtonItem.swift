//
//  View+BarButtonItem.swift
//  ModuleCore
//
//  Created by alexej_ne on 05/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import ReactorKit
import RxSwift
import RxCocoa

public extension SceneView {
    func fire(_ action: Reactor.Action, onTap button: UIBarButtonItem) {
        button.rx.tap
            .map { action }
            .bind(to: rctr.action)
            .disposed(by: disposeBag)
    }

}
