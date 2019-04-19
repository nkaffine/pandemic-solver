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
    private var simulator: PandemicSimulatorProtocol
    private var utility: WeightedUtilityFunction
    
    init(utility: WeightedUtilityFunction, missingRole: Role? = nil)
    {
        simulator = PandemicSimulator(missingRule: nil)
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
            simulator = simulator.startGame()
            print(simulator.gameStatus)
            while simulator.gameStatus.isInProgress
            {
                //var updatedState: Simulator
                
             // let actions = simulator.legalActions()
                /*for action in actions {
                    print(action)
                }*/
                //let countActions = actions.count
               // let actionNumber  = Int.random(in: 0 ..< countActions)
               // print(actionNumber)
               //  print(actions[actionNumber])
                
                //try! updatedState = simulator.execute(action: actions[actionNumber])
                //simulator = try! simulator.execute(action: actions[actionNumber])
                /**
                 Maps a list of legal actions to the gamestate that would result from executing them.
                 */
                let gameStates = simulator.legalActions().map
               
              { action -> PandemicSimulatorProtocol in
                    print(action.description)
                    return try! simulator.execute(action: action)
                }
               
                let maxGameState = gameStates.max(by:
                   
                { (gameState1, gameState2) -> Bool in
                    self.utility.calculateUtilityWithWeights(currentGameState: gameState1, currentWeights: utility.weights)
                        < utility.calculateUtilityWithWeights(currentGameState: gameState2, currentWeights: utility.weights)
                })
                //Assuming just greedy
                print (self.utility.calculateUtilityWithWeights(currentGameState:maxGameState!, currentWeights: utility.weights))
                
        }
            
            print(simulator.gameStatus)
            simulator = simulator.reset()
            //TODO: Calculate distance between two locations
            //Use LocationSearchHelper
        }
    }
    
}
