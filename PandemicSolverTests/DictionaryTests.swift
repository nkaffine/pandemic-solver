//
//  DictionaryTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/29/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class DictionaryTests: XCTestCase {
    func testImmutableUpdate()
    {
        let dictionary = ["hello": "hello1"]
        let dictionary2 = dictionary.imutableUpdate(key: "hello", value: "hello2")
        XCTAssertEqual(dictionary2["hello"], "hello2")
        XCTAssertEqual(dictionary["hello"], "hello1")
        
        let dictionary3 = ["hello":"hello1", "hello1":"hello1", "hello3":"hello1"]
        let dictionary4 = dictionary3.imutableUpdate(key: "hello1", value: "hello2")
        XCTAssertEqual(dictionary4["hello1"], "hello2")
        XCTAssertEqual(dictionary3["hello"], "hello1")
    }
}
