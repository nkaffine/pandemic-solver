//
//  InfectionRateTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/5/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class InfectionRateTests: XCTestCase {
    func testCardsToDraw()
    {
        XCTAssertEqual(InfectionRate.one.cardsToDraw, 2)
        XCTAssertEqual(InfectionRate.two.cardsToDraw, 2)
        XCTAssertEqual(InfectionRate.three.cardsToDraw, 2)
        XCTAssertEqual(InfectionRate.four.cardsToDraw, 3)
        XCTAssertEqual(InfectionRate.five.cardsToDraw, 3)
        XCTAssertEqual(InfectionRate.six.cardsToDraw, 4)
        XCTAssertEqual(InfectionRate.seven.cardsToDraw, 4)
    }
    
    func testNext()
    {
        XCTAssertEqual(InfectionRate.one.next(), .two)
        XCTAssertEqual(InfectionRate.two.next(), .three)
        XCTAssertEqual(InfectionRate.three.next(), .four)
        XCTAssertEqual(InfectionRate.four.next(), .five)
        XCTAssertEqual(InfectionRate.five.next(), .six)
        XCTAssertEqual(InfectionRate.six.next(), .seven)
        XCTAssertEqual(InfectionRate.seven.next(), .seven)
    }
}
