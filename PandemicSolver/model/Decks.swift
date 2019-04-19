//
//  Decks.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

/**
    An enum for all the errors that can occur in deck actions
 */
enum DeckError: Error
{
    case invalidDraw, invalidDiscard
}


/**
    There are two types of decks in the game, the player deck and the infection deck. A deck has the ability to draw
    a given number of cards, compute the probability of drawing a given card, and draw a card from the bottom.
 */
protocol Deck
{
    /**
     A list of cards in the discard pile of the given deck, the players are allowed to see these cards but not change
     them.
     */
    var discardPile: [Card] { get }
    /**
     The count of the cards in the deck.
    */
    var count: Int { get }
    /**
     Returns an array with the given number of cards.
     - Parameters:
        - numberOfCards: the number of cards to be draw from the deck.
     - Throws: `DeckError.invalidDraw` when there are not enough cards in the deck to draw.
     */
    func drawCards(numberOfCards: Int) throws -> (deck: Deck, cards: [Card])
    /**
     - Throws: `DeckError.invalidDiscard`
     - Returns: the card from the bottom of the deck
    */
    func drawFromBottom() throws -> (deck: Deck, card: Card)
    /**
     Adds the given card to the discard pile of this deck.
     - Parameters:
        - card: the card to be added to the discard pile.
     - Throws: `DeckError.invalidDiscard` when the card is in the discard pile or still in the deck.
    */
    func discard(card: Card) throws -> Deck
    /**
     Adds the given cards to the dicard pile of this deck in order where the last item will be at the top of the
     discard pile.
     - Parameters:
        - cards: the cards to be added to the discard pile of this deck
     - Throws: `DeckError.invalidDiscard` when one or more cards is in the discard pile or still in the deck.
     */
    func discard(cards: [Card]) throws -> Deck
    /**
     Returns the probability of drawing the given card in the current state of the deck.
     - Parameters:
        - card: the card that is the query of the probability.
     - Returns: the probability of drawing that card.
     */
    func probability(ofDrawing card: Card) -> Double
    /**
     Returns the probability of drawing the given card in the current state of the deck in the next given number of draws.
     - Parameters:
        - card: the card being queried.
        - draws: the number of draws.
     - Returns: the probability of drawing the given card in the next given number of draws.
     */
    func probability(ofDrawing card: Card, inNext draws: Int) -> Double
    /**
     Returns the probability of drawing all of the given cards in the next given number of draws.
     - Parameters:
        - cards: the cards being queried.
        - draws: the number of draws being considered.
     - Returns: the probability of drawing the given cards in the next given number of draws.
     - Note: If the number of cards is greater than the number of draws, the probability will be 0.
     */
    func probability(ofDrawing cards: [Card], inNext draws: Int) -> Double
    /**
     Adds the given cards to the top of the deck.
     - Parameters:
     - cards: the cards being added to the top of th dcek.
     */
    func add(cards: [Card]) -> Deck
    
    //TODO: Test this
    /**
     Removes all the cards in the discard pile.
     - Returns: the state of the deck after removing discard pile.
    */
    func clearDiscardPile() -> Deck
    
    /**
     Returns a deck with all of the same cards as the current deck in a random
     different order.
     - Returns: a deck containing the same cards in a random new order.
    */
    func shuffled() -> Deck
}

/**
 The deck that players draw cards from.
 */
struct PlayerDeck: Deck
{
    /**
     The deck of cards that the players draw from.
     Note: The deck is stored where the last index is the top of the deck.
    */
    private let deck: ImmutableProbabilityDeck
    let discardPile: [Card]
    var count: Int
    {
        return deck.count
    }
    
    init(deck: [Card])
    {
        //Generate all the cards for the deck without epidemics
        self.deck = ImmutablePartition(piles: PlayerDeck.generatePartitionedEpidemicDecks(from: deck))
        self.discardPile = []
    }
    
    private init(deck: ImmutableProbabilityDeck, discardPile: [Card])
    {
        self.deck = deck
        self.discardPile = discardPile
    }
    
    func drawCards(numberOfCards: Int) throws -> (deck: Deck, cards: [Card]) {
        let (deck, drawn) = try self.deck.draw(numberOfCards: numberOfCards)
        return (PlayerDeck(deck: deck, discardPile: discardPile), drawn)
    }
    
