//
//  GameStartHelper.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

class GameStartHelper
{
    static func initialDiseaseCubeCount() -> [DiseaseColor:Int]
    {
        return DiseaseColor.allCases.reduce([:])
        { result, color -> [DiseaseColor:Int] in
            return (try? result + [color: 24]) ?? result
        }
    }
    
    static func selectPawns() -> [Pawn]
    {
        //TODO: Actually select pawns
        return []
    }
    
    /**
     Generates a lits of cards with one card per city name.
     - Returns: A list of cards containing one card per city name.
     */
    static func generateCityCards() -> [Card]
    {
        return CityName.allCases.map
            { cityName -> Card in
                return Card(cityName: cityName)
            }.shuffled()
    }
}
