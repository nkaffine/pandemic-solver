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
    var utility: Double
    /** the reward value for a win
     */
    var reward: Double
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
    var weights: [String: Double]
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
        reward = 1000.0
    }
    /**
     Adds the given card to the discard pile of this deck.
     - Parameters:
     - currentGameState: the currentGameState
     - Returns
     - utility
     */
    func calculateUtility(currentGameState: PandemicSimulatorProtocol) -> Double
    {
        var total: Double
        let cubesOnBoard = 1.0
        let cubesRemaining = Double(currentGameState.cubesRemaining[.yellow]!)
            + Double(currentGameState.cubesRemaining[.red]!)
            + Double(currentGameState.cubesRemaining[.blue]!)
            +  Double(currentGameState.cubesRemaining[.black]!)
        total = Double(cubesRemaining*weights["cubesRemaining"]!) + cubesOnBoard * weights["cubesOnBoard"]!
        total += Double(currentGameState.infectionRate.cardsToDraw)*weights["infectionRate"]!
        total += Double(currentGameState.curedDiseases.count)*weights["curedDiseases"]!
        total += Double(currentGameState.infectionRate.cardsToDraw)*weights["infectionRate"]!
        total += Double(currentGameState.maxOutbreaks)*weights["maxOutbreaks"]!
        total += Double(currentGameState.playerDeck.count)*weights["playerDeckCount"]!
        total += Double(currentGameState.uncuredDiseases.count)*weights["uncuredDiseases"]!
        total += Double(currentGameState.outbreaksSoFar)*weights["outbreaksSoFar"]!
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
    func updateWeights(currentGameState: PandemicSimulatorProtocol,currentWeights:Dictionary<String, Double>,
                           predictedUtility: Double, actualUtility: Double )-> Dictionary<String, Double>
    {
        let alpha = Double(0.005)
        let infectedCitites =  currentGameState.infectedCities
        let difference = (predictedUtility  - actualUtility)*alpha
        let minDistance = calcMinDistance(currentGameState: currentGameState)
    
        var redCount  = 0
        var yellowCount  = 0
        var blackCount  = 0
        var blueCount  = 0
        for city  in infectedCitites{
            switch (city.1[0].disease)
            {
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
        let cubesOnBoard  = Double(blackCount + redCount + yellowCount + blueCount)
        let cubesRemaining = (1/Double(currentGameState.cubesRemaining[.yellow]!) + 0.01)
            + (1/Double(currentGameState.cubesRemaining[.red]!) + 0.01)
            + (1/Double(currentGameState.cubesRemaining[.blue]!) + 0.01)
            + (1/Double(currentGameState.cubesRemaining[.black]!) + 0.01)
        weights["minDistance"] =  currentWeights["minDistance"]! +  difference*(minDistance)*0.01
        weights["cubesOnBoard"] = currentWeights["cubesOnBoard"]!
        weights["cubesRemaining"] = currentWeights["cubesRemaining"]! + difference*cubesRemaining*0.001
        weights["curedDiseases"] = currentWeights["curedDiseases"]! + Double(currentGameState.curedDiseases.count)*0.01
        weights["maxOutbreaks"] = currentWeights["maxOutbreaks"]! + Double(currentGameState.maxOutbreaks)*0.01
        weights["playerDeckCount"] = currentWeights["playerDeckCount"]! + Double(1/currentGameState.playerDeck.count)
        weights["uncuredDiseases"] = currentWeights["uncuredDiseases"]! + Double(currentGameState.uncuredDiseases.count)*0.01
        weights["outbreaksSoFar"] = currentWeights["outbreaksSoFar"]! + Double(currentGameState.outbreaksSoFar)*0.01
        weights["infectionRate"] = currentWeights["infectionRate"]! + Double(currentGameState.infectionRate.cardsToDraw)*0.01
        return weights
    }
    /**
     Calculates the Utility funtion with the given weights
     - Parameters:
     - currentGameState: the currentGameState
     - currentWeights: the current weights
     */
    func calculateUtilityWithWeights(currentGameState: PandemicSimulatorProtocol,
                                     currentWeights:Dictionary<String, Double> ) -> Double
    {
        var total: Double
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
        let cubesRemaining = (1/Double(currentGameState.cubesRemaining[.yellow]!) + 0.01)
            + (1/Double(currentGameState.cubesRemaining[.red]!) + 0.01)
            + (1/Double(currentGameState.cubesRemaining[.blue]!) + 0.01)
            +  (1/Double(currentGameState.cubesRemaining[.black]!) + 0.01)
        let cubesOnBoard  = Double(blackCount + redCount + yellowCount + blueCount)
        total = Double((cubesRemaining)*weights["cubesRemaining"]!)
        total += (cubesOnBoard)*weights["cubesOnBoard"]!
        total += Double((minDistance))*weights["minDistance"]!
        total += Double(currentGameState.infectionRate.cardsToDraw)*weights["infectionRate"]!
        total += Double(currentGameState.curedDiseases.count)*weights["curedDiseases"]!
        total += Double(currentGameState.maxOutbreaks)*weights["maxOutbreaks"]!
        total += Double(1/currentGameState.playerDeck.count)*weights["playerDeckCount"]!
        total += Double(currentGameState.uncuredDiseases.count)*weights["uncuredDiseases"]!
        total += Double(currentGameState.outbreaksSoFar)*weights["outbreaksSoFar"]!
       if (cubesOnBoard == 0) {
            total += reward
        }
        return total
    }
    
   
    func calcMinDistance(currentGameState:PandemicSimulatorProtocol) -> Double {
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
        return Double(minDistance)
        
    }
}


struct UtilityPolicy: PolicyProtocol
{
    private var utility: Utility
    
    init()
    {
        self.utility = Utility()
    }
    
    func action(for game: PandemicSimulatorProtocol) -> Action {
        return game.legalActions().map
            { action -> (Action, Double) in
                (action, utility.calculateUtility(currentGameState: try! game.execute(action: action).0))
            }.max(by: { (action1, action2) -> Bool in
                action1.1 < action2.1
            })!.0
    }
}

