//
//  Pawn.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/29/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

enum Role: CaseIterable
{
    case medic, operationsExpert, dispatcher, scientist, researcher
}

/**
 Ideally all of the functions in this struct except for getLegalMoves would be private but given
 the amount of testing required to test all of the helper functions through that main function,
 I am going to leave that as a big TODO.
 */
struct Pawn: Hashable, CaseIterable
{
    typealias AllCases = [Pawn]
    
    static var allCases: [Pawn]
    {
        return Role.allCases.map{ Pawn(role: $0) }
    }
    
    let role: Role

    /**
     Gets all of the legal moves that this role can execute given the location graph, the pawns current hand, the
     pawns current location, the location of the other pawns, and the hands of the other pawns.
     - Parameters:
         - locationGraph: the graph of locations on the board.
         - currentHand: the current hand of the pawn.
         - currentLocation: the current location of the pawn.
         - otherPawnLocations: the locations of the all pawns in the game.
         - pawnHands: the hands of all the pawns in the game.
     - Returns: a list of all valid moves for the current gamestate.s
    */
    func getLegalMoves(for locationGraph: LocationGraphProtocol, with currentHand: HandProtocol, currentLocation: BoardLocation,
                       otherPawnLocations: [Pawn: CityName], pawnHands: [Pawn: HandProtocol]) -> [Action]
    {
        var actions = [Action.general(action: .pass)]
        if currentHand.cards.contains(where:
        { card -> Bool in
            switch card
            {
            case .cityCard(let cityCard):
                return cityCard.city == currentLocation.city
            case .epidemic:
                return false
            }
        })
        {
            actions.append(.general(action: .buildResearchStation))
        }
        
        actions.append(contentsOf: getTreatingActions(from: currentLocation))
        actions.append(contentsOf: getDrivingActions(from: currentLocation, on: locationGraph))
        actions.append(contentsOf: getOtherTransportationActions(from: currentLocation, currentHand: currentHand,
                                                                 locationGraph: locationGraph))
        actions.append(contentsOf: getCuringActions(from: currentHand, currentLocation: currentLocation))
        actions.append(contentsOf: getShareKnowledgeActions(with: currentHand,
                                                            otherPawnHands: pawnHands.filter { $0.key != self },
                                                            currentLocation: currentLocation.city.name,
                                                            otherPawnLocations: otherPawnLocations.filter
                                                            { (pawn, city) -> Bool in
                                                                return pawn != self
                                                            }))
        actions.append(contentsOf: getDispatcherMoves(otherPawnLocations: otherPawnLocations,
                                                      currentHand: currentHand, on: locationGraph))
        return actions
    }
    
    /**
     Gets all of the treating actions the pawn can take in their current city.
     - Parameters:
        - currentLocation: the current location on the board of the pawn.
     - Returns: a list of treating actions the pawn can take.
    */
    func getTreatingActions(from currentLocation: BoardLocation) -> [Action]
    {
        var actions = [Action]()
        if currentLocation.cubes.red > .zero
        {
            actions.append(Action.general(action: .treat(disease: .red)))
        }
        if currentLocation.cubes.yellow > .zero
        {
            actions.append(Action.general(action: .treat(disease: .yellow)))
        }
        if currentLocation.cubes.blue > .zero
        {
            actions.append(Action.general(action: .treat(disease: .blue)))
        }
        if currentLocation.cubes.black > .zero
        {
            actions.append(Action.general(action: .treat(disease: .black)))
        }
        return actions
    }
    
    /**
     Gets a list of driving actions the pawn can take based on their current location.
     - Parameters:
        - currentLocation: the spot on the board that they are in.
        - currentBoard: the current location graph.
     - Returns: a list of driving actions the pawn can take.
    */
    func getDrivingActions(from currentLocation: BoardLocation, on currentBoard: LocationGraphProtocol) -> [Action]
    {
        return currentBoard.edges[currentLocation.city.name]!.map
        { city -> Action in
            return Action.general(action: .drive(to: city))
        }
    }
    
