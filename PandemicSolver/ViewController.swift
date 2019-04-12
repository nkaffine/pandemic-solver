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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.gameRunner = GameBoard().startGame() as! GameBoard
        while gameRunner.gameStatus == .inProgress
        {
            let legalActions = gameRunner.legalActions()
            let action = legalActions.randomElement()!
            let currentPawn = gameRunner.currentPlayer
            let oldGameRunner = gameRunner
//            gameRunner = try? gameRunner.execute(action: action) as! GameBoard
            let theGameRunner = try? gameRunner.execute(action: action) as! GameBoard
            if theGameRunner != nil
            {
                gameRunner = theGameRunner
            }
            else
            {
                try? oldGameRunner?.execute(action: action)
            }
        }
        print(gameRunner!)
    }
}

