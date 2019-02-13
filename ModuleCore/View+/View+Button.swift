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
    var vm: Reactor {
        guard let vm = reactor else {  fatalError()  }
        return vm
    }

    func enable(button: UIButton, when stateMap: @escaping (Reactor.State) -> Bool) {
        rctr.state.map(stateMap)
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
    }

    func fire(_ action: Reactor.Action, onTap button: UIButton, disposeBag: DisposeBag? = nil) {
        button.rx.tap
            .map { action }
            .bind(to: vm.action)
            .disposed(by: disposeBag ?? self.disposeBag)
    }

}
