//
//  CardTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/28/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class CardTests: XCTestCase {
    func testEqualCard()
    {
        let card1 = Card.epidemic
        let card2 = Card.epidemic
        XCTAssertEqual(card1, card2)
        
        let card3 = Card.cityCard(card: CityCard(city: City(name: .algiers)))
        let card4 = Card.cityCard(card: CityCard(city: City(name: .algiers)))
        XCTAssertNotEqual(card2, card3)
        XCTAssertEqual(card3, card4)
        
        let card5 = Card.cityCard(card: CityCard(city: City(name: .atlanta)))
        XCTAssertNotEqual(card4, card5)
    }
}
