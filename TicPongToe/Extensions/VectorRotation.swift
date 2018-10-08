//
//  VectorRotation.swift
//  TicPongToe
//
//  Created by Nathan Lane on 10/7/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

extension CGVector {
    
    func speed() -> CGFloat {
        return sqrt(dx*dx+dy*dy)
    }
    
    func angle() -> CGFloat {
        return atan2(dy, dx)
    }
}
