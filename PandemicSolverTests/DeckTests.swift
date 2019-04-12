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
        let epidemics = drawn?.cards.filter { $0 == .epidemic }
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
        //TODO: fix this
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
