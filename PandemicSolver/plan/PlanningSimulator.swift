//
//  PlanningSimulator.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/18/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class PlanningSimulator
{
    private var planner: PlannerProtocol
    private var gameState: GameState
    
    init(planner: PlannerProtocol)
    {
        self.planner = planner
        gameState = GameBoard()
    }
    
    func simulateGame() -> GameState
    {
        gameState = gameState.startGame()
        while gameState.gameStatus.isInProgress
        {
            gameState = try! gameState.execute(action: planner.calcaulateAction(from: gameState)).0
        }
        return gameState
    }
    
    func reset()
    {
        self.gameState = GameBoard()
    }
}