    func discard(card: Card) throws -> Deck {
        return try discard(cards: [card])
    }
    
    func discard(cards: [Card]) throws -> Deck {
        return PlayerDeck(deck: deck, discardPile: discardPile + cards)
    }
    
    //TODO: The probability of the epidemic can be more detailed
    //such that it is dependent on the current pile being drawn from.
    func probability(ofDrawing card: Card) -> Double {
        //Check probability when the deck is empty.
        guard deck.count > 0 else
        {
            return 0
        }
        //There is only one version of each card in the deck except for epidemics
        switch card
        {
            case .epidemic:
                //The deck needs to be set up such that it is partitioned but
                //I should be able to do this with some math for now.
                //Each section of the deck has 9 cards
                let numLeftInSection = deck.count % 9 == 0 ? 9 : deck.count % 9
                if deck.probability(ofDrawing: .epidemic, inNext: numLeftInSection) != 0
                {
                    return Double(1) / Double(numLeftInSection)
                }
                else
                {
                    return 0
                }
            
            case .cityCard:
                if deck.contains(card)
                {
                    return Double(1) / Double(deck.count)
                }
                else
                {
                    return 0
                }
        }
    }
    
    func probability(ofDrawing card: Card, inNext draws: Int) -> Double {
        switch card
        {
            case .epidemic:
                let numLeftInSection = deck.count % 9 == 0 ? 9 : deck.count % 9
                if deck.probability(ofDrawing: .epidemic, inNext: numLeftInSection) != 0
                {
                    let probOfNotDrawingEpidemic = Double(numLeftInSection - 1) / Double(numLeftInSection)
                    return 1 - pow(probOfNotDrawingEpidemic, Double(draws))
                }
                else
                {
                    return 0
                }
            case .cityCard:
                //Get the probability of drawing the card.
                let probOfDrawing = probability(ofDrawing: card)
                //Get the probability of not drawing the card.
                let probOfNotDrawing = 1 - probOfDrawing
                //Get the probability of now drawing the card in the next x turns.
                let probOfNotDrawingInTurns = pow(probOfNotDrawing, Double(draws))
                //Return 1 - probability of not drawing in next x turns.
                return 1 - probOfNotDrawingInTurns
        }
    }
    
    func probability(ofDrawing cards: [Card], inNext draws: Int) -> Double {
        //Guarding for invalid probabilities
        if cards.count > draws
        {
            return 0
        }
        //TODO: Check to see if the combination is possible, right now
        //the probability of getting 6 epidemics is > 0 which is shouldn't
        //be because there are only ever 5 in the deck.
        let epidemic = cards.filter { $0 == .epidemic }
        if epidemic.count > 1
        {
            if probability(ofDrawing: .epidemic) == 1
            {
                //Checking to see that all cards are in the deck
                let newCards = cards.filter { $0 != .epidemic } + [.epidemic]
                if newCards.reduce(true,
                                { result, card -> Bool in
                                    return result && deck.contains(card)
                })
                {
                    let prob = newCards.reduce(1)
                    { result, card -> Double in
                        result * probability(ofDrawing: card, inNext: draws)
                    }
                    return prob
                }
                else
                {
                    return 0
                }
            }
            else
            {
                return 0
            }
        }
        else
        {
            //Checking to see that all cards are in the deck
            if cards.reduce(true,
                            { result, card -> Bool in
                                return result && deck.contains(card)
            })
            {
                let prob = cards.reduce(1)
                { result, card -> Double in
                    result * probability(ofDrawing: card, inNext: draws)
                }
                return prob
            }
            else
            {
                return 0
            }
        }
    }
    
    func drawFromBottom() throws -> (deck: Deck, card: Card) {
        let (newDeck, card) = try self.deck.drawFromBottom()
        return (PlayerDeck(deck: newDeck, discardPile: self.discardPile), card)
    }
    
