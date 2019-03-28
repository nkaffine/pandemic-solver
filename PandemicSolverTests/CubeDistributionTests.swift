//
//  CubeDistributionTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class CubeDistributionTests: XCTestCase {
    var distribution: CubeDistribution!
    var delegate: MockOutbreakDelegate!
    
    override func setUp() {
        distribution = CubeDistribution()
        delegate = MockOutbreakDelegate()
        distribution.delegate = delegate
    }
    
    func testAddingCubesToSingleColor()
    {
        //Testing each color
        distribution.add(cubes: 1, of: .red)
        XCTAssertEqual(distribution.red, 1)
        
        distribution.add(cubes: 1, of: .yellow)
        XCTAssertEqual(distribution.yellow, 1)
        
        distribution.add(cubes: 1, of: .blue)
        XCTAssertEqual(distribution.blue, 1)
        
        distribution.add(cubes: 1, of: .black)
        XCTAssertEqual(distribution.black, 1)
        
        //Testing edge case of 3 cubes
        distribution.add(cubes: 2, of: .red)
        XCTAssertEqual(distribution.red, 3)
        XCTAssertNil(delegate.outbreakColor)
        
        distribution.add(cubes: 2, of: .yellow)
        XCTAssertEqual(distribution.yellow, 3)
        XCTAssertNil(delegate.outbreakColor)
        
        distribution.add(cubes: 2, of: .blue)
        XCTAssertEqual(distribution.blue, 3)
        XCTAssertNil(delegate.outbreakColor)
        
        distribution.add(cubes: 2, of: .black)
        XCTAssertEqual(distribution.black, 3)
        XCTAssertNil(delegate.outbreakColor)
    }
    
    func testAddingCubesToManyColors()
    {
        //Test adding no colors
        distribution.add(cubes: [:])
        XCTAssertEqual(distribution.red, 0)
        XCTAssertEqual(distribution.yellow, 0)
        XCTAssertEqual(distribution.blue, 0)
        XCTAssertEqual(distribution.black, 0)
        
        //Test adding each color
        distribution.add(cubes: [.red : 1, .yellow: 2, .blue: 3, .black: 4])
        XCTAssertEqual(distribution.red, 1)
        XCTAssertEqual(distribution.yellow, 2)
        XCTAssertEqual(distribution.blue, 3)
        XCTAssertEqual(distribution.black, 3)
        XCTAssertEqual(delegate.outbreakColor, .black)
    }
    
    func testCheckingForOutbreak()
    {
        //Testing that an outbreak will occur for each color
        distribution.add(cubes: 4, of: .red)
        XCTAssertEqual(delegate.outbreakColor, .red)
        
        distribution.add(cubes: 4, of: .yellow)
        XCTAssertEqual(delegate.outbreakColor, .yellow)
        
        distribution.add(cubes: 4, of: .black)
        XCTAssertEqual(delegate.outbreakColor, .black)
        
        distribution.add(cubes: 4, of: .blue)
        XCTAssertEqual(delegate.outbreakColor, .blue)
    }
    
    func testRemovingCubeFromOneColor()
    {
        setUpFullDistribution()
        
        //Test each color
        distribution.remove(cubes: 1, of: .red)
        XCTAssertEqual(distribution.red, 2)
        
        distribution.remove(cubes: 1, of: .yellow)
        XCTAssertEqual(distribution.yellow, 2)
        
        distribution.remove(cubes: 1, of: .black)
        XCTAssertEqual(distribution.black, 2)
        
        distribution.remove(cubes: 1, of: .blue)
        XCTAssertEqual(distribution.blue, 2)
    }
    
    func testRemovingCubeFromMoreThanOneColor()
    {
        setUpFullDistribution()
        
        //Test removing nothing
        distribution.remove(cubes: [:])
        XCTAssertEqual(distribution.red, 3)
        XCTAssertEqual(distribution.yellow, 3)
        XCTAssertEqual(distribution.blue, 3)
        XCTAssertEqual(distribution.black, 3)
        
        distribution.remove(cubes: [.red: 1, .yellow: 2, .blue: 3, .black: 4])
        XCTAssertEqual(distribution.red, 2)
        XCTAssertEqual(distribution.yellow, 1)
        XCTAssertEqual(distribution.blue, 0)
        XCTAssertEqual(distribution.black, 0)
    }
    
    func testRemovingPastZero()
    {
        setUpFullDistribution()
        //Testing each color
        distribution.remove(cubes: 4, of: .red)
        XCTAssertEqual(distribution.red, 0)
        
        distribution.remove(cubes: 4, of: .yellow)
        XCTAssertEqual(distribution.yellow, 0)
        
        distribution.remove(cubes: 4, of: .blue)
        XCTAssertEqual(distribution.blue, 0)
        
        distribution.remove(cubes: 4, of: .black)
        XCTAssertEqual(distribution.black, 0)
    }
    
    private func setUpFullDistribution()
    {
        distribution.add(cubes: [.red: 3, .yellow: 3, .black: 3, .blue: 3])
    }
}

class MockOutbreakDelegate: OutbreakDelegate
{
    var outbreakColor: DiseaseColor?
    
    func didOutbreak(for color: DiseaseColor)
    {
        outbreakColor = color
    }
    
    func reset()
    {
        outbreakColor = nil
    }
}
