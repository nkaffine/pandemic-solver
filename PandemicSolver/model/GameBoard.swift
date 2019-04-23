//
//  Board.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/7/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class GameBoard: GameState, Simulator, CustomStringConvertible
{
    private let locationGraph: LocationGraphProtocol
    
    private let pawnLocations: [Pawn: CityName]
    
    private let pawnHands: [Pawn: HandProtocol]
    
    private let currentTurn: CurrentTurn
    
    let pawns: [Pawn]
    
    let playerDeck: Deck
    
    let infectionPile: Deck
    
    let infectionRate: InfectionRate
    
    let outbreaksSoFar: Int
    
    let maxOutbreaks: Int
    
    var cubesRemaining: [DiseaseColor : Int]
    {
        return locationGraph.cubesRemaining
    }
    
    let uncuredDiseases: [DiseaseColor]
    
    let curedDiseases: [DiseaseColor]
    
    let gameStatus: GameStatus
    
    var locations: [BoardLocation]
    {
        return locationGraph.locations.values.reduce([]) {$0 + [$1]}
    }
    
    var currentPlayer: Pawn
    {
        return currentTurn.currentPawn
    }
    
    var actionsRemaining: Int
    {
        return currentTurn.actionsLeft
    }
    
    var description: String
    {
        return "Pawns: \(pawns)\nPawn Locations: \(pawnLocations)\nInfection Rate: \(infectionRate)\nOutbreaks "
            + "So Far: \(outbreaksSoFar)\nCubes Remaining: \(cubesRemaining)\nUncured Diseases: \(uncuredDiseases)"
            + "\nCured Disease: \(curedDiseases)\nGame Status: \(gameStatus)\nPlayer Deck Count: \(playerDeck.count)\n"
            + "Infection Deck Count: \(infectionPile.count)\nCubes:\n"
            + locations.filter{$0.isInfected}.sorted(by:
            { location1, location2 -> Bool in
                location2.cubes.maxCount < location1.cubes.maxCount
            }).map({ location -> String in return "\t" + location.description + "\n" })
                .reduce("", {$0 + $1})
    }
    
    /**
     Initializes the game but does not set the game up.
     */
    init(missingRole: Role? = nil) {
        self.locationGraph = LocationGraph()
        self.pawns = GameStartHelper.selectPawns(with: missingRole)
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
        self.uncuredDiseases = DiseaseColor.allCases
        self.curedDiseases = []
        self.gameStatus = .notStarted
        //This should always be non-nil
        self.currentTurn = CurrentTurn(pawns: pawns)
    }
    
    /**
     Private initializer to allow for copying of game state.
    */
    private init(locationGraph: LocationGraphProtocol, pawnLocations: [Pawn: CityName], pawnHands: [Pawn: HandProtocol],
                 pawns: [Pawn], playerDeck: Deck, infectionPile: Deck, infectionRate: InfectionRate, outbreaksSoFar: Int,
                 maxOutbreaks: Int, uncuredDiseases: [DiseaseColor],
                curedDiseases: [DiseaseColor], gameStatus: GameStatus, currentPlayer: CurrentTurn)
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
        self.uncuredDiseases = uncuredDiseases
        self.curedDiseases = curedDiseases
        self.gameStatus = gameStatus
        self.currentTurn = currentPlayer
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
    
    func transition(pawn: Pawn, for action: Action) throws -> (GameState, Reward)
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
                        return (move(pawn: pawn1, to: city), .none)
                }
            case .general(let generalAction):
                return try execute(action: generalAction, for: pawn)
            case .drawAndInfect:
                guard currentTurn.actionsLeft == 0 else
                {
                    throw BoardError.invalidMove
                }
                return (self.drawPlayerCards().drawInfectionCards(), .none)
        }
    }
    
    func legalActions() -> [Action] {
        if currentTurn.actionsLeft == 0
        {
            return [Action.drawAndInfect]
        }
        else
        {
             return legalActions(for: currentTurn.currentPawn)
        }
    }
    
    func execute(action: Action) throws -> GameState {
        return try (transition(pawn: currentTurn.currentPawn, for: action) as! GameBoard).incrementTurn()
    }
    
    /**
     Increments the turn by one action. If the action switches to the next turn, the current player
     is updated. Returns the gamestate after the turn has been incremented
    */
    private func incrementTurn() -> GameState
    {
        return copy(currentPlayer: currentTurn.next())
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
    
    func startGame() -> GameState
    {
        guard let cities = try? self.infectionPile.drawCards(numberOfCards: 9), !cities.cards.contains(.epidemic) else
        {
            //Return the state of the game but marked as a loss
            return gameEnd(with: .loss(reason: "Could not draw cards."))
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
}

//MARK: action execution utilities
extension GameBoard
{
    /**
     Executes the given general action for the given pawn.
     - Parameters:
     - action: the action the pawn is going to execute
     - pawn: the pawn that is going to execute the action.
     - Throws: `BoardError.invalidMove` when the move is invalid
     - Returns: the gamestate with the updated state for the action and the reward of that reaction.
     */
    private func execute(action: GeneralAction, for pawn: Pawn) throws -> (GameState, Reward)
    {
        //TODO: Break these out into helper functions
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
                return (copy(locationGraph: locationGraph.addResearchStation(to: city), pawnHands: newHands), .none)
            }
            else
            {
                return (copy(locationGraph: locationGraph.addResearchStation(to: city)), .none)
            }
            
        case .drive(let city):
            guard locationGraph.isAdjacent(pawnLocations[pawn]!, to: city) else
            {
                throw BoardError.invalidMove
            }
            return (move(pawn: pawn, to: city), .none)
            
        //The cases where you move and don't discard a card
        case .shuttleFlight(let city):
            guard let location = locationGraph.locations[city], location.hasResearchStation else
            {
                throw BoardError.invalidMove
            }
            return (move(pawn: pawn, to: city), .none)
            
        //The cases where you move and discard a card
        case .directFlight(let city):
            guard let hand = pawnHands[currentPlayer], hand.cards.contains(Card(cityName: city)) else
            {
                throw BoardError.invalidMove
            }
            //TODO: Deal with hand limit stuff
            let (atHandLimit, newHand) = hand.discard(card: Card(cityName: city))
            let newHands = pawnHands.imutableUpdate(key: currentPlayer, value: newHand)
            return (copy(pawnHands: newHands).move(pawn: pawn, to: city), .none)
            
        case .charterFlight(let city):
            guard let hand = pawnHands[currentPlayer], let currentLocation = pawnLocations[pawn],
                hand.cards.contains(Card(cityName: currentLocation))  else
            {
                throw BoardError.invalidMove
            }
            //TODO: Deal with hand limit stuff
            let (atHandLimit, newHand) = hand.discard(card: Card(cityName: currentLocation))
            let newHands = pawnHands.imutableUpdate(key: currentPlayer, value: newHand)
            return (copy(pawnHands: newHands).move(pawn: pawn, to: city), .none)
            
        case .cure(let disease):
            let threshold = pawn.role == .scientist ? 4 : 5
            guard let hand = pawnHands[pawn], hand.cards.count >= threshold else
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
                }[0..<threshold])
            //TODO: Do stuff with hand limits
            let (atHandLimit, newHand) = hand.discard(cards: cardsToDiscard)
            let newHands = pawnHands.imutableUpdate(key: pawn, value: newHand)
            let newCuredDisease = self.curedDiseases + [disease]
            return (copy(pawnHands: newHands,
                        uncuredDiseases: uncuredDiseases.filter { $0 != disease },
                        curedDiseases: newCuredDisease,
                        gameStatus: newCuredDisease.count == 4 ? .win(reason: "All Diseases Cured") : .inProgress), .curedDisease)
            
        case .treat(let disease):
            guard let city = pawnLocations[pawn] else
            {
                throw BoardError.invalidMove
            }
            return (copy(locationGraph: locationGraph.removeCubes(.one, of: disease, on: city), gameStatus: gameStatus), .treatedDisease)
            
        case .pass:
            return (self, .none)
            
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
            return (copy(pawnHands: newPawnHands), .sharedKnowledge)
        }
    }
}

