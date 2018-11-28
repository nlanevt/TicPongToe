//
//  Paddle.swift
//  TicPongToe
//
//  Created by Nathan Lane on 11/27/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit


class Paddle: SKSpriteNode {
    
    private var paddle_physics_height:CGFloat = CGFloat.init(15.0);
    private var previous_position = CGFloat.init(0);
    
    private var paddle_size_decrement:CGFloat = 24;
    private var paddleDeathFrames: [SKTexture] = [];
    private var paddle96ShrinkFrames: [SKTexture] = [];
    private var paddle72ShrinkFrames: [SKTexture] = [];
    private var paddle48ShrinkFrames: [SKTexture] = [];
    private var paddle24GrowFrames: [SKTexture] = [];
    private var paddle48GrowFrames: [SKTexture] = [];
    private var paddle72GrowFrames: [SKTexture] = [];
    private var paddleGrowthFrames:[SKTexture] = [];
    private var default_texture_name = "Paddle96";
    private var default_texture:SKTexture = SKTexture.init(imageNamed: "Paddle96");
    
    public var down = false; //if down == true, then it's the enemy; else if false it is the player
    public var paddle_speed = CGFloat.init(0);
    public var paddle_width = CGFloat.init(96);
    
    /*
     * if direction_down == true, then it's the enemy; else if false it is the player
     */
    init(direction_down: Bool) {
        down = direction_down;
        default_texture = SKTexture(imageNamed: "Paddle96");
        super.init(texture: default_texture, color: .clear, size: default_texture.size());
        applyPhysicsBody();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func setAnimationFrames() {
        // Build animation frames
        paddleDeathFrames = (AnimationFramesManager?.getPaddleDeathFrames())!;
        paddle96ShrinkFrames = (AnimationFramesManager?.getPaddle96ShrinkFrames())!;
        paddle72ShrinkFrames = (AnimationFramesManager?.getPaddle72ShrinkFrames())!;
        paddle48ShrinkFrames = (AnimationFramesManager?.getPaddle48ShrinkFrames())!;
        paddle24GrowFrames = (AnimationFramesManager?.getPaddle24GrowFrames())!;
        paddle48GrowFrames = (AnimationFramesManager?.getPaddle48GrowFrames())!;
        paddle72GrowFrames = (AnimationFramesManager?.getPaddle72GrowFrames())!;
        paddleGrowthFrames = (AnimationFramesManager?.getPaddleGrowthFrames())!;
    }
    
    public func applyPhysicsBody()
    {
        self.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.size.width, height: paddle_physics_height));
        self.physicsBody?.categoryBitMask = 1
        self.physicsBody?.collisionBitMask = 2
        self.physicsBody?.mass = 0.266666680574417;
        self.physicsBody?.linearDamping = 0.1;
        self.physicsBody?.angularDamping = 0.1;
        self.physicsBody?.isDynamic = false;
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.contactTestBitMask = down ? 2 : 1 // 2 if the enemy paddle; 1 if player
    }
    
    /*
     * Completely removes paddle, except doesn't delete the node
     * Used when the game is over.
     */
    public func animateRemoval()
    {
        let deathAction = SKAction.animate(with: paddleDeathFrames, timePerFrame: 0.025);
        self.size.width = 256;
        self.run(deathAction, completion: {
            self.isHidden = true;
            
            self.physicsBody = nil;
        })
    }
    
    /*
     ** Used when scored on and paddle is deleted and regenerated.
     */
    public func animateDeath(completion: @escaping ()->Void)
    {
        
        self.texture = paddleDeathFrames[0];
        self.size.width = 256;
        self.run(SKAction.animate(with: paddleDeathFrames, timePerFrame: 0.025), completion: {
            self.size.width = self.paddle_width;
            completion();
        })
    }
    
    // Grow the paddle
    public func animateGrowth(completion: @escaping ()->Void) {
        self.size.width = paddle_width;
        self.run(SKAction.sequence([SKAction.animate(with: paddleGrowthFrames, timePerFrame: 0.01), SKAction.setTexture(default_texture)]), completion: {
            self.size.width = self.paddle_width;
            self.applyPhysicsBody();
            completion();
        })
    }
    
    // This method does the paddle shrink animation
    public func shrink()
    {
        var shrinkAction:SKAction? = nil;
        var setFinalPaddleTextureAction:SKAction? = nil;
        
        if (self.size.width == 96)
        {
            shrinkAction = SKAction.animate(with: paddle96ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle72"));
        }
        else if (self.size.width == 72)
        {
            shrinkAction = SKAction.animate(with: paddle72ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle48"));
        }
        else if (self.size.width == 48)
        {
            shrinkAction = SKAction.animate(with: paddle48ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle24"));
        }
        else if (self.size.width == 24)
        {
            self.size.width = self.size.width - self.paddle_size_decrement;
            applyPhysicsBody();
            return;
        }
        else
        {
            return;
        }
        
        let shrinkSequence = SKAction.sequence([shrinkAction!, setFinalPaddleTextureAction!]);
        self.run(shrinkSequence, completion: {
            self.size.width = self.size.width - self.paddle_size_decrement;
            self.applyPhysicsBody();
        })
    }
    
    public func grow()
    {
        var growAction:SKAction? = nil;
        var setFinalPaddleTextureAction:SKAction? = nil;
        
        if (self.size.width == 72)
        {
            growAction = SKAction.animate(with: paddle72GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(default_texture);
        }
        else if (self.size.width == 48)
        {
            growAction = SKAction.animate(with: paddle48GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle72"));
        }
        else if (self.size.width == 24)
        {
            growAction = SKAction.animate(with: paddle24GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle48"));
        }
        else
        {
            return;
        }
        self.size.width = self.size.width + self.paddle_size_decrement;
        let growSequence = SKAction.sequence([growAction!, setFinalPaddleTextureAction!]);
        self.run(growSequence, completion: {
            self.applyPhysicsBody();
        })
    }
    
    public func updateSpeed()
    {
        paddle_speed = (self.position.x - previous_position)/60.0;
        previous_position = self.position.x;
    }
}
