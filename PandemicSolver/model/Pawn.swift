//
//  Pawn.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/29/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

enum Role: CaseIterable
{
    case medic, operationsExpert, dispatcher, scientist, researcher
}

protocol PawnProtocol
{
    var role: Role { get }
}

struct Pawn: PawnProtocol
{
    let role: Role
}
