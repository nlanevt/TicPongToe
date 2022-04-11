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
    private var smallA_texture:SKTexture = SKTexture.init(imageNamed: "Paddle72");
    private var smallB_texture:SKTexture = SKTexture.init(imageNamed: "Paddle48");
    private var smallC_texture:SKTexture = SKTexture.init(imageNamed: "Paddle24");
    private var bigBoy_texture:SKTexture = SKTexture.init(imageNamed: "Paddle192");
    private var superBigBoy_texture:SKTexture = SKTexture.init(imageNamed: "Paddle288");

    private var BigBoyActionKey = "BigBoyAction";
    private var FastBallActionKey = "FastBallAction";
    
    public var down = false; //if down == true, then it's the enemy; else if false it is the player
    public var paddle_speed = CGFloat.init(0);
    private var fastBallSpeed:CGFloat = 0.0;
    private var isDying = false;
    private var isGrowing = false;
    
    public static var default_paddle_width = CGFloat.init(96);
    private static var fastBallDefaultSpeed:CGFloat = 60;
    private static var superFastBallDefaultSpeed:CGFloat = 75;
    private static var smallA_paddle_width:CGFloat = 72;
    private static var smallB_paddle_width:CGFloat = 48;
    private static var smallC_paddle_width:CGFloat = 24;
    private static var bigBoy_width = CGFloat.init(192);
    private static var superBigBoy_width = CGFloat.init(288);
    
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
        //self.physicsBody?.contactTestBitMask = down ? 2 : 1 // 2 if the enemy paddle; 1 if player
        self.physicsBody?.contactTestBitMask = 2;
    }
    
    /*
     * Completely removes paddle, except doesn't delete the node
     * Used when the game is over.
     */
    public func animateRemoval()
    {
        resetPaddle();
        isDying = true;
        let deathAction = SKAction.animate(with: paddleDeathFrames, timePerFrame: 0.025);
        self.size.width = 256;
        self.run(deathAction, completion: {
            [weak self] in
            self!.isHidden = true;
            self!.physicsBody = nil;
        })
    }
    
    /*
     ** Used when scored on and paddle is deleted and regenerated.
     */
    public func animateDeath(completion: @escaping ()->Void)
    {
        resetPaddle();
        isDying = true;
        self.texture = paddleDeathFrames[0];
        self.size.width = 256;
        self.run(SKAction.sequence([SKAction.unhide(), SKAction.animate(with: paddleDeathFrames, timePerFrame: 0.025)]), completion: {
            [weak self] in
            self!.resetPaddle();
            self!.isDying = false;
            completion();
        })
    }
    
    // Grow the paddle
    public func animateGrowth(completion: @escaping ()->Void) {
        resetPaddle();
        isGrowing = true;
        self.run(SKAction.sequence([SKAction.unhide(), SKAction.animate(with: paddleGrowthFrames, timePerFrame: 0.01), SKAction.setTexture(default_texture)]), completion: {
            [weak self] in
            self!.resetPaddle();
            self!.isGrowing = false;
            self!.applyPhysicsBody();
            completion();
        })
    }
    
    // This method does the paddle shrink animation
    public func shrink()
    {
        var shrinkAction:SKAction? = nil;
        var setFinalPaddleTextureAction:SKAction? = nil;
        if (self.size.width <= 0) {return}
        
        if (self.size.width == Paddle.default_paddle_width)
        {
            shrinkAction = SKAction.animate(with: paddle96ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(self.getCurrentPaddleSprite());
        }
        else if (self.size.width == Paddle.smallA_paddle_width)
        {
            shrinkAction = SKAction.animate(with: paddle72ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(self.getCurrentPaddleSprite());
        }
        else if (self.size.width == Paddle.smallB_paddle_width)
        {
            shrinkAction = SKAction.animate(with: paddle48ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(self.getCurrentPaddleSprite());
        }
        else if (self.size.width == Paddle.smallC_paddle_width)
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
            [weak self] in
            self!.size.width = self!.size.width - self!.paddle_size_decrement;
            self!.applyPhysicsBody();
        })
    }
    
    public func grow()
    {
        var growAction:SKAction? = nil;
        var setFinalPaddleTextureAction:SKAction? = nil;
        
        if (self.size.width >= Paddle.default_paddle_width) {return}
        
        if (self.size.width == Paddle.smallA_paddle_width)
        {
            growAction = SKAction.animate(with: paddle72GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(self.getCurrentPaddleSprite());
        }
        else if (self.size.width == Paddle.smallB_paddle_width)
        {
            growAction = SKAction.animate(with: paddle48GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(self.getCurrentPaddleSprite());
        }
        else if (self.size.width == Paddle.smallC_paddle_width)
        {
            growAction = SKAction.animate(with: paddle24GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(self.getCurrentPaddleSprite());
        }
        else
        {
            return;
        }
        self.size.width = self.size.width + self.paddle_size_decrement;
        let growSequence = SKAction.sequence([growAction!, setFinalPaddleTextureAction!]);
        self.run(growSequence, completion: {
            [weak self] in
            self!.applyPhysicsBody();
        })
    }
    
    public func updateSpeed()
    {
        paddle_speed = (self.position.x - previous_position)/60.0;
        previous_position = self.position.x;
    }
    
    public func runFastBallPowerUp(is_super: Bool) {
        if (isDying || isGrowing) {return}
        
        if (fastBallSpeed > 0) {
            self.removeAction(forKey: FastBallActionKey)
        }
        
        fastBallSpeed = is_super ? Paddle.superFastBallDefaultSpeed : Paddle.fastBallDefaultSpeed;
        
        let flashingAction = SKAction.run({[weak self] in self!.texture = self!.getFlashSprite()});
        let setTextureAction = SKAction.run({[weak self] in self!.texture = self!.getCurrentPaddleSprite()});
        let waitAction = SKAction.wait(forDuration: 0.1);
        
        let appearingAction = SKAction.sequence([flashingAction, waitAction, setTextureAction]);
    
        self.run(SKAction.sequence([appearingAction, waitAction, appearingAction, SKAction.wait(forDuration: 10), appearingAction, waitAction, flashingAction, waitAction, SKAction.run({[weak self] in self!.fastBallSpeed = 0}), setTextureAction]), withKey: FastBallActionKey);
    }
    
    public func checkIfFastBall() -> Bool {
        return fastBallSpeed > 0;
    }
    
    public func getFastBallSpeed() -> CGFloat {
        return fastBallSpeed;
    }
    
    public func runBigBoyBoosterPowerUp(is_super: Bool) {
        if (isDying || isGrowing) {return}
        
        if (self.size.width > Paddle.default_paddle_width) {
            self.removeAction(forKey: BigBoyActionKey);
        }
        
        self.size.width = Paddle.bigBoy_width;
        var flashingAction = SKAction.setTexture(SKTexture.init(imageNamed: "Paddle192Flash"));

        if (is_super) {
            self.size.width = Paddle.superBigBoy_width
            flashingAction = SKAction.setTexture(SKTexture.init(imageNamed: "Paddle288Flash"));
        }
        
        self.applyPhysicsBody()
        let waitAction = SKAction.wait(forDuration: 0.1);
        let defaultTextureFlashAction = SKAction.setTexture(SKTexture.init(imageNamed: "Paddle96Flash"));
        let slowWaitAction = SKAction.wait(forDuration: 0.2);
        let flashingPaddleAction = SKAction.sequence([flashingAction, waitAction, SKAction.hide(), waitAction, SKAction.unhide(),
                                                 waitAction, SKAction.hide(), waitAction, SKAction.unhide(),
                                                 waitAction, SKAction.hide(), waitAction, SKAction.unhide(),
                                                 waitAction, SKAction.hide(), waitAction, SKAction.unhide(),
                                                 waitAction, SKAction.run({[weak self] in self!.texture = self!.getCurrentPaddleSprite()})])
        let disappearingAction = SKAction.sequence([flashingAction, slowWaitAction, SKAction.hide(), slowWaitAction, SKAction.unhide(),
                                                 slowWaitAction, SKAction.hide(), slowWaitAction, SKAction.unhide(),
                                                 slowWaitAction, SKAction.hide(), slowWaitAction])
        let reappearingDefaultAction = SKAction.sequence([SKAction.run({[weak self] in self!.size.width = Paddle.default_paddle_width; self!.applyPhysicsBody()}), defaultTextureFlashAction, SKAction.unhide(), slowWaitAction, SKAction.hide(), slowWaitAction, SKAction.unhide(), slowWaitAction, SKAction.run({[weak self] in self!.texture = self!.getCurrentPaddleSprite()})])
        
        self.run(SKAction.sequence([flashingPaddleAction, SKAction.wait(forDuration: 9), disappearingAction, reappearingDefaultAction]), withKey: BigBoyActionKey)
    }
    
    public func resetPaddle() {
        if (self.hasActions()) {
            self.removeAllActions();
        }
        
        self.size.width = Paddle.default_paddle_width
        fastBallSpeed = 0;
        isDying = false;
        isGrowing = false;
    }
    
    private func getCurrentPaddleSprite() -> SKTexture {
        if (self.size.width == Paddle.default_paddle_width) {
            if (fastBallSpeed <= 0) {
                return default_texture;
            }
            else if (fastBallSpeed == Paddle.fastBallDefaultSpeed) {
                return SKTexture.init(imageNamed: "Paddle96Fast");
            }
            else { //Paddle.superFastBallDefaultSpeed
                return SKTexture.init(imageNamed: "Paddle96SuperFast");
            }
        }
        else if (self.size.width < Paddle.default_paddle_width) { //Shrunk sizes
            if (self.size.width == Paddle.smallA_paddle_width) {
                if (fastBallSpeed <= 0) {
                    return smallA_texture;
                }
                else if (fastBallSpeed == Paddle.fastBallDefaultSpeed) {
                    return SKTexture.init(imageNamed: "Paddle72Fast");
                }
                else { //Paddle.superFastBallDefaultSpeed
                    return SKTexture.init(imageNamed: "Paddle72SuperFast");
                }
            }
            else if (self.size.width == Paddle.smallB_paddle_width) {
                if (fastBallSpeed <= 0) {
                    return smallB_texture;
                }
                else if (fastBallSpeed == Paddle.fastBallDefaultSpeed) {
                    return SKTexture.init(imageNamed: "Paddle48Fast");
                }
                else { //Paddle.superFastBallDefaultSpeed
                    return SKTexture.init(imageNamed: "Paddle48SuperFast");
                }
            }
            else { //Paddle.smallC_paddle_width
                if (fastBallSpeed <= 0) {
                    return smallC_texture;
                }
                else if (fastBallSpeed == Paddle.fastBallDefaultSpeed) {
                    return SKTexture.init(imageNamed: "Paddle24Fast");
                }
                else { //Paddle.superFastBallDefaultSpeed
                    return SKTexture.init(imageNamed: "Paddle24SuperFast");
                }
            }
        }
        else { //BigBoy sizes
            if (self.size.width == Paddle.bigBoy_width) {
                if (fastBallSpeed <= 0) {
                    return bigBoy_texture;
                }
                else if (fastBallSpeed == Paddle.fastBallDefaultSpeed) {
                    return SKTexture.init(imageNamed: "Paddle192Fast");
                }
                else { //Paddle.superFastBallDefaultSpeed
                    return SKTexture.init(imageNamed: "Paddle192SuperFast");
                }
            }
            else { //SuperBigBoy width
                if (fastBallSpeed <= 0) {
                    return superBigBoy_texture;
                }
                else if (fastBallSpeed == Paddle.fastBallDefaultSpeed) {
                    return SKTexture.init(imageNamed: "Paddle288Fast");
                }
                else { //Paddle.superFastBallDefaultSpeed
                    return SKTexture.init(imageNamed: "Paddle288SuperFast");
                }
            }
        }
    }
    
    private func getFlashSprite() -> SKTexture {
        switch self.size.width {
        case Paddle.default_paddle_width:
            return SKTexture.init(imageNamed: "Paddle96Flash");
        case Paddle.bigBoy_width:
            return SKTexture.init(imageNamed: "Paddle192Flash");
        case Paddle.superBigBoy_width:
            return SKTexture.init(imageNamed: "Paddle288Flash")
        case Paddle.smallA_paddle_width:
            return SKTexture.init(imageNamed: "Paddle72Flash");
        case Paddle.smallB_paddle_width:
            return SKTexture.init(imageNamed: "Paddle48Flash");
        case Paddle.smallC_paddle_width:
            return SKTexture.init(imageNamed: "Paddle24Flash");
        default:
            return SKTexture.init(imageNamed: "Paddle96Flash");
        }
    }
}
