//
//  UINavigationController+.swift
//  ModuleCore
//
//  Created by Andrey Raevnev on 23/07/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

extension UINavigationController {
    func pop(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let completion = completion else { popViewController(animated: animated); return }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popViewController(animated: animated)
        CATransaction.commit()
    }
    
    func popToViewController(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let completion = completion else { popToViewController(vc, animated: animated); return }

        CATransaction.begin()
        CATransaction.setCompletionBlock(completion)
        popToViewController(vc, animated: animated)
        CATransaction.commit()
    }
}
