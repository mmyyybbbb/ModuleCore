//
//  CacheTests.swift
//  ModuleCoreTests
//
//  Created by Alexey Nenastev on 15.05.2020.
//  Copyright © 2020 BCS. All rights reserved.
//

import XCTest
@testable import ModuleCore
import RxSwift
import ReactorKit

class CacheTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_cache() {
        let cacheId = "myCache\(Date())"
        let expiration: TimeInterval = 3
        let dataToStore: [SomeDate] = [.data1, .data2]
        
        print("CacheId ", cacheId)
        
        let cache = Cache(cacheId: cacheId, expiration: expiration, dataStorage: SomeDateDateStorage())
        XCTAssert(cache.state == .noCachedData)
        let dateBeforeSave = Date()
        print("dateBeforeSave", dateBeforeSave)
        sleep(1)
        cache.push(data: dataToStore)
        sleep(1)
        let dateAfterSave = Date()
        print("dateAfterSave", dateAfterSave)
        print(cache.state)
        print("pushDate", cache.pushDate ?? "")
        XCTAssert(cache.state == .hasFreshData)
        guard let pushDate = cache.pushDate else { XCTFail(); return }
        XCTAssert(pushDate > dateBeforeSave)
        XCTAssert(pushDate < dateAfterSave)
        guard let data = cache.pull(), data.count == dataToStore.count else { XCTFail(); return }
        sleep(UInt32(expiration))
        XCTAssert(cache.state == .hasExpiredData)
    }
}

fileprivate final class SomeDateDateStorage: DataStorageType {
    func push(data: [SomeDate]) {
        let dat = try? JSONEncoder().encode(data)
        UserDefaults.standard.set(dat, forKey: "someDate")
    }
    
    func pull() -> [SomeDate]? {
        guard let data = UserDefaults.standard.data(forKey: "someDate") else { return nil }
        return try? JSONDecoder().decode([SomeDate].self, from: data)
    }
}

fileprivate struct SomeDate: Codable {
    let id: Int
    let str: String
    
    public static let data1 = SomeDate(id: 1, str: "1")
    public static let data2 = SomeDate(id: 2, str: "2")
}
