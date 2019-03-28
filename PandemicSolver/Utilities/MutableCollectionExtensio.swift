//
//  MutableCollectionExtensio.swift
//  PandemicSolver
//
//  Created by Nicholas Kaffine on 3/27/19.
//  Copyright © 2019 Nicholas Kaffine. All rights reserved.
//

import Foundation

extension MutableCollection
{
    /* Implementing the Fisher-Yates Shuffle Algorithm: https://www.geeksforgeeks.org/shuffle-a-given-array-using-fisher-yates-shuffle-algorithm/
     */
    mutating func shuffle()
    {
        let range = (0..<count)
        range.forEach
        { index in
            let currentIndex = self.index(self.startIndex, offsetBy: index)
            let randomIndex = self.index(self.startIndex, offsetBy: Int.random(in: range))
            self.swapAt(currentIndex, randomIndex)
        }
    }
}
