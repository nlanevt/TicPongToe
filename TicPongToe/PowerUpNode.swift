//
//  PowerUpNode.swift
//  TicPongToe
//
//  Created by Nathan Lane on 11/26/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

enum powerUpType {
    case heart;
    case power_hit;
    case slow_down;
    case quarter_shrinker;
    case half_shrinker;
    case expander
}

class PowerUpNode: SKSpriteNode {
    
    private var type = powerUpType.heart;
    
    init(power_up_type: powerUpType) {
        var imageName = "HeartPowerUp";
        
        switch power_up_type {
        case .heart:
            imageName = "HeartPowerUp";
            break
        case .power_hit:
            imageName = "PowerHitPowerUp";
            break
        case .slow_down:
            imageName = "SlowDownPowerUp";
            break
        case .quarter_shrinker:
            imageName = "QuarterShrinkerPowerUp";
            break
        case .half_shrinker:
            imageName = "HalfShrinkerPowerUp";
            break
        case .expander:
            imageName = "ExpanderPowerUp";
            break
        default:
            imageName = "HeartPowerUp";
            break;
        }
        let texture = SKTexture(imageNamed: imageName);
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    convenience init() {
        self.init(power_up_type: .heart);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
