//
//  CollectionsCell.swift
//  ModuleCore
//
//  Created by Alexey Nenastev on 27.04.2020.
//  Copyright © 2020 BCS. All rights reserved.
//

import Differentiator

/// Ячейка в коллекции
public enum CollectionCell<T> {
    case item(T)
    case showMore(ShowMoreCellData)
}

extension String : Error {}

extension CollectionCell: Codable where T: Codable {
    private enum CodingKeys: String, CodingKey {
        case item
        case showMore
    }
     
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(T.self, forKey: .item) {
            self = .item(value)
            return
        } else if let value = try? values.decode(ShowMoreCellData.self, forKey: .showMore) {
            self = .showMore(value)
            return
        }
        
        throw  "Whoops! \(dump(values))"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .item(let data):
            try container.encode(data, forKey: .item)
        case .showMore(let showMore):
            try container.encode(showMore, forKey: .showMore)
        }
    }
}


/// Данные в ячейке ShowMore
public struct ShowMoreCellData: Codable, Equatable {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public static func == (lhs: ShowMoreCellData, rhs: ShowMoreCellData) -> Bool {
        lhs.title == rhs.title
    }
}


extension CollectionCell: IdentifiableType where T: IdentifiableType {
     public var identity : String {
        switch self {
        case let .item(item): return "\(item.identity)"
        case let .showMore(data): return data.title
        }
    }
}

extension CollectionCell: Equatable where T: Equatable {
    public static func == (lhs: CollectionCell<T>, rhs: CollectionCell<T>) -> Bool {
        switch (lhs, rhs) {
        case let (.item(l), .item(r)):  return l == r
        case let (.showMore(l), .showMore(r)):  return l == r
        default: return false
        }
    }
}
