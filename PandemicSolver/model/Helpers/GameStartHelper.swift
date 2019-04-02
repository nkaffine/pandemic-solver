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
        let availablePawns  = Role.allCases.map { role -> Pawn in return Pawn(role: role) }
        return availablePawns.shuffled().dropLast(availablePawns.count - 4)
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
    
    static func generateEdgeDictionary() -> [CityName: [CityName]]
    {
        var edges = [CityName:[CityName]]()
        //MARK: Blue
        edges[.sanFrancisco] = [.tokyo, .manila, .chicago, .losAngeles]
        edges[.chicago] = [.sanFrancisco, .toronto, .losAngeles, .mexicoCity, .atlanta]
        edges[.toronto] = [.chicago, .newYork, .washington]
        edges[.newYork] = [.toronto, .washington, .london, .madrid]
        edges[.london] = [.newYork, .essen, .paris, .madrid]
        edges[.essen] = [.london, .stPetersburg, .paris, .milan]
        edges[.stPetersburg] = [.essen, .moscow, .istanbul]
        edges[.atlanta] = [CityName.chicago, .washington, .miami]
        edges[.washington] = [.atlanta, .toronto, .newYork, .miami]
        edges[.madrid] = [.newYork, .london, .paris, .saoPaulo, .algiers]
        edges[.paris] = [.madrid, .london, .essen, .milan, .algiers]
        edges[.milan] = [.paris, .essen, .istanbul]
        //Mark: Yellow
        edges[.losAngeles] = [.sanFrancisco, .chicago, .mexicoCity, .sydney]
        edges[.mexicoCity] = [.losAngeles, .chicago, .miami, .bogota, .lima]
        edges[.miami] = [.mexicoCity, .atlanta, .washington, .bogota]
        edges[.bogota] = [.mexicoCity, .miami, .lima, .buenosAres, .saoPaulo]
        edges[.lagos] = [.saoPaulo, .kinshasa, .khartoum]
        edges[.khartoum] = [.lagos, .cairo, .kinshasa, .johannesburg]
        edges[.lima] = [.santiago, .mexicoCity, .bogota]
        edges[.saoPaulo] = [.bogota, .buenosAres, .madrid, .lagos]
        edges[.kinshasa] = [.lagos, .khartoum, .johannesburg]
        edges[.santiago] = [.lima]
        edges[.buenosAres] = [.bogota, .saoPaulo]
        edges[.johannesburg] = [.kinshasa, .khartoum]
        //Mark: Black
        edges[.algiers] = [.paris, .istanbul, .cairo, .madrid]
        edges[.istanbul] = [.algiers, .milan, .stPetersburg, .moscow, .baghdad, .cairo]
        edges[.moscow] = [.stPetersburg, .istanbul, .tehran]
        edges[.cairo] = [.algiers, .istanbul, .baghdad, .riyadh, .khartoum]
        edges[.baghdad] = [.cairo, .istanbul, .tehran, .karachi, .riyadh]
        edges[.tehran] = [.baghdad, .moscow, .delhi, .karachi]
        edges[.riyadh] = [.cairo, .baghdad, .karachi]
        edges[.karachi] = [.riyadh, .baghdad, .tehran, .delhi, .mumbai]
        edges[.delhi] = [.karachi, .tehran, .chennai, .mumbai, .kolkata]
        edges[.mumbai] = [.karachi, .delhi, .chennai]
        edges[.kolkata] = [.delhi, .chennai, .bangkok, .hongKong]
        edges[.chennai] = [.mumbai, .delhi, .kolkata, .bangkok, .jakarta]
        //Mark: Red
        edges[.beijing] = [.shanghai, .seoul]
        edges[.seoul] = [.beijing, .shanghai, .tokyo]
        edges[.shanghai] = [.beijing, .seoul, .tokyo, .taipei, .hongKong]
        edges[.tokyo] = [.shanghai, .seoul, .sanFrancisco, .osaka]
        edges[.hongKong] = [.kolkata, .shanghai, .taipei, .manila, .hoChiMinhCity, .bangkok]
        edges[.taipei] = [.hongKong, .osaka, .manila, .shanghai]
        edges[.osaka] = [.tokyo, .taipei]
        edges[.bangkok] = [.chennai, .kolkata, .hongKong, .hoChiMinhCity, .jakarta]
        edges[.hoChiMinhCity] = [.jakarta, .bangkok, .hongKong, .manila]
        edges[.manila] = [.hoChiMinhCity, .hongKong, .taipei, .sanFrancisco, .sydney]
        edges[.jakarta] = [.chennai, .bangkok, .hoChiMinhCity, .sydney]
        edges[.sydney] = [.jakarta, .manila, .losAngeles]
        return edges
    }
    
    static func generateLocationsMap() -> [CityName: BoardLocation]
    {
        var locations: [CityName: BoardLocation] = [:]
        CityName.allCases.forEach
            { name in
                locations.updateValue(BoardLocation(city: City(name: name)), forKey: name)
        }
        return locations
    }
}
