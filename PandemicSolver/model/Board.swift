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
    var cubes: CubeDistributionProtocol { get }
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

struct GameBoard: GameState
{
    let pawns: [Role]
    
    let playerDeck: [Deck]
    
    let infectionPile: [Deck]
    
    let infectionRate: Int
    
    let outBreaksSoFar: Int
    
    let maxOutBreaks: Int
    
    let cubesRemaining: [DiseaseColor : Int]
    
    let cities: [BoardLocation]
    
    let connections: [(BoardLocation, BoardLocation)]
    
    let uncuredDiseases: [DiseaseColor]
    
    let curedDisease: [DiseaseColor]
    
    //TODO: rename to something a little more clear
    let playState: PlayState
    
    func location(of pawn: Pawn) -> BoardLocation {
        //TODO: return a real location
        return Location(city: City(name: .algiers), cubes: CubeDistribution())
    }
    
    func legalActions(for pawn: Pawn) -> [Action] {
        //TODO: return a real list of legal actions
        return []
    }
    
    func transition(pawn: Pawn, for action: Action) throws -> GameState {
        //TODO: return real changed gamestate
        return self
    }
    
    func hand(for pawn: Pawn) throws -> HandProtocol {
        //TODO: return a real hand
        return Hand()
    }
    
    init() {
        self.pawns = []
        self.playerDeck = []
        self.infectionPile = []
        self.infectionRate = 2
        self.outBreaksSoFar = 0
        self.maxOutBreaks = 7
        self.cubesRemaining = GameStartHelper.initialDiseaseCubeCount()
        self.cities = []
        self.connections = []
        self.uncuredDiseases = []
        self.curedDisease = []
        self.playState = .inProgress
    }
}

struct Location: BoardLocation
{
    let city: City
    let cubes: CubeDistributionProtocol
    
    init(city: City, cubes: CubeDistributionProtocol) {
        self.city = city
        self.cubes = cubes
    }
}

struct Hand: HandProtocol
{
    private var hand: [Card]
    var cards: [Card]
    {
        return hand
    }
    
    init() {
        hand = []
    }
    
    func draw(card: Card) throws {
        
    }
    
    func draw(cards: [Card]) throws {
        
    }
    
    func discard(card: Card) throws -> Card {
        //TODO: discard a real card
        return .epidemic
    }
    
    func discard(cards: [Card]) throws -> [Card] {
        //TODO: discard real cards
        return []
    }
    
    
}
