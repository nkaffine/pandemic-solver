//
//  CityTest.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class CityTest: XCTestCase {

    func testCityInit()
    {
        let city = City(name: .atlanta)
        XCTAssertEqual(city.name, .atlanta)
        XCTAssertEqual(city.color, .blue)
    }
    
    func testCityColor()
    {
        XCTAssertEqual(CityName.algiers.color, .black)
        XCTAssertEqual(CityName.atlanta.color, .blue)
        XCTAssertEqual(CityName.tokyo.color, .red)
        XCTAssertEqual(CityName.johannesburg.color, .yellow)
    }
}
