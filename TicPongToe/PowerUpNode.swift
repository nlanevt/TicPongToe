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
    case health_booster;
    case super_health_booster;
    case full_replenish;
    case fast_ball;
    case super_fast_ball;
    case large_size_booster;
    case mega_size_booster;
    case small_bomb_item;
    case big_bomb_item;
    case small_missile_item;
    case big_missile_item;
    
}

class PowerUpNode: SKSpriteNode {
    
    private var type = powerUpType.health_booster;
    
    init(power_up_type: powerUpType) {
        var imageName = "HealthBoosterPowerUp";
        
        switch power_up_type {
        case .health_booster:
            imageName = "HealthBoosterPowerUp";
            break
        default:
            break
        }
        let texture = SKTexture(imageNamed: imageName);
        super.init(texture: texture, color: .clear, size: texture.size())
    }
    
    convenience init() {
        self.init(power_up_type: .health_booster);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Runs the animation that results in the powerups appearance.
    public func appear() {
        
    }
    
    // Runs the animation for when the powerup is selected.
    // Sets the paddles capabilities if its a power up
    // If its an item, assigns it to the paddle. 
    // @by is the paddle/player that selected the powerup
    public func select(by: SKSpriteNode) {
        var paddle = by;
        
    }
    
    // Runs the animation to disappear and remove the powerup from the screen as well as producing any background effects made by the power up / item selection
    public func disappear() {
        
    }
    
    
    
}
