//
//  PlayerCard.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/6/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

/**
    Every playing card has one attribute, the city that it is associated with
 */
protocol CityCardProtocol
{
    ///The city that the card is associated with
    var city: City { get }
}

struct CityCard: CityCardProtocol, Equatable, CustomStringConvertible
{
    var description: String
    {
        return city.name.rawValue
    }
    
    static func == (lhs: CityCard, rhs: CityCard) -> Bool {
        return lhs.city == rhs.city
    }
    
    let city: City
}

/**
    A card can either be a city card or it can be an epidemic
 */
enum Card: Equatable, CustomStringConvertible
{
    var description: String
    {
        switch self
        {
            case .epidemic:
                return "epidemic"
            case .cityCard(let card):
                return card.description
        }
    }
    case cityCard(card: CityCard)
    case epidemic
    
    init(cityName: CityName)
    {
        self = .cityCard(card: CityCard(city: City(name: cityName)))
    }
}
