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
    @IBOutlet weak private (set) var runButton: UIButton!
    @IBOutlet weak private (set) var outputView: UITextView!
    
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
        while gameRunner.gameStatus.isInProgress
        {
            let legalActions = gameRunner.legalActions()
            let action = legalActions.randomElement()!
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
    }
    
    private func updateOutputView()
    {
        outputView.text = gameRunner.description
    }
    
    @IBAction func runGameTapped(_ sender: UIButton)
    {
        resetGame()
        runGame()
        updateOutputView()
    }
}

