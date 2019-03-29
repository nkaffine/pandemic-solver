//
//  TestCubeCount.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/29/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class TestCubeCount: XCTestCase {
    func testAddingCubeCount()
    {
        CubeCount.allCases.forEach
        { cubeCount in
            XCTAssertEqual(cubeCount + .zero, cubeCount)
        }
        XCTAssertEqual(CubeCount.one + .one, .two)
        XCTAssertEqual(CubeCount.one + .two, .three)
        XCTAssertEqual(CubeCount.one + .three, .three)
        XCTAssertEqual(CubeCount.two + .two, .three)
        XCTAssertEqual(CubeCount.two + .three, .three)
        XCTAssertEqual(CubeCount.three + .three, .three)
    }
    
    func testSubtractingCubeCount()
    {
        CubeCount.allCases.forEach
        { cubeCount in
            XCTAssertEqual(cubeCount - .zero, cubeCount)
            XCTAssertEqual(.zero - cubeCount, .zero)
        }
        XCTAssertEqual(CubeCount.one - .one, .zero)
        XCTAssertEqual(CubeCount.one - .two, .zero)
        XCTAssertEqual(CubeCount.one - .three, .zero)
        XCTAssertEqual(CubeCount.two - .one, .one)
        XCTAssertEqual(CubeCount.two - .two, .zero)
        XCTAssertEqual(CubeCount.two - .three, .zero)
        XCTAssertEqual(CubeCount.three - .one, .two)
        XCTAssertEqual(CubeCount.three - .two, .one)
        XCTAssertEqual(CubeCount.three - .three, .zero)
    }
    
    func testLessThanCubeCount()
    {
        CubeCount.allCases.forEach
        { cubeCount in
            XCTAssertFalse(cubeCount < cubeCount)
        }
        XCTAssertTrue(.zero < .one)
        XCTAssertTrue(.zero < .two)
        XCTAssertTrue(.zero < .three)
        XCTAssertFalse(.one < .zero)
        XCTAssertTrue(.one < .two)
        XCTAssertTrue(.one < .three)
        XCTAssertFalse(.two < .zero)
        XCTAssertFalse(.two < .one)
        XCTAssertTrue(.two < .three)
        CubeCount.allCases.forEach
        { cubeCount in
            XCTAssertFalse(.three < cubeCount)
        }
    }
    
    func testWillOutbreak()
    {
        XCTAssertFalse(CubeCount.zero.willOutbreak(with: .zero))
        XCTAssertFalse(CubeCount.zero.willOutbreak(with: .one))
        XCTAssertFalse(CubeCount.zero.willOutbreak(with: .two))
        XCTAssertFalse(CubeCount.zero.willOutbreak(with: .three))
        
        XCTAssertFalse(CubeCount.one.willOutbreak(with: .zero))
        XCTAssertFalse(CubeCount.one.willOutbreak(with: .one))
        XCTAssertFalse(CubeCount.one.willOutbreak(with: .two))
        XCTAssertTrue(CubeCount.one.willOutbreak(with: .three))
        
        XCTAssertFalse(CubeCount.two.willOutbreak(with: .zero))
        XCTAssertFalse(CubeCount.two.willOutbreak(with: .one))
        XCTAssertTrue(CubeCount.two.willOutbreak(with: .two))
        XCTAssertTrue(CubeCount.two.willOutbreak(with: .three))
        
        XCTAssertFalse(CubeCount.three.willOutbreak(with: .zero))
        XCTAssertTrue(CubeCount.three.willOutbreak(with: .one))
        XCTAssertTrue(CubeCount.three.willOutbreak(with: .two))
        XCTAssertTrue(CubeCount.three.willOutbreak(with: .three))
        
    }
}
