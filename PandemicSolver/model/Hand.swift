//
//  Hand.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

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
     Adds the given card to this hand and returns whether the hand is over hand limit.
     - Parameters:
        - card: the card to add to this hand.
     - Returns: A tuple of wether the hand went over hand limit and the new hand.
     */
    func draw(card: Card) -> (Bool, HandProtocol)
    /**
     Adds the given cards to this hand and returns whether the hand is over hand limit.
     - Parameters:
        - cards: the cards to add to this hand.
     - Returns: A tuple of wether the hand is over hand limit and returns the new hand.
     */
    func draw(cards: [Card]) -> (Bool, HandProtocol)
    /**
     Removes the given card from this hand.
     - Parameters:
        - card : the card being removed from this hand.
     - Returns: The new hand.
     */
    func discard(card: Card) -> (Bool, HandProtocol)
    /**
     Removes the given cards from this hand.
     - Parameters:
        - card : the cards being removed from this hand.
     - Returns: The new hand.
     */
    func discard(cards: [Card]) -> (Bool, HandProtocol)
}

struct Hand: HandProtocol
{
    let cards: [Card]
    var atHandLimit: Bool
    {
        return cards.count > 7
    }
    
    init(card1: Card, card2: Card)
    {
        self.cards = [card1, card2]
    }
    
    init() {
        self.cards = []
    }
    
    private init(cards: [Card])
    {
        self.cards = cards
    }
    
    func draw(card: Card) -> (Bool, HandProtocol)
    {
        let newHand = Hand(cards: cards + [card])
        return (newHand.atHandLimit, newHand)
    }
    
    func draw(cards: [Card]) -> (Bool, HandProtocol)
    {
        let newHand = Hand(cards: self.cards + cards)
        return (newHand.atHandLimit, newHand)
    }
    
    func discard(card: Card) -> (Bool, HandProtocol)
    {
        let newHand = Hand(cards: cards.filter { $0 != card })
        return (newHand.atHandLimit, newHand)
    }
    
    func discard(cards: [Card]) -> (Bool, HandProtocol)
    {
        let newHand = Hand(cards: self.cards.filter{ !cards.contains($0) })
        return (newHand.atHandLimit, newHand)
    }
}
