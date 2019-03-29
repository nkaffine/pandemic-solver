//
//  LocationGraph.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/28/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

protocol LocationGraphProtocol
{
    var locations: [CityName: BoardLocation] { get }
    var edges: [CityName : [CityName]] { get }
}

struct LocationGraph: LocationGraphProtocol
{
    var locations: [CityName: BoardLocation]
    let edges: [CityName: [CityName]]
    
    init() {
        locations = [:]
        edges = [:]
        CityName.allCases.forEach
        { name in
            locations.updateValue(BoardLocation(city: City(name: name), cubes: CubeDistribution()), forKey: name)
        }
        
    }
}
