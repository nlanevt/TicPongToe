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
    private var center_position = CGPoint();
    
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
        default:
            break
        }
    }
    
    public func isSelectable() -> Bool {
        return is_selectable;
    }
    
    private func healthBoosterAppear() {
        is_selectable = false;
        self.floatAnimation();
        self.run(getAppearenceAction(textureName: "HealthBoosterPowerUp", flashName: "HealthBoosterFlash"), completion: {
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
        //print("power up: health booster selected");
        is_selectable = false;
        let scene = self.parent as! GameScene;
        if (by.name == "main") {
            scene.growLife(amount: 1);
        }
        else {
           // print("power up: enemy selected health booster");
            scene.ai.growLife(wait_time: 0.0);
        }
        
        // will end up also running other background effects
        self.run(getDisappearenceAction(textureName: "HealthBoosterPowerUp", flashName: "HealthBoosterFlash"), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func superHealthBoosterAppear() {
        is_selectable = false;
        self.floatAnimation();
        self.run(getAppearenceAction(textureName: "SuperHealthBoosterPowerUp", flashName: "HealthBoosterFlash"), completion: {
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
        //print("power up: super health booster selected");
        is_selectable = false;
        let scene = self.parent as! GameScene;
        if (by.name == "main") {
            scene.growLife(amount: 2);
        }
        else {
            //print("power up: enemy selected super health booster");
            scene.ai.growLife(wait_time: 0.0);
            scene.ai.growLife(wait_time: 0.2);
        }
        
        // will end up also running other background effects
        self.run(getDisappearenceAction(textureName: "SuperHealthBoosterPowerUp", flashName: "HealthBoosterFlash"), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func fullReplenishAppear() {
        is_selectable = false;
        self.floatAnimation();
        self.run(getAppearenceAction(textureName: "FullReplenishPowerUp", flashName: "HealthBoosterFlash"), completion: {
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
        //print("power up: super health booster selected");
        is_selectable = false;
        let scene = self.parent as! GameScene;
        if (by.name == "main") {
            scene.growLife(amount: scene.getLivesLeft());
        }
        else {
            //print("power up: enemy selected super health booster");
            var wait_time = 0.0;
            while (scene.ai.growLife(wait_time: wait_time)) {wait_time = wait_time + 0.2}
        }
        
        // will end up also running other background effects
        self.run(getDisappearenceAction(textureName: "FullReplenishPowerUp", flashName: "HealthBoosterFlash"), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func fastBallAppear() {
        is_selectable = false;
        floatAnimation();

        self.run(getAppearenceAction(textureName: "FastBallPowerUp", flashName: "FastBallPowerUpFlash"), completion: {
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
        //print("power up: fast ball selected");
        is_selectable = false;
 
        by.runFastBallPowerUp(is_super: false);

        // will end up also running other background effects
        self.run(getDisappearenceAction(textureName: "FastBallPowerUp", flashName: "FastBallPowerUpFlash"), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func superFastBallAppear() {
        is_selectable = false;
        floatAnimation();

        self.run(getAppearenceAction(textureName: "SuperFastBallPowerUp", flashName: "FastBallPowerUpFlash"), completion: {
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
        //print("power up: fast ball selected");
        is_selectable = false;
        
        by.runFastBallPowerUp(is_super: true);
        
        // will end up also running other background effects
        self.run(getDisappearenceAction(textureName: "SuperFastBallPowerUp", flashName: "FastBallPowerUpFlash"), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func bigBoyBoosterAppear() {
        is_selectable = false;
        floatAnimation();

        self.run(getAppearenceAction(textureName: "BigBoyBoosterPowerUp", flashName: "BigBoyBoosterPowerUpFlash"), completion: {
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
        //print("power up: Big Boy Booster selected");
        is_selectable = false;
        
        by.runBigBoyBoosterPowerUp(is_super: false);
        
        // will end up also running other background effects
        self.run(getDisappearenceAction(textureName: "BigBoyBoosterPowerUp", flashName: "BigBoyBoosterPowerUpFlash"), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func superBigBoyBoosterAppear() {
        is_selectable = false;
        floatAnimation();

        self.run(getAppearenceAction(textureName: "SuperBigBoyBoosterPowerUp", flashName: "BigBoyBoosterPowerUpFlash"), completion: {
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
        //print("power up: Big Boy Booster selected");
        is_selectable = false;
        
        by.runBigBoyBoosterPowerUp(is_super: true);
        
        // will end up also running other background effects
        self.run(getDisappearenceAction(textureName: "SuperBigBoyBoosterPowerUp", flashName: "BigBoyBoosterPowerUpFlash"), completion: {
            self.removeFromParent();
            completion();
        });
    }
    
    private func floatAnimation() {
        let floatUp = SKAction.moveTo(y: self.position.y+3, duration: 0.3);
        let floatUpSmall = SKAction.moveTo(y: self.position.y+2, duration: 0.3);
        let floatDown = SKAction.moveTo(y: self.position.y-3, duration: 0.3);
        let floatDownSmall = SKAction.moveTo(y: self.position.y-2, duration: 0.3);
        var repeatingFloat = SKAction.repeatForever(SKAction.sequence([floatUp, floatUpSmall, floatDownSmall, floatDown, floatDown, floatDownSmall, floatUpSmall, floatUp]));
        
        if (Int(arc4random_uniform(2)) == 0) {
            repeatingFloat = SKAction.repeatForever(SKAction.sequence([floatDown, floatDownSmall, floatUpSmall, floatUp, floatUp, floatUpSmall, floatDownSmall, floatDown]));
        }
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: Double.random(in: 0...0.5)), repeatingFloat]));
    }
    
    public func setCenterPosition(position: CGPoint) {
        self.center_position = position;
        self.position = center_position;
    }
    
    public func getCenterPosition() -> CGPoint {
        return self.center_position;
    }
    
    private func getAppearenceAction(textureName: String, flashName: String) -> SKAction {
        let setFlashAction = SKAction.setTexture(SKTexture.init(imageNamed: flashName));
        let setTextureAction = SKAction.setTexture(SKTexture.init(imageNamed: textureName));
        let appearingSequenceAction = SKAction.sequence([SKAction.wait(forDuration: wait_time), SKAction.fadeAlpha(to: 0.25, duration: 0.3), setFlashAction, SKAction.wait(forDuration: 0.2), setTextureAction, SKAction.wait(forDuration: 0.2), setFlashAction, SKAction.fadeAlpha(to: 0.5, duration: 0.1), SKAction.wait(forDuration: 0.1), setTextureAction, SKAction.wait(forDuration: 0.2), setFlashAction, SKAction.fadeAlpha(to: 1.0, duration: 0.1), SKAction.wait(forDuration: 0.1), setTextureAction]);
        return appearingSequenceAction;
    }
    
    private func getDisappearenceAction(textureName: String, flashName: String) -> SKAction {
        let setFlashAction = SKAction.setTexture(SKTexture.init(imageNamed: flashName));
        let setTextureAction = SKAction.setTexture(SKTexture.init(imageNamed: textureName));
        let appearingSequenceAction = SKAction.sequence([setFlashAction, SKAction.wait(forDuration: 0.05), SKAction.fadeAlpha(to: 0.5, duration: 0.05), setTextureAction, SKAction.wait(forDuration: 0.1), setFlashAction, SKAction.wait(forDuration: 0.1), setTextureAction, SKAction.wait(forDuration: 0.1), setFlashAction, SKAction.wait(forDuration: 0.05), SKAction.fadeAlpha(to: 0.0, duration: 0.05)]);
        return appearingSequenceAction;
    }
}
