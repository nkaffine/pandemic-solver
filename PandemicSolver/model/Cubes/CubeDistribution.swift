//
//  CubeDistribution.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

enum CubeCount: Int, Comparable, CaseIterable
{
    case zero = 0, one = 1, two = 2, three = 3
    
    func willOutbreak(with cubes: CubeCount) -> Bool
    {
        switch self
        {
            case .zero:
                return false
            case .one:
                return cubes > .two
            case .two:
                return cubes > .one
            case .three:
                return cubes > .zero
        }
    }
    
    static func < (lhs: CubeCount, rhs: CubeCount) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    static func +(lhs: CubeCount, rhs: CubeCount) -> CubeCount
    {
        return CubeCount(rawValue: lhs.rawValue + rhs.rawValue) ?? .three
    }
    
    static func -(lhs: CubeCount, rhs: CubeCount) -> CubeCount
    {
        return CubeCount(rawValue: lhs.rawValue - rhs.rawValue) ?? .zero
    }
}

typealias Outbreak = [DiseaseColor]

protocol CubeDistributionProtocol: CustomStringConvertible
{
    /**
     The number of red cubes in the distribution.
     */
    var red: CubeCount { get }
    /**
     The number of yellow cubes in the distribution.
     */
    var yellow: CubeCount { get }
    /**
     The number of blue cubes in the distribution.
     */
    var blue: CubeCount { get }
    /**
     The number of black cubes in the distribution.
     */
    var black: CubeCount { get }
    /**
     The max number of cubes of one color.
    */
    var maxCount: Int { get }
    /**
     TODO: test this
     Whether or not there are any cubes of any color in the distribution.
    */
    var isInfected: Bool { get }
    
    /**
     Adds the given cubes to the distribution.
     - Parameters:
        - cubes: a dictionary of disease color to integer for the number of cubes of each color.
     - Returns
     */
    func add(cubes: [DiseaseColor : CubeCount]) -> (outbreak: Outbreak, distribution: CubeDistribution)
    
    /**
     Adds the given number of cubes of the given disease to the distribution.
     - Parameters:
        - cubes: the number of cubes to be added.
        - disease: the disease of the cubes being added.
     - Throws: `CubeDistributionError.outbreak` when the total number of cubes for the given
     disease would be increased to greater than 3.
     */
    func add(cubes: CubeCount, of disease: DiseaseColor) -> (outbreak: Outbreak, distribution: CubeDistribution)
    
    /**
     Removes the given cubess from the distribution.
     - Parameters:
        - cubes: a dictionary of disease color ot integer for the number of cubes of each color.
     - Note: if the function is supplied with more disease cubes than the number currently in
     the distribution it will just 0 that color out.
     */
    func remove(cubes: [DiseaseColor: CubeCount]) -> CubeDistribution
    
    /**
     Removes the given number of cubes from the given disease in the distribution.
     - Parameters:
        - cubes: the number of cubes to be removed.
        - disease: the disease color being removed.
     - Note: if the function is supplied with more disease cubes than the number currenlty in the
     distribution it will just 0 that color out.
    */
    func remove(cubes: CubeCount, of disease: DiseaseColor) -> CubeDistribution
}

struct CubeDistribution: CubeDistributionProtocol
{
    var maxCount: Int
    {
        return max(red, yellow, blue, black).rawValue
    }
    
    var description: String
    {
        var string = ""
        if red > .zero
        {
            string += "red: \(red) "
        }
        if yellow > .zero
        {
            string += "yellow: \(yellow) "
        }
        if blue > .zero
        {
            string += "blue: \(blue) "
        }
        if black > .zero
        {
            string += "black: \(black) "
        }
        return string
    }
    var red: CubeCount
    var yellow: CubeCount
    var blue: CubeCount
    var black: CubeCount
    var isInfected: Bool
    {
        return red > .zero || yellow > .zero || blue > .zero || black > .zero
    }
    
    init()
    {
        red = .zero
        yellow = .zero
        blue = .zero
        black = .zero
    }
    
    private init(red: CubeCount, yellow: CubeCount, blue: CubeCount, black: CubeCount)
    {
        self.red = red
        self.yellow = yellow
        self.blue = blue
        self.black = black
    }
    
    func add(cubes: [DiseaseColor : CubeCount]) -> (outbreak: Outbreak, distribution: CubeDistribution)
    {
        let red = self.red + (cubes[.red] ?? .zero)
        let yellow = self.yellow + (cubes[.yellow] ?? .zero)
        let blue = self.blue + (cubes[.blue] ?? .zero)
        let black = self.black + (cubes[.black] ?? .zero)
        let outbreaks = getOutbreaks(from: cubes)
        return (outbreaks, CubeDistribution(red: red, yellow: yellow, blue: blue, black: black))
    }
    
    func add(cubes: CubeCount, of disease: DiseaseColor) -> (outbreak: Outbreak, distribution: CubeDistribution)
    {
        return add(cubes: [disease: cubes])
    }
    
    func remove(cubes: [DiseaseColor : CubeCount]) -> CubeDistribution
    {
        let red = self.red - (cubes[.red] ?? .zero)
        let yellow = self.yellow - (cubes[.yellow] ?? .zero)
        let blue = self.blue - (cubes[.blue] ?? .zero)
        let black = self.black - (cubes[.black] ?? .zero)
        return CubeDistribution(red: red, yellow: yellow, blue: blue, black: black)
        
    }
    
    func remove(cubes: CubeCount, of disease: DiseaseColor) -> CubeDistribution
    {
        return remove(cubes: [disease: cubes])
    }
    
    /**
     Gets a list of all the colors that will outbreak with the given added cubes.
     - Parameters:
        - cubes: a map from disease color to the number of cubes being placed
     - Returns: a list of all colors that will outbreak.
    */
    private func getOutbreaks(from cubes: [DiseaseColor: CubeCount]) -> Outbreak
    {
        var outbreaks = [DiseaseColor]()
        if cubes[.red]?.willOutbreak(with: red) ?? false
        {
            outbreaks.append(.red)
        }
        if cubes[.yellow]?.willOutbreak(with: yellow) ?? false
        {
            outbreaks.append(.yellow)
        }
        if cubes[.blue]?.willOutbreak(with: blue) ?? false
        {
            outbreaks.append(.blue)
        }
        if cubes[.black]?.willOutbreak(with: black) ?? false
        {
            outbreaks.append(.black)
        }
        return outbreaks
    }
}
