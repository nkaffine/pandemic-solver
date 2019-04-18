//
//  Disease.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

/**
 There are 4 colors of cards in the game, each representing a different disease.
 */
enum DiseaseColor: String, CaseIterable, CustomStringConvertible
{
    var description: String
    {
        return self.rawValue
    }
    
    case red, black, blue, yellow
}