//MARK: draw, infecting, and epidemic utilities
extension GameBoard
{
    /**
     Handles the player card drawing step. Returns the gamestate after cards have been drawn.
     */
    private func drawPlayerCards() -> GameBoard
    {
        guard let cards = try? playerDeck.drawCards(numberOfCards: 2) else
        {
            return gameEnd(with: .loss(reason: "Could not draw cards"))
        }
        //TODO: Handle disscarding cards
        let newHand = pawnHands[currentTurn.currentPawn]!.draw(cards: cards.cards.filter { $0 != .epidemic }).1
        if cards.cards.contains(.epidemic)
        {
            return copy(pawnHands: pawnHands.imutableUpdate(key: currentTurn.currentPawn, value: newHand),
                        playerDeck: cards.deck).epidemic()
        }
        else
        {
            return copy(pawnHands: pawnHands.imutableUpdate(key: currentTurn.currentPawn, value: newHand),
                        playerDeck: cards.deck)
        }
    }
    
    /**
     Handles the drawing of infection cards and subsequent infections. Returns the game board after being infected.
     */
    private func drawInfectionCards() -> GameBoard
    {
        guard let cards = try? infectionPile.drawCards(numberOfCards: infectionRate.cardsToDraw) else
        {
            return gameEnd(with: .loss(reason: "Could not draw infection cards"))
        }
        var newState = copy(infectionPile: cards.deck)
        let cityCards = cards.cards.compactMap
        { card -> CityCard? in
            switch card
            {
            case .epidemic:
                return nil
            case .cityCard(let cityCard):
                return cityCard
            }
        }
        cityCards.forEach
            { cityCard in
                if newState.gameStatus.isInProgress
                {
                    let (outbreaks, newLocationGraph) = locationGraph.place(.one, of: cityCard.city.color, on: cityCard.city.name)
                    if outbreaks.count + outbreaksSoFar > maxOutbreaks
                    {
                        newState = gameEnd(with: .loss(reason: "Maximum outbreaks reached. Would have had: \(outbreaks.count + outbreaksSoFar)"))
                    }
                    else if !newLocationGraph.hasValidCubeCount
                    {
                        newState = gameEnd(with: .loss(reason: "Ran out of cubes \(newLocationGraph.cubesRemaining)"))
                    }
                    else
                    {
                        newState = newState.copy(locationGraph: newLocationGraph, outbreaksSoFar: outbreaksSoFar + outbreaks.count)
                    }
                }
        }
        guard let newInfectionPile = try? cards.deck.discard(cards: cards.cards) else
        {
            return gameEnd(with: .loss(reason: "Could not discard infection cards"))
        }
        
        return newState.copy(infectionPile: newInfectionPile)
    }
    
