//
//  MonteCarloTreeSearch.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class MonteCarloPlanner: PlannerProtocol
{
    func calcaulateAction(from game: GameState) -> Action
    {
        return game.legalActions().first!
    }
}
