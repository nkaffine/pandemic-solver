//
//  Reward.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/22/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

enum Reward
{
    ///The player cured a disease
    case curedDisease
    ///Count outbreaks ocurred.
    case outbreak(count: Int)
    ///A card was traded.
    case sharedKnowledge
    ///Treated a disease.
    case treatedDisease
    ///No reward was earned.
    case none
    
    /**
     The reward of the given action for the linear value function approximation.
    */
    var reward: Int
    {
        switch self
        {
            case .curedDisease:
                return 0
            case .outbreak(let count):
                return 0 * count
            case .sharedKnowledge:
                return 0
            case .treatedDisease:
                return 0
            case .none:
                return 0
        }
    }
}
