//
//  Policy.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/28/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

protocol Policy
{
    func chooseAction(from actions: [Action], with gameState: GameState) -> Action
}
