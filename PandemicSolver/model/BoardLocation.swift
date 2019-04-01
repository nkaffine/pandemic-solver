//
//  BoardLocation.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/30/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

struct BoardLocation: Hashable, Equatable
{
    let city: City
    let cubes: CubeDistributionProtocol
    
    init(city: City)
    {
        self.city = city
        self.cubes = CubeDistribution()
    }
    
    private init(city: City, cubes: CubeDistributionProtocol) {
        self.city = city
        self.cubes = cubes
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
    
    func remove(cubes: CubeCount, of color: DiseaseColor) -> BoardLocation
    {
        return BoardLocation(city: city, cubes: self.cubes.remove(cubes: cubes, of: color))
    }
}
