//
//  CurrentPlayerTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/11/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class CurrentPlayerTests: XCTestCase {
    var pawns: [Pawn]!
    var sut: CurrentTurn!
    
    override func setUp()
    {
        pawns = Pawn.allCases
        sut = CurrentTurn(pawns: pawns)
    }
    
    func testNext()
    {
        var perceivedPawnOrder = [sut.currentPawn]
        (0..<(5 * pawns.count) - 1).forEach
        { _ in
            sut = sut.next()
            if perceivedPawnOrder.last != sut.currentPawn
            {
                perceivedPawnOrder.append(sut.currentPawn)
            }
        }
        XCTAssertEqual(perceivedPawnOrder.count, pawns.count)
        sut = sut.next()
        var currentPawn = sut.currentPawn
        (0..<pawns.count).forEach
        { _ in
            XCTAssertEqual(sut.actionsLeft, 4)
            (0..<4).forEach
                { turnNum in
                    sut = sut.next()
                    XCTAssertEqual(sut.actionsLeft, 4 - (turnNum + 1))
                    XCTAssertEqual(sut.currentPawn, currentPawn)
            }
            
            sut = sut.next()
            XCTAssertEqual(sut.actionsLeft, 4)
            XCTAssertEqual(perceivedPawnOrder.index(of: sut.currentPawn),
                           (perceivedPawnOrder.index(of: currentPawn)! + 1) % perceivedPawnOrder.count)
            currentPawn = sut.currentPawn
        }
    }
}
