//
//  PlayerCard.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

/**
    There are 4 colors of cards in the game, each representing a different disease.
 */
enum DiseaseColor: CaseIterable
{
    case red, black, blue, yellow
}

/**
    There are finite number of cities in the game
 */
enum CityName: CaseIterable
{
    case atlanta
}

/**
    A city represents a unique location which is attached to cards and locations on the board. Each
    city has a color and a name associated with it.
 */
struct City
{
    ///The color of the city
    let color: DiseaseColor
    ///The name of the city
    let name: CityName
}

/**
    Every playing card has one attribute, the city that it is associated with
 */
protocol CityCardProtocol
{
    ///The city that the card is associated with
    var city: City { get }
}

struct CityCard
{
    let city: City
}

/**
    A card can either be a city card or it can be an epidemic
 */
enum Card
{
    case cityCard(card: CityCard)
    case epidemic
}
