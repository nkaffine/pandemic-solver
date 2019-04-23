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
        (0..<20).forEach
        { iteration in
            /**
             This will just run the same game every time, Nick will write something to easily reset it.
             */
            var maxQ = Double(0.0)
            simulator = simulator.startGame()
            print(simulator.gameStatus)
            var  count = 0
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
                //print(action.description)
                    return try! simulator.execute(action: action).0
                }
               
                var maxGameState = gameStates.max(by:
                   
                { (gameState1, gameState2) -> Bool in
                    self.utility.calculateUtilityWithWeights(currentGameState: gameState1, currentWeights: utility.weights)
                        > utility.calculateUtilityWithWeights(currentGameState: gameState2, currentWeights: utility.weights)
                })
                //Assuming just greedy
                let newMax = self.utility.calculateUtilityWithWeights(currentGameState:maxGameState!, currentWeights: utility.weights)
                //print (newMax)
              
                utility.weights = utility.updateWeights(currentGameState: simulator, currentWeights: utility.weights, predictedUtility: newMax, actualUtility:maxQ)
                //print(newMax)
                //epison greedy
                
                    let epsilonGreedy  = Double.random(in: 0 ..< 1)
                    if epsilonGreedy < 0.05 {
                        let actions = simulator.legalActions()
                        let countActions = actions.count
                        let actionNumber  = Int.random(in: 0 ..< countActions)
                        // print(actionNumber)
                        //  print(actions[actionNumber])
                        //try! (maxGameState, reward) = simulator.execute(action: actions[actionNumber])
                         try! maxGameState = simulator.execute(action: actions[actionNumber]).0
                        print("Greedy!")
                        //simulator = try! simulator.execute(action: actions[actionNumber])
                    }
                simulator = maxGameState!
                //print(simulator.cubesRemaining, simulator.curedDiseases, simulator.infectionRate, simulator.location(of: simulator.currentPlayer))
                count = count + 1
                
        }
            
            print(simulator.gameStatus)
            print(utility.weights)
            print(count)
             
           /* utility.weights["minDistance"] =  utility.weights["minDistance"]! * -0.01
           utility.weights["cubesOnBoard"] = utility.weights["cubesOnBoard"]! * -0.01
            utility.weights["cubesRemaining"] = utility.weights["cubesRemaining"]! * -0.01
            utility.weights["curedDiseases"] = utility.weights["curedDiseases"]! * -0.01
            utility.weights["maxOutbreaks"] = utility.weights["maxOutbreaks"]! * -0.01
            utility.weights["playerDeckCount"] = utility.weights["playerDeckCount"]! * -0.01
            utility.weights["uncuredDiseases"] = utility.weights["uncuredDiseases"]! * -0.01
            utility.weights["outbreaksSoFar"] = utility.weights["outbreaksSoFar"]! * -0.01
            utility.weights["playerDeckCount"] = utility.weights["infectionRate"]! * -0.01*/
            
            utility.weights["minDistance"] =   -1.0
             utility.weights["cubesOnBoard"] = -1.0
             utility.weights["cubesRemaining"] = -1.0
             utility.weights["curedDiseases"] = 1.0
             utility.weights["maxOutbreaks"] = -10.0
             utility.weights["playerDeckCount"] = -1.0
             utility.weights["uncuredDiseases"] = -1.0
             utility.weights["outbreaksSoFar"] = -1.0
               utility.weights["infectionRate"] = -3.0
            
         
        
           
            simulator = simulator.reset()
            //TODO: Calculate distance between two locations
            //Use LocationSearchHelper
        }
    }
    
}
