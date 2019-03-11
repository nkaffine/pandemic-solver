//
//  Board.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/7/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

enum CubeDistributionError
{
    /// When the number of cubes added to a distribution would cause there
    ///to be more than 3 cubes of that color
    case outbreak
}

protocol CubeDistribution
{
    /**
     The number of red cubes in the distribution.
     */
    var red: Int { get }
    /**
     The number of yellow cubes in the distribution.
    */
    var yellow: Int { get }
    /**
     The number of blue cubes in the distribution.
     */
    var blue: Int { get }
    /**
     The number of black cubes in the distribution.
     */
    var black: Int { get }
    
    /**
     Adds the given cubes to the distribution.
     - Parameters:
        - cubes: a dictionary of disease color to integer for the number of cubes of each color.
     - Throws: `CubeDistributionError.outbreak` when the total number of cubes for the given
        disease would be increased to greater than 3.
    */
    func add(cubes: [DiseaseColor : Int]) throws
    
    /**
     Adds the given number of cubes of the given disease to the distribution.
     - Parameters:
        - cubes: the number of cubes to be added.
        - disease: the disease of the cubes being added
     - Throws: `CubeDistributionError.outbreak` when the total number of cubes for the given
        disease would be increased to greater than 3.
     */
    func add(cubes: Int, ofDisease disease: DiseaseColor) throws
}

protocol BoardLocation
{
    var city: City { get }
    var cubes: CubeDistribution { get }
}

enum PlayState
{
    case inProgress, win, loss
}

enum BoardError: Error
{
    case invalidMove, invalidPawn
}

enum Role: CaseIterable
{
    case medic, operationsExpert, dispatcher, scientist, researcher
}

protocol Pawn
{
    var role: Role { get }
}

protocol GameState
{
    /**
     A list of pawns in the game.
    */
    var pawns: [Role] { get }
    /**
     The deck the players draw from at the end of each turn.
     */
    var playerDeck: [Deck] { get }
    /**
     The deck that is drawn from after players draw to determine what should be infected
     */
    var infectionPile: [Deck] { get }
    /**
     The number of cards that will be drawn from the infection pile after each player draws.
     */
    var infectionRate: Int { get }
    /**
     The number of outbreaks that have occurred in the game so far.
     */
    var outBreaksSoFar: Int { get }
    /**
     The maximum number of outbreaks that can occur before without losing the game.
     */
    var maxOutBreaks: Int { get }
    /**
     A dictinoary of disease cubes to the number of cubes of that color that
     can be placed on the board.
     */
    var cubesRemaining: [DiseaseColor : Int] { get }
    /**
     The cities on the board.
     */
    var cities: [BoardLocation] { get }
    /**
     The edges between all of the cities on the baord (this might be refactored later)
    */
    var connections: [(BoardLocation, BoardLocation)] { get }
    /**
     List of diseases that are not cured.
     */
    var uncuredDiseases: [DiseaseColor] { get }
    /**
     List of diseases that are cured
     */
    var curedDisease: [DiseaseColor] { get }
    /**
     Whether the game is still in progress, lost, or won.
     */
    var playState: PlayState { get }
    /**
     Returns the current location of the given pawn on the board.
     - Parameters:
        - pawn: the pawn being queried.
     - Returns: the location of the pawn on the board.
     - Throws: `BoardError.invalidpawn` when the pawn is not in the game
     */
    func location(of pawn: Pawn) -> BoardLocation
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
     - Returns: the state of the game after the transition (if this is implemented as a struct
        this will be easy to make multithreaded).
     */
    func transition(pawn: Pawn, for action: Action) throws -> GameState
    /**
     Returns the current hand for the given pawn.
     - Parameters:
        - pawn: the pawn that is the subject of the query.
     - Returns: the hand of the given pawn.
     - Throws: `BoardError.invalidpawn` when the pawn is not in the game
     */
    func hand(for pawn: Pawn) throws -> HandProtocol
}
