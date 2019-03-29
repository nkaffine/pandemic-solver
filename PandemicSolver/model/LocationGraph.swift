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
 
    /**
     Places the given number of the given disease color on the given city.
     - Parameters:
        - cubes: the number of cubes to be placed.
        - city: the city where the cubes will be placed.
        - color: the color of the disease cubes being placed.
     - Returns: the location graph with the updated state.
    */
    func place(_ cubes: Int, of color: DiseaseColor, on city: CityName) -> LocationGraph
    
    /**
     Removes the given number of cubes of the given disease color from the given city.
     - Parameters:
        - cubes: the number of cubes being removed.
        - city: the city where the cubes will be placed.
        - color: the color of the disease cubes being placed.
     - Returns: the location graph with the updated state.
    */
    func removeCubes(_ cubes: Int, of color: DiseaseColor, on city: CityName) -> LocationGraph
}

struct LocationGraph: LocationGraphProtocol
{
    let locations: [CityName: BoardLocation]
    let edges: [CityName: [CityName]]
    
    init()
    {
        locations = GameStartHelper.generateLocationsMap()
        edges = GameStartHelper.generateEdgeDictionary()
    }
    
    func place(_ cubes: Int, of color: DiseaseColor, on city: CityName) -> LocationGraph
    {
        //TODO: actually do this.
        return self
    }
    
    func removeCubes(_ cubes: Int, of color: DiseaseColor, on city: CityName) -> LocationGraph
    {
        //TODO: actually do this.
        return self
    }
}
