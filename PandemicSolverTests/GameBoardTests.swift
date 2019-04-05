//
//  GameBoardTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/1/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class GameBoardTests: XCTestCase {
    var sut: GameBoard!
    
    override func setUp()
    {
        sut = GameBoard()
    }
    
    func testInit()
    {
        DiseaseColor.allCases.forEach
        { disease in
            XCTAssertEqual(sut.cubesRemaining[disease]!, 24)
        }
        XCTAssertEqual(sut.curedDiseases, [])
        XCTAssertEqual(sut.uncuredDiseases, DiseaseColor.allCases)
        sut.locations.forEach
        { location in
            XCTAssertEqual(location.cubes.black, .zero)
            XCTAssertEqual(location.cubes.red, .zero)
            XCTAssertEqual(location.cubes.blue, .zero)
            XCTAssertEqual(location.cubes.yellow, .zero)
        }
        XCTAssertEqual(sut.pawns.count, 4)
        sut.pawns.forEach
        { pawn in
            XCTAssertEqual(sut.location(of: pawn).city.name, .atlanta)
            XCTAssertEqual(try! sut.hand(for: pawn).cards.count, 2)
            XCTAssertTrue(!(try! sut.hand(for: pawn).cards.contains(.epidemic)))
        }
        XCTAssertEqual(sut.playerDeck.count, 45)
        //TODO: This should be fixed when the probability function is fixed
        XCTAssertEqual(sut.playerDeck.probability(ofDrawing: .epidemic), 1/Double(5))
        XCTAssertEqual(sut.infectionPile.count, 48)
        XCTAssertEqual(sut.infectionRate, 2)
        XCTAssertEqual(sut.outbreaksSoFar, 0)
        XCTAssertEqual(sut.maxOutbreaks, 7)
        XCTAssertEqual(sut.gameStatus, .notStarted)
        sut.locations.forEach
        { location in
            XCTAssertFalse(location.hasResearchStation)
        }
    }
    
    func testSetup()
    {
        let sut1 = sut.startGame()
        XCTAssertEqual(sut1.locations.filter { location -> Bool in
            return onlyHasOneSetOfCubes(cubes: location.cubes, with: .three)
        }.count, 3)
        XCTAssertEqual(sut1.locations.filter({ location -> Bool in
            return onlyHasOneSetOfCubes(cubes: location.cubes, with: .two)
        }).count, 3)
        XCTAssertEqual(sut1.locations.filter({ location -> Bool in
            return onlyHasOneSetOfCubes(cubes: location.cubes, with: .one)
        }).count, 3)
        XCTAssertEqual(sut1.locations.filter({ location -> Bool in
            return onlyHasOneSetOfCubes(cubes: location.cubes, with: .zero)
        }).count, 39)
        XCTAssertEqual(sut1.gameStatus, .inProgress)
        sut1.locations.forEach
        { location in
            location.city.name != .atlanta ? XCTAssertFalse(location.hasResearchStation) : XCTAssertTrue(location.hasResearchStation)
        }
    }
    
    func testAvailableInitialMoves()
    {
//        sut = sut.setupGame()
    }
    
    
    ///MARK: Utility functions
    private func hasDistribution(cubes: CubeDistributionProtocol, red: CubeCount = .zero,
                                 yellow: CubeCount = .zero, blue: CubeCount = .zero,
                                 black: CubeCount = .zero) -> Bool
    {
        return cubes.red == red && cubes.yellow == yellow && cubes.blue == blue && cubes.black == black
    }
    
    private func onlyHasOneSetOfCubes(cubes: CubeDistributionProtocol, with count: CubeCount) -> Bool
    {
        return hasDistribution(cubes: cubes, red: count)
            || hasDistribution(cubes: cubes, yellow: count)
            || hasDistribution(cubes: cubes, blue: count)
            || hasDistribution(cubes: cubes, black: count)
    }
}
