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
    //  Test shuttle flight
    //  Test direct flight error
    //  Save the curring for when there is a draw and infect action.
    //  Test curring action
    //  Test curring error
    
    //  Test treating action
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
        
        //Should not be able to build a research station because one already exists.
        XCTAssertFalse(newSut.legalActions(for: operationsExpert).contains(buildResearchStation))
        
        //Should be able to build after moving as well
        let newSut2 = moveRandomLegalDirection(with: operationsExpert, in: newSut)
        XCTAssertTrue(newSut2.legalActions(for: operationsExpert).contains(buildResearchStation))
        let newSut3 = try! newSut2.transition(pawn: operationsExpert, for: buildResearchStation)
        //Ops expert shouldn't discard card.
        XCTAssertEqual(try! newSut3.hand(for: operationsExpert).cards, try! sut.hand(for: operationsExpert).cards)
        
        //Should not be able to build a research station because one already exists.
        XCTAssertFalse(newSut3.legalActions(for: operationsExpert).contains(buildResearchStation))
        
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
        var haveDoneCharterActions: [Pawn : Bool] = [:]
        while !(sut.pawns.reduce(true,
        { result, pawn -> Bool in
            return result && (haveDoneCharterActions[pawn] ?? false)
        }))
        {
            let legalActions = sut.legalActions()
            let charterActions = legalActions.filter
            { action -> Bool in
                switch action
                {
                    case .general(let generalAction):
                        switch generalAction
                        {
                            case .charterFlight:
                                return true
                            default:
                                return false
                        }
                    case .dispatcher(action: let dispatcherAction):
                        switch dispatcherAction
                        {
                        case .control(_, let action):
                            switch action
                            {
                                case .general(action: .charterFlight):
                                    return true
                                default:
                                    return false
                            }
                        case .snap:
                            return false
                        }
                    case .drawAndInfect:
                        return false
                }
            }
            if !charterActions.isEmpty
            {
                let oldState = sut!
                let currentPlayer = sut.currentPlayer
                sut = try! sut.execute(action: charterActions.randomElement()!)
                XCTAssertNotEqual(try! sut.hand(for: currentPlayer).cards, try! oldState.hand(for: currentPlayer).cards)
                XCTAssertFalse(try sut.hand(for: currentPlayer)
                    .cards.contains(Card(cityName: oldState.location(of: currentPlayer).city.name)))
                haveDoneCharterActions[currentPlayer] = true
            }
            else
            {
                sut = try! sut.execute(action: legalActions.randomElement()!)
            }
            if !sut.gameStatus.isInProgress
            {
                sut = GameBoard().startGame()
            }
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
        var haveDoneDirectFlights: [Pawn : Bool] = [:]
        while !(sut.pawns.reduce(true,
                                 { result, pawn -> Bool in
                                    return result && (haveDoneDirectFlights[pawn] ?? false)
        }))
        {
            let legalActions = sut.legalActions()
            let directFlightActions = legalActions.filter
            { action -> Bool in
                switch action
                {
                case .general(let generalAction):
                    switch generalAction
                    {
                    case .directFlight:
                        return true
                    default:
                        return false
                    }
                case .dispatcher(action: let dispatcherAction):
                    switch dispatcherAction
                    {
                    case .control(_, let action):
                        switch action
                        {
                            case .general(action: .directFlight):
                                return true
                            default:
                                return false
                        }
                    case .snap:
                        return false
                    }
                case .drawAndInfect:
                    return false
                }
            }
            if !directFlightActions.isEmpty
            {
                let oldState = sut!
                let currentPlayer = sut.currentPlayer
                let action = directFlightActions.randomElement()!
                let movingPawn =
                { () -> Pawn in
                    switch action
                    {
                        case .dispatcher(let dispatcherAction):
                            switch dispatcherAction
                            {
                                case .control(let pawn, _):
                                    return pawn
                                default:
                                    return currentPlayer
                            }
                        default:
                            return currentPlayer
                    }
                }()
                sut = try! sut.execute(action: action)
                let cardDiscarded = (try! oldState.hand(for: currentPlayer)).cards
                    .filter{ !(try! sut.hand(for: currentPlayer)).cards.contains($0) }.first!
                XCTAssertEqual(sut.location(of: movingPawn).city.name, cardDiscarded.cityName!)
                XCTAssertNotEqual(try! sut.hand(for: currentPlayer).cards, try! oldState.hand(for: currentPlayer).cards)
                XCTAssertFalse(try sut.hand(for: currentPlayer).cards
                    .contains(Card(cityName: sut.location(of: movingPawn).city.name)))
                haveDoneDirectFlights[currentPlayer] = true
            }
            else
            {
                sut = try! sut.execute(action: legalActions.randomElement()!)
            }
            if !sut.gameStatus.isInProgress
            {
                sut = GameBoard().startGame()
            }
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
    
    func testShuttleFlight()
    {
        let pawn = Pawn(role: .operationsExpert)
        var researchStations = [CityName]()
        researchStations.append(sut.location(of: pawn).city.name)
        let sut2 = try! sut.transition(pawn: pawn, for: .general(action: .buildResearchStation))
        let sut3 = try! moveRandomLegalDirection(with: pawn, in: sut2)
            .transition(pawn: pawn, for: .general(action: .buildResearchStation))
        researchStations.append(sut3.location(of: pawn).city.name)
        sut.pawns.filter{ $0.role != .operationsExpert }.forEach
        { pawn in
            XCTAssertTrue(sut3.legalActions(for: pawn).contains(.general(action: .shuttleFlight(to: researchStations[1]))))
            let sut4 = try! sut3.transition(pawn: pawn, for: .general(action: .shuttleFlight(to: researchStations[1])))
            XCTAssertEqual(sut4.location(of: pawn).city.name, researchStations[1])
        }
        XCTAssertTrue(sut3.legalActions(for: pawn).contains(.general(action: .shuttleFlight(to: researchStations[0]))))
        let sut4 = try! sut3.transition(pawn: pawn, for: .general(action: .shuttleFlight(to: researchStations[0])))
        XCTAssertEqual(sut4.location(of: pawn).city.name, researchStations[0])
    }
    
    func testShuttleFlightError()
    {
        sut.pawns.forEach
        { pawn in
            XCTAssertNil(try? sut.transition(pawn: pawn, for: .general(action: .shuttleFlight(to: .atlanta))))
        }
    }
    
    func testTreatingAction()
    {
        sut = sut.startGame()
        let infected = sut.locations.filter{ $0.cubes.black > .zero || $0.cubes.red > .zero
            || $0.cubes.blue > .zero || $0.cubes.yellow > .zero}
        sut.pawns.forEach
        { pawn in
            var currentState = sut!
            while !infected.contains(currentState.location(of: pawn))
            {
                currentState = moveRandomLegalDirection(with: pawn, in: currentState)
            }
            let currentLocation = currentState.location(of: pawn)
            switch currentLocation.city.color
            {
                case .red:
                    let newState = try! currentState.transition(pawn: pawn, for: .general(action: .treat(disease: .red)))
                    XCTAssertTrue(newState.locations.first(where: { $0 == currentLocation })!.cubes.red <
                        currentState.locations.first(where: { $0 == currentLocation })!.cubes.red)
                case .yellow:
                    let newState = try! currentState.transition(pawn: pawn, for: .general(action: .treat(disease: .yellow)))
                    XCTAssertTrue(newState.locations.first(where: { $0 == currentLocation })!.cubes.yellow <
                        currentState.locations.first(where: { $0 == currentLocation })!.cubes.yellow)
                case .black:
                    let newState = try! currentState.transition(pawn: pawn, for: .general(action: .treat(disease: .black)))
                    XCTAssertTrue(newState.locations.first(where: { $0 == currentLocation })!.cubes.black <
                        currentState.locations.first(where: { $0 == currentLocation })!.cubes.black)
                case .blue:
                    let newState = try! currentState.transition(pawn: pawn, for: .general(action: .treat(disease: .blue)))
                    XCTAssertTrue(newState.locations.first(where: { $0 == currentLocation })!.cubes.blue <
                        currentState.locations.first(where: { $0 == currentLocation })!.cubes.blue)
            }
        }
    }
    
    func testPassAction()
    {
        sut.pawns.forEach
        { pawn in
            let newSut = try! sut.transition(pawn: pawn, for: .general(action: .pass))
            XCTAssertEqual(newSut.actionsRemaining, sut.actionsRemaining)
            XCTAssertEqual(newSut.cubesRemaining, sut.cubesRemaining)
            XCTAssertEqual(newSut.curedDiseases, sut.curedDiseases)
            XCTAssertEqual(newSut.currentPlayer, sut.currentPlayer)
            XCTAssertEqual(newSut.gameStatus, sut.gameStatus)
            sut.pawns.forEach
            { pawn1 in
                XCTAssertEqual(try! newSut.hand(for: pawn).cards, try! sut.hand(for: pawn).cards)
                XCTAssertEqual(newSut.location(of: pawn), sut.location(of: pawn))
            }
            XCTAssertEqual(newSut.infectionPile.count, sut.infectionPile.count)
            XCTAssertEqual(newSut.infectionRate, sut.infectionRate)
            XCTAssertEqual(newSut.locations, sut.locations)
            XCTAssertEqual(newSut.maxOutbreaks, sut.maxOutbreaks)
            XCTAssertEqual(newSut.outbreaksSoFar, sut.outbreaksSoFar)
            XCTAssertEqual(newSut.pawns, sut.pawns)
            XCTAssertEqual(newSut.playerDeck.count, sut.playerDeck.count)
            XCTAssertEqual(newSut.uncuredDiseases, sut.uncuredDiseases)
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
                case .drawAndInfect:
                    return false
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
                case .drawAndInfect:
                    return false
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
                case .drawAndInfect:
                    return false
            }
        }.isEmpty
    }
}
