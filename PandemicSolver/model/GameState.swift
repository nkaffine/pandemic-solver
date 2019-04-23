//
//  GameState.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/12/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

enum GameStatus: Equatable
{
    //TODO: reasons should probably be an enum
    case notStarted, inProgress, win(reason: String), loss(reason: String)
    var isInProgress: Bool
    {
        switch self
        {
        case .notStarted, .win, .loss:
            return false
        case .inProgress:
            return true
        }
    }
    
    static func ==(lhs: GameStatus, rhs: GameStatus) -> Bool
    {
        switch lhs
        {
            case .notStarted:
                switch rhs
                {
                    case .notStarted:
                        return true
                    case .win, .loss, .inProgress:
                        return false
                }
            
            case .inProgress:
                switch rhs
                {
                    case .inProgress:
                        return true
                    case .notStarted, .loss, .win:
                        return false
                }
            
            case .win:
                switch rhs
                {
                    case .win:
                        return true
                    case .notStarted, .loss, .inProgress:
                        return false
                }
            
            case .loss:
                switch rhs
                {
                    case .loss:
                        return true
                    case .win, .inProgress, .notStarted:
                        return false
                }
        }
    }
}

enum BoardError: Error
{
    case invalidMove, invalidPawn
}

protocol GameState
{
    /**
     A list of pawns in the game.
     */
    var pawns: [Pawn] { get }
    /**
     The deck the players draw from at the end of each turn.
     */
    var playerDeck: Deck { get }
    /**
     The deck that is drawn from after players draw to determine what should be infected
     */
    var infectionPile: Deck { get }
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
     Whether the game is still in progress, lost, or won.
     */
    var gameStatus: GameStatus { get }
    /**
     The locations for the game.
     */
    var locations: [BoardLocation] { get }
    
    /**
     The pawn who is currently executing their turn and how many actions they have left.
     */
    var currentPlayer: Pawn { get }
    
    /**
     The number of actions remaining in this turn.
     */
    var actionsRemaining: Int { get }
    
    /**
     Returns the current location of the given pawn on the board.
     - Parameters:
     - pawn: the pawn being queried.
     - Returns: the location of the pawn on the board.
     - Throws: `BoardError.invalidpawn` when the pawn is not in the game
     */
    func location(of pawn: Pawn) -> BoardLocation
    
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
    func execute(action: Action) throws -> (GameState, Reward)
    
    /**
     Returns all the legal actions in the current state for the given pawn.
     - Parameters:
     - pawn: the pawn being queried.
     - Returns: the actions that the pawn can legally make.
     - Throws: `BoardError.invalidpawn` when the pawn is not in the game
     */
    func legalActions(for pawn: Pawn) -> [Action]
    /**
     Moves the given pawn by doing the given action.
     - Parameters:
         - pawn: the pawn that is performing the action.
         - action: the action that is being performed.
     - Throws: `BoardError.invalidMove` if the move is invalid.
     - `BoardError.invalidPawn` when the pawn is not in the game
     - Returns: the state of the game after the transition and the reward
        correlated with the action taken.
     */
    func transition(pawn: Pawn, for action: Action) throws -> (GameState, Reward)
    /**
     Returns the current hand for the given pawn.
     - Parameters:
     - pawn: the pawn that is the subject of the query.
     - Returns: the hand of the given pawn.
     - Throws: `BoardError.invalidpawn` when the pawn is not in the game
     */
    func hand(for pawn: Pawn) throws -> HandProtocol
    /**
     Does the first round of infecting and changes the game status to inProgress.
     - Returns: the new gameboard with the updated state.
     */
    func startGame() -> GameState
}
