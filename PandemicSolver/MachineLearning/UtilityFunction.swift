//
//  UtilityFunction.swift
//  PandemicSolver
//
//  Created by JOAN COYNE on 4/1/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation
/**
 The Utility Function takes in a game state, a set of weights,
 and returns the utility of the gamestate with those weights
 */
protocol UtilityFunction
{
    
    var utility: Float { get }
    /** the current value of the game state
     */
    
    
    func calculateUtility(currentGameState: GameState,
                          currentWeights: Dictionary<String, Float>) -> Float
    /**
     Adds the given card to the discard pile of this deck.
     - Parameters:
     - currentGameState: the currentGameState
     - Returns
     - utility
     */
}
