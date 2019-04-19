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
    @IBOutlet weak var timeOutput: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameRunner = GameBoard().startGame() as! GameBoard
    }
    
    @IBAction func timeCheck(_ sender: Any)
    {
        if let startTime = startTime
        {
            self.timeOutput.text = "\(Date().timeIntervalSince(startTime))"
        }
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
    }
}

///MARK: Simualator stuff
extension ViewController
{
    private func simulate()
    {
        simulator.reset()
        outputView.text = "Players: \(simulator.startingState.pawns)"
        activityIndicator.startAnimating()
        runButton.isEnabled = false
        startTime = Date()
        DispatchQueue.global(qos: .userInitiated).async
        {
            self.gameState = self.simulator.simulateGame()
            DispatchQueue.main.async
            {
                self.finishSimulation()
            }
        }
    }
    
    private func finishSimulation()
    {
        endTime = Date()
        activityIndicator.stopAnimating()
        runButton.isEnabled = true
        outputSimulationResults()
    }
    
    private func outputSimulationResults()
    {
        if let gameState = gameState, let startTime = startTime, let endTime = endTime
        {
            timeOutput.text = "Time taken: \(endTime.timeIntervalSince(startTime))"
            outputView.text = (gameState as! GameBoard).description
        }
    }
}

