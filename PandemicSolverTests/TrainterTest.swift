//
//  TrainterTest.swift
//  PandemicSolverTests
//
//  Created by JOAN COYNE on 4/19/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class TrainterTest: XCTestCase {
 var trainer: Trainer!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
       let utility = Utility()
        trainer = Trainer(utility:utility)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        trainer.train()
        /**
         var simulator: PandemicSimulatorProtocol = PandemicSimulator(missingRule: nil)
         simulator = simulator.startGame()
         print(simulator.gameStatus)
 */
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
