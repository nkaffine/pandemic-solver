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
    //var reward: Float
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
            "cubesOnBoard" : -1,
            "cubesRemaining" : -1,
            "curedDiseases" : 1,
            "infectionRate" : -3,
            "maxOutbreaks" : -10,
            "playerDeckCount" : -1,
            "uncuredDiseases" : -1,
            "outbreaksSoFar" : -1,
             "minDistance" : -1,
            
            
        ]
        utility = 0.0
       
    }
    
    
    /**
     Adds the given card to the discard pile of this deck.
     - Parameters:
     - currentGameState: the currentGameState
     - Returns
     - utility
     */
    func calculateUtility(currentGameState: PandemicSimulatorProtocol) -> Float{
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
       
      /**  let cubesOnBoard = 1.0
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
    */
        
              
       return 1.0
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
        
    
    func updateWeights(currentGameState: PandemicSimulatorProtocol,currentWeights:Dictionary<String, Float>,
                           predictedUtility: Float, actualUtility: Float )
            -> Dictionary<String, Float>{
            
                let alpha = Float(0.005)
                 let infectedCitites =  currentGameState.infectedCities
                let difference = (predictedUtility  - actualUtility)*alpha
                let minDistance = calcMinDistance(currentGameState: currentGameState)
                
                var redCount  = 0
                var yellowCount  = 0
                var blackCount  = 0
                var blueCount  = 0
                for city  in infectedCitites{
                    switch (city.1[0].disease) {
                    case .red:
                        redCount = redCount + city.1[0].count
                        
                    case .blue:
                        blueCount = blueCount +  city.1[0].count
                    case .yellow:
                        yellowCount = yellowCount + city.1[0].count
                    case .black:
                        blackCount =  blackCount + city.1[0].count
                        
                        
                        
                    }
                    
                    
                }
                 let cubesOnBoard  = Float(blackCount + redCount + yellowCount + blueCount)
                let cubesRemaining = (1/Float(currentGameState.cubesRemaining[.yellow]!) + 0.01)
                    + (1/Float(currentGameState.cubesRemaining[.red]!) + 0.01)
                    + (1/Float(currentGameState.cubesRemaining[.blue]!) + 0.01)
                    +  (1/Float(currentGameState.cubesRemaining[.black]!) + 0.01)
                weights["minDistance"] =  currentWeights["minDistance"]! +  difference*(minDistance)*0.01
                weights["cubesOnBoard"] = currentWeights["cubesOnBoard"]! 
                 weights["cubesRemaining"] = currentWeights["cubesRemaining"]! + difference*cubesRemaining*0.001
                 weights["curedDiseases"] = currentWeights["curedDiseases"]! + Float(currentGameState.curedDiseases.count)*0.01
                 weights["maxOutbreaks"] = currentWeights["maxOutbreaks"]! + Float(currentGameState.maxOutbreaks)*0.01
                 weights["playerDeckCount"] = currentWeights["playerDeckCount"]! + Float(1/currentGameState.playerDeck.count)
                weights["uncuredDiseases"] = currentWeights["uncuredDiseases"]! + Float(currentGameState.uncuredDiseases.count)*0.01
                weights["outbreaksSoFar"] = currentWeights["outbreaksSoFar"]! + Float(currentGameState.outbreaksSoFar)*0.01
                weights["infectionRate"] = currentWeights["infectionRate"]! + Float(currentGameState.infectionRate.cardsToDraw)*0.01
                
                    
                    
                
                    
               
    
                
               
        
        return weights
    }
    /**
     Calculates the Utility funtion with the given weights
     - Parameters:
     - currentGameState: the currentGameState
     - currentWeights: the current weights
     */
    func calculateUtilityWithWeights(currentGameState: PandemicSimulatorProtocol,
                                     currentWeights:Dictionary<String, Float>, reward: Reward ) -> Float{
        var total: Float
        var redCount  = 0
        var yellowCount  = 0
        var blackCount  = 0
        var blueCount  = 0
        let infectedCitites =  currentGameState.infectedCities
        
       
        
   
       
       
        
        var minDistance   =  calcMinDistance(currentGameState: currentGameState)
        //print(currentLocation.city.name)
        for city  in infectedCitites{
            switch (city.1[0].disease) {
            case .red:
                redCount = redCount + city.1[0].count
                
            case .blue:
                blueCount = blueCount +  city.1[0].count
            case .yellow:
                yellowCount = yellowCount + city.1[0].count
            case .black:
                blackCount =  blackCount + city.1[0].count
            
            
            
            }
        
          
        }
        
        //print("Current Cubes \(cubesOnBoard)")
        //print("Yellow \(currentGameState.cubesRemaining[.yellow]!) and \(yellowCount)")
        //print("Blue \(currentGameState.cubesRemaining[.blue]!) and \(blueCount)")
        //print("Red \(currentGameState.cubesRemaining[.red]!) and \(redCount)")
        //print("Black \(currentGameState.cubesRemaining[.black]!) and \(blackCount)")
        //Use the inverso of cubes remaining so that a small number of cubes is bad
        let cubesRemaining = (1/Float(currentGameState.cubesRemaining[.yellow]!) + 0.01)
            + (1/Float(currentGameState.cubesRemaining[.red]!) + 0.01)
            + (1/Float(currentGameState.cubesRemaining[.blue]!) + 0.01)
            +  (1/Float(currentGameState.cubesRemaining[.black]!) + 0.01)
        let cubesOnBoard  = Float(blackCount + redCount + yellowCount + blueCount)
        total = Float((cubesRemaining)*weights["cubesRemaining"]!)
        total += (cubesOnBoard)*weights["cubesOnBoard"]!
        total += Float((minDistance))*weights["minDistance"]!
        total += Float(currentGameState.infectionRate.cardsToDraw)*weights["infectionRate"]!
        total += Float(currentGameState.curedDiseases.count)*weights["curedDiseases"]!
        total += Float(currentGameState.maxOutbreaks)*weights["maxOutbreaks"]!
        total += Float(1/currentGameState.playerDeck.count)*weights["playerDeckCount"]!
        total += Float(currentGameState.uncuredDiseases.count)*weights["uncuredDiseases"]!
        total += Float(currentGameState.outbreaksSoFar)*weights["outbreaksSoFar"]!
        // add in rewards
        total += reward.reward
        //print(reward.reward)
        
      
       
    
        return total
    }
    
   
func calcMinDistance(currentGameState:PandemicSimulatorProtocol) -> Float {
    let currentLocation  = currentGameState.location(of: currentGameState.currentPlayer)
    let infectedCitites =  currentGameState.infectedCities
    var minDistance   = 100
    let  graph = LocationGraph()
    
    for city  in infectedCitites{
        let distanceToCity  = LocationSearchHelper.distance(from: currentLocation.city.name, to: city.city, in: graph)
        if (distanceToCity < minDistance){
            minDistance = distanceToCity
        }
       
    }
    return Float(minDistance)
    
}
}
