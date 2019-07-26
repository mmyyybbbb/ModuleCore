//
//  AnimatableSectionModel+.swift
//  ModuleCore
//
//  Created by alexej_ne on 26.07.2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import RxDataSources

public extension AnimatableSectionModel {
    mutating func addItems(items: [Item]) {
        self.items += items
    }
}

public struct OneSection: IdentifiableType {
   public var identity : Int { return 1 }
}
