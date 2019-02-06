//
//  Projectile.swift
//  TicPongToe
//
//  Created by Nathan Lane on 1/30/19.
//  Copyright © 2019 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Projectile: SKSpriteNode {
    
    private var type:powerUpType = powerUpType.blaster_item;
    private var power_up_size:CGSize!;
    private var paddle:Paddle!;
    private var damage = 1;
    
    init(type: powerUpType) {
        self.type = type;
        var image_name = "BlasterRound1";
        power_up_size = CGSize(width: 16, height: 48.0);
        
        switch type {
        case .blaster_item:
            image_name = "BlasterRound1";
            power_up_size = CGSize(width: 16, height: 48.0);
            break;
        case .beam_item:
            image_name = "BeamRound1";
            power_up_size = CGSize(width: 16, height: 48.0);
            break;
        case .bomb_item:
            image_name = "Bomb";
            power_up_size = CGSize(width: 48, height: 48.0);
            break;
        case .big_bomb_item:
            image_name = "BigBomb";
            power_up_size = CGSize(width: 48, height: 48.0);
            break;
        default:
            break
        }
        
        super.init(texture: SKTexture(imageNamed: image_name), color: .clear, size: power_up_size)
        self.applyPhysicsBody();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func applyPhysicsBody()
    {
        self.physicsBody = SKPhysicsBody(rectangleOf: power_up_size);
        self.physicsBody?.categoryBitMask = self.type == .bomb_item ? 32 : 16;
        self.physicsBody?.collisionBitMask = 63
        self.physicsBody?.mass = 0.266666680574417;
        self.physicsBody?.linearDamping = 0;
        self.physicsBody?.angularDamping = 0;
        self.physicsBody?.restitution = 1;
        self.physicsBody?.isDynamic = true; // may change if its a bomb.
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.contactTestBitMask = self.type == .bomb_item ? 63 : 59;
        self.physicsBody?.affectedByGravity = false;
    }
    
    public func launch(by: Paddle) {
        self.paddle = by;
        var animation_frames:[SKTexture]!;
        var impulse:CGFloat = 40;
        var follower_animation_frames:[SKTexture]!;
        var follower_image_name = "BlasterFollower1";
        
        let impulse_direction:CGFloat = paddle.name == "main" ? 1.0 : -1.0;
        
        switch self.type {
        case .blaster_item:
            animation_frames = AnimationFramesManager?.blasterFrames;
            follower_animation_frames = AnimationFramesManager?.blasterFollowerFrames;
            follower_image_name = "BlasterFollower1";
            impulse = impulse_direction * 40;
            break;
        case .beam_item:
            //animation_frames = AnimationFramesManager?.blasterFrames;
            impulse = impulse_direction * 40;
            break;
        case .bomb_item:
            //animation_frames = AnimationFramesManager?.blasterFrames;
            impulse = impulse_direction * 40;
            break;
        default:
            break;
        }
        
        self.position = paddle.position;
        self.zPosition = paddle.zPosition;
        self.zRotation = paddle.name == "main" ? 0.0 : .pi;
        
        paddle.parent?.addChild(self);
        
        self.run(SKAction.repeatForever(SKAction.animate(with: animation_frames, timePerFrame: 0.1)));
        //self.createFollowers(follower_image_name: follower_image_name, follower_animation_frames: follower_animation_frames);
        self.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulse));
    }
    
    public func hit() {
        switch self.type {
        case .blaster_item:
            break;
        case .beam_item:
            break;
        case .bomb_item:
            break;
        default:
            break;
        }
    }
    
    public func explode() {
        switch self.type {
        case .blaster_item:
            break;
        case .beam_item:
            break;
        case .bomb_item:
            break;
        default:
            break;
        }
    }
    
    private func createFollowers(follower_image_name: String, follower_animation_frames: [SKTexture]) {
        if (paddle == nil) {return};
         self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 0.25), SKAction.run {
            self.createFollowers(follower_image_name: follower_image_name, follower_animation_frames: follower_animation_frames)
            }])));

    }
    
    private func createFollowerNode(follower_image_name: String, follower_animation_frames: [SKTexture]) {
        let follower_node = SKSpriteNode(imageNamed: follower_image_name);
        follower_node.position = self.position;
        follower_node.zPosition = self.zPosition;
        follower_node.zRotation = self.zRotation;
        follower_node.size = CGSize(width: follower_animation_frames[0].size().width / 2, height: follower_animation_frames[0].size().height / 2);
        paddle.parent?.addChild(follower_node);
        
        follower_node.run(SKAction.animate(with: follower_animation_frames, timePerFrame: 0.1), completion: {
            follower_node.removeFromParent();
        });
    }
}
