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
    var distribution: CubeDistribution = CubeDistribution()
    var outbreak: Outbreak = []
    
    override func setUp() {
        distribution = CubeDistribution()
        outbreak = []
    }
    
    func testAddingCubesToSingleColor()
    {
        //Testing each color
        (outbreak, distribution) = distribution.add(cubes: .one, of: .red)
        XCTAssertEqual(distribution.red, .one)
        
        (outbreak, distribution) = distribution.add(cubes: .one, of: .yellow)
        XCTAssertEqual(distribution.yellow, .one)
        
        (outbreak, distribution) = distribution.add(cubes: .one, of: .blue)
        XCTAssertEqual(distribution.blue, .one)
        
        (outbreak, distribution) = distribution.add(cubes: .one, of: .black)
        XCTAssertEqual(distribution.black, .one)
        
        //Testing edge case of 3 cubes
        (outbreak, distribution) = distribution.add(cubes: .two, of: .red)
        XCTAssertEqual(distribution.red, .three)
        XCTAssertEqual(outbreak, [])
        
        (outbreak, distribution) = distribution.add(cubes: .two, of: .yellow)
        XCTAssertEqual(distribution.yellow, .three)
        XCTAssertEqual(outbreak, [])
        
        (outbreak, distribution) = distribution.add(cubes: .two, of: .blue)
        XCTAssertEqual(distribution.blue, .three)
        XCTAssertEqual(outbreak, [])
        
        (outbreak, distribution) = distribution.add(cubes: .two, of: .black)
        XCTAssertEqual(distribution.black, .three)
        XCTAssertEqual(outbreak, [])
    }
    
    func testAddingCubesToManyColors()
    {
        //Test adding no colors
        (outbreak, distribution) = distribution.add(cubes: [:])
        XCTAssertEqual(distribution.red, .zero)
        XCTAssertEqual(distribution.yellow, .zero)
        XCTAssertEqual(distribution.blue, .zero)
        XCTAssertEqual(distribution.black, .zero)
        
        //Test adding each color
        (outbreak, distribution) = distribution.add(cubes: [.red : .one, .yellow: .two, .blue: .three, .black: .three])
        (outbreak, distribution) = distribution.add(cubes: .one, of: .black)
        XCTAssertEqual(distribution.red, .one)
        XCTAssertEqual(distribution.yellow, .two)
        XCTAssertEqual(distribution.blue, .three)
        XCTAssertEqual(distribution.black, .three)
        XCTAssertEqual(outbreak, [.black])
    }
    
    func testCheckingForOutbreak()
    {
        //Testing that an outbreak will occur for each color
        (outbreak, distribution) = distribution.add(cubes: .three, of: .red)
        (outbreak, distribution) = distribution.add(cubes: .one, of: .red)
        XCTAssertEqual(outbreak, [.red])
        
        (outbreak, distribution) = distribution.add(cubes: .two, of: .yellow)
        (outbreak, distribution) = distribution.add(cubes: .two, of: .yellow)
        XCTAssertEqual(outbreak, [.yellow])
        
        (outbreak, distribution) = distribution.add(cubes: .two, of: .black)
        (outbreak, distribution) = distribution.add(cubes: .two, of: .black)
        XCTAssertEqual(outbreak, [.black])
        
        (outbreak, distribution) = distribution.add(cubes: .two, of: .blue)
        (outbreak, distribution) = distribution.add(cubes: .two, of: .blue)
        XCTAssertEqual(outbreak, [.blue])
    }
    
    func testRemovingCubeFromOneColor()
    {
        setUpFullDistribution()
        
        //Test each color
        distribution = distribution.remove(cubes: .one, of: .red)
        XCTAssertEqual(distribution.red, .two)
        
        distribution = distribution.remove(cubes: .one, of: .yellow)
        XCTAssertEqual(distribution.yellow, .two)
        
        distribution = distribution.remove(cubes: .one, of: .black)
        XCTAssertEqual(distribution.black, .two)
        
        distribution = distribution.remove(cubes: .one, of: .blue)
        XCTAssertEqual(distribution.blue, .two)
    }
    
    func testRemovingCubeFromMoreThanOneColor()
    {
        setUpFullDistribution()
        
        //Test removing nothing
        distribution = distribution.remove(cubes: [:])
        XCTAssertEqual(distribution.red, .three)
        XCTAssertEqual(distribution.yellow, .three)
        XCTAssertEqual(distribution.blue, .three)
        XCTAssertEqual(distribution.black, .three)
        
        distribution = distribution.remove(cubes: [.red: .one, .yellow: .two, .blue: .three, .black: .three])
        distribution = distribution.remove(cubes: .one, of: .black)
        XCTAssertEqual(distribution.red, .two)
        XCTAssertEqual(distribution.yellow, .one)
        XCTAssertEqual(distribution.blue, .zero)
        XCTAssertEqual(distribution.black, .zero)
    }
    
    func testRemovingPastZero()
    {
        setUpFullDistribution()
        //Testing each color
        distribution = distribution.remove(cubes: .two, of: .red)
        distribution = distribution.remove(cubes: .two, of: .red)
        XCTAssertEqual(distribution.red, .zero)
        
        distribution = distribution.remove(cubes: .two, of: .yellow)
        distribution = distribution.remove(cubes: .two, of: .yellow)
        XCTAssertEqual(distribution.yellow, .zero)
        
        distribution = distribution.remove(cubes: .two, of: .blue)
        distribution = distribution.remove(cubes: .two, of: .blue)
        XCTAssertEqual(distribution.blue, .zero)
        
        distribution = distribution.remove(cubes: .two, of: .black)
        distribution = distribution.remove(cubes: .two, of: .black)
        XCTAssertEqual(distribution.black, .zero)
    }
    
    private func setUpFullDistribution()
    {
        (outbreak, distribution) = distribution.add(cubes: [.red: .three, .yellow: .three, .black: .three, .blue: .three])
    }
}
