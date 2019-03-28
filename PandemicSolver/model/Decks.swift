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
    //TODO: Create a better datastructure for this
    private var deck: [[Card]]
    var discardPile: [Card]
    
    /**
     With the discard pile it always has the same cards to start.
    */
    init() {
        deck = [GameStartHelper.generateCityCards()]
    }

    func drawCards(numberOfCards: Int) throws -> [Card] {
        //Set up local variable for cards
        var cards = [Card]()
        //Get the first pile to start pulling from
        var currentPile = self.deck.first
        //Iterate while there are still cards left in the deck
        //and the right number of cards haven't been drawn
        while cards.count < numberOfCards && currentPile != nil
        {
            if let card = currentPile?.first
            {
                cards.append(card)
            }
            if currentPile?.isEmpty ?? false
            {
                self.deck.removeLast()
                currentPile = self.deck.first
            }
        }
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
        let totalCards = deck.reduce([]){ $0 + $1 }
        return Double(totalCards.filter{ deckCard in card == deckCard }.count) / Double(totalCards.count)
    }

    func probability(ofDrawing card: Card, inNext draws: Int) -> Double {
        //TODO: actually do it
        return 0
    }

    func probability(ofDrawing cards: [Card], inNext draws: Int) -> Double {
        //TODO: actually do it
        return 0
    }


}
