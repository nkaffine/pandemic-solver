//
//  PartitionedDeckTests.swift
//  PandemicSolverTests
//
//  Created by Nicholas Kaffine on 3/28/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import XCTest
@testable import PandemicSolver

class PartitionedDeckTests: XCTestCase
{
    func testDrawingCards()
    {
        let cityCards = GameStartHelper.generateCityCards()
        let cards: [[Card]] = [[.epidemic], [cityCards[0]]]
        let deck = ImmutablePartition(piles: cards)
        let startProb = deck.probability(ofDrawing: .epidemic)
        
        //Draw the first card
        let drawResult1 = (try? deck.draw(numberOfCards: 1))!
        let deck1 = drawResult1.deck
        let cards1 = drawResult1.cards
        XCTAssertEqual(cards1.first, Card.epidemic)
        
        //Draw the second card
        let drawResult2 = (try? deck1.draw(numberOfCards: 1))!
        let deck2 = drawResult2.deck
        let cards2 = drawResult2.cards
        XCTAssertEqual(cards2.first, cityCards[0])
        
        //Check to see an error occurs because there are no cards
        XCTAssertNil((try? deck2.draw(numberOfCards: 1)))
        
        //Check probability of drawing epidemic now
        let endProb = deck2.probability(ofDrawing: .epidemic)
        XCTAssertTrue(endProb < startProb)
        
        //Check an error occurs when drawing more than the capacity.
        let deck3 = ImmutablePartition(piles: [[.epidemic]])
        XCTAssertNil(try? deck3.draw(numberOfCards: 2))
    }
    
    func testProbabilityOfCard()
    {
        let cityCards = GameStartHelper.generateCityCards()
        let cards: [[Card]] = [[.epidemic], [cityCards[0]]]
        let deck = ImmutablePartition(piles: cards)
        
        XCTAssertEqual(deck.probability(ofDrawing: .epidemic), 1)
        XCTAssertEqual(deck.probability(ofDrawing: cityCards[0]), 0)
    }
    
    func testProbabilityOfCardMultipleDraws()
    {
        let cityCards = GameStartHelper.generateCityCards()
        let cards: [[Card]] = [[.epidemic], [cityCards[0]]]
        let deck = ImmutablePartition(piles: cards)
        
        XCTAssertEqual(deck.probability(ofDrawing: .epidemic, inNext: 2), 1)
        XCTAssertEqual(deck.probability(ofDrawing: cityCards[0], inNext: 2), 1)
        
        let cards2: [[Card]] = [[.epidemic, cityCards[0]], [.epidemic, cityCards[1], cityCards[2]]]
        let deck2 = ImmutablePartition(piles: cards2)
        
        XCTAssertEqual(deck2.probability(ofDrawing: .epidemic, inNext: 2), 1)
        XCTAssertEqual(deck2.probability(ofDrawing: cityCards[0], inNext: 2), 1)
        XCTAssertEqual(deck2.probability(ofDrawing: cityCards[0], inNext: 1), 0.5)
        XCTAssertEqual(deck2.probability(ofDrawing: .epidemic, inNext: 1), 0.5)
        XCTAssertEqual(deck2.probability(ofDrawing: cityCards[1], inNext: 3), Double(1)/Double(3))
    }
    
    func testProbabilityOfMultiCardMultiDraw()
    {
        let cityCards = GameStartHelper.generateCityCards()
        let cards: [[Card]] = [[.epidemic], [cityCards[0]]]
        let deck = ImmutablePartition(piles: cards)
        
        XCTAssertEqual(deck.probability(ofDrawing: [.epidemic, cityCards[0]], inNext: 2), 1)
        XCTAssertEqual(deck.probability(ofDrawing: [.epidemic, cityCards[0]], inNext: 1), 0)
        XCTAssertEqual(deck.probability(ofDrawing: [.epidemic], inNext: 2), 1)
        
        let cards2: [[Card]] = [[.epidemic, cityCards[0]], [cityCards[1], cityCards[2], cityCards[3]]]
        let deck2 = ImmutablePartition(piles: cards2)
        
        XCTAssertEqual(deck2.probability(ofDrawing: [.epidemic, cityCards[0]], inNext: 2), 1)
        XCTAssertEqual(deck2.probability(ofDrawing: [cityCards[0], cityCards[1]], inNext: 2), 0)
        XCTAssertEqual(deck2.probability(ofDrawing: [cityCards[0], cityCards[1]], inNext: 3), Double(1)/Double(3))
        XCTAssertEqual(deck2.probability(ofDrawing: [cityCards[1], cityCards[2]], inNext: 3), 0)
        XCTAssertEqual(deck2.probability(ofDrawing: [cityCards[1], cityCards[2]], inNext: 4), Double(1)/Double(81))
    }
    
    func testStartOfGameProbabilities()
    {
        let cityCards = GameStartHelper.generateCityCards()
        let cards: [[Card]] = [cityCards]
        let deck = ImmutablePartition(piles: cards)
        
        XCTAssertEqual(deck.probability(ofDrawing: cityCards[0]), 1 / Double(cityCards.count))
        XCTAssertEqual(deck.probability(ofDrawing: cityCards[0], inNext: 2), pow(1 / Double(cityCards.count), 2))
        XCTAssertEqual(deck.probability(ofDrawing: [cityCards[0], cityCards[1]], inNext: 3),
                       pow(1 / Double(cityCards.count), 3) * pow(1 / Double(cityCards.count), 3))
    }
    
    func testAddingCards()
    {
        let deck = ImmutablePartition(piles: [])
        XCTAssertNil(try? deck.draw(numberOfCards: 1))
        
        let deck1 = deck.add(cards: [.epidemic])
        let deckResult = (try? deck1.draw(numberOfCards: 1))!
        XCTAssertEqual(deckResult.cards.first, .epidemic)
    }
}
