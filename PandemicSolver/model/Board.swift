//
//  Board.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/7/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

protocol BoardLocation
{
    var city: City { get }
    var cubes: [DiseaseColor : Int] { get }
}

enum Action
{
    case general(action: GeneralAction)
}

enum GeneralAction
{
    case drive(to: BoardLocation)
    case directFlight(to: BoardLocation)
    case charterFlight(to: BoardLocation)
    case shuttleFlight(to: BoardLocation)
    case buildResearchStation, treat
    case cure(disease: DiseaseColor)
    case shareKnowledge(card: Card, pawn: Pawn)
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
    var pawns: [Pawn] { get }
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
     The number of cubes available for each color.
     */
    var totalCubesPerColor: Int { get }
    /**
     A dictionary of disease cubes to the number of cubes currently on the board.
     */
    var cubesInPlay: [DiseaseColor : Int] { get }
    /**
     The cities on the board.
     */
    var cities: [BoardLocation] { get }
    /**
     List of diseases that are not cured.
     */
    var uncuredDiseases: [DiseaseColor] { get }
    /**
     List of diseases that are cured
     */
    var curedDisease: [DiseaseColor] { get }
    /**
     Whether or not the game is in the goal state.
     */
    var isGoalState: Bool { get }
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
     */
    func transition(pawn: Pawn, for action: Action) throws
    /**
     Returns the current hand for the given pawn.
     - Parameters:
        - pawn: the pawn that is the subject of the query.
     - Returns: the hand of the given pawn.
     - Throws: `BoardError.invalidpawn` when the pawn is not in the game
     */
    func hand(for pawn: Pawn) throws -> HandProtocol
}
