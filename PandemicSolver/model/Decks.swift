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
    func drawCards(numberOfCards: Int) throws -> [Card]
    /**
     Adds the given card to the discard pile of this deck.
     - Parameters:
        - card: the card to be added to the discard pile.
     - Throws: `DeckError.invalidDiscard` when the card is in the discard pile or still in the deck.
    */
    func discard(card: Card) throws
    /**
     Adds the given cards to the dicard pile of this deck in order where the last item will be at the top of the
     discard pile.
     - Parameters:
        - cards: the cards to be added to the discard pile of this deck
     - Throws: `DeckError.invalidDiscard` when one or more cards is in the discard pile or still in the deck.
     */
    func discard(cards: [Card]) throws
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
}

/**
 The deck that players draw cards from.
 */
class PlayerDeck: Deck
{
    /**
     The deck of cards that the players draw from.
     Note: The deck is stored where the last index is the top of the deck.
    */
    private var deck: [Card]
    var discardPile: [Card]
    var count: Int
    {
        return deck.count
    }
    
    init(deck: [Card])
    {
        //Generate all the cards for the deck without epidemics
        self.deck = PlayerDeck.generatePartitionedEpidemicDecks(from: deck).reduce([], { $0 + $1 })
        self.discardPile = []
    }
    
    func drawCards(numberOfCards: Int) throws -> [Card] {
        return try (0..<numberOfCards).reduce([])
        { result, _ -> [Card] in
            if let card = deck.popLast()
            {
                return result + [card]
            }
            else
            {
                throw DeckError.invalidDraw
            }
        }
    }
    
    func discard(card: Card) throws {
        try discard(cards: [card])
    }
    
    func discard(cards: [Card]) throws {
        //TODO: Maybe check to see if the cards they are discarding are valid
        //but for now for performance reasons I am going to just move them to the discard pile.
        //Another option would be to keep track of the cards that are neither in the
        //player deck or the discard pile but that might get complicated.
        discardPile.append(contentsOf: cards)
    }
    
    //TODO: The probability of the epidemic can be more detailed
    //such that it is dependent on the current pile being drawn from.
    func probability(ofDrawing card: Card) -> Double {
        guard !discardPile.contains(card) else
        {
            return 0
        }
        let cards = deck.filter { $0 == card }
        return Double(cards.count) / Double(deck.count)
    }
    
    func probability(ofDrawing card: Card, inNext draws: Int) -> Double {
        //Get the probability of drawing the card.
        let probOfDrawing = probability(ofDrawing: card)
        //Get the probability of not drawing the card.
        let probOfNotDrawing = 1 - probOfDrawing
        //Get the probability of now drawing the card in the next x turns.
        let probOfNotDrawingInTurns = pow(probOfNotDrawing, Double(draws))
        //Return 1 - probability of not drawing in next x turns.
        return 1 - probOfNotDrawingInTurns
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
        let prob = cards.reduce(1)
        { result, card -> Double in
            result * probability(ofDrawing: card, inNext: draws)
        }
        return prob
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
}

class InfectionPile: Deck
{
    var count: Int
    {
       return deck.count
    }
    
    //TODO: Create a better datastructure for this
    private var deck: PartitionedDeck
    var discardPile: [Card]
    
    /**
     With the discard pile it always has the same cards to start.
    */
    init() {
        deck = PartitionedDeck(piles: [GameStartHelper.generateCityCards()])
        discardPile = []
    }

    func drawCards(numberOfCards: Int) throws -> [Card] {
        let cards = deck.draw(numberOfCards: numberOfCards)
        if cards.count < numberOfCards
        {
            throw DeckError.invalidDraw
        }
        return cards
    }

    func discard(card: Card) throws {
        discardPile.append(card)
    }

    func discard(cards: [Card]) throws {
        discardPile.append(contentsOf: cards)
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

    func addCards(cards: [Card])
    {
        deck.add(cards: cards)
    }
}

protocol ProbabilityDeck
{
    /**
     Draw and remove a card from the top of the deck.
     - Parameters:
        -numberOfCards: the number of cards to be drawn
    */
    func draw(numberOfCards: Int) -> [Card]
    
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
    func add(cards: [Card])
 }

/**
 Class to handle the paritioned aspect of the infection pile.
 - Note: This class does not handle duplicate cards since it is not something
 that can happen in the infection pile.
 */
class PartitionedDeck: ProbabilityDeck
{
    private var deck: [[Card]]
    
    init(piles: [[Card]]) {
        deck = piles
    }
    
    var count: Int
    {
        return deck.reduce(0) { $0 + $1.count }
    }
    
    /**
     Draws the given number of cards from the top of the deck.
     - Parameters:
        -numberOfCards: the number of cards to be drawn
    */
    func draw(numberOfCards: Int) -> [Card]
    {
        return (0..<numberOfCards).compactMap { _ -> Card? in return removeOne() }
            .reduce([]){ result, card -> [Card] in return result + [card] }
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
    
    func add(cards: [Card]) {
        deck = [cards] + deck
    }
    
    /**
     Removes the first card of the deck and remeoves the first list if thee first list is empty.
     - Returns: the first card of the deck if there is one.
    */
    private func removeOne() -> Card?
    {
        if deck.count > 0
        {
            let card = deck[0].removeFirst()
            if deck[0].isEmpty
            {
                deck.removeFirst()
            }
            return card
        }
        return nil
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
}