    /**
     Generates the 5 shuffled sections of the deck that each contain an
     epidemic.
     - Parameters:
        - deck: a list of cards that will be included in the game
     - Returns: A list of 5 list of cards each shuffled containing 1 epidemic.
    */
    private static func generatePartitionedEpidemicDecks(from deck: [Card]) -> [[Card]]
    {
        //Initialize five empty piles.
        var piles = (0..<5).map{ _ in [Card]() }
        //The current pile is 0.
        var currentPile = 0
        //Iterate over all city cards and add them to a pile.
        deck.forEach
        { card in
            piles[currentPile].append(card)
            currentPile = (currentPile + 1) % piles.count
        }
        //Add an epidemic to each pile and shuffle it.
        (0..<piles.count).forEach
        { index in
            piles[index].append(.epidemic)
            piles[index] = piles[index].shuffled()
        }
        return piles
    }
    
    func add(cards: [Card]) -> Deck {
        //Do nothing because it is not allowed
        return self
    }
    
    func clearDiscardPile() -> Deck {
        return PlayerDeck(deck: deck, discardPile: [])
    }
    
    func shuffled() -> Deck
    {
        //This is going to require switching over to the partition deck
        return self
    }
}

struct InfectionPile: Deck
{
    var count: Int
    {
       return deck.count
    }
    
    private let deck: ImmutableProbabilityDeck
    let discardPile: [Card]
    
    /**
     With the discard pile it always has the same cards to start.
    */
    init() {
        deck = ImmutablePartition(piles: [GameStartHelper.generateCityCards()])
        discardPile = []
    }
    
    private init(partitionDeck: ImmutableProbabilityDeck, discardPile: [Card])
    {
        self.deck = partitionDeck
        self.discardPile = discardPile
    }
    
    func drawCards(numberOfCards: Int) throws -> (deck: Deck, cards: [Card]) {
        let deckResult = try deck.draw(numberOfCards: numberOfCards)
        return (InfectionPile(partitionDeck: deckResult.deck, discardPile: discardPile), deckResult.cards)
    }

    func discard(card: Card) throws -> Deck
    {
        return try self.discard(cards: [card])
    }
    
    func discard(cards: [Card]) throws -> Deck {
        return InfectionPile(partitionDeck: deck, discardPile: discardPile + cards)
    }

    func probability(ofDrawing card: Card) -> Double {
        return deck.probability(ofDrawing: card)
    }

    func probability(ofDrawing card: Card, inNext draws: Int) -> Double {
        return deck.probability(ofDrawing: card, inNext: draws)
    }

    func probability(ofDrawing cards: [Card], inNext draws: Int) -> Double {
        return deck.probability(ofDrawing: cards, inNext: draws)
    }

    func add(cards: [Card]) -> Deck
    {
        return InfectionPile(partitionDeck: deck.add(cards: cards), discardPile: discardPile)
    }
    
    func drawFromBottom() throws -> (deck: Deck, card: Card)
    {
        let drawResult = try deck.drawFromBottom()
        return (InfectionPile(partitionDeck: drawResult.deck, discardPile: discardPile), drawResult.card)
    }
    
    func clearDiscardPile() -> Deck {
        return InfectionPile(partitionDeck: self.deck, discardPile: [])
    }
    
    func shuffled() -> Deck
    {
        return InfectionPile(partitionDeck: deck.shuffled(), discardPile: discardPile)
    }
}

protocol ImmutableProbabilityDeck
{
    var count: Int { get }
    /**
     Draw and remove a card from the top of the deck.
     - Parameters:
        -numberOfCards: the number of cards to be drawn
     - Returns: the updated probability deck with the cards removed, the cards that we removed.
     */
    func draw(numberOfCards: Int) throws -> (deck: ImmutableProbabilityDeck, cards: [Card])
    
    /**
     Returns the probability of drawing the given card.
     - Parameters:
        -card: the card that is the subject of the probabilistic query.
     */
    func probability(ofDrawing card: Card) -> Double
    
    /**
     Returns the probability of drawing the given card in the next given number
     of draws.
     - Parameters:
         -card: the card that is the subject of the probabilistic query.
         -draws: the number of trials for drawing the card.
     */
    func probability(ofDrawing card: Card, inNext draws: Int) -> Double
    
