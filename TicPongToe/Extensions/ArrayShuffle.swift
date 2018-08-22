//
//  ArrayShuffle.swift
//  TicPongToe
//
//  Created by Nathan Lane on 7/15/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation

extension Array {
    mutating func shuffle() {
        for i in indices.reversed() {
            let j = arc4random_uniform( numericCast(i+1) )
            swapAt(i, numericCast(j))
        }
    }
    
    func shuffled() -> Array {
        var newArray = self
        newArray.shuffle()
        return newArray
    }
}
