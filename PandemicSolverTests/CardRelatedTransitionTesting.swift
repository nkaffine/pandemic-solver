//
//  CardRelatedTransitionTesting.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
/*@testable import PandemicSolver

class CardRelatedTransitionTesting: XCTestCase {
    var sut: GameState!
    
    override func setUp()
    {
        sut = GameBoard()
    }
    
    //TODO: Test curing and errors
    func testCuringWorks()
    {
        let startState = sut!.startGame()
        //Testing it a bunch of times just to get a good chance of each role being tested
        (0..<10).forEach
        { _ in
            var currentState = startState
            while !hasFiveOfSameColor(hand: try! currentState.hand(for: currentState.currentPlayer))
            {
                currentState = makeRandomMovingMove(state: currentState)
                //TODO: just restart the test if the game is lost.
                XCTAssertNotEqual(currentState.gameStatus, GameStatus.loss(reason: "random reason"))
            }
            while !currentState.legalActions().contains(where:
                { action -> Bool in
                    switch action
                    {
                    case .dispatcher:
                        return false
                    case .drawAndInfect:
                        return false
                    case .general(let generalAction):
                        switch generalAction
                        {
                        case .cure:
                            return true
                        default:
                            return false
                        }
                    }
            })
            {
                currentState = tryToCureInAtlanta(state: currentState)
                XCTAssertNotEqual(currentState.gameStatus, GameStatus.loss(reason: "random reason"))
            }
            let newState = try! currentState.execute(action: currentState.legalActions().filter({ action -> Bool in
                switch action
                {
                case Action.general(let generalAction):
                    switch generalAction
                    {
                    case .cure:
                        return true
                    default:
                        return false
                    }
                default:
                    return false
                }
            }).first!)
            XCTAssertEqual(newState.curedDiseases.count, 1)
            let threshold = newState.currentPlayer.role == .scientist ? 4 : 5
            XCTAssertTrue((try! newState.hand(for: newState.currentPlayer)).cards.count
                < (try! currentState.hand(for: newState.currentPlayer)).cards.count)
            XCTAssertEqual((try! newState.hand(for: newState.currentPlayer)).cards.count,
                           (try! currentState.hand(for: newState.currentPlayer)).cards.count - threshold,
                           "\(newState.currentPlayer.role)")
            let cardDifference = try! currentState.hand(for: newState.currentPlayer).cards.filter
            { card -> Bool in
                return !(try! newState.hand(for: newState.currentPlayer)).cards.contains(card)
            }
            XCTAssertTrue(cardDifference.reduce((true, cardDifference.first!),
                                                { result, card -> (Bool, Card) in
                                                    return (result.0 && result.1.cityName!.color == card.cityName!.color, card)
            }).0)
        }
    }
    
    private func hasFiveOfSameColor(hand: HandProtocol) -> Bool
    {
        return DiseaseColor.allCases.reduce(false)
        { result, color -> Bool in
            return result || hasFiveOf(color: color, hand: hand)
        }
    }
    
    private func hasFiveOf(color: DiseaseColor, hand: HandProtocol) -> Bool
    {
        return hand.cards.filter { $0.cityName!.color == color }.count >= 5
    }
    
    private func makeRandomMovingMove(state: GameState) -> GameState
    {
        let movingActions = state.legalActions().filter
        { action -> Bool in
            switch action
            {
                case .dispatcher:
                    return false
                case .drawAndInfect:
                    return true
                case .general(let generalAction):
                    switch generalAction
                    {
                        case .drive:
                            return true
                        default:
                            return false
                    }
            }
        }
        return try! state.execute(action: movingActions.randomElement()!)
    }
    
    private func tryToCureInAtlanta(state: GameState) -> GameState
    {
        let legalActions = state.legalActions()
        let drawAndInfect = legalActions.filter
        { action -> Bool in
            switch action
            {
                case .dispatcher:
                    return false
                case .drawAndInfect:
                    return true
                case .general:
                    return false
            }
        }
        if !drawAndInfect.isEmpty
        {
            return try! state.execute(action: .drawAndInfect)
        }
        let curing = legalActions.filter
        { action -> Bool in
            switch action
            {
                case .dispatcher:
                    return false
                case .drawAndInfect:
                    return false
                case .general(let generalAction):
                    switch generalAction
                    {
                        case .cure:
                            return true
                        default:
                            return false
                    }
            }
        }
        if !curing.isEmpty
        {
            return try! state.execute(action: curing.first!)
        }
        else
        {
            let moveActions = legalActions.compactMap
            { action -> GeneralAction? in
                switch action
                {
                    case .dispatcher:
                        return nil
                    case .drawAndInfect:
                        return nil
                    case .general(let generalAction):
                        switch generalAction
                        {
                            case .drive:
                                return generalAction
                            default:
                                return nil
                        }
                    }
            }
            var bestAction: (Int, GeneralAction)? = nil
            moveActions.forEach
            { action in
                switch action
                {
                    case .drive(let city):
                        let distToAtlanta = StupidHelper.bestDistanceToAtlanta(from: city)
                        if let (dist, _) = bestAction
                        {
                            if dist > distToAtlanta
                            {
                                bestAction = (distToAtlanta, action)
                            }
                        }
                        else
                        {
                            bestAction = (distToAtlanta, action)
                        }
                    default:
                        break
                }
            }
            if let (_, bestAction) = bestAction
            {
                return try! state.execute(action: .general(action: bestAction))
            }
            else
            {
                return state
            }
        }
    }
    
    
    //TODO: Test share knowledge and errors
}

struct StupidHelper
{
    static func bestDistanceToAtlanta(from city: CityName) -> Int
    {
        switch city
        {
        case .sanFrancisco:
            return 2
        case .chicago:
            return 1
        case .toronto:
            return 2
        case .newYork:
            return 2
        case .losAngeles:
            return 2
        case .atlanta:
            return 0
        case .washington:
            return 1
        case .mexicoCity:
            return 2
        case .miami:
            return 1
        case .bogota:
            return 2
        case .lima:
            return 3
        case .saoPaulo:
            return 3
        case .santiago:
            return 4
        case .buenosAres:
            return 3
        case .london:
            return 3
        case .essen:
            return 4
        case .stPetersburg:
            return 5
        case .madrid:
            return 3
        case .paris:
            return 4
        case .milan:
            return 5
        case .algiers:
            return 4
        case .istanbul:
            return 5
        case .moscow:
            return 6
        case .cairo:
            return 5
        case .baghdad:
            return 6
        case .tehran:
            return 7
        case .riyadh:
            return 6
        case .karachi:
            return 7
        case .delhi:
            return 6
        case .mumbai:
            return 6
        case .kolkata:
            return 5
        case .chennai:
            return 5
        case .lagos:
            return 4
        case .khartoum:
            return 5
        case .kinshasa:
            return 5
        case .johannesburg:
            return 6
        case .beijing:
            return 5
        case .seoul:
            return 4
        case .shanghai:
            return 4
        case .tokyo:
            return 3
        case .hongKong:
            return 4
        case .taipei:
            return 4
        case .osaka:
            return 4
        case .bangkok:
            return 5
        case .hoChiMinhCity:
            return 4
        case .manila:
            return 3
        case .jakarta:
            return 4
        case .sydney:
            return 3
        }
    }
}*/