    /**
     Returns the probability of drawing the given list of cards in the next
     given number of draws.
     - Parameters:
         -cards: a list of cards that are the subject of the probabilisitc query.
         -draws: the number of trials for drawing the list of cards
     */
    func probability(ofDrawing cards: [Card], inNext draws: Int) -> Double
    
    /**
     Adds the given cards to the top of the deck.
     - Parameters:
        - cards: the cards being added to the top of th dcek.
     */
    func add(cards: [Card]) -> ImmutableProbabilityDeck
    
    /**
     Draws a card from the bottom of the deck.
     - Returns: the card at the bottom of the deck.
     */
    func drawFromBottom() throws -> (deck: ImmutableProbabilityDeck, card: Card)
    
    /**
     Returns a deck with all of the same cards as the current deck in a random
     different order preserving the cards in each pile.
     - Returns: a deck containing the same cards in a random new order preserving cards in each pile.
     */
    func shuffled() -> ImmutableProbabilityDeck
    
    /**
     Returns a deck with all of the same cards as the current deck but in a random new
     order not keeping cards in the correct pile but ensuring that there is an epidemic
     per pile.
    */
    func superShuffle() -> ImmutableProbabilityDeck
    
    func contains(_ element: Card) -> Bool
}

/**
 Class to handle the partitioned aspect of the infection pile.
 */
struct ImmutablePartition: ImmutableProbabilityDeck
{
    private var deck: [[Card]]
    
    init(piles: [[Card]]) {
        deck = piles
    }
    
    var count: Int
    {
        return deck.reduce(0) { $0 + $1.count }
    }
    
    func draw(numberOfCards: Int) throws -> (deck: ImmutableProbabilityDeck, cards: [Card]) {
        let newDeckComponents = try self.getCardsAndKeptArrays(numberOfCards: numberOfCards)
        return (ImmutablePartition(piles: newDeckComponents.deckRemaining), newDeckComponents.drawnCards)
    }
    
    func add(cards: [Card]) -> ImmutableProbabilityDeck {
        return ImmutablePartition(piles: [cards] + deck)
    }
    
    func drawFromBottom() throws -> (deck: ImmutableProbabilityDeck, card: Card) {
        //TODO: this throws an exception when there are no more cards left in the deck.
        if deck.isEmpty
        {
            throw DeckError.invalidDraw
        }
        let untouchedDecks = Array(deck[0..<(deck.count - 1)])
        let lastDeck = deck[deck.count - 1]
        guard let card = lastDeck.last else
        {
            throw DeckError.invalidDraw
        }
        let newLastDeck = Array(lastDeck[0..<(lastDeck.count - 1)])
        if !lastDeck.isEmpty
        {
            return (ImmutablePartition(piles: untouchedDecks + [newLastDeck]), card)
        }
        else
        {
            return (ImmutablePartition(piles: untouchedDecks), card)
        }
    }
    
    /**
     If the card is not in the top deck then the probability is zero.
     */
    func probability(ofDrawing card: Card) -> Double
    {
        if let deck = deck.first, deck.contains(card)
        {
            return 1 / Double(deck.count)
        }
        return 0
    }
    
    func probability(ofDrawing card: Card, inNext draws: Int) -> Double
    {
        let (guaranteed, probable) = topCardPiles(numberOfCards: draws)
        if guaranteed.contains(card)
        {
            return 1
        }
        else if probable.contains(card)
        {
            return pow(1 / Double(probable.count), Double(draws - guaranteed.count))
        }
        else
        {
            return 0
        }
    }
    
    func probability(ofDrawing cards: [Card], inNext draws: Int) -> Double
    {
        if (cards.count > draws)
        {
            return 0
        }
        let (guaranteed, probable) = topCardPiles(numberOfCards: draws)
        var probability: Double = 1
        let nonGuaranteedCards = cards.filter{!guaranteed.contains($0)}
        if guaranteed.count + nonGuaranteedCards.count > draws
        {
            return 0
        }
        cards.forEach
            { card in
                if !guaranteed.contains(card) && !probable.contains(card)
                {
                    //Allows for escaping early if it gets zeroed out.
                    probability = 0
                    return
                }
                else if probable.contains(card)
                {
                    probability = probability * pow(1 / Double(probable.count), Double(draws - guaranteed.count))
                }
        }
        return probability
    }
    
