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
    case bomb_item;
    case big_bomb_item;
    case missile_item;
    case big_missile_item;
    case blaster_item;
    case beam_item;
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
        case .super_health_booster:
            imageName = "SuperHealthBoosterPowerUp";
            power_up_size = CGSize(width: 64.0, height: 64.0);
            break;
        case .full_replenish:
            imageName = "FullReplenishPowerUp";
            power_up_size = CGSize(width: 64.0, height: 64.0);
            break;
        case .fast_ball:
            imageName = "FastBallPowerUp";
            power_up_size = CGSize(width: 64.0, height: 64.0);
            break;
        case .super_fast_ball:
            imageName = "SuperFastBallPowerUp";
            power_up_size = CGSize(width: 64.0, height: 64.0);
            break;
        case .big_boy_booster:
            imageName = "BigBoyBoosterPowerUp";
            power_up_size = CGSize(width: 48.0, height: 48.0);
            break;
        case .super_big_boy_booster:
            imageName = "SuperBigBoyBoosterPowerUp";
            power_up_size = CGSize(width: 64.0, height: 64.0);
            break;
        case .bomb_item:
            imageName = "BombItemPowerUp";
            power_up_size = CGSize(width: 48.0, height: 48.0);
            break;
        case .missile_item:
            imageName = "MissileItemPowerUp";
            power_up_size = CGSize(width: 48.0, height: 48.0);
            break;
        case .blaster_item:
            imageName = "MissileItemPowerUp";
            power_up_size = CGSize(width: 48.0, height: 48.0);
            break;
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
        case .super_health_booster:
            superHealthBoosterAppear();
            break;
        case .full_replenish:
            fullReplenishAppear();
            break;
        case .fast_ball:
            fastBallAppear();
            break;
        case .super_fast_ball:
            superFastBallAppear();
            break;
        case .big_boy_booster:
            bigBoyBoosterAppear();
            break;
        case .super_big_boy_booster:
            superBigBoyBoosterAppear();
            break;
        case .bomb_item:
            // TO DO
            break;
        case .missile_item:
            missileItemAppear();
            break;
        case .blaster_item:
            blasterItemAppear();
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
        case .super_health_booster:
            superHealthBoosterSelected(by: paddle, completion: {completion()});
            break;
        case .full_replenish:
            fullReplenishSelected(by: paddle, completion: {completion()})
            break;
        case .fast_ball:
            fastBallSelected(by: paddle, completion: {completion()});
            break;
        case .super_fast_ball:
            superFastBallSelected(by: paddle, completion: {completion()});
            break;
        case .big_boy_booster:
            bigBoyBoosterSelected(by: paddle, completion: {completion()});
            break;
        case .super_big_boy_booster:
            superBigBoyBoosterSelected(by: paddle, completion: {completion()})
            break;
        case .bomb_item:
            // TO DO
            break;
        case .missile_item:
            missileItemSelected(by: paddle, completion: {completion()})
            break;
        case .blaster_item:
            blasterItemSelected(by: paddle, completion: {completion()})
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
        case .super_health_booster:
            superHealthBoosterDisappear();
            break;
        case .full_replenish:
            fullReplenishDisappear();
            break;
        case .fast_ball:
            fastBallDisappear();
            break;
        case .super_fast_ball:
            superFastBallDisappear();
            break;
        case .big_boy_booster:
            bigBoyBoosterDisappear();
            break;
        case .super_big_boy_booster:
            superBigBoyBoosterDisappear();
            break;
        case .bomb_item:
            // TO DO
            break;
        case .missile_item:
            missileItemDisappear();
            break;
        case .blaster_item:
            blasterItemDisappear();
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
            scene.ai.growLife(wait_time: 0.0);
        }
        
        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func superHealthBoosterAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func superHealthBoosterDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func superHealthBoosterSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: super health booster selected");
        is_selectable = false;
        let scene = self.parent as! GameScene;
        if (by.name == "main") {
            scene.growLife();
            scene.growLife();
        }
        else {
            print("power up: enemy selected super health booster");
            scene.ai.growLife(wait_time: 0.0);
            scene.ai.growLife(wait_time: 0.2);
        }
        
        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func fullReplenishAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func fullReplenishDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func fullReplenishSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: super health booster selected");
        is_selectable = false;
        let scene = self.parent as! GameScene;
        if (by.name == "main") {
            while (scene.growLife()) {}
        }
        else {
            print("power up: enemy selected super health booster");
            var wait_time = 0.0;
            while (scene.ai.growLife(wait_time: wait_time)) {wait_time = wait_time + 0.2}
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
 
        by.startFastBallPowerUp(is_super: false);

        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func superFastBallAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func superFastBallDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func superFastBallSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: fast ball selected");
        is_selectable = false;
        
        by.startFastBallPowerUp(is_super: true);
        
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
        
        by.startBigBoyBoosterPowerUp(is_super: false);
        
        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func superBigBoyBoosterAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func superBigBoyBoosterDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func superBigBoyBoosterSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: Big Boy Booster selected");
        is_selectable = false;
        
        by.startBigBoyBoosterPowerUp(is_super: true);
        
        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func bombItemAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func bombItemDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func bombItemSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: Big Boy Booster selected");
        is_selectable = false;
        
        // DO Stuff
        
        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func missileItemAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func missileItemDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func missileItemSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: Big Boy Booster selected");
        is_selectable = false;
        
        // Missile Useage Steps:
        // (1) Create missile button
        // (2) When missile button is pressed, a missile launches and does its behavior
        
        by.launchMissile(missile_type: "normal");
        
        // will end up also running other background effects
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    
    private func blasterItemAppear() {
        is_selectable = false;
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeIn(withDuration: 1.0)]), completion: {
            self.is_selectable = true;
            self.wait_time = 0.0;
        });
    }
    
    private func blasterItemDisappear() {
        is_selectable = false;
        self.run(SKAction.fadeOut(withDuration: 1.0), completion: {
            self.removeFromParent();
        });
    }
    
    private func blasterItemSelected(by: Paddle, completion: @escaping ()->Void) {
        print("power up: Blaster selected");
        is_selectable = false;
        let scene = self.parent as! GameScene;

        by.setBlasterButton(amount: 1);
        
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
