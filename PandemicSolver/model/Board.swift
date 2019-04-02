//
//  Board.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/7/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

enum GameStatus
{
    case notStarted, inProgress, win, loss
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
    var infectionRate: Int { get }
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
    /**
     Does the first round of infecting and changes the game status to inProgress.
     - Returns: the new gameboard with the updated state.
    */
    func setupGame() -> GameBoard
}

struct GameBoard: GameState
{
    private let locationGraph: LocationGraphProtocol
    
    private let pawnLocations: [Pawn: CityName]
    
    private let pawnHands: [Pawn: HandProtocol]
    
    let pawns: [Pawn]
    
    let playerDeck: Deck
    
    let infectionPile: Deck
    
    let infectionRate: Int
    
    let outbreaksSoFar: Int
    
    let maxOutbreaks: Int
    
    let cubesRemaining: [DiseaseColor : Int]
    
    let uncuredDiseases: [DiseaseColor]
    
    let curedDiseases: [DiseaseColor]
    
    let gameStatus: GameStatus
    
    var locations: [BoardLocation]
    {
        return locationGraph.locations.values.reduce([]) {$0 + [$1]}
    }
    
    private init(locationGraph: LocationGraphProtocol, pawnLocations: [Pawn: CityName], pawnHands: [Pawn: HandProtocol],
                 pawns: [Pawn], playerDeck: Deck, infectionPile: Deck, infectionRate: Int, outbreaksSoFar: Int,
                 maxOutbreaks: Int, cubesRemaining: [DiseaseColor : Int], uncuredDiseases: [DiseaseColor],
                 curedDiseases: [DiseaseColor], gameStatus: GameStatus)
    {
        self.locationGraph = locationGraph
        self.pawnLocations = pawnLocations
        self.pawnHands = pawnHands
        self.pawns = pawns
        self.playerDeck = playerDeck
        self.infectionPile = infectionPile
        self.infectionRate = infectionRate
        self.outbreaksSoFar = outbreaksSoFar
        self.maxOutbreaks = maxOutbreaks
        self.cubesRemaining = cubesRemaining
        self.uncuredDiseases = uncuredDiseases
        self.curedDiseases = curedDiseases
        self.gameStatus = gameStatus
    }
    
    func location(of pawn: Pawn) -> BoardLocation {
        //If either of these are nil there is something wrong.
        let city = pawnLocations[pawn]!
        return locationGraph.locations[city]!
    }
    
    func legalActions(for pawn: Pawn) -> [Action] {
        //TODO: return a real list of legal actions
        guard let currentLocation = pawnLocations[pawn], let currentHand = pawnHands[pawn] else
        {
            return []
        }
        let otherHands = pawnHands.values.filter { $0.cards != currentHand.cards }
        return []
    }
    
    func transition(pawn: Pawn, for action: Action) throws -> GameState {
        //TODO: return real changed gamestate
        return self
    }
    
    func hand(for pawn: Pawn) throws -> HandProtocol {
        guard let hand = pawnHands[pawn] else
        {
            throw BoardError.invalidPawn
        }
        return hand
    }
    
    init() {
        self.locationGraph = LocationGraph()
        self.pawns = GameStartHelper.selectPawns()
        var locations = [Pawn: CityName]()
        var cityCards = GameStartHelper.generateCityCards()
        var pawnHands = [Pawn: HandProtocol]()
        self.pawns.forEach
        { pawn in
            locations[pawn] = .atlanta
            pawnHands[pawn] = Hand(card1: cityCards[0], card2: cityCards[1])
            cityCards.removeFirst(2)
        }
        self.pawnLocations = locations
        self.pawnHands = pawnHands
        self.playerDeck = PlayerDeck(deck: cityCards)
        self.infectionPile = InfectionPile()
        self.infectionRate = 2
        self.outbreaksSoFar = 0
        self.maxOutbreaks = 7
        self.cubesRemaining = GameStartHelper.initialDiseaseCubeCount()
        self.uncuredDiseases = DiseaseColor.allCases
        self.curedDiseases = []
        self.gameStatus = .notStarted
    }
    
    func setupGame() -> GameBoard
    {
        guard let cities = try? self.infectionPile.drawCards(numberOfCards: 9), !cities.contains(.epidemic) else
        {
            //Return the state of the game but marked as a loss
            return gameEnd(with: .loss)
        }
        
        func cubePlacement(of card: Card, with count: CubeCount) -> CubePlacement?
        {
            switch card
            {
                case .cityCard(let cityCard):
                    return CubePlacement(city: cityCard.city.name, disease: cityCard.city.color, cubes: count)
                case .epidemic:
                    return nil
            }
        }
        
        let threes = Array(cities[0..<3]).compactMap { cubePlacement(of: $0, with: .three) }
        let twos = Array(cities[3..<6]).compactMap { cubePlacement(of: $0, with: .two) }
        let ones = Array(cities[6..<9]).compactMap { cubePlacement(of: $0, with: .one) }
        let (outbreaks, newGraph) = locationGraph.place(cubes: threes + twos + ones)
        if !outbreaks.isEmpty
        {
            print("this should never happen")
        }
        return copy(with: newGraph.addResearchStation(to: .atlanta), and: .inProgress)
    }
    
    private func gameEnd(with status: GameStatus) -> GameBoard
    {
        return GameBoard(locationGraph: self.locationGraph, pawnLocations: self.pawnLocations,
                         pawnHands: self.pawnHands, pawns: self.pawns, playerDeck: self.playerDeck,
                         infectionPile: self.infectionPile, infectionRate: self.infectionRate,
                         outbreaksSoFar: self.outbreaksSoFar, maxOutbreaks: self.maxOutbreaks, cubesRemaining: self.cubesRemaining,
                         uncuredDiseases: self.uncuredDiseases, curedDiseases: self.curedDiseases, gameStatus: status)
    }
    
    private func copy(with newGraph: LocationGraphProtocol, and status: GameStatus) -> GameBoard
    {
        return GameBoard(locationGraph: newGraph, pawnLocations: pawnLocations,
                         pawnHands: pawnHands, pawns: pawns, playerDeck: playerDeck,
                         infectionPile: infectionPile, infectionRate: infectionRate,
                         outbreaksSoFar: outbreaksSoFar, maxOutbreaks: maxOutbreaks,
                         cubesRemaining: cubesRemaining, uncuredDiseases: uncuredDiseases,
                         curedDiseases: curedDiseases, gameStatus: status)
    }
}