    func shuffled() -> ImmutableProbabilityDeck
    {
        let newDeck = self.deck.map
        { cardList -> [Card] in
            cardList.shuffled()
        }
        return ImmutablePartition(piles: newDeck)
    }
    
    func superShuffle() -> ImmutableProbabilityDeck
    {
        var allPlayerCards = deck.reduce([]) { $0 + $1 }.filter
        { card -> Bool in
            switch card
            {
                case .cityCard:
                    return true
                case .epidemic:
                    return false
            }
        }
        allPlayerCards.shuffle()
        let newDeck = deck.map
        { cards -> [Card] in
            let numCityCards = cards.contains(.epidemic) ? cards.count - 1 : cards.count
            let newCards = (Array(allPlayerCards[0..<numCityCards]) + (cards.contains(.epidemic) ? [.epidemic] : [])).shuffled()
            allPlayerCards = Array(allPlayerCards[numCityCards...])
            return newCards
        }
        return ImmutablePartition(piles: newDeck)
    }
    
    func contains(_ element: Card) -> Bool
    {
        return deck.reduce(false,
        { result, list -> Bool in
            result || list.contains(element)
        })
    }
    
    /**
     Gets a list of cards that will be drawn for sure and a list of cards that might be drawn.
     - Parameters:
     - numberOfCards: the number of cards that are going to be drawn
     - Returns: a tuple with the cards that will definitely be drawn and the cards that might be drawn.
     */
    private func topCardPiles(numberOfCards: Int) -> (guaranteed: [Card], probabilistic: [Card])
    {
        //Initializing the list of piles to an empty array.
        var piles = [[Card]]()
        //Keeping track of the total cards in all the piles combined.
        var count = 0
        deck.forEach
            { pile in
                if count < numberOfCards
                {
                    piles.append(pile)
                    count += pile.count
                }
        }
        let last = piles.removeLast()
        let first = piles.reduce([]) { result, pile -> [Card] in return result + pile }
        if first.isEmpty && last.count == numberOfCards
        {
            return (last, first)
        }
        else
        {
            return (first, last)
        }
    }
    
    /**
     Gets the deck after removing the given number of cards and an array with those cards.
     - Parameters:
        - numberOfCards: the number of cards to be drawn from the deck
     - Returns: a tuple with the deck after removing the cards and the cards that were removed from the deck.
    */
    private func getCardsAndKeptArrays(numberOfCards: Int) throws -> (deckRemaining: [[Card]], drawnCards: [Card])
    {
        var deckIndex = 0
        var cardsLeft = numberOfCards
        var drawnCards = [Card]()
        var deckRemaining = [[Card]]()
        while cardsLeft > 0
        {
            guard deckIndex < deck.count else
            {
                throw DeckError.invalidDraw
            }
            
            let resultTuple = getNextFromArray(section: deck[deckIndex], numberOfCards: cardsLeft)
            drawnCards.append(contentsOf: resultTuple.usedDeck)
            cardsLeft = cardsLeft - resultTuple.usedDeck.count
            if cardsLeft == 0
            {
                deckRemaining.append(contentsOf: Array(deck[(deckIndex + 1)..<deck.count]))
                if !resultTuple.remainingDeck.isEmpty
                {
                    deckRemaining = [resultTuple.remainingDeck] + deckRemaining
                }
            }
            deckIndex += 1
        }
        return (deckRemaining, drawnCards)
    }
    
    /**
     Gets as many cards from the given array of cards as it can and returns the cards it got, the amount it couldn't supply,
     and any leftover cards.
     - Parameters:
        - section: the array of cards that is being drawn from.
        -numberOfCards: the number of cards to be taken from the deck.
     - Returns: the top cards from the deck, any cards that are remaining in the deck, and the number leftover from the request.
    */
    private func getNextFromArray(section: [Card], numberOfCards: Int) -> (usedDeck: [Card], remainingDeck: [Card], leftOver: Int)
    {
        if section.count <= numberOfCards
        {
            return (section, [], numberOfCards - section.count)
        }
        else
        {
            return (Array(section[0..<numberOfCards]), Array(section[numberOfCards..<section.count]), section.count - numberOfCards)
        }
    }
}
