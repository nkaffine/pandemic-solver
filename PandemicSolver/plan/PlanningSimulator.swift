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
    private var gameState: PandemicSimulatorProtocol
    
    var startingState: PandemicSimulatorProtocol
    
    init(planner: PlannerProtocol)
    {
        self.planner = planner
        gameState = PandemicSimulator()
        startingState = gameState
    }
    
    func simulateGame() -> PandemicSimulatorProtocol
    {
        gameState = gameState.startGame()
        while gameState.gameStatus.isInProgress
        {
            gameState = try! gameState.execute(action: planner.calcaulateAction(from: gameState))
        }
        return gameState
    }
    
    func reset()
    {
        self.gameState = gameState.reset()
    }
}
