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
    case big_boy_booster;
    case super_big_boy_booster;
    case small_bomb_item;
    case big_bomb_item;
    case small_missile_item;
    case big_missile_item;
    
}

enum obstacleType {
    case rouge_rookie;
    case batter_bro;
}

class PowerUpNode: SKSpriteNode {
    
    private var type = powerUpType.health_booster;
    private var is_selectable = false;
    private var wait_time:TimeInterval = 0.0;
    private var power_up_size = CGSize(width: 48.0, height: 48.0);
    
    init(power_up_type: powerUpType) {
        type = power_up_type;
        var imageName = "HealthBoosterPowerUp";
        switch power_up_type {
        case .health_booster:
            imageName = "HealthBoosterPowerUp";
            power_up_size = CGSize(width: 48.0, height: 48.0);
            break;
        case .fast_ball:
            imageName = "FastBallPowerUp";
            power_up_size = CGSize(width: 64.0, height: 64.0);
        case .big_boy_booster:
            imageName = "BigBoyBoosterPowerUp";
            power_up_size = CGSize(width: 64.0, height: 64.0);
        default:
            break
        }
        let texture = SKTexture(imageNamed: imageName);
        super.init(texture: texture, color: .clear, size: power_up_size)
        self.alpha = 0.0;
    }
    
    convenience init() {
        self.init(power_up_type: .health_booster);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func appear(wait_time: TimeInterval) {
        print("power up appear: wait time \(wait_time)");
        self.wait_time = wait_time;
        appear();
    }
    
    // Runs the animation that results in the powerups appearance.
    public func appear() {
        switch self.type {
        case .health_booster:
            healthBoosterAppear();
            break;
        case .fast_ball:
            fastBallAppear();
            break;
        case .big_boy_booster:
            bigBoyBoosterAppear();
            break;
        default:
            break
        }
    }
    
    // Runs the animation for when the powerup is selected.
    // Sets the paddles capabilities if its a power up
    // If its an item, assigns it to the paddle.
    // @by is the paddle/player that selected the powerup
    public func select(by: Paddle, completion: @escaping ()->Void) {
        print("power up selected: \(type)");
        let paddle = by;
        switch self.type {
        case .health_booster:
            healthBoosterSelected(by: paddle, completion: {completion()});
            // assign capabilities to sprite
            break;
        case .fast_ball:
            fastBallSelected(by: paddle, completion: {completion()});
            break;
        case .big_boy_booster:
            bigBoyBoosterSelected(by: paddle, completion: {completion()});
            break;
        default:
            break
        }
    }
    
    // Runs the animation to disappear and remove the powerup from the screen as well as producing any background effects made by the power up / item selection
    public func disappear() {
        switch self.type {
        case .health_booster:
            healthBoosterDisappear();
            break;
        case .fast_ball:
            fastBallDisappear();
            break;
        case .big_boy_booster:
            bigBoyBoosterDisappear();
            break;
        default:
            break
        }
    }
    
    private func healthBoosterAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func healthBoosterDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func healthBoosterSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: health booster selected");
        is_selectable = false;
        let scene = self.parent as! GameScene;
        if (by.name == "main") {
            scene.growLife();
        }
        else {
            print("power up: enemy selected health booster");
            scene.ai.growLife();
        }
        
        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func fastBallAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func fastBallDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func fastBallSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: fast ball selected");
        is_selectable = false;
 
        by.startFastBallPowerUp();

        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func bigBoyBoosterAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func bigBoyBoosterDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func bigBoyBoosterSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: Big Boy Booster selected");
        is_selectable = false;
        
        by.startBigBoyBoosterPowerUp();
        
        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    public func isSelectable() -> Bool {
        return is_selectable;
    }
    
    
}
