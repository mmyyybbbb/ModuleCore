//
//  DataSourceSection.swift
//  BrokerNewsModule
//
//  Created by Alexej Nenastev on 30/03/2019.
//  Copyright © 2019 BCS. All rights reserved.
//
import RxDataSources

public struct DataSourceSection<Item> {
    public var items: [Item]
    
    public init(_ items: [Item]) {
        self.items = items
    }
    
    mutating func addItems(items: [Item]) {
        self.items += items
    }
}

extension DataSourceSection: SectionModelType {
    public init(original: DataSourceSection, items: [Item]) {
        self = original
        self.items = items
    }
}
