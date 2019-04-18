//
//  BasicPlanner.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

/**
 The basic planner will search through all of the moves that a player can make in their turn before the
 non-determinism of card drawing will be introduced and make a decision based solely on those actions.
 */
struct BasicPlanner: PlannerProtocol
{
    /**
     The object that will calculate the utility.
     */
    private var utility: UtilityProtocol
    
    init(utility: UtilityProtocol) {
        self.utility = utility
    }
    
    func calcaulateAction(from game: GameState) -> Action
    {
        var bestAction: ActionUtilityPair?
        game.legalActions().forEach
        { action in
            let utility = getUtility(of: action, from: game)
            if bestAction == nil
            {
                bestAction = ActionUtilityPair(action: action, utility: utility)
            }
            else
            {
                bestAction = max(bestAction!, ActionUtilityPair(action: action, utility: utility))
            }
        }
        //There's always at least one legal action
        return bestAction!.action
    }
    
    private func getUtility(of action: Action, from game: GameState) -> Utility
    {
        if action == .drawAndInfect
        {
            return utility.utility(of: game)
        }
        else
        {
            var maxUtility: Double?
            let nextGameState: GameState = try! game.execute(action: action)
            nextGameState.legalActions().forEach
            { legalAction in
                let utility = getUtility(of: legalAction, from: nextGameState)
                if maxUtility == nil
                {
                    maxUtility = utility
                }
                else
                {
                    maxUtility = max(maxUtility!, utility)
                }
            }
            //There should always be at least one legal action.
            return maxUtility!
        }
    }
}

private struct ActionUtilityPair: Comparable
{
    let action: Action
    let utility: Utility
    
    static func < (lhs: ActionUtilityPair, rhs: ActionUtilityPair) -> Bool
    {
        return lhs.utility < rhs.utility
    }
}
