//
//  DisposeBagHolder.swift
//  ModuleCore
//
//  Created by alexej_ne on 05/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxSwift

public protocol DisposeBagHolder {
    var disposeBag: DisposeBag { get }
}
