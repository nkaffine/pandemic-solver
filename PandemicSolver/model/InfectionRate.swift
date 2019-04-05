//
//  InfectionRate.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/5/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

enum InfectionRate
{
    case one, two, three, four, five, six, seven
    
    var cardsToDraw: Int
    {
        switch self
        {
            case .one, .two, .three:
                return 2
            case .four, .five:
                return 3
            case .six, .seven:
                return 4
        }
    }
    
    func next() -> InfectionRate
    {
        switch self
        {
            case .one:
                return .two
            case .two:
                return .three
            case .three:
                return .four
            case .four:
                return .five
            case .five:
                return .six
            case .six:
                return .seven
            case .seven:
                //Might be better to throw an error but for now leaving it as is.
                return .seven
        }
    }
}
