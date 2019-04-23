//
//  Simulation.swift
//  PandemicSolver
//
//  Created by JOAN COYNE on 4/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class Simulation {
    var interations: Int
    var currentGame: Simulator
    var weights: [String: Double]
    var utility: Utility
    
    init(iterations: Int){
        self.interations = 10
        self.weights = ["cubesRemaining": 1,
                        "diseasesCured": 1,
                        "outbreakCities": 1,
                        "outbreaksSoFar": 1,
                        "maxOutbreaks":1,
                        "infectionRate": 1,
                        "playerCardsLeft":1]
       
      
        
        currentGame = GameBoard()
        utility = Utility()
        
    }
    
    func run() -> GameState {
       
        
        let gs = currentGame.startGame()
        let turnOne  = oneTurn(gs: gs)
        
       
        return gs
         }
        
        
       
    func oneTurn(gs: GameState) -> GameState {
        
   
        
        
        var updatedState: GameState
        var chosenAction: Action
        let cubesLeft = gs.cubesRemaining
        //print(cubesLeft)
        //print(gs.gameStatus)
       
      
      
            
        
        var currentPlayer = gs.currentPlayer
        let actions = gs.legalActions(for: currentPlayer)
        //If actions = drive check the city and if it has a cube on it
        //get the action with the most cubes
        //if action has a treat in it, just treat
        //If no cities have cubes, just randomly pick one to drive to
        //After 4 turns, draw and infect
        //randomly pick an action
        
        let countActions = actions.count
        let actionNumber  = Int.random(in: 0 ..< countActions)
      
        try! updatedState = gs.execute(action: actions[actionNumber]).0
        print("Action taken \(actions[actionNumber])")
        let pawns = updatedState.pawns
        for pawn in pawns {
            print("\(updatedState.location(of:pawn).city.name),\(updatedState.location(of:pawn).cubes.black)\(updatedState.location(of:pawn).cubes.blue),\(updatedState.location(of:pawn).cubes.red), \(updatedState.location(of:pawn).cubes.yellow)")
           
        }
        let util = utility.calculateUtility(currentGameState: updatedState as! PandemicSimulatorProtocol)
        print("Util: \(util)")
       
       
    
        
        
        
        print(util)
          
        return updatedState
    }
        
        
    
        
        
    func take1turns(gs: GameState) -> GameState {
        
        
        
        let turnOne  = oneTurn(gs: gs)
        
        let turnTwo  = oneTurn(gs: turnOne)
        let turnThree  = oneTurn(gs: turnTwo)
        let turnFour  = oneTurn(gs: turnThree)
     
        return turnFour
        
        
    }
        

  
}
