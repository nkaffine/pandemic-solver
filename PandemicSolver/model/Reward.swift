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
    case outbreak
    ///A card was traded.
    case sharedKnowledge
    ///Treated a disease.
    case treatedDisease
    ///No reward was earned.
    case none
    
    /**
     The reward of the given action for the linear value function approximation.
    */
    var reward: Float
    {
        switch self
        {
            case .curedDisease:
                return 2000.0
            case .outbreak:
                return 0.0
            case .sharedKnowledge:
                return 1000.0
            case .treatedDisease:
                return 200.0
            case .none:
                return 0.0
        }
    }
}
