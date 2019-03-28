//
//  City.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

/**
 There are finite number of cities in the game
 */
enum CityName: String, CaseIterable
{
    case sanFrancisco, chicago, toronto, newYork, losAngeles,
    atlanta, washington, mexicoCity, miami, bogota, lima, saoPaulo,
    santiago, buenosAres, london, essen, stPetersburg, madrid, paris, milan,
    algiers, istanbul, moscow, cairo, baghdad, tehran, riyadh, karachi, delhi,
    mumbai, kolkata, chennai, lagos, khartoum, kinshasa, johannesburg, beijing,
    seoul, shanghai, tokyo, hongKong, taipei, osaka, bangkok, hoChiMinhCity, manila,
    jakarta, sydney
    
    var color: DiseaseColor
    {
        switch self
        {
        case .sanFrancisco, .chicago, .toronto, .newYork, .atlanta,
             .washington, .london, .essen, .stPetersburg, .madrid, .paris, .milan:
            return .blue
        case .losAngeles, .mexicoCity, .miami, .bogota, .lima, .santiago, .buenosAres,
             .saoPaulo, .lagos, .khartoum, .kinshasa, .johannesburg:
            return .yellow
        case .algiers, .istanbul, .moscow, .cairo, .baghdad, .tehran, .riyadh,
             .karachi, .delhi, .mumbai, .kolkata, .chennai:
            return .black
        case .beijing, .seoul, .shanghai, .tokyo, .hongKong, .taipei, .osaka, .bangkok, .hoChiMinhCity, .manila, .jakarta, .sydney:
            return .red
        }
    }
}

/**
 A city represents a unique location which is attached to cards and locations on the board. Each
 city has a color and a name associated with it.
 */
struct City: Equatable
{
    ///The color of the city
    let color: DiseaseColor
    ///The name of the city
    let name: CityName
    
    init(name: CityName)
    {
        self.name = name
        self.color = name.color
    }
}