    /**
     Gets a lits of all of the transportation actions that aren't the standard driving actions.
     - Parameters:
        - currentLocation: the current location the pawn is on the board.
        - currentHand: the current hand of the pawn.
        - locationGraph: the graph of all cities and connections
     - Returns: the moving actions not including driving the pawn can take based on current location
     and current hand.
    */
    func getOtherTransportationActions(from currentLocation: BoardLocation, currentHand: HandProtocol,
                                       locationGraph: LocationGraphProtocol) -> [Action]
    {
        var actions = currentHand.cards.compactMap
        { card -> Action? in
            switch card
            {
                case .cityCard(let cityCard):
                    if cityCard.city != currentLocation.city
                    {
                        return Action.general(action: .directFlight(to: cityCard.city.name))
                    }
                    else
                    {
                        return nil
                    }
                case .epidemic:
                    return nil
            }
        }
        if currentHand.cards.contains(where:
        { card -> Bool in
            switch card
            {
                case .cityCard(let cityCard):
                    return cityCard.city == currentLocation.city
                case .epidemic:
                    return false
            }
        })
        {
            actions.append(contentsOf: CityName.allCases.compactMap
            { city -> Action? in
                if city != currentLocation.city.name
                {
                    return Action.general(action: .charterFlight(to: city))
                }
                else
                {
                    return nil
                }
            })
        }
        if (currentLocation.hasResearchStation)
        {
            actions.append(contentsOf: locationGraph.getAllResearchStations().compactMap
            { location -> Action? in
                if location != currentLocation
                {
                    return Action.general(action: .shuttleFlight(to: location.city.name))
                }
                else
                {
                    return nil
                }
            })
        }
        return actions
    }
    
    /**
     Returns all curing actions the pawn can take.
     - Parameters:
        - currentHand: the current hand of the pawn
        - currentLocation: the current location of the pawn
     - Returns: the list of curing actions the pawn can take.
    */
    func getCuringActions(from currentHand: HandProtocol, currentLocation: BoardLocation) -> [Action]
    {
        let threshold: Int = self.role == .scientist ? 4 : 5
        if currentHand.cards.count < threshold || !currentLocation.hasResearchStation
        {
            return []
        }
        //Check the counts of all the cards in their hand.
        //TODO: Make this use a dictionary, I thought it wouldn't work but it definitely will.
        var red = 0
        var yellow = 0
        var blue = 0
        var black = 0
        currentHand.cards.forEach
        { card in
            switch card
            {
                case .cityCard(let cityCard):
                    switch cityCard.city.color
                    {
                        case .red:
                            red += 1
                        case .yellow:
                            yellow += 1
                        case .blue:
                            blue += 1
                        case .black:
                            black += 1
                    }
                case .epidemic:
                    break
                }
        }
        var actions = [Action]()
        if red >= threshold
        {
            actions.append(Action.general(action: .cure(disease: .red)))
        }
        if yellow >= threshold
        {
            actions.append(Action.general(action: .cure(disease: .yellow)))
        }
        if blue >= threshold
        {
            actions.append(Action.general(action: .cure(disease: .blue)))
        }
        if black >= threshold
        {
            actions.append(Action.general(action: .cure(disease: .black)))
        }
        //TODO: need to check if they are in a research station.
        return actions
    }
    
