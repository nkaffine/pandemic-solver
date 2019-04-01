//
//  LocationGraph.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/28/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

struct CubePlacement
{
    let city: CityName
    let disease: DiseaseColor
    let cubes: CubeCount
}

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
     - Returns: a list of the cities that outbroke and the new location graph
    */
    func place(_ cubes: CubeCount, of color: DiseaseColor, on city: CityName) -> (outbreakCities: [CityName], graph: LocationGraph)
    
    /**
     Places the given cube distributions on the given cities.
     - Parameters:
         - cubes: an array of tuples where the first item is the city and the second item is
        a tuple with the disease color and the cube count
     - Returns: a list of cities that outbroke and the new location graph
    */
    func place(cubes: [CubePlacement]) -> (outbreakCities: [CityName], graph: LocationGraph)
    
    /**
     Removes the given number of cubes of the given disease color from the given city.
     - Parameters:
        - cubes: the number of cubes being removed.
        - city: the city where the cubes will be placed.
        - color: the color of the disease cubes being placed.
     - Returns: the location graph with the updated state.
    */
    func removeCubes(_ cubes: CubeCount, of color: DiseaseColor, on city: CityName) -> LocationGraph
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
    
    private init(locations: [CityName: BoardLocation], edges: [CityName: [CityName]])
    {
        self.locations = locations
        self.edges = edges
    }
    
    func place(_ cubes: CubeCount, of color: DiseaseColor, on city: CityName) -> (outbreakCities: [CityName], graph: LocationGraph)
    {
        return place(cubes, of: color, on: city, outbreakCities: [])
    }
    
    private func place(_ cubes: CubeCount, of color: DiseaseColor, on city: CityName, outbreakCities: [CityName]) -> (outbreakCities: [CityName], graph: LocationGraph)
    {
        //Unwrapping because this should never be nil
        let (outbreaks, location) = self.locations[city]!.add(cubes: cubes, of: color)
        let locations = self.locations.imutableUpdate(key: city, value: location)
        
        var outbrokeCities = outbreakCities
        var newGraph = LocationGraph(locations: locations, edges: edges)
        
        if (!outbreaks.isEmpty)
        {
            //Have to handle the outbreak
            //Should never be nil
            let cities = self.edges[city]!
            if !outbrokeCities.contains(city)
            {
                outbrokeCities.append(city)
            }
            outbreaks.forEach
            { disease in
                //This does not catch the case where a city should outbreak from multiple colors
                //but the game would be going so horribly if that were to happen.
                cities.filter{!outbrokeCities.contains($0)}.forEach
                { city in
                    var newOutbreaks = [CityName]()
                    (newOutbreaks, newGraph) = newGraph.place(.one, of: disease, on: city, outbreakCities: outbrokeCities)
                    //There won't be enough outbreaks in one turn for the speed of this to be important
                    newOutbreaks.forEach
                    { cityName in
                        if !outbrokeCities.contains(cityName)
                        {
                            outbrokeCities.append(cityName)
                        }
                    }
                }
            }
        }
        return (outbrokeCities, newGraph)
    }
    
    func place(cubes: [CubePlacement]) -> (outbreakCities: [CityName], graph: LocationGraph)
    {
        var outbreaksSoFar = [CityName]()
        var newGraph = self
        var newOutbreaks = [CityName]()
        cubes.forEach
        { placement in
            if !outbreaksSoFar.contains(placement.city)
            {
                (newOutbreaks, newGraph) = newGraph.place(placement.cubes, of: placement.disease,
                                                          on: placement.city, outbreakCities: outbreaksSoFar)
                newOutbreaks.forEach
                { city in
                        if !outbreaksSoFar.contains(city)
                        {
                            outbreaksSoFar.append(city)
                        }
                }
            }
        }
        return (outbreaksSoFar, newGraph)
    }
    
    func removeCubes(_ cubes: CubeCount, of color: DiseaseColor, on city: CityName) -> LocationGraph
    {
        //Unwrapping because this should never be nil
        var location = locations[city]!
        location = location.remove(cubes: cubes, of: color)
        return LocationGraph(locations: locations.imutableUpdate(key: city, value: location), edges: edges)
    }
}
