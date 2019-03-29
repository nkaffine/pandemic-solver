//
//  Hand.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

protocol HandDelegate
{
    func didGoOverHandLimit()
}

/**
 Protocol to represent the hand of a player.
 */
protocol HandProtocol
{
    /**
     The delegate that will be notified when the player needs to discard a card.
    */
    var delegate: HandDelegate? { get set }
    /**
     The cards currently in this hand.
     */
    var cards: [Card] { get }
    /**
     Adds the given card to this hand.
     - Parameters:
        - card: the card to add to this hand.
     */
    func draw(card: Card)
    /**
     Adds the given cards to this hand.
     - Parameters:
        - cards: the cards to add to this hand.
     */
    func draw(cards: [Card])
    /**
     Removes the given card from this hand.
     - Parameters:
        - card : the card being removed from this hand.
     */
    func discard(card: Card)
    /**
     Removes the given cards from this hand.
     - Parameters:
        - card : the cards being removed from this hand.
     */
    func discard(cards: [Card])
}

class Hand: HandProtocol
{
    var delegate: HandDelegate?
    var cards: [Card]
    init() {
        self.cards = []
    }
    
    func draw(card: Card)
    {
        self.cards.append(card)
        checkHandLimit()
    }
    
    func draw(cards: [Card])
    {
        self.cards.append(contentsOf: cards)
        checkHandLimit()
    }
    
    func discard(card: Card)
    {
        discard(cards: [card])
    }
    
    func discard(cards: [Card])
    {
        self.cards.removeAll
        { card -> Bool in
            cards.contains(card)
        }
    }
    
    private func checkHandLimit()
    {
        if self.cards.count > 7
        {
            delegate?.didGoOverHandLimit()
        }
    }
}
