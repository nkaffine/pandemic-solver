//
//  DeckTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/28/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class DeckTests: XCTestCase {
    func testBasicPartitioning()
    {
        var cards = GameStartHelper.generateCityCards()
        var removedCards = [Card]()
        (0..<8).forEach
        { _ in
            removedCards.append(cards.removeFirst())
        }
        let playerDeck = PlayerDeck(deck: cards)
        XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic), 1 / 9)
        XCTAssertEqual(playerDeck.probability(ofDrawing: removedCards.first!), 0)
    }
    
    func testSomePartitioning()
    {
        var cards = GameStartHelper.generateCityCards()
        var removedCards = [Card]()
        (0..<8).forEach
            { _ in
                removedCards.append(cards.removeFirst())
        }
        var playerDeck = PlayerDeck(deck: cards)
        
        var hasDrawnEpidemic = false
        var drawnCards: [Card] = []
        (0..<9).forEach
        { iteration in
            if !hasDrawnEpidemic
            {
                XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic), 1/Double((9 - iteration)))
            }
            else
            {
                XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic), 0)
            }
            (playerDeck, drawnCards) = try! playerDeck.drawCards(numberOfCards: 1) as! (PlayerDeck, [Card])
            if drawnCards.first! == .epidemic
            {
                hasDrawnEpidemic = true
            }
        }
    }
    
    func testPlayerDeckInit()
    {
        var cards = GameStartHelper.generateCityCards()
        (0..<8).forEach
        { _ in
            cards.removeFirst()
        }
        let playerDeck = PlayerDeck(deck: cards)
        XCTAssertEqual(playerDeck.discardPile, [])
        XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic), 5 / Double(cards.count + 5))
    }
    
    func testProbabilities()
    {
        var cards = GameStartHelper.generateCityCards()
        (0..<8).forEach
            { _ in
                cards.removeFirst()
        }
        let playerDeck = PlayerDeck(deck: cards)
        let probabilityOfEpidemicIn2Turns = 1 - pow(8 / Double(9), 2)
        XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic, inNext: 2), probabilityOfEpidemicIn2Turns)
        
        let probabilityOf1In2Turns = 1 - pow(Double(playerDeck.count - 1) / Double(playerDeck.count), 2)
        let cityCard = cards.first { card -> Bool in card != .epidemic }!
        XCTAssertEqual(playerDeck.probability(ofDrawing: cityCard, inNext: 2), probabilityOf1In2Turns)
        
        //Testing probability of getting an epidemic and a specific card on the next two draws
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, cityCard], inNext: 2), probabilityOfEpidemicIn2Turns * probabilityOf1In2Turns)
    }
    
    func testWhenProbabilityIsZero()
    {
        var cards = GameStartHelper.generateCityCards()
        var removedCards: [Card] = []
        (0..<8).forEach
        { _ in
            removedCards.append(cards.removeFirst())
        }
        let playerDeck = PlayerDeck(deck: cards)
        let cityCard = cards.filter { !removedCards.contains($0) }.randomElement()!
        
        let probabilityOfEpidemicIn2 = 1 - pow(8/Double(9), 2)
        let probabilityOfNormalCard = 1 - pow(44/Double(45), 2)
        
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, cityCard], inNext: 2),
                       probabilityOfNormalCard * probabilityOfEpidemicIn2)
        
        //Checking when there aren't that many epidemics
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, .epidemic, .epidemic, .epidemic, .epidemic, .epidemic],
                                              inNext: 6), 0)
        
        //Checking when the number of cards exceeds inNext
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, .epidemic], inNext: 1), 0)
    }
    
    func testProbabilityWhenDeckIsLow()
    {
        var cards = GameStartHelper.generateCityCards()
        var removedCards: [Card] = []
        (0..<8).forEach
            { _ in
                removedCards.append(cards.removeFirst())
        }
        var playerDeck = PlayerDeck(deck: cards)
        
        //This should draw all except the last cards
        var drawnCards = [Card]()
        (playerDeck, drawnCards) = try! playerDeck.drawCards(numberOfCards: 36) as! (PlayerDeck, [Card])
        
        let cityCard = cards.filter { !(removedCards.contains($0) || drawnCards.contains($0)) }.randomElement()!
        
        //There should be 9 cards left now
        let probabilityOfEpidemicAndCityCard = Double(1) - pow(8/9, 5)
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, cityCard], inNext: 5),
                       probabilityOfEpidemicAndCityCard * probabilityOfEpidemicAndCityCard)
    }
    
    func testEpidemicsSpreadOut()
    {
        var deck = GameStartHelper.generateCityCards()
        deck = [deck[0]] + [deck[1]] + [deck[2]] + [deck[3]] + [deck[4]]
        let playerDeck = PlayerDeck(deck: deck)
        (0..<5).forEach
        { _ in
            let cards = try? playerDeck.drawCards(numberOfCards: 2)
            XCTAssertEqual(cards!.cards.filter { $0 == .epidemic }.count, 1)
        }
    }
    
    func testDiscardCards()
    {
        let deck = GameStartHelper.generateCityCards()
        let playerDeck = PlayerDeck(deck: deck)
        let drawResult1 = try! playerDeck.drawCards(numberOfCards: 2)
        let cards1 = drawResult1.cards
        let deck2 = drawResult1.deck
        
        //Add to the discard pile and check its there
        let deck3 = (try? deck2.discard(cards: cards1))!
        XCTAssertEqual(deck3.discardPile.count, 2)
        cards1.forEach { card in XCTAssertTrue(deck3.discardPile.contains(card)) }
        
        //Testing adding just one cards
        let drawResult2 = (try? deck3.drawCards(numberOfCards: 1))!
        let card2 = drawResult2.cards.first!
        let deck4 = drawResult2.deck
        
        let deck5 = (try? deck4.discard(card: card2))!
        XCTAssertEqual(deck5.discardPile.count, 3)
        XCTAssertTrue(deck5.discardPile.contains(card2))
    }
    
    func testNormalInfectionFlow()
    {
        let population = GameStartHelper.generateCityCards()
        let infectionPile = InfectionPile()
        let (infectionPile1, cards1) = (try? infectionPile.drawCards(numberOfCards: 10))!
        let notSelectedCards = population.filter{!cards1.contains($0)}
        
        
        XCTAssertEqual(infectionPile1.probability(ofDrawing: notSelectedCards[0]), 1 / Double(notSelectedCards.count))
        XCTAssertEqual(infectionPile1.probability(ofDrawing: notSelectedCards[0], inNext: 2), pow(1 / Double(notSelectedCards.count), 2))
        XCTAssertEqual(infectionPile1.probability(ofDrawing: [notSelectedCards[0], notSelectedCards[1]], inNext: 2),
                       pow(pow(1 / Double(notSelectedCards.count), 2), 2))
        
        //Adding the drawn cards back to the infection pile
        let infectionPile2 = infectionPile1.add(cards: cards1)
        XCTAssertEqual(infectionPile2.probability(ofDrawing: notSelectedCards[0]), 0)
        XCTAssertEqual(infectionPile2.probability(ofDrawing: cards1[0], inNext: 2), 1/Double(100), accuracy: 0.001)
        XCTAssertEqual(infectionPile2.probability(ofDrawing: [cards1[0], cards1[1]], inNext: 2), 1/Double(10000), accuracy: 0.0001)
        XCTAssertEqual(infectionPile1.probability(ofDrawing: [cards1[0], notSelectedCards[0]], inNext: 2), 0)
        
        //Drawing all cards except 2 from top of the infection pile.
        let (infectionPile3, cards2) = (try? infectionPile2.drawCards(numberOfCards: 8))!
        let leftovers = cards1.filter{!cards2.contains($0)}
        XCTAssertEqual(infectionPile3.probability(ofDrawing: leftovers[0], inNext: 2), 1)
        XCTAssertEqual(infectionPile3.probability(ofDrawing: [leftovers[0], notSelectedCards[0]], inNext: 3), 1/Double(notSelectedCards.count))
    }
}