    private func epidemic() -> GameBoard
    {
        guard let drawResult = try? infectionPile.drawFromBottom() else
        {
            return gameEnd(with: .loss(reason: "Could not draw cards"))
        }
        //TODO: add a function to card that returns an optional city card. Nil if epidemic.
        switch drawResult.card
        {
            case .epidemic:
                //TODO: Should something different here happen? Throw and error?
                return gameEnd(with: .loss(reason: "Drew an epidemic from the infection pile, this should not happen."))
            case .cityCard(let cityCard):
                let (outbreaks, newGraph) = locationGraph.place(.three, of: cityCard.city.color, on: cityCard.city.name)
                //Add the cards from the discard pile of the infection deck to the top of the deck shuffled
                let discardPile = drawResult.deck.discardPile + [drawResult.card]
                let newDeck = drawResult.deck.add(cards: discardPile.shuffled()).clearDiscardPile()
                return copy(locationGraph: newGraph,infectionPile: newDeck,
                            infectionRate: infectionRate.next(),
                            outbreaksSoFar: outbreaksSoFar + outbreaks.count)
        }
    }
}

//MARK: Copying utilties
extension GameBoard
{
    /**
     Returns a gameboard where the game status is set to the given status.
     - Parameters:
        - status: the status of the game
     - Returns: a board with updated state.
    */
    private func gameEnd(with status: GameStatus) -> GameBoard
    {
        return GameBoard(locationGraph: self.locationGraph, pawnLocations: self.pawnLocations,
                         pawnHands: self.pawnHands, pawns: self.pawns, playerDeck: self.playerDeck,
                         infectionPile: self.infectionPile, infectionRate: self.infectionRate,
                         outbreaksSoFar: self.outbreaksSoFar, maxOutbreaks: self.maxOutbreaks,
                         uncuredDiseases: self.uncuredDiseases, curedDiseases: self.curedDiseases, gameStatus: status,
                         currentPlayer: currentTurn)
    }
    
