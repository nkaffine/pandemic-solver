//
//  Hand.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

/**
 Enum for all of the errors that could occur from interacting with a hand.
 */
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
