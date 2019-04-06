//
//  Simulator.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/5/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

protocol Simulator
{
    /**
     Whether the game is still in progress, lost, or won.
     */
    var gameStatus: GameStatus { get }
    /**
     The pawn who is currently executing their turn.
     */
    var currentPlayer: Pawn { get }
    /**
     The numnber of actions the current player has remaining in their turn.
     */
    var actionsRemaining: Int { get }
    /**
     Get all the legal moves for the current state of the game.
     - Returns: a list of legal actions for the current state.
     - Note: these actions are for the pawn whose turn it is currently.
     */
    func legalActions() -> [Action]
    /**
     Executes the given action on the game state.
     - Parameters:
     - action: the action being executed
     - Throws: `BoardError.invalidMove` when the move is invalid
     - Returns: the gamestate after the action is executed
     - Note: this executes the action as the pawn whose turn it is currently.
     */
    func execute(action: Action) throws -> GameState
    /**
     Does the first round of infecting and changes the game status to inProgress.
     - Returns: the new gameboard with the updated state.
     */
    func startGame() -> GameBoard
}

protocol GameStateFeatures
{
    /**
     A list of pawns in the game.
     */
    var pawns: [Pawn] { get }
    /**
     The number of cards that will be drawn from the infection pile after each player draws.
     */
    var infectionRate: InfectionRate { get }
    /**
     The number of outbreaks that have occurred in the game so far.
     */
    var outbreaksSoFar: Int { get }
    /**
     The maximum number of outbreaks that can occur before without losing the game.
     */
    var maxOutbreaks: Int { get }
    /**
     A dictinoary of disease cubes to the number of cubes of that color that
     can be placed on the board.
     */
    var cubesRemaining: [DiseaseColor : Int] { get }
    /**
     List of diseases that are not cured.
     */
    var uncuredDiseases: [DiseaseColor] { get }
    /**
     List of diseases that are cured
     */
    var curedDiseases: [DiseaseColor] { get }
    /**
     Returns the current location of the given pawn on the board.
     - Parameters:
     - pawn: the pawn being queried.
     - Returns: the location of the pawn on the board.
     - Throws: `BoardError.invalidpawn` when the pawn is not in the game
     */
    func location(of pawn: Pawn) -> BoardLocation
    /**
     Returns the current hand for the given pawn.
     - Parameters:
     - pawn: the pawn that is the subject of the query.
     - Returns: the hand of the given pawn.
     - Throws: `BoardError.invalidpawn` when the pawn is not in the game
     */
    func hand(for pawn: Pawn) throws -> HandProtocol
}
