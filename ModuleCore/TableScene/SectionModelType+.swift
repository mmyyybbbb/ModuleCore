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

public extension Array where Element: SectionModelType {
    
    subscript(_ ip: IndexPath) -> Element.Item {
        get { return self[ip.section].items[ip.row] }
    }
    
}

public extension AnimatableSectionModel {
    static func merge(new array: [AnimatableSectionModel], to old: inout [AnimatableSectionModel]) {
        if let last = old.last, let newFirst = old.first, last.identity == newFirst.identity   {
            let lastIndex = old.count - 1
            old[lastIndex].addItems(items: newFirst.items)
            var array = array
            array.removeFirst()
            old.append(contentsOf: array)
        } else {
            old.append(contentsOf: array)
        }
    }
}


