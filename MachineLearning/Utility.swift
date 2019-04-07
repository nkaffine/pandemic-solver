//
//  Utility.swift
//  PandemicSolver
//
//  Created by JOAN COYNE on 4/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation
class Utility: WeightedUtilityFunction, UtilityFunction {
    
    
    
    
    
    
    /** the current value of the game state
     */
    var utility: Float
    /** the reward value for a win
     */
    var reward: Float
    /**
     weights for the current game state. The cube based weights are the same
     for all colors
     -Weights:
     Cubes:
     - cubesRemaining
     - cured (multiplier on how many cubes can be removed in one turn)
     - outbreakCities (count)
     - eradicated - 1 or 0, if this has been eradicated, then we don't care about this color
     
     Game overall:
     - outbreakssofar
     - playerCardsLeft
     - diseasesCured
     
     */
    
    var weights: [String: Float]
    
   
    init() {
        weights = [
            "cubesOnBoard" : 1,
            "cubesRemaining" : 1,
            "curedDiseases" : 1,
            "infectionRate" : 1,
            "maxOutbreaks" : 1,
            "playerDeckCount" : 1,
            "uncuredDiseases" : 1,
            "outbreaksSoFar" : 1,
            
            
        ]
        utility = 0.0
        reward = 1000.0
    }
    
    
    /**
     Adds the given card to the discard pile of this deck.
     - Parameters:
     - currentGameState: the currentGameState
     - Returns
     - utility
     */
    func calculateUtility(currentGameState: GameState) -> Float{
        var total: Float
        
        
        
        /*print("cubes Remaining \(updatedState.cubesRemaining)")
         print("cured diseases \(updatedState.curedDiseases)")
         print("Infection rate\(updatedState.infectionRate)")
         print("Max Outbreaks \(updatedState.maxOutbreaks)")
         print("Card Count \(updatedState.playerDeck.count)")
         print("Uncured \(updatedState.uncuredDiseases)")
         print("Outbreaks \(updatedState.outbreaksSoFar)")
       print(currentGameState.cubesRemaining[.yellow]!)
            print(currentGameState.curedDiseases.count)
            print(currentGameState.infectionRate.cardsToDraw)
            print(currentGameState.maxOutbreaks)
        print(currentGameState.playerDeck.count)
            print(currentGameState.uncuredDiseases.count)
            print(currentGameState.outbreaksSoFar)*/
            let cubesOnBoard =  Float(calcCubesOnBoard(currentGameState: currentGameState))
         print("Current Cubes \(cubesOnBoard)")
        
        let cubesRemaining = Float(currentGameState.cubesRemaining[.yellow]!)
            + Float(currentGameState.cubesRemaining[.red]!)
            + Float(currentGameState.cubesRemaining[.blue]!)
            +  Float(currentGameState.cubesRemaining[.black]!)
        total = Float(cubesRemaining*weights["cubesRemaining"]!) + cubesOnBoard*weights["cubesOnBoard"]!
             total += Float(currentGameState.infectionRate.cardsToDraw)*weights["infectionRate"]!
          total += Float(currentGameState.curedDiseases.count)*weights["curedDiseases"]!
             total += Float(currentGameState.infectionRate.cardsToDraw)*weights["infectionRate"]!
          total += Float(currentGameState.maxOutbreaks)*weights["maxOutbreaks"]!
           total += Float(currentGameState.playerDeck.count)*weights["playerDeckCount"]!
            total += Float(currentGameState.uncuredDiseases.count)*weights["uncuredDiseases"]!
             total += Float(currentGameState.outbreaksSoFar)*weights["outbreaksSoFar"]!
        if (cubesOnBoard == 0){
            total += reward
        }
    
        
              
       return total
    }

        
        /**
         Given the current weights, the predicted utility, and the actual utility,
         calculates the updated weights for that run
         - Parameters:
         - currentWeights: Dictionary of the current weights
         - predictedUtility - the utility value we predicted
         - actualUtility - what we ended up with
         Returns
         - newWeights - updated dictionary of weights
         */
        
        
        func updateWeights(currentWeights:Dictionary<String, Float>,
                           predictedUtility: Float, actualUtility: Float )
            -> Dictionary<String, Float>{
        
        return self.weights
    }
    /**
     Calculates the Utility funtion with the given weights
     - Parameters:
     - currentGameState: the currentGameState
     - currentWeights: the current weights
     */
    func calculateUtilityWithWeights(currentGameState: GameState,
                                     currentWeights:Dictionary<String, Float> ) -> Float{
        return 1.0
    }
    
    func calcCubesOnBoard(currentGameState: GameState) -> Int {
        var count = 0
        for location in currentGameState.locations{
            count += location.cubes.black.rawValue
            count += location.cubes.yellow.rawValue
            count += location.cubes.blue.rawValue
            count += location.cubes.red.rawValue
        }
        return count
        
    }
    
    
    
}