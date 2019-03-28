//
//  CubeDistribution.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

protocol CubeDistributionProtocol
{
    /**
     The delegate that will be notified if there is an outbreak.
    */
    var delegate: OutbreakDelegate? { get set }
    /**
     The number of red cubes in the distribution.
     */
    var red: Int { get }
    /**
     The number of yellow cubes in the distribution.
     */
    var yellow: Int { get }
    /**
     The number of blue cubes in the distribution.
     */
    var blue: Int { get }
    /**
     The number of black cubes in the distribution.
     */
    var black: Int { get }
    
    /**
     Adds the given cubes to the distribution.
     - Parameters:
        - cubes: a dictionary of disease color to integer for the number of cubes of each color.
     - Note: This function will call the delegate if there is an outbreak.
     */
    func add(cubes: [DiseaseColor : Int])
    
    /**
     Adds the given number of cubes of the given disease to the distribution.
     - Parameters:
        - cubes: the number of cubes to be added.
        - disease: the disease of the cubes being added.
     - Throws: `CubeDistributionError.outbreak` when the total number of cubes for the given
     disease would be increased to greater than 3.
     */
    func add(cubes: Int, of disease: DiseaseColor)
    
    /**
     Removes the given cubess from the distribution.
     - Parameters:
        - cubes: a dictionary of disease color ot integer for the number of cubes of each color.
     - Note: if the function is supplied with more disease cubes than the number currently in
     the distribution it will just 0 that color out.
     */
    func remove(cubes: [DiseaseColor: Int])
    
    /**
     Removes the given number of cubes from the given disease in the distribution.
     - Parameters:
        - cubes: the number of cubes to be removed.
        - disease: the disease color being removed.
     - Note: if the function is supplied with more disease cubes than the number currenlty in the
     distribution it will just 0 that color out.
    */
    func remove(cubes: Int, of disease: DiseaseColor)
}

protocol OutbreakDelegate: class
{
    /**
     Function called when a city outbreaks.
     - Parameters:
     - color: the disease that caused the outbreak.
     */
    func didOutbreak(for color: DiseaseColor)
}

class CubeDistribution: CubeDistributionProtocol
{
    weak var delegate: OutbreakDelegate?
    var red: Int
    var yellow: Int
    var blue: Int
    var black: Int
    
    init()
    {
        red = 0
        yellow = 0
        blue = 0
        black = 0
    }
    
    func add(cubes: [DiseaseColor : Int])
    {
        red += cubes[.red] ?? 0
        yellow += cubes[.yellow] ?? 0
        blue += cubes[.blue] ?? 0
        black += cubes[.black] ?? 0
        checkForOutbreaks()
    }
    
    func add(cubes: Int, of disease: DiseaseColor)
    {
        add(cubes: [disease: cubes])
    }
    
    /**
     Checks each of the stored colors for outbreaks. If an outbreak occured, it will
     set that to 3 and then notify the delegate.
    */
    private func checkForOutbreaks()
    {
        if (red > 3)
        {
            red = 3
            delegate?.didOutbreak(for: .red)
        }
        if (yellow > 3)
        {
            yellow = 3
            delegate?.didOutbreak(for: .yellow)
        }
        if (blue > 3)
        {
            blue = 3
            delegate?.didOutbreak(for: .blue)
        }
        if (black > 3)
        {
            black = 3
            delegate?.didOutbreak(for: .black)
        }
    }
    
    func remove(cubes: [DiseaseColor : Int])
    {
        red -= cubes[.red] ?? 0
        yellow -= cubes[.yellow] ?? 0
        blue -= cubes[.blue] ?? 0
        black -= cubes[.black] ?? 0
        checkForNegatives()
    }
    
    func remove(cubes: Int, of disease: DiseaseColor)
    {
        remove(cubes: [disease: cubes])
    }
    
    private func checkForNegatives()
    {
        if red < 0
        {
            red = 0
        }
        if yellow < 0
        {
            yellow = 0
        }
        if blue < 0
        {
            blue = 0
        }
        if black < 0
        {
            black = 0
        }
    }
}

