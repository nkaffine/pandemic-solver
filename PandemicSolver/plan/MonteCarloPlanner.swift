//
//  MonteCarloTreeSearch.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class MonteCarloPlannerSimpleExploration: PlannerProtocol
{
    private let utility: UtilityProtocol
    private let numberOfSimulations = 100
    
    init(utility: UtilityProtocol)
    {
        self.utility = utility
    }
    
    /**
     Evenly simulates each available action the same number of simulations and returns
     the action that leads to the best result.
    */
    func calcaulateAction(from game: PandemicSimulatorProtocol) -> Action
    {
        return game.legalActions().map
        { action -> (action: Action, successRatio: Double) in
            var wins = 0
            var trials = 0
            (0..<numberOfSimulations).forEach
            { _ in
                switch simulateRollout(for: action, in: game)
                {
                    case .win:
                        wins += 1
                        trials += 1
                    default:
                        trials += 1
                }
            }
            return (action, Double(wins) / Double(trials))
        }.max(by: { (action1, action2) -> Bool in
            return action1.successRatio < action2.successRatio
        })!.action
    }
    
    /**
     Uses the utility function to decide which actions to use in the rollout and then picks the least bad action
     based on the results.
     - Parameters:
         - action: the action being simulated
         - game: the game state where the action is being simulated.
     - Returns: the game status at the end of the game (either win or loss)
    */
    private func simulateRollout(for action: Action, in game: PandemicSimulatorProtocol) -> GameStatus
    {
        var currentGame = game
        while currentGame.gameStatus.isInProgress
        {
            currentGame = try! currentGame.execute(action: getMaxAction(for: currentGame))
        }
        return currentGame.gameStatus
    }
    
    /**
     Gets the action that has the highest utility based on the current utility.
     - Parameters:
        - game: the current game state
     - Returns: the action that maximizes the utilitty.
    */
    private func getMaxAction(for game: PandemicSimulatorProtocol) -> Action
    {
        return game.legalActions().map
        { action -> (action: Action, utility: UtilityValue) in
            return (action, self.utility.utility(of: try! game.execute(action: action)))
        }.max(by:
        { (action1, action2) -> Bool in
            action1.utility < action2.utility
        })!.action
    }
}