    /**
     Gets all of the available share knowledge actions for the pawn in the current location with other pawns
     positions and hands.
     - Parameters:
         - currentHand: the current hand of the pawn.
         - otherPawnHands: a map of pawns ot their respecitve hands (not including this pawn).
         - currentLocation: the city where the pawn is currently.
         - otherPawnLocations: a map of pawns to the city where they are (not including this pawn).
     - Returns: a list of all available share knowledge actions.
    */
    func getShareKnowledgeActions(with currentHand: HandProtocol, otherPawnHands: [Pawn: HandProtocol],
                                          currentLocation: CityName, otherPawnLocations: [Pawn: CityName]) -> [Action]
    {
        
        let relevantPawns = otherPawnLocations.filter
        { (pawn, city) -> Bool in
            return city == currentLocation && pawn != self
        }
        if relevantPawns.count > 0
        {
            //Getting cards that can be taken.
            var actions = relevantPawns.compactMap
            { (pawn, city) -> (Pawn, HandProtocol)? in
                guard let hand = otherPawnHands[pawn] else
                {
                    return nil
                }
                return (pawn, hand)
            }.compactMap(
            { (pawn, hand) -> Action? in
                if hand.cards.contains(where:
                    { card -> Bool in
                        switch card
                        {
                        case .cityCard(let cityCard):
                            return cityCard.city.name == currentLocation
                        case .epidemic:
                            return false
                        }
                })
                {
                    return Action.general(action: .shareKnowledge(card: Card(cityName: currentLocation), pawn: pawn))
                }
                else
                {
                    return nil
                }
            })
            
            //Getting the cards that can be given
            if role == .researcher
            {
                //Can give any card as long as pawns are in the same city
                actions.append(contentsOf: relevantPawns.reduce([],
                { result, keyValuePair -> [Action] in
                    return result + currentHand.cards.map(
                    { card -> Action in
                        return Action.general(action: .shareKnowledge(card: card, pawn: keyValuePair.key))
                    })
                }))
            }
            else
            {
                if currentHand.cards.contains(where:
                { card -> Bool in
                    switch card
                    {
                        case .cityCard(let cityCard):
                            return cityCard.city.name == currentLocation
                        case .epidemic:
                            return false
                    }
                })
                {
                    actions.append(contentsOf: relevantPawns.map
                    { (pawn, city) -> Action in
                        return Action.general(action: .shareKnowledge(card: Card(cityName: currentLocation), pawn: pawn))
                    })
                }
            }
            return actions
        }
        else
        {
            return []
        }
    }
    
    /**
     Gets the moves for the dispatcher.
     - Parameters:
        - otherPawnLocations: a map of pawn to city name of where the pawns on the board are.
        - currentHand: the hand of the current pawn.
        - locationGraph: the current location graph.
     - Returns: a list of the actions for the dispatcher.
    */
    func getDispatcherMoves(otherPawnLocations: [Pawn: CityName],
                                    currentHand: HandProtocol,
                                    on locationGraph: LocationGraphProtocol) -> [Action]
    {
        guard role == .dispatcher else
        {
            return []
        }
        //Get all snapping moves
        var actions = otherPawnLocations.reduce([])
        { result, keyValuePair -> [Action] in
            return result + otherPawnLocations.reduce([])
            { result, innerKeyValuePair -> [Action] in
                if keyValuePair.key != innerKeyValuePair.key
                {
                    return result + [Action.dispatcher(action: .snap(pawn: keyValuePair.key, to: innerKeyValuePair.key))]
                }
                else
                {
                    return result
                }
            }
        }
        
        //Get all moves for other pawns
        actions.append(contentsOf: otherPawnLocations.filter{$0.key != self}
            .reduce([],
            { result, keyValuePair -> [Action] in
                let drivingActions = getDrivingActions(from: locationGraph.locations[keyValuePair.value]!, on: locationGraph)
                    .map(
                { action -> Action in
                    return .dispatcher(action: .control(pawn: keyValuePair.key, action: action))
                })
                let otherTransportationActions = getOtherTransportationActions(from: locationGraph.locations[keyValuePair.value]!, currentHand: currentHand, locationGraph: locationGraph).map(
                { action -> Action in
                    return .dispatcher(action: .control(pawn: keyValuePair.key, action: action))
                })
                return result + drivingActions + otherTransportationActions
            }))
        return actions
    }
}
