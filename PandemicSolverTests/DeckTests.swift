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
    func testEmptyPartitioning()
    {
        let cityCard = CityCard(city: City(name: .atlanta))
        let deck = [Card]()
        let playerDeck = PlayerDeck(deck: deck)
        XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic), 1)
        XCTAssertEqual(playerDeck.probability(ofDrawing: .cityCard(card: cityCard)), 0)
    }
    
    func testSomePartitioning()
    {
        var deck = GameStartHelper.generateCityCards()
        deck = [deck[0]] + [deck[1]] + [deck[2]] + [deck[3]] + [deck[4]]
        let playerDeck = PlayerDeck(deck: deck)
        
        XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic), 0.5)
        XCTAssertEqual(playerDeck.probability(ofDrawing: deck.first!), 0.1)
        let drawn = try? playerDeck.drawCards(numberOfCards: 10)
        let epidemics = drawn?.filter { $0 == .epidemic }
        XCTAssertEqual(epidemics?.count, 5)
    }
    
    func testPlayerDeckInit()
    {
        let cards = GameStartHelper.generateCityCards()
        let playerDeck = PlayerDeck(deck: cards)
        XCTAssertEqual(playerDeck.discardPile, [])
        XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic), 5 / Double(cards.count + 5))
    }
    
    func testProbabilities()
    {
        let cards = GameStartHelper.generateCityCards()
        let playerDeck = PlayerDeck(deck: cards)
        let deckSize = cards.count + 5
        //TODO: this will need to be updated with the new epidemic probabilities
        //Currently 1 - deck-size/deck-size + epidemics ^ 2
        let probabilityOfEpidemicIn2Turns = 1 - pow(Double(cards.count) / Double(deckSize), 2)
        XCTAssertEqual(playerDeck.probability(ofDrawing: .epidemic, inNext: 2), probabilityOfEpidemicIn2Turns)
        
        //Testing regular card that only has one instance in deck
        //Currently 1 - deck-size + epidemics - 1/deck-size + epidemics
        let probabilityOf1In2Turns = 1 - pow(Double(deckSize - 1) / Double(deckSize), 2)
        let cityCard = Card.cityCard(card: CityCard(city: City(name: .algiers)))
        XCTAssertEqual(playerDeck.probability(ofDrawing: cityCard, inNext: 2), probabilityOf1In2Turns)
        
        //Testing probability of getting an epidemic and a specific card on the next two draws
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, cityCard], inNext: 2), probabilityOfEpidemicIn2Turns * probabilityOf1In2Turns)
    }
    
    func testWhenProbabilityIsZero()
    {
        let playerDeck = PlayerDeck(deck: [])
        let cityCard = Card.cityCard(card: CityCard(city: City(name: .algiers)))
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, cityCard], inNext: 2), 0)
        //Checking when there aren't that many epidemics
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, .epidemic, .epidemic, .epidemic, .epidemic, .epidemic],
                                              inNext: 6), 0)
        //Checking when the number of cards exceeds inNext
        XCTAssertEqual(playerDeck.probability(ofDrawing: [.epidemic, .epidemic], inNext: 1), 0)
        
        let playerDeck2 = PlayerDeck(deck: [cityCard])
        //Checking when the number of cards is less than the number of drwas
        //I think it should be 1 - 5/6^5 * 1 - 1/6 ^ 5
        let probabilityOfEpidemic = Double(1) - pow(5/6, 5)
        let probabilityOfCard = Double(1) - pow(1/6, 5)
        XCTAssertEqual(playerDeck2.probability(ofDrawing: [.epidemic, cityCard], inNext: 5), probabilityOfEpidemic * probabilityOfCard)
    }
    
    func testEpidemicsSpreadOut()
    {
        var deck = GameStartHelper.generateCityCards()
        deck = [deck[0]] + [deck[1]] + [deck[2]] + [deck[3]] + [deck[4]]
        let playerDeck = PlayerDeck(deck: deck)
        (0..<5).forEach
        { _ in
            let cards = try? playerDeck.drawCards(numberOfCards: 2)
            XCTAssertEqual(cards!.filter { $0 == .epidemic }.count, 1)
        }
    }
    
    func testDiscardCards()
    {
        let deck = GameStartHelper.generateCityCards()
        let playerDeck = PlayerDeck(deck: deck)
        let cards1 = try? playerDeck.drawCards(numberOfCards: 2)
        try? playerDeck.discard(cards: cards1!)
        XCTAssertEqual(playerDeck.discardPile.count, 2)
        cards1!.forEach{ card in XCTAssertTrue(playerDeck.discardPile.contains(card)) }
        
        let card2 = (try? playerDeck.drawCards(numberOfCards: 1))?.first
        try? playerDeck.discard(card: card2!)
        XCTAssertEqual(playerDeck.discardPile.count, 3)
        XCTAssertTrue(playerDeck.discardPile.contains(card2!))
    }
    
    func testNormalInfectionFlow()
    {
        let population = GameStartHelper.generateCityCards()
        let infectionPile = InfectionPile()
        let cards = (try? infectionPile.drawCards(numberOfCards: 10))!
        let notSelectedCards = population.filter{!cards.contains($0)}
        XCTAssertEqual(infectionPile.probability(ofDrawing: notSelectedCards[0]), 1 / Double(notSelectedCards.count))
        XCTAssertEqual(infectionPile.probability(ofDrawing: notSelectedCards[0], inNext: 2), pow(1 / Double(notSelectedCards.count), 2))
        XCTAssertEqual(infectionPile.probability(ofDrawing: [notSelectedCards[0], notSelectedCards[1]], inNext: 2),
                       pow(pow(1 / Double(notSelectedCards.count), 2), 2))
        infectionPile.addCards(cards: cards)
        XCTAssertEqual(infectionPile.probability(ofDrawing: notSelectedCards[0]), 0)
        XCTAssertEqual(infectionPile.probability(ofDrawing: cards[0], inNext: 2), 1/Double(100), accuracy: 0.001)
        XCTAssertEqual(infectionPile.probability(ofDrawing: [cards[0],cards[1]], inNext: 2), 1/Double(10000), accuracy: 0.0001)
        XCTAssertEqual(infectionPile.probability(ofDrawing: [cards[0], notSelectedCards[0]], inNext: 2), 0)
        
        let redrawn = (try? infectionPile.drawCards(numberOfCards: 8))!
        let leftovers = cards.filter{!redrawn.contains($0)}
        XCTAssertEqual(infectionPile.probability(ofDrawing: leftovers[0], inNext: 2), 1)
        XCTAssertEqual(infectionPile.probability(ofDrawing: [leftovers[0], notSelectedCards[0]], inNext: 3), 1/Double(notSelectedCards.count))
    }
}
