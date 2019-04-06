//
//  RegularTransitionTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/5/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class RegularTransitionTests: XCTestCase {
    var sut: GameState!
    
    override func setUp() {
        sut = GameBoard()
        //Will need all except dispatcher to thouroughly test some functions
        while sut.pawns.contains(Pawn(role: .dispatcher))
        {
            sut = GameBoard()
        }
    }
    
    //Regular actions:
    //  Test building research station
    //  Test building research station error
    //  Test charter flight
    //  Test charter flight error
    //  Test direct flight
    //  Test direct flight error
    //  Test curring action
    //  Test treating action
    //  Test treet error
    //  Test pass
    //  Test share knowledge
    //  Test share knoweldge error
    func testResearchStation()
    {
        let (pawn, city) = moveUntilCanBuildResearchStation()
        //Testing that there wasn't already a research station there
        XCTAssertFalse(sut.locations.filter { $0.city.name == city }.first!.hasResearchStation)
        
        //Check that the move actually did something and that the old state wasn't changed
        let newSut1 = (try! sut.transition(pawn: pawn, for: Action.general(action: .buildResearchStation)))
        
        //Check that the card was discarded
        XCTAssertTrue(try! sut.hand(for: pawn).cards.contains(Card(cityName: sut.location(of: pawn).city.name)))
        XCTAssertFalse(try! newSut1.hand(for: pawn).cards.contains(Card(cityName: sut.location(of: pawn).city.name)))
        
        //Make sure they can't make the research station now
        XCTAssertTrue(newSut1.legalActions(for: pawn).filter { $0 == Action.general(action: .buildResearchStation)}.isEmpty)
        XCTAssertFalse(sut.locations.filter { $0.city.name == city }.first!.hasResearchStation)
        XCTAssertTrue(newSut1.locations.filter { $0.city.name == city }.first!.hasResearchStation)
    }
    
    func testResearchStationError()
    {
        //Check that the board with throw an error if they try to build a research station where they can't
        let (pawn, _) = moveUntilCantBuildResearchStation()
        let action  = Action.general(action: .buildResearchStation)
        XCTAssertNil(try? sut.transition(pawn: pawn, for: action))
    }
    
    func testResearchStationWithOpsExpert()
    {
        //Going to test that he can move to three different cities and build research stations because he
        //can do it without having the cards and he only has two cards to start with.
        let operationsExpert = Pawn(role: .operationsExpert)
        let buildResearchStation = Action.general(action: .buildResearchStation)
        
        //Check that the ops expert can build the research station from the start
        XCTAssertTrue(sut.legalActions(for: operationsExpert).contains(buildResearchStation))
        let newSut = try! sut.transition(pawn: operationsExpert, for: buildResearchStation)
        //Ops expert shouldn't discard a card
        XCTAssertEqual(try! newSut.hand(for: operationsExpert).cards, try! sut.hand(for: operationsExpert).cards)
        
        //Should still be able to build a research station for now.
        //TODO: remove building research station from the list if there is alread a research station.
        XCTAssertTrue(newSut.legalActions(for: operationsExpert).contains(buildResearchStation))
        
        //Should be able to build after moving as well
        let newSut2 = moveRandomLegalDirection(with: operationsExpert, in: newSut)
        XCTAssertTrue(newSut2.legalActions(for: operationsExpert).contains(buildResearchStation))
        let newSut3 = try! newSut2.transition(pawn: operationsExpert, for: buildResearchStation)
        //Ops expert shouldn't discard card.
        XCTAssertEqual(try! newSut3.hand(for: operationsExpert).cards, try! sut.hand(for: operationsExpert).cards)
        
        //Should still be able to build a research station for now.
        XCTAssertTrue(newSut3.legalActions(for: operationsExpert).contains(buildResearchStation))
        
        //No other pawn in any scenario should be able to build at this point.
        let newSut4 = moveRandomLegalDirection(with: operationsExpert, in: newSut3)
        XCTAssertTrue(newSut4.legalActions(for: operationsExpert).contains(buildResearchStation))
        //Ops expert shouldn't discard a card
        XCTAssertEqual(try! newSut4.hand(for: operationsExpert).cards, try! sut.hand(for: operationsExpert).cards)
    }
    
    func testOperationsExpertDoesntDiscardToBuildResearchStation()
    {
        let pawn = Pawn(role: .operationsExpert)
        var newState = sut!
        //Moving until the ops expert is in a city where he has the card in his hand.
        while !(try! newState.hand(for: pawn)).cards.contains(Card(cityName: newState.location(of: pawn).city.name))
        {
            newState = moveRandomLegalDirection(with: pawn, in: newState)
        }
        let newState2 = try! newState.transition(pawn: pawn, for: Action.general(action: .buildResearchStation))
        XCTAssertTrue((try! newState2.hand(for: pawn)).cards.contains(Card(cityName: newState2.location(of: pawn).city.name)))
    }
    
    func testCharterFlight()
    {
        try! sut.pawns.forEach
        { pawn in
            var newState = sut!
            while !hasLocationInHand(pawn: pawn, state: newState)
            {
                newState = moveRandomLegalDirection(with: pawn, in: newState)
            }
            let charterActions = newState.legalActions(for: pawn).filter
            { action -> Bool in
                switch action
                {
                case .dispatcher:
                    return false
                case .general(let generalAction):
                    switch generalAction
                    {
                    case .charterFlight:
                        return true
                    default:
                        return false
                    }
                }
            }
            let newState1 = try! newState.transition(pawn: pawn, for: charterActions.randomElement()!)
            XCTAssertNotEqual(try! newState1.hand(for: pawn).cards, try! newState.hand(for: pawn).cards)
            XCTAssertFalse(try newState1.hand(for: pawn).cards.contains(Card(cityName: newState.location(of: pawn).city.name)))
        }
    }
    
    func testCharterFlightError()
    {
        sut.pawns.forEach
        { pawn in
            var newState = sut!
            while hasLocationInHand(pawn: pawn, state: newState)
            {
                newState = moveRandomLegalDirection(with: pawn, in: newState)
            }
            XCTAssertNil(try? newState.transition(pawn: pawn, for: .general(action: .charterFlight(to: .algiers))))
        }
    }
    
    func testDirectFlight()
    {
        try! sut.pawns.forEach
        { pawn in
            var newState = sut!
            while hasLocationInHand(pawn: pawn, state: newState)
            {
                newState = moveRandomLegalDirection(with: pawn, in: newState)
            }
            let directFlightAction = newState.legalActions(for: pawn).filter
            { action -> Bool in
                switch action
                {
                case .dispatcher:
                    return false
                case .general(let generalAction):
                    switch generalAction
                    {
                    case .directFlight:
                        return true
                    default:
                        return false
                    }
                }
            }
            let newState1 = try! newState.transition(pawn: pawn, for: directFlightAction.first!)
            let cardDiscarded = (try! newState.hand(for: pawn)).cards
                .filter{ !(try! newState1.hand(for: pawn)).cards.contains($0) }.first!
            XCTAssertEqual(newState1.location(of: pawn).city.name, cardDiscarded.cityName!)
            XCTAssertNotEqual(try! newState1.hand(for: pawn).cards, try! newState.hand(for: pawn).cards)
            XCTAssertFalse(try newState1.hand(for: pawn).cards.contains(Card(cityName: newState1.location(of: pawn).city.name)))
        }
    }
    
    func testDirectFlightError()
    {
        let cityCards = GameStartHelper.generateCityCards()
        sut.pawns.forEach
        { pawn in
            let nonLegalDirectFlights = cityCards.filter{!(try! sut.hand(for: pawn).cards.contains($0))}
            XCTAssertNil(try? sut.transition(pawn: pawn, for: Action.general(action: .directFlight(to: nonLegalDirectFlights.randomElement()!.cityName!))))
        }
    }
    
    /**
     Returns whether the given pawn is in a location that is in its hand.
     - Parameters:
        - pawn: the pawn whose location is being querried.
        - state: the game state that is context for the query.
     - Returns: the boolean whether the pawn is in a location that is in its hand.
    */
    private func hasLocationInHand(pawn: Pawn, state: GameState) -> Bool
    {
        return (try! state.hand(for: pawn)).cards.contains(Card(cityName: state.location(of: pawn).city.name))
    }
    
    /**
     Takes the current state and moves the given pawn one direction randomly and returns the resulting gamestate.
    */
    private func moveRandomLegalDirection(with pawn: Pawn, in state: GameState) -> GameState
    {
        let legalAction = state.legalActions(for: pawn)
        let legalMoveActions = legalAction.filter
        { action -> Bool in
            switch action
            {
                case .dispatcher:
                    return false
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
        return try! state.transition(pawn: pawn, for: legalMoveActions.randomElement()!)
    }
    
    /**
     Performs random driving moves until the pawn is able to build a research station.
    */
    private func moveUntilCanBuildResearchStation() -> (pawn: Pawn, city: CityName)
    {
        let pawn = sut.pawns.filter{ $0 != Pawn(role: .operationsExpert) }.first!
        while !canBuildResearchStation(pawn: pawn)
        {
            makeRandomDrivingMove(pawn: pawn)
            
        }
        return (pawn, sut.location(of: pawn).city.name)
    }
    
    /**
     Performs random driving moves until the pawn is not able to build a research station.
    */
    private func moveUntilCantBuildResearchStation() -> (pawn: Pawn, city: CityName)
    {
        let pawn = sut.pawns.filter { $0 != Pawn(role: .operationsExpert) }.first!
        while canBuildResearchStation(pawn: pawn)
        {
            makeRandomDrivingMove(pawn: pawn)
        }
        return (pawn, sut.location(of: pawn).city.name)
    }
    
    /**
     Makes a random move and reasigns sut to the result of making that move.
    */
    private func makeRandomDrivingMove(pawn: Pawn)
    {
        sut = try! sut.transition(pawn: pawn, for: sut.legalActions(for: pawn).filter
        { action -> Bool in
            switch action
            {
                case .dispatcher:
                    return false
                case .general(let generalAction):
                    switch generalAction
                    {
                        case .drive:
                            return true
                        default:
                            return false
                    }
            }
        }.randomElement()!)
    }
    
    private func canBuildResearchStation(pawn: Pawn) -> Bool
    {
        return !sut.legalActions(for: pawn).filter
        { action -> Bool in
            switch action
            {
                case .dispatcher:
                    return false
                case .general(let generalAction):
                    switch generalAction
                    {
                        case .buildResearchStation:
                            return true
                        default:
                            return false
                    }
            }
        }.isEmpty
    }
}
