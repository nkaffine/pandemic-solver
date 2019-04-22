//
//  Action.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/10/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

indirect enum Action: Equatable, CustomStringConvertible
{
    var description: String
    {
        switch self
        {
            case .general(let generalAction):
                return generalAction.description
            case .dispatcher(let dispatcherAction):
                return dispatcherAction.description
            case .drawAndInfect:
                return "draw and infect"
        }
    }
    
    case general(action: GeneralAction)
    case dispatcher(action: DispatcherAction)
    case drawAndInfect
}

enum GeneralAction: Equatable, CustomStringConvertible
{
    var description: String
    {
        switch self
        {
            case .drive(let city):
                return "drive to \(city)"
            case .directFlight(let city):
                return "direct flight to \(city)"
            case .charterFlight(let city):
                return "charter flight to \(city)"
            case .shuttleFlight(let city):
                return "shuttle flight to \(city)"
            case .buildResearchStation:
                return "build research station"
            case .treat(let disease):
                return "treat \(disease)"
            case .cure(let disease):
                return "cure \(disease)"
            case .shareKnowledge(let card, let pawn):
                return "share \(card) with \(pawn)"
            case .pass:
                return "pass"
        }
    }
    
    /// The pawn moves from their current location to an adjacent location
    case drive(to: CityName)
    /// The pawn discards a card from their hand and moves to the location of that card.
    case directFlight(to: CityName)
    /// The pawn discards the card of their current location and moves anywhere on the baord.
    case charterFlight(to: CityName)
    /// The pawn moves from the research station they are currently in to another research station.
    case shuttleFlight(to: CityName)
    /// The pawn builds a research station in their current location.
    case buildResearchStation, pass
    /// The pawn removes one cube o f the given disease color from their current location.
    case treat(disease: DiseaseColor)
    /// The pawn discards the appropriate number of cards for their role and cures the given disease.
    case cure(disease: DiseaseColor)
    /// The pawn transfers the card of the location they are in to a pawn in their location.
    case shareKnowledge(card: Card, pawn: Pawn)
}

/**
 The dispatcher is the only role that has special actions, all other roles have enhanced versions
 of regular actions.
 */
enum DispatcherAction: Equatable, CustomStringConvertible
{
    var description: String
    {
        switch self
        {
        case .control(let pawn, let action):
            return "control \(pawn) \(action.description)"
        case .snap(let pawn1, let pawn2):
            return "snap \(pawn1) to \(pawn2)"
        }
    }
    
    /// The case where the dispatchers moves another pawn as if it were their own.
    case control(pawn: Pawn, action: Action)
    /// The case where the dispatcher moves one pawn to the same city as another.
    case snap(pawn: Pawn, to: Pawn)
}
