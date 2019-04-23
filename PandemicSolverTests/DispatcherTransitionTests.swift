//
//  BoardTransitionTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/2/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class DispatcherTransitionTests: XCTestCase {
    var sut: DispatcherMockBoard!
    
    override func setUp()
    {
        sut = DispatcherMockBoard()
        while !sut.pawns.contains(Pawn(role: .dispatcher))
        {
            sut = DispatcherMockBoard()
        }
    }
    
    func testDispatcherControlAction()
    {
        while !sut.pawns.contains(Pawn(role: .dispatcher))
        {
            sut = DispatcherMockBoard()
        }
        let pawn1 = Pawn(role: .dispatcher)
        let pawn2 = sut.pawns.filter{ $0.role != .dispatcher }.randomElement()!
        let controlAction = Action.general(action: .drive(to: .washington))
        let action = Action.dispatcher(action: .control(pawn: pawn2, action: controlAction))
        let _ = try! sut.transition(pawn: pawn1, for: action)
        XCTAssertEqual(sut.transitions[0].0, pawn1)
        XCTAssertEqual(sut.transitions[0].1, action)
        XCTAssertEqual(sut.transitions[1].0, pawn2)
        XCTAssertEqual(sut.transitions[1].1, controlAction)
    }
    
    func testSnapAction()
    {
        //Testing invalid snap actions
        let pawnNotOnBoard = Pawn.allCases.filter { !sut.pawns.contains($0) }.first!
        let swappingPawn = sut.pawns.first!
        let action = Action.dispatcher(action: .snap(pawn: swappingPawn, to: pawnNotOnBoard))
        let dispatcher = Pawn(role: .dispatcher)
        XCTAssertNil(try? sut.transition(pawn: dispatcher, for: action))
        
        let action2 = Action.dispatcher(action: .snap(pawn: pawnNotOnBoard, to: swappingPawn))
        XCTAssertNil(try? sut.transition(pawn: dispatcher, for: action2))
        
        //Moving one pawn in the snap because they all start in the same city by default.
        let swappingPawn2 = sut.pawns[1]
        let moveAction = sut.legalActions(for: swappingPawn2).filter
        { action -> Bool in
            switch action
            {
                case .general(let generalAction):
                    switch generalAction
                    {
                        case .drive:
                            return true
                        default:
                            return false
                    }
                case .dispatcher:
                    return false
                case .drawAndInfect:
                    
                    return false
            }
        }.first!
        //Making sure the two pawns in the swap are not in the same city.
        let newSut = try! sut.transition(pawn: swappingPawn2, for: moveAction).0
        XCTAssertNotEqual(sut.location(of: swappingPawn2), newSut.location(of: swappingPawn2))
        XCTAssertNotEqual(newSut.location(of: swappingPawn2), sut.location(of: swappingPawn))
        
        //Checking that swapping them moves them to the same city and that the city is the second pawns original city.
        let newAction = Action.dispatcher(action: .snap(pawn: swappingPawn2, to: swappingPawn))
        let newSut2 = try! newSut.transition(pawn: dispatcher, for: newAction).0
        XCTAssertEqual(newSut2.location(of: swappingPawn2), newSut2.location(of: swappingPawn))
        XCTAssertEqual(newSut2.location(of: swappingPawn), sut.location(of: swappingPawn))
    }
    
    func testThatOnlyDispatcherCanDoDispatcherMoves()
    {
        let nonDispatcher = sut.pawns.filter { $0 != Pawn(role: .dispatcher) }.first!
        let dispatcher = Pawn(role: .dispatcher)
        let controlAction = Action.dispatcher(action: .control(pawn: dispatcher, action: .general(action: .buildResearchStation)))
        XCTAssertNil(try? sut.transition(pawn: nonDispatcher, for: controlAction))
        
        let swapAction = Action.dispatcher(action: .snap(pawn: nonDispatcher, to: dispatcher))
        XCTAssertNil(try? sut.transition(pawn: nonDispatcher, for: swapAction))
    }
}


class DispatcherMockBoard: GameBoard
{
    var transitions: [(pawn: Pawn, action: Action)] = []
    override func transition(pawn: Pawn, for action: Action) throws -> (GameState, Reward)
    {
        transitions.append((pawn, action))
        return try super.transition(pawn: pawn, for: action)
    }
}
