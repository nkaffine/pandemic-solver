//
//  HandTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 4/1/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class HandTests: XCTestCase {
    var sut: Hand!
    
    override func setUp() {
        sut = Hand()
    }
    
    func testAddingCardToHand()
    {
        let cityCard = Card(cityName: .atlanta)
        let (atHandLimit, hand1) = sut.draw(card: cityCard)
        XCTAssertFalse(atHandLimit)
        XCTAssertEqual(hand1.cards, [cityCard])
        var hand = hand1
        var atLimit = atHandLimit
        
        (0..<6).forEach
        { index in
            (atLimit, hand) = hand.draw(card: cityCard)
        }
        XCTAssertFalse(atLimit)
        XCTAssertEqual(hand.cards, [cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard])
        
        (atLimit, hand) = hand.draw(card: cityCard)
        XCTAssertTrue(atLimit)
        XCTAssertEqual(hand.cards, [cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard])
    }
    
    func testAddingMultipleCards()
    {
        let cityCard = Card(cityName: .atlanta)
        var (atHandLimit, hand) = sut.draw(cards: [cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard])
        XCTAssertFalse(atHandLimit)
        XCTAssertEqual(hand.cards, [cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard])
        
        (atHandLimit, hand) = hand.draw(cards: [cityCard, cityCard, cityCard])
        XCTAssertTrue(atHandLimit)
        XCTAssertEqual(hand.cards, [cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard, cityCard])
    }
    
    func testRemovingCard()
    {
        let cityCards = GameStartHelper.generateCityCards()
        let cards = Array(cityCards[0..<8])
        var (atHandLimit, hand) = sut.draw(cards: cards)
        XCTAssertTrue(atHandLimit)
        XCTAssertEqual(hand.cards, cards)
        
        (atHandLimit, hand) = hand.discard(card: cards[0])
        XCTAssertFalse(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cards[1..<cards.count]))
        
        (atHandLimit, hand) = sut.draw(cards: Array(cityCards[0..<9]))
        XCTAssertTrue(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cityCards[0..<9]))
        
        (atHandLimit, hand) = hand.discard(card: cityCards[0])
        XCTAssertTrue(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cityCards[1..<9]))
        
        (atHandLimit, hand) = hand.discard(card: .epidemic)
        XCTAssertTrue(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cityCards[1..<9]))
    }
    
    func testRemovingMutlipleCards()
    {
        XCTAssertFalse(sut.discard(cards: [.epidemic]).0)
        XCTAssertEqual(sut.discard(cards: [.epidemic]).1.cards, [Card]())
        
        let cityCards = GameStartHelper.generateCityCards()
        var (atHandLimit, hand) = sut.draw(cards: Array(cityCards[0..<9]))
        XCTAssertTrue(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cityCards[0..<9]))
        
        (atHandLimit, hand) = hand.discard(cards: Array(cityCards[0..<2]))
        XCTAssertFalse(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cityCards[2..<9]))
        
        (atHandLimit, hand) = hand.discard(cards: [.epidemic, .epidemic])
        XCTAssertFalse(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cityCards[2..<9]))
        
        (atHandLimit, hand) = sut.draw(cards: Array(cityCards[0..<9]))
        XCTAssertTrue(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cityCards[0..<9]))
        
        (atHandLimit, hand) = hand.discard(cards: [cityCards[0], .epidemic])
        XCTAssertTrue(atHandLimit)
        XCTAssertEqual(hand.cards, Array(cityCards[1..<9]))
    }
}

