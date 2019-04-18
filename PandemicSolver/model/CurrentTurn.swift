//
//  TurnIterator.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 4/11/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

struct CurrentTurn
{
    private let pawns: [Pawn]
    private let currentPawnIndex: Int
    var currentPawn: Pawn
    {
        return pawns[currentPawnIndex]
    }
    let actionsLeft: Int
    
    init(pawns: [Pawn])
    {
        self.pawns = pawns
        self.currentPawnIndex = (0..<(pawns.count - 1)).randomElement()!
        actionsLeft = 4
    }
    
    private init(currentPawnIndex: Int, actionsLeft: Int, pawns: [Pawn])
    {
        self.pawns = pawns
        self.currentPawnIndex = currentPawnIndex
        self.actionsLeft = actionsLeft
    }
    
    /**
     Gets the state of the next turn updating the number of remaining actions and the current player.
     - Returns: the state of the current player after updating appropriate.
    */
    func next() -> CurrentTurn
    {
        if actionsLeft == 0
        {
            return CurrentTurn(currentPawnIndex: self.nextPawnIndex(), actionsLeft: 4, pawns: self.pawns)
        }
        else
        {
            return CurrentTurn(currentPawnIndex: self.currentPawnIndex, actionsLeft: self.actionsLeft - 1, pawns: self.pawns)
        }
    }
    
    /**
     Gets the index of the next pawn whose turn it is.
     - Returns: the index of the pawn whose turn is next.
    */
    private func nextPawnIndex() -> Int
    {
        let incrementedIndex = self.currentPawnIndex + 1
        return incrementedIndex == self.pawns.count ? 0 : incrementedIndex
    }
}
