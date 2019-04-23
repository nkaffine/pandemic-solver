//
//  WeightedUtilityFunction.swift
//  PandemicSolver
//
//  Created by JOAN COYNE on 4/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation
protocol WeightedUtilityFunction
{
    
    var utility: Double { get }
    /** the current value of the game state
     */
    var reward: Double { get }
    /** the reward value for a win
     */
    var weights: [String: Double] {get set}
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
    
    /**
     Calculates the Utility funtion with the given weights
     - Parameters:
     - currentGameState: the currentGameState
     - currentWeights: the current weights
     */
    func calculateUtilityWithWeights(currentGameState: PandemicSimulatorProtocol,
                          currentWeights:Dictionary<String, Double> ) -> Double
    
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
    
    
    func updateWeights(currentGameState: PandemicSimulatorProtocol, currentWeights:Dictionary<String, Double>,
                       predictedUtility: Double, actualUtility: Double )
        -> Dictionary<String, Double>
    
   
}
