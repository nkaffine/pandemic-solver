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
        let deck = PartitionedDeck(piles: cards)
        let startProb = deck.probability(ofDrawing: .epidemic)
        XCTAssertEqual(deck.draw(numberOfCards: 1).first, Card.epidemic)
        XCTAssertEqual(deck.draw(numberOfCards: 1).first, cityCards[0])
        XCTAssertNil(deck.draw(numberOfCards: 1).first)
        let endProb = deck.probability(ofDrawing: .epidemic)
        XCTAssertTrue(endProb < startProb)
        
        let deck2 = PartitionedDeck(piles: [[.epidemic]])
        XCTAssertEqual(deck2.draw(numberOfCards: 2).count, 1)
    }
    
    func testProbabilityOfCard()
    {
        let cityCards = GameStartHelper.generateCityCards()
        let cards: [[Card]] = [[.epidemic], [cityCards[0]]]
        let deck = PartitionedDeck(piles: cards)
        
        XCTAssertEqual(deck.probability(ofDrawing: .epidemic), 1)
        XCTAssertEqual(deck.probability(ofDrawing: cityCards[0]), 0)
    }
    
    func testProbabilityOfCardMultipleDraws()
    {
        let cityCards = GameStartHelper.generateCityCards()
        let cards: [[Card]] = [[.epidemic], [cityCards[0]]]
        let deck = PartitionedDeck(piles: cards)
        
        XCTAssertEqual(deck.probability(ofDrawing: .epidemic, inNext: 2), 1)
        XCTAssertEqual(deck.probability(ofDrawing: cityCards[0], inNext: 2), 1)
        
        let cards2: [[Card]] = [[.epidemic, cityCards[0]], [.epidemic, cityCards[1], cityCards[2]]]
        let deck2 = PartitionedDeck(piles: cards2)
        
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
        let deck = PartitionedDeck(piles: cards)
        
        XCTAssertEqual(deck.probability(ofDrawing: [.epidemic, cityCards[0]], inNext: 2), 1)
        XCTAssertEqual(deck.probability(ofDrawing: [.epidemic, cityCards[0]], inNext: 1), 0)
        XCTAssertEqual(deck.probability(ofDrawing: [.epidemic], inNext: 2), 1)
        
        let cards2: [[Card]] = [[.epidemic, cityCards[0]], [cityCards[1], cityCards[2], cityCards[3]]]
        let deck2 = PartitionedDeck(piles: cards2)
        
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
        let deck = PartitionedDeck(piles: cards)
        
        XCTAssertEqual(deck.probability(ofDrawing: cityCards[0]), 1 / Double(cityCards.count))
        XCTAssertEqual(deck.probability(ofDrawing: cityCards[0], inNext: 2), pow(1 / Double(cityCards.count), 2))
        XCTAssertEqual(deck.probability(ofDrawing: [cityCards[0], cityCards[1]], inNext: 3),
                       pow(1 / Double(cityCards.count), 3) * pow(1 / Double(cityCards.count), 3))
    }
    
    func testAddingCards()
    {
        let deck = PartitionedDeck(piles: [])
        XCTAssertNil(deck.draw(numberOfCards: 1).first)
        
        deck.add(cards: [.epidemic])
        XCTAssertEqual(deck.draw(numberOfCards: 1).first, .epidemic)
    }
}
