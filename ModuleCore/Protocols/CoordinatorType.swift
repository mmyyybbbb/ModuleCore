//
//  CoordinatorType.swift
//  ModuleCore
//
//  Created by Alexej Nenastev on 11/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

public protocol CoordinatorType: AnyObject {
    func show(_ style: UIAlertController.Style, title: String?, message: String, items: UIAlertAction...)
    func dismiss(completion: (() -> Void)?)
    func pop()
    func close(completion: (() -> Void)?)
}
