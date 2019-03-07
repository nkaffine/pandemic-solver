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

enum HandError: Error
{
    case invalidDraw, invalidDiscard
}

/**
    Protocol to represent the hand of a player.
 */
protocol HandProtocol
{
    /**
     The cards currently in this hand.
     */
    var cards: [Card] { get }
    /**
     Adds the given card to this hand.
     - Parameters:
        - card: the card to add to this hand.
     - Throws: `HandError.invalidDraw` when the hand is above handlimit or there is a duplicate card in the hand.
     */
    func draw(card: Card) throws
    /**
     Adds the given cards to this hand.
     - Parameters:
        - cards: the cards to add to this hand.
     - Throws: `HandError.invalidDraw` when the hand is above handlimit or there are any duplicates in the hand.
    */
    func draw(cards: [Card]) throws
    /**
     Removes the given card from this hand.
     - Parameters:
        - card : the card being removed from this hand.
     - Throws: `HandError.invalidDiscard` when the card is not in the hand.
     - Returns: the card that was removed from the hand.
     */
    func discard(card: Card) throws -> Card
    /**
     Removes the given cards from this hand.
     - Parameters:
        - card : the cards being removed from this hand.
     - Throws: `HandError.invalidDiscard` when any of the cards are not in the hand.
     - Returns: the cards that were removed from the hand.
     */
    func discard(cards: [Card]) throws -> [Card]
}
