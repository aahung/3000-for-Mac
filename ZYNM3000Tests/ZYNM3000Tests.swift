//
//  ZYNM3000Tests.swift
//  ZYNM3000Tests
//
//  Created by Xinhong LIU on 17/7/2016.
//  Copyright © 2016 XH. All rights reserved.
//

import XCTest
@testable import ZYNM3000

class ZYNM3000Tests: XCTestCase {
    
    var words3000 = Words3000()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let lists = words3000.lists()
        XCTAssert(lists.count == 31)
        for list in lists {
            XCTAssert(words3000.units(list: list).count >= 8)
        }
    }
    
    func testWordsParsing() {
        let words = words3000.words(list: 1, unit: 1)
        XCTAssert(words.count == 10)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
