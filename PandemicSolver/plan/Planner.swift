//
//  Planner.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

protocol PlannerProtocol
{
    /**
     Calculates the optimal action for the given game state
     - Parameters:
        - game: the game state form which the best action will be derived.
    */
    func calcaulateAction(from game: PandemicSimulatorProtocol) -> Action
}

//MARK: Temporary stuff.
typealias UtilityValue = Double

protocol UtilityProtocol
{
    /**
     Calculates the utility of the given gamestate.
     - Parameters:
        - game: the game state from which the utility will be calculated.
     - Returns: a double representing how promissing the given gamestate is.
     */
    func utility(of game: PandemicSimulatorProtocol) -> UtilityValue
}

struct RandomUtility: UtilityProtocol
{
    func utility(of game: PandemicSimulatorProtocol) -> UtilityValue
    {
        return Double((-100..<100).randomElement()!)
    }
}

