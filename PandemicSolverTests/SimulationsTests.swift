//
//  SimulationsTests.swift
//  PandemicSolverTests
//
//  Created by JOAN COYNE on 4/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class SimulationsTests: XCTestCase {
    var sim: Simulation!

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        sim = Simulation(iterations:  10)
    }
    func testInit()
    {
        print("Hello")
    }
    func testGameState()
    {
        var newGS: GameState
         var gs1: GameState
        var gs2: GameState
        var gs3: GameState
        var gs4: GameState
        var gs5: GameState
        var gs6: GameState
        var gs7: GameState
        var gs8: GameState
        var gs9: GameState
        var gs10: GameState
         newGS  = sim.run()
         gs1 = sim.oneTurn(gs: newGS)
       
        for _ in 1...350{
            gs2 = sim.oneTurn(gs:gs1)
            gs3 = sim.oneTurn(gs: gs2)
            gs4 = sim.oneTurn(gs: gs3)
            gs5 = sim.oneTurn(gs: gs4)
            gs6 = sim.oneTurn(gs: gs5)
            gs7 = sim.oneTurn(gs: gs6)
            gs8 = sim.oneTurn(gs: gs7)
            gs9 = sim.oneTurn(gs: gs8)
            gs10 = sim.oneTurn(gs: gs9)
            gs1 = sim.oneTurn(gs: gs10)
        }
        
        
        
        
       
        
        
       
        
    }
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
