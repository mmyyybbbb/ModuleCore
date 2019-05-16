//
//  UIAlertController+.swift
//  ModuleCore
//
//  Created by alexej_ne on 16/05/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import ReactorKit

public extension UIAlertController {
    func addAction<R:Reactor>(reactor: R, action: R.Action, title: String?, style: UIAlertAction.Style = .default  , handler: @escaping (() -> Void)? = nil) {
        let alertAction = UIAlertAction(title: title, style: style) { [weak reactor] _ in
            reactor?.action.onNext(action)
            handler?()
        }
        addAction(alertAction)
    }
}
