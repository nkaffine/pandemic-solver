//
//  LocationGraphTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/28/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class LocationGraphTests: XCTestCase {
    var edges: [CityName: [CityName]]!
    var locations: [CityName: BoardLocation]!
    
    override func setUp()
    {
        self.edges = GameStartHelper.generateEdgeDictionary()
        self.locations = GameStartHelper.generateLocationsMap()
    }
    
    func testInitEdges()
    {
        edges.forEach
        { (key: CityName, value: [CityName]) in
            value.forEach
            { name in
                if (!(edges[name]?.contains(key) ?? true))
                {
                    print(name, key)
                }
                XCTAssertTrue(edges[name]?.contains(key) ?? false)
            }
        }
    }
    
    func testInitLocatitons()
    {
        XCTAssertEqual(locations.count, 48)
        locations.forEach
        { (cityName, location) in
            XCTAssertEqual(cityName, location.city.name)
            XCTAssertEqual(cityName.color, location.city.color)
            XCTAssertEqual(location.cubes.red, .zero)
            XCTAssertEqual(location.cubes.yellow, .zero)
            XCTAssertEqual(location.cubes.blue, .zero)
            XCTAssertEqual(location.cubes.black, .zero)
        }
    }
}
