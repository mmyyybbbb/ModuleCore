//
//  CollectionsCell.swift
//  ModuleCore
//
//  Created by Alexey Nenastev on 27.04.2020.
//  Copyright © 2020 BCS. All rights reserved.
//

/// Ячейка в коллекции
public enum CollectionCell<T> {
    case item(T)
    case showMore(ShowMoreCellData)
}

/// Данные в ячейке ShowMore
public struct ShowMoreCellData {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}
