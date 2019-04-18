//
//  ViewController.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var gameRunner: GameBoard!
    private var simulator: PlanningSimulator = PlanningSimulator(planner: BasicPlanner(utility: RandomUtility()))
    private var gameState: GameState?
    private var startTime: Date?
    private var endTime: Date?
    @IBOutlet weak private (set) var runButton: UIButton!
    @IBOutlet weak private (set) var outputView: UITextView!
    @IBOutlet weak private (set) var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameRunner = GameBoard().startGame() as! GameBoard
    }
    
    private func resetGame()
    {
        gameRunner = GameBoard().startGame() as! GameBoard
    }
    
    private func runGame()
    {
        var actionsTaken = [(Pawn, Action)]()
        while gameRunner.gameStatus.isInProgress
        {
            let legalActions = gameRunner.legalActions()
            let action = legalActions.randomElement()!
            actionsTaken.append((gameRunner.currentPlayer, action))
            let theGameRunner = try? gameRunner.execute(action: action) as! GameBoard
            if theGameRunner != nil
            {
                gameRunner = theGameRunner
            }
            else
            {
                //try? oldGameRunner?.execute(action: action)
                print("Something borked")
            }
        }
        actionsTaken.forEach
        { (pawn, action) in
            print("\(pawn): \(action)")
        }
        print("total turns: \(actionsTaken.count / 4)")
    }
    
    private func updateOutputView()
    {
        outputView.text = gameRunner.description
    }
    
    @IBAction func runGameTapped(_ sender: UIButton)
    {
        simulate()
        outputSimulationResults()
    }
}

///MARK: Simualator stuff
extension ViewController
{
    private func simulate()
    {
        simulator.reset()
        activityIndicator.startAnimating()
        startTime = Date()
        self.gameState = simulator.simulateGame()
        endTime = Date()
        activityIndicator.stopAnimating()
    }
    
    private func outputSimulationResults()
    {
        if let gameState = gameState, let startTime = startTime, let endTime = endTime
        {
            outputView.text = "Time taken: \(endTime.timeIntervalSince(startTime))\n\n" + (gameState as! GameBoard).description
        }
    }
}

