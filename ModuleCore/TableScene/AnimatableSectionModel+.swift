//
//  AnimatableSectionModel+.swift
//  ModuleCore
//
//  Created by alexej_ne on 30.07.2019.
//  Copyright © 2019 BCS. All rights reserved.
//


import RxDataSources

public extension AnimatableSectionModel {
    mutating func addItems(items: [Item]) {
        self.items += items
    }
}
