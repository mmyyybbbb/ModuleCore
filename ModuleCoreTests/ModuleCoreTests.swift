//
//  ModuleCoreTests.swift
//  ModuleCoreTests
//
//  Created by alexej_ne on 01/02/2019.
//  Copyright © 2019 BCS. All rights reserved.
//

import XCTest
@testable import ModuleCore
import RxSwift
import ReactorKit

class ModuleCoreTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_configuratingSomeScene() {
        let factory = MyFactory() 
        let sc = factory.myScene()
        
        guard let reactor = (sc as! MyViewController).reactor else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(reactor.interactor is MyInteractor)
        XCTAssertTrue(reactor.coordinator is MyCoordinator)
    } 
}


