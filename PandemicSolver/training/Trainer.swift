//
//  Trainer.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class Trainer
{
    private let simulator: Simulator
    private var editableSimulator: Simulator
    private var utility: WeightedUtilityFunction
    
    init(utility: WeightedUtilityFunction, missingRole: Role? = nil)
    {
        simulator = GameBoard(missingRole: missingRole)
        editableSimulator = simulator
        self.utility = utility
    }
    
    func train()
    {
        /**
         Iterating however many times you wanna do this.
        */
        (0..<100).forEach
        { iteration in
            /**
             This will just run the same game every time, Nick will write something to easily reset it.
             */
            editableSimulator = simulator
            while editableSimulator.gameStatus.isInProgress
            {
                /**
                 Maps a list of legal actions to the gamestate that would result from executing them.
                 */
                let gameStates = editableSimulator.legalActions().map
                { action -> GameState in
                    return try! editableSimulator.execute(action: action)
                }
                let maxGameState = gameStates.max(by:
                { (gameState1, gameState2) -> Bool in
                    self.utility.calculateUtilityWithWeights(currentGameState: gameState1, currentWeights: utility.weights)
                        < utility.calculateUtilityWithWeights(currentGameState: gameState2, currentWeights: utility.weights)
                })
                //Assuming just greedy
                editableSimulator = (maxGameState! as! Simulator)
            }
            //TODO: Calculate distance between two locations
            //Use LocationSearchHelper
        }
    }
}
