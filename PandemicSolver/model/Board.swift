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
     The pawn who is currently executing their turn.
    */
    var currentPlayer: Pawn { get }
    
    /**
     The numnber of actions the current player has remaining in their turn.
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
    func execute(action: Action) throws -> GameState
    
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
    func startGame() -> GameBoard
}

class GameBoard: GameState
{
    private let locationGraph: LocationGraphProtocol
    
    private let pawnLocations: [Pawn: CityName]
    
    private let pawnHands: [Pawn: HandProtocol]
    
    let pawns: [Pawn]
    
    let playerDeck: Deck
    
    let infectionPile: Deck
    
    let infectionRate: InfectionRate
    
    let outbreaksSoFar: Int
    
    let maxOutbreaks: Int
    
    let cubesRemaining: [DiseaseColor : Int]
    
    let uncuredDiseases: [DiseaseColor]
    
    let curedDiseases: [DiseaseColor]
    
    let gameStatus: GameStatus
    
    let currentPlayer: Pawn
    
    let actionsRemaining: Int
    
    var locations: [BoardLocation]
    {
        return locationGraph.locations.values.reduce([]) {$0 + [$1]}
    }
    
    /**
     Initializes the game but does not set the game up.
     */
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
        self.infectionRate = .one
        self.outbreaksSoFar = 0
        self.maxOutbreaks = 7
        self.cubesRemaining = GameStartHelper.initialDiseaseCubeCount()
        self.uncuredDiseases = DiseaseColor.allCases
        self.curedDiseases = []
        self.gameStatus = .notStarted
        //This should always be non-nil
        self.currentPlayer = self.pawns.randomElement()!
        self.actionsRemaining = 4
    }
    
    /**
     Private initializer to allow for copying of game state.
    */
    private init(locationGraph: LocationGraphProtocol, pawnLocations: [Pawn: CityName], pawnHands: [Pawn: HandProtocol],
                 pawns: [Pawn], playerDeck: Deck, infectionPile: Deck, infectionRate: InfectionRate, outbreaksSoFar: Int,
                 maxOutbreaks: Int, cubesRemaining: [DiseaseColor : Int], uncuredDiseases: [DiseaseColor],
                curedDiseases: [DiseaseColor], gameStatus: GameStatus, currentPlayer: Pawn, actionsRemaining: Int)
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
        self.currentPlayer = currentPlayer
        self.actionsRemaining = actionsRemaining
    }
    
    func location(of pawn: Pawn) -> BoardLocation {
        //If either of these are nil there is something wrong.
        let city = pawnLocations[pawn]!
        return locationGraph.locations[city]!
    }
    
    func legalActions(for pawn: Pawn) -> [Action]
    {
        guard let pawnCity = pawnLocations[pawn], let currentLocation = locationGraph.locations[pawnCity],
            let currentHand = pawnHands[pawn] else
        {
            return []
        }
        return pawn.getLegalMoves(for: self.locationGraph, with: currentHand,
                                  currentLocation: currentLocation,
                                  otherPawnLocations: pawnLocations,
                                  pawnHands: pawnHands)
    }
    
    func transition(pawn: Pawn, for action: Action) throws -> GameState
    {
        switch action
        {
            case .dispatcher(let dispactherAction):
                if pawn.role != .dispatcher
                {
                    throw BoardError.invalidMove
                }
                switch dispactherAction
                {
                    case .control(let newPawn, let newAction):
                        return try transition(pawn: newPawn, for: newAction)
                    case .snap(let pawn1, let pawn2):
                        //Move pawn 1 to pawn2
                        if !pawns.contains(pawn1) || !pawns.contains(pawn2)
                        {
                            throw BoardError.invalidMove
                        }
                        guard let city = pawnLocations[pawn2] else
                        {
                            throw BoardError.invalidMove
                        }
                        return move(pawn: pawn1, to: city)
                }
            case .general(let generalAction):
                return try execute(action: generalAction, for: pawn)
        }
    }
    
    /**
     Executes the given general action for the given pawn.
     - Parameters:
        - action: the action the pawn is going to execute
        - pawn: the pawn that is going to execute the action.
     - Throws: `BoardError.invalidMove` when the move is invalid
     - Returns: the gamestate with the updated state for the action.
     */
    private func execute(action: GeneralAction, for pawn: Pawn) throws -> GameState
    {
        switch action
        {
            case .buildResearchStation:
                guard let city = pawnLocations[pawn], let hand = pawnHands[pawn],
                    (hand.cards.contains(Card(cityName: city)) || pawn.role == .operationsExpert) else
                {
                    throw BoardError.invalidMove
                }
                
                //The operations expert doesn't discard a card when building a research station.
                if pawn.role != .operationsExpert
                {
                    //TODO: Deal with hand limit stuff
                    let (atHandLimit, newHand) = hand.discard(card: Card(cityName: city))
                    let newHands = pawnHands.imutableUpdate(key: pawn, value: newHand)
                    return copy(locationGraph: locationGraph.addResearchStation(to: city), pawnHands: newHands)
                }
                else
                {
                    return copy(locationGraph: locationGraph.addResearchStation(to: city))
                }
            
            //The cases where you move and don't discard a card
            case .shuttleFlight(let city), .drive(let city):
                return move(pawn: pawn, to: city)
            
            //The cases where you move and discard a card
            case .directFlight(let city):
                guard let hand = pawnHands[pawn], hand.cards.contains(Card(cityName: city)) else
                {
                    throw BoardError.invalidMove
                }
                //TODO: Deal with hand limit stuff
                let (atHandLimit, newHand) = hand.discard(card: Card(cityName: city))
                let newHands = pawnHands.imutableUpdate(key: pawn, value: newHand)
                return copy(pawnHands: newHands).move(pawn: pawn, to: city)
            
            case .charterFlight(let city):
                guard let hand = pawnHands[pawn], let currentLocation = pawnLocations[pawn],
                    hand.cards.contains(Card(cityName: currentLocation))  else
                {
                    throw BoardError.invalidMove
                }
                //TODO: Deal with hand limit stuff
                let (atHandLimit, newHand) = hand.discard(card: Card(cityName: currentLocation))
                let newHands = pawnHands.imutableUpdate(key: pawn, value: newHand)
                return copy(pawnHands: newHands).move(pawn: pawn, to: city)
            
            case .cure(let disease):
                guard let hand = pawnHands[pawn] else
                {
                    throw BoardError.invalidMove
                }
                let cardsToDiscard = Array(hand.cards.compactMap
                { card -> Card? in
                    switch card
                    {
                        case .epidemic:
                            return nil
                        case .cityCard(let cityCard):
                            if cityCard.city.color == disease
                            {
                                return Card.cityCard(card: cityCard)
                            }
                            else
                            {
                                return nil
                            }
                        }
                }[0..<5])
                //TODO: Do stuff with hand limits
                let (atHandLimit, newHand) = hand.discard(cards: cardsToDiscard)
                let newHands = pawnHands.imutableUpdate(key: pawn, value: newHand)
                let newCuredDisease = self.curedDiseases + [disease]
                return copy(pawnHands: newHands,
                            uncuredDiseases: uncuredDiseases.filter { $0 != disease },
                            curedDiseases: newCuredDisease,
                            gameStatus: newCuredDisease.count == 4 ? .win : .inProgress)
            
            case .treat(let disease):
                guard let city = pawnLocations[pawn] else
                {
                    throw BoardError.invalidMove
                }
                return copy(with: locationGraph.removeCubes(.one, of: disease, on: city), and: gameStatus)
            
            case .pass:
                return self
            
            case .shareKnowledge(let card, let pawn2):
                guard let hand1 = pawnHands[pawn], let hand2 = pawnHands[pawn2] else
                {
                    throw BoardError.invalidMove
                }
                //TODO: Add discarding card mechanism.
                let newHand1 = hand1.discard(card: card).1
                //TODO: Add discarding card mechanism.
                let newHand2 = hand2.draw(card: card).1
                let newPawnHands = pawnHands.imutableUpdate(key: pawn, value: newHand1).imutableUpdate(key: pawn2, value: newHand2)
                return copy(pawnHands: newPawnHands)
        }
    }
    
    func legalActions() -> [Action] {
        return legalActions(for: currentPlayer)
    }
    
    func execute(action: Action) throws -> GameState {
        return try transition(pawn: currentPlayer, for: action)
    }
    
    private func incrementTurn() -> GameState
    {
        let actionsRemaining = self.actionsRemaining == 1 ? 4 : self.actionsRemaining - 1
        var player = currentPlayer
        var newBoard = self
        if actionsRemaining == 4
        {
            player = pawns[(pawns.index(of: currentPlayer)! + 1) % 3]
            newBoard = newBoard.drawPlayerCards().drawInfectionCards()
        }
        return newBoard.copy(gameStatus: newBoard.evaluateGameStatus(),
                             currentPlayer: player,
                             actionsRemaining: actionsRemaining)
    }
    
    private func drawPlayerCards() -> GameBoard
    {
        guard let cards = try? playerDeck.drawCards(numberOfCards: 2) else
        {
            return gameEnd(with: .loss)
        }
        //TODO: Handle disscarding cards
        let newHand = pawnHands[currentPlayer]!.draw(cards: cards.cards.filter { $0 != .epidemic }).1
        if cards.cards.contains(.epidemic)
        {
            return copy(pawnHands: pawnHands.imutableUpdate(key: currentPlayer, value: newHand), playerDeck: cards.deck).epidemic()
        }
        else
        {
            return copy(pawnHands: pawnHands.imutableUpdate(key: currentPlayer, value: newHand), playerDeck: cards.deck)
        }
    }
    
    private func drawInfectionCards() -> GameBoard
    {
        guard let cards = try? infectionPile.drawCards(numberOfCards: infectionRate.cardsToDraw) else
        {
            return gameEnd(with: .loss)
        }
        var newState = copy(infectionPile: cards.deck)
        cards.cards.compactMap
        { card -> CityCard? in
            switch card
            {
                case .epidemic:
                    return nil
                case .cityCard(let cityCard):
                    return cityCard
            }
        }.forEach
        { cityCard in
            if newState.gameStatus == .inProgress
            {
                let (outbreaks, newLocationGraph) = locationGraph.place(.one, of: cityCard.city.color, on: cityCard.city.name)
                if outbreaks.count + outbreaksSoFar > maxOutbreaks
                {
                    newState = gameEnd(with: .loss)
                }
                else
                {
                    newState = newState.copy(locationGraph: newLocationGraph, outbreaksSoFar: outbreaksSoFar + outbreaks.count)
                }
            }
        }
        return newState
    }
    
    private func epidemic() -> GameBoard
    {
        //TODO: Draw from button on infection pile.
        guard let drawResult = try? infectionPile.drawFromBottom() else
        {
            return gameEnd(with: .loss)
        }
        //TODO: add a function to card that returns an optional city card. Nil if epidemic.
        switch drawResult.card
        {
            case .epidemic:
                //TODO: Should something different here happen? Throw and error?
                return gameEnd(with: .loss)
            case .cityCard(let cityCard):
                //TODO: Infect the city card.
                let (outbreaks, newGraph) = locationGraph.place(.three, of: cityCard.city.color, on: cityCard.city.name)
                return copy(locationGraph: newGraph, infectionRate: infectionRate.next(), outbreaksSoFar: outbreaksSoFar + outbreaks.count)
        }
    }
    
    private func evaluateGameStatus() -> GameStatus
    {
        return self.gameStatus
    }
    
    func hand(for pawn: Pawn) throws -> HandProtocol {
        guard let hand = pawnHands[pawn] else
        {
            throw BoardError.invalidPawn
        }
        return hand
    }
    
    func startGame() -> GameBoard
    {
        guard let cities = try? self.infectionPile.drawCards(numberOfCards: 9), !cities.cards.contains(.epidemic) else
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
        
        let threes = Array(cities.cards[0..<3]).compactMap { cubePlacement(of: $0, with: .three) }
        let twos = Array(cities.cards[3..<6]).compactMap { cubePlacement(of: $0, with: .two) }
        let ones = Array(cities.cards[6..<9]).compactMap { cubePlacement(of: $0, with: .one) }
        let (outbreaks, newGraph) = locationGraph.place(cubes: threes + twos + ones)
        if !outbreaks.isEmpty
        {
            print("this should never happen")
        }
        return copy(locationGraph: newGraph.addResearchStation(to: .atlanta), infectionPile: cities.deck, gameStatus: .inProgress)
    }
    
    private func gameEnd(with status: GameStatus) -> GameBoard
    {
        return GameBoard(locationGraph: self.locationGraph, pawnLocations: self.pawnLocations,
                         pawnHands: self.pawnHands, pawns: self.pawns, playerDeck: self.playerDeck,
                         infectionPile: self.infectionPile, infectionRate: self.infectionRate,
                         outbreaksSoFar: self.outbreaksSoFar, maxOutbreaks: self.maxOutbreaks, cubesRemaining: self.cubesRemaining,
                         uncuredDiseases: self.uncuredDiseases, curedDiseases: self.curedDiseases, gameStatus: status,
                         currentPlayer: currentPlayer, actionsRemaining: actionsRemaining)
    }
    
    private func copy(with newGraph: LocationGraphProtocol, and status: GameStatus) -> GameBoard
    {
        return GameBoard(locationGraph: newGraph, pawnLocations: pawnLocations,
                         pawnHands: pawnHands, pawns: pawns, playerDeck: playerDeck,
                         infectionPile: infectionPile, infectionRate: infectionRate,
                         outbreaksSoFar: outbreaksSoFar, maxOutbreaks: maxOutbreaks,
                         cubesRemaining: cubesRemaining, uncuredDiseases: uncuredDiseases,
                         curedDiseases: curedDiseases, gameStatus: status, currentPlayer: currentPlayer,
                         actionsRemaining: actionsRemaining)
    }
    
    private func move(pawn: Pawn, to city: CityName) -> GameBoard
    {
        return GameBoard(locationGraph: locationGraph,
                         pawnLocations: pawnLocations.imutableUpdate(key: pawn, value: city),
                         pawnHands: pawnHands, pawns: pawns,
                         playerDeck: playerDeck, infectionPile: infectionPile,
                         infectionRate: infectionRate, outbreaksSoFar: outbreaksSoFar,
                         maxOutbreaks: maxOutbreaks, cubesRemaining: cubesRemaining,
                         uncuredDiseases: uncuredDiseases, curedDiseases: curedDiseases,
                         gameStatus: gameStatus, currentPlayer: currentPlayer,
                         actionsRemaining: actionsRemaining)
    }
    
    private func copy(locationGraph: LocationGraphProtocol? = nil,
                      pawnLocations: [Pawn: CityName]? = nil,
                      pawnHands: [Pawn: HandProtocol]? = nil,
                      pawns: [Pawn]? = nil, playerDeck: Deck? = nil,
                      infectionPile: Deck? = nil, infectionRate: InfectionRate? = nil,
                      outbreaksSoFar: Int? = nil, maxOutbreaks: Int? = nil,
                      cubesRemaining: [DiseaseColor : Int]? = nil,
                      uncuredDiseases: [DiseaseColor]? = nil,
                      curedDiseases: [DiseaseColor]? = nil,
                      gameStatus: GameStatus? = nil,
                      currentPlayer: Pawn? = nil,
                      actionsRemaining: Int? = nil) -> GameBoard
    {
        return GameBoard(locationGraph: locationGraph ?? self.locationGraph,
                         pawnLocations: pawnLocations ?? self.pawnLocations,
                         pawnHands: pawnHands ?? self.pawnHands,
                         pawns: pawns ?? self.pawns,
                         playerDeck: playerDeck ?? self.playerDeck,
                         infectionPile: infectionPile ?? self.infectionPile,
                         infectionRate: infectionRate ?? self.infectionRate,
                         outbreaksSoFar: outbreaksSoFar ?? self.outbreaksSoFar,
                         maxOutbreaks: maxOutbreaks ?? self.maxOutbreaks,
                         cubesRemaining: cubesRemaining ?? self.cubesRemaining,
                         uncuredDiseases: uncuredDiseases ?? self.uncuredDiseases,
                         curedDiseases: curedDiseases ?? self.curedDiseases,
                         gameStatus: gameStatus ?? self.gameStatus,
                         currentPlayer: currentPlayer ?? self.currentPlayer,
                         actionsRemaining: actionsRemaining ?? self.actionsRemaining)
    }
}