    /**
     Moves the given pawn to the given city and returns the board state reflecting that update.
     - Parameters:
         - pawn: the pawn being moved.
         - city: the name of the city the pawn should be moved to.
     - Returns: a game board where the state reflects the move.
    */
    private func move(pawn: Pawn, to city: CityName) -> GameBoard
    {
        return GameBoard(locationGraph: locationGraph,
                         pawnLocations: pawnLocations.imutableUpdate(key: pawn, value: city),
                         pawnHands: pawnHands, pawns: pawns,
                         playerDeck: playerDeck, infectionPile: infectionPile,
                         infectionRate: infectionRate, outbreaksSoFar: outbreaksSoFar,
                         maxOutbreaks: maxOutbreaks,
                         uncuredDiseases: uncuredDiseases, curedDiseases: curedDiseases,
                         gameStatus: gameStatus, currentPlayer: currentTurn)
    }
    
    /**
     Convenience function that will copy the state but update any field that is passed as
     a parameter to the given value.
     - Parameters:
         - locationGraph: either an updated location graph or nil.
         - pawnLocations: either an updated dictionary of pawn locations or nil.
         - pawnHands: either an updated dictionary of pawn hands of nil.
         - infectionPile: either an updated infection pile or nil.
         - outbreaksSoFar: either an updated outbreaks so far number or nil.
         - uncuredDiseases: either an updated list of uncured diseases or nil.
         - curedDiseases: either an updated list of cured disaeses or nil.
         - gameStatus: either an updated game status or nil.
         - currentPlayer: either an updated current player structure or nil.
     - Returns: a copy of the state with any values passed updated to the given value
    */
    private func copy(locationGraph: LocationGraphProtocol? = nil,
                      pawnLocations: [Pawn: CityName]? = nil,
                      pawnHands: [Pawn: HandProtocol]? = nil,
                      pawns: [Pawn]? = nil, playerDeck: Deck? = nil,
                      infectionPile: Deck? = nil, infectionRate: InfectionRate? = nil,
                      outbreaksSoFar: Int? = nil, maxOutbreaks: Int? = nil,
                      uncuredDiseases: [DiseaseColor]? = nil,
                      curedDiseases: [DiseaseColor]? = nil,
                      gameStatus: GameStatus? = nil,
                      currentPlayer: CurrentTurn? = nil) -> GameBoard
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
                         uncuredDiseases: uncuredDiseases ?? self.uncuredDiseases,
                         curedDiseases: curedDiseases ?? self.curedDiseases,
                         gameStatus: gameStatus ?? self.gameStatus,
                         currentPlayer: currentPlayer ?? self.currentTurn)
    }
}
