//
//  Pawn.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/29/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

protocol PawnProtocol
{
    var role: Role { get }
}

struct Pawn: PawnProtocol
{
    let role: Role
}
