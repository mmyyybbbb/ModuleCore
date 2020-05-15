//
//  Cache.swift
//  ModuleCore
//
//  Created by Alexey Nenastev on 15.05.2020.
//  Copyright © 2020 BCS. All rights reserved.
//

/// Кеш данных
public final class Cache<Data> {
    /// Ид
    public let cacheId: String
    /// Время жизни
    public let expiration: TimeInterval
    /// Время когда данные были закешированы
    public var pushDate: Date? {
        get { userDefaults.object(forKey: pushDateUserDefaultKey) as? Date  }
        set { userDefaults.set(newValue, forKey: pushDateUserDefaultKey) }
    }
    
    /// Состояние кеша
    public enum State {
        /// Есть свежие данные ( лежат в кеше меньше чем expiration)
        case hasFreshData
        /// Есть закешированные данные но они лежат в кеши дольше чем expiration
        case hasExpiredData
        /// Нет закешированных данных
        case noCachedData
    }
    
    /// Текущее состояние кеша
    public var state: State {
        guard let date = pushDate else { return .noCachedData }
        return date.addingTimeInterval(expiration) > Date() ? .hasFreshData : .hasExpiredData
    }
    
    private let dataStoragePush: (Data) -> Void
    private let dataStoragePull: () -> Data?
    private let userDefaults: UserDefaults 
    
    private var pushDateUserDefaultKey: String { "cache_\(cacheId)_pushDate" }
    
    public init<T>(cacheId: String, expiration: TimeInterval, dataStorage: T, userDefaults: UserDefaults = .standard) where T: DataStorageType, T.Data == Data {
        self.cacheId = cacheId
        self.expiration = expiration
        self.dataStoragePush = dataStorage.push(data:)
        self.dataStoragePull = dataStorage.pull
        self.userDefaults = userDefaults
    }
    
    /// Сохранить данные в кеш
    public func push(data: Data) {
        dataStoragePush(data)
        pushDate = Date()
    }
     
    /// Получить данные из кеша
    public func pull() -> Data? {
        dataStoragePull()
    }
}
 
