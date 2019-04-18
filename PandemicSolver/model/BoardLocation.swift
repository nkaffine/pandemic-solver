//
//  BoardLocation.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/30/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

struct BoardLocation: Hashable, Equatable, CustomStringConvertible
{
    var description: String
    {
        return "\(city.name): \n\t\t\(cubes)"
    }
    
    let city: City
    let cubes: CubeDistributionProtocol
    let hasResearchStation: Bool
    var isInfected: Bool
    {
        return cubes.isInfected
    }
    
    init(city: City)
    {
        self.city = city
        self.cubes = CubeDistribution()
        self.hasResearchStation = false
    }
    
    private init(city: City, cubes: CubeDistributionProtocol, hasResearchStation: Bool = false) {
        self.city = city
        self.cubes = cubes
        self.hasResearchStation = hasResearchStation
    }
    
    static func == (lhs: BoardLocation, rhs: BoardLocation) -> Bool {
        return lhs.city == rhs.city
    }
    
    func hash(into hasher: inout Hasher)
    {
        hasher.combine(city)
    }
    
    /**
     Returns the location of the board after adding the given number of cubes of the
     given disease color and any outbreaks that occured.
     - Parameters:
     - cubes: the number of cubes to be added
     - disease: the color of the disease to be added
     - Returns: a list of the colors that outbroke and the location after the cubes being added.
     */
    func add(cubes: CubeCount, of disease: DiseaseColor) -> (Outbreak, BoardLocation)
    {
        let (outbreak, distribution) = self.cubes.add(cubes: cubes, of: disease)
        return (outbreak, BoardLocation(city: city, cubes: distribution))
    }
    
    /**
     Returns the location of the board after adding the given number of cubes per disease
     in the dictionary.
     - Parameters:
     - cubes: a dictionary maping disease color to how many cubes to add
     - Returns: a list of the colors that outbroke and the location after the cubes being added.
     */
    func add(cubes: [DiseaseColor: CubeCount]) -> (Outbreak, BoardLocation)
    {
        let (outbreak, distribution) = self.cubes.add(cubes: cubes)
        return (outbreak, BoardLocation(city: city, cubes: distribution))
    }
    
    /**
     Removes the given number of cubes of the given color from this location and returns
     the new state.
     - Parameters:
        - cubes: the number of cubes being removed.
        - color: the color of the disease being removed.
     - Returns: The board location with the updated cubes.
    */
    func remove(cubes: CubeCount, of color: DiseaseColor) -> BoardLocation
    {
        return BoardLocation(city: city, cubes: self.cubes.remove(cubes: cubes, of: color))
    }
    
    /**
     Adds a research station to this location on the board.
     - Returns: The board location with the updated research station.
    */
    func addResearchStation() -> BoardLocation
    {
        return BoardLocation(city: city, cubes: cubes, hasResearchStation: true)
    }
}
