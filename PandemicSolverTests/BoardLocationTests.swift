//
//  BoardLocationTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/30/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class BoardLocationTests: XCTestCase {
    var location: BoardLocation!
    
    override func setUp() {
        location = BoardLocation(city: City(name: .mexicoCity))
    }
    
    func testLocationInit()
    {
        XCTAssertEqual(location.city, City(name: .mexicoCity))
        XCTAssertEqual(location.cubes.red, .zero)
        XCTAssertEqual(location.cubes.blue, .zero)
        XCTAssertEqual(location.cubes.yellow, .zero)
        XCTAssertEqual(location.cubes.black, .zero)
        XCTAssertFalse(location.hasResearchStation)
    }
    
    func testLocationEquals()
    {
        let notLocation = BoardLocation(city: City(name: .cairo))
        XCTAssertEqual(location, location)
        XCTAssertNotEqual(location, notLocation)
        XCTAssertEqual(location, location.add(cubes: .one, of: .red).1)
    }
    
    func testAddingOneColorCubes()
    {
        //Testing non-outbreaks
        let (outbreak1, location1) = location.add(cubes: .one, of: .red)
        XCTAssertTrue(outbreak1.isEmpty)
        assertDiseaseCounts(of: location1, red: .one)
        
        let (outbreak2, location2) = location.add(cubes: .one, of: .yellow)
        XCTAssertTrue(outbreak2.isEmpty)
        assertDiseaseCounts(of: location2, yellow: .one)
        
        let (outbreak3, location3) = location.add(cubes: .one, of: .blue)
        XCTAssertTrue(outbreak3.isEmpty)
        assertDiseaseCounts(of: location3, blue: .one)
        
        let (outbreak4, location4) = location.add(cubes: .one, of: .black)
        XCTAssertTrue(outbreak4.isEmpty)
        assertDiseaseCounts(of: location4, black: .one)
        
        //Testing outbreaks
        let (outbreak5, location5) = location1.add(cubes: .three, of: .red)
        XCTAssertEqual(outbreak5, [.red])
        assertDiseaseCounts(of: location5, red: .three)
        
        let (outbreak6, location6) = location2.add(cubes: .three, of: .yellow)
        XCTAssertEqual(outbreak6, [.yellow])
        assertDiseaseCounts(of: location6, yellow: .three)
        
        let (outbreak7, location7) = location3.add(cubes: .three, of: .blue)
        XCTAssertEqual(outbreak7, [.blue])
        assertDiseaseCounts(of: location7, blue: .three)
        
        let (outbreak8, location8) = location4.add(cubes: .three, of: .black)
        XCTAssertEqual(outbreak8, [.black])
        assertDiseaseCounts(of: location8, black: .three)
    }
    
    func testAddingMultipleColors()
    {
        let (outbreak1, location1) = location.add(cubes: [.red: .three, .yellow: .three, .blue: .three, .black: .three])
        XCTAssertTrue(outbreak1.isEmpty)
        assertDiseaseCounts(of: location1, red: .three, yellow: .three, blue: .three, black: .three)
        
        let (outbreak2, location2) = location1.add(cubes: [.red: .two, .yellow: .two, .blue: .two, .black: .two])
        XCTAssertEqual(outbreak2, [.red, .yellow, .blue, .black])
        assertDiseaseCounts(of: location2, red: .three, yellow: .three, blue: .three, black: .three)
    }
    
    func testRemovingCubes()
    {
        let (_, location1) = location.add(cubes: [.red: .one, .yellow: .one, .blue: .one, .black: .one])
        
        let location2 = location1.remove(cubes: .two, of: .red)
        assertDiseaseCounts(of: location2, red: .zero, yellow: .one, blue: .one, black: .one)
        
        let location3 = location1.remove(cubes: .two, of: .yellow)
        assertDiseaseCounts(of: location3, red: .one, yellow: .zero, blue: .one, black: .one)
        
        let location4 = location1.remove(cubes: .two, of: .blue)
        assertDiseaseCounts(of: location4, red: .one, yellow: .one, blue: .zero, black: .one)
        
        let location5 = location1.remove(cubes: .two, of: .black)
        assertDiseaseCounts(of: location5, red: .one, yellow: .one, blue: .one, black: .zero)
    }
    
    func testAddingResearchStation()
    {
        let location1 = location.addResearchStation()
        XCTAssertTrue(location1.hasResearchStation)
        XCTAssertEqual(location.cubes.black, location1.cubes.black)
        XCTAssertEqual(location.cubes.red, location1.cubes.red)
        XCTAssertEqual(location.cubes.yellow, location1.cubes.yellow)
        XCTAssertEqual(location.cubes.blue, location1.cubes.blue)
        XCTAssertEqual(location.city, location1.city)
    }
    
    private func assertDiseaseCounts(of boardLocation: BoardLocation, red: CubeCount = .zero,
                                     yellow: CubeCount = .zero,
                                     blue: CubeCount = .zero,
                                     black: CubeCount = .zero)
    {
        XCTAssertEqual(boardLocation.cubes.red, red)
        XCTAssertEqual(boardLocation.cubes.yellow, yellow)
        XCTAssertEqual(boardLocation.cubes.blue, blue)
        XCTAssertEqual(boardLocation.cubes.black, black)
    }
}
