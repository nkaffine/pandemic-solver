//
//  LocationSearchHelperTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class LocationSearchHelperTests: XCTestCase {
    var graph: LocationGraph!
    
    override func setUp()
    {
        graph = LocationGraph()
    }
    
    func testFindDistance()
    {
        XCTAssertEqual(LocationSearchHelper.distance(from: .atlanta, to: .washington, in: graph), 1)
        XCTAssertEqual(LocationSearchHelper.distance(from: .atlanta, to: .chicago, in: graph), 1)
        XCTAssertEqual(LocationSearchHelper.distance(from: .atlanta, to: .miami, in: graph), 1)
        XCTAssertEqual(LocationSearchHelper.distance(from: .santiago, to: .buenosAres, in: graph), 3)
        XCTAssertEqual(LocationSearchHelper.distance(from: .baghdad, to: .losAngeles, in: graph), 6)
    }
    
    func testFindDistanceWithStupidHelper()
    {
        graph.locations.keys.forEach
        { city in
            XCTAssertEqual(StupidHelper.bestDistanceToAtlanta(from: city), LocationSearchHelper.distance(from: .atlanta, to: city, in: graph), "\(city)")
        }
    }
    
    func testPath()
    {
        XCTAssertEqual(LocationSearchHelper.path(from: .atlanta, to: .sanFrancisco, in: graph), [.atlanta, .chicago, .sanFrancisco])
        XCTAssertEqual(LocationSearchHelper.path(from: .buenosAres, to: .beijing, in: graph), [.buenosAres, .bogota, .mexicoCity, .losAngeles, .sanFrancisco, .tokyo, .shanghai, .beijing])
    }
}
