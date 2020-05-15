//
//  DataStorageType.swift
//  ModuleCore
//
//  Created by Alexey Nenastev on 15.05.2020.
//  Copyright © 2020 BCS. All rights reserved.
//

import Foundation

/// Хранилище данных
public protocol DataStorageType {
    associatedtype Data
    
    /// Получить данные
    func pull() -> Data?
    
    /// Сохранить данные
    func push(data: Data)
}
