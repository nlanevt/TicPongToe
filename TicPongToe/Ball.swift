//
//  Ball.swift
//  TicPongToe
//
//  Created by Nathan Lane on 10/6/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class Ball  {
    private var fireBallFrames:[SKTexture] = [];
    private var ballStartFrames:[SKTexture] = [];
    
    public var balldx:CGFloat = 0.0;
    public var balldy:CGFloat = 0.0;
    public var ballspeed:CGFloat = 40.0;
    public var ball_start_position:CGPoint = CGPoint(x: 0, y: 30);
    private var ballStartSpeed:CGFloat = 40.0;
    private var ball = SKSpriteNode();
    private var angle_offset = CGFloat(Double.pi / 2);
    
    init(ball: inout SKSpriteNode)
    {
        fireBallFrames = (AnimationFramesManager?.getFireBallFrames())!;
        ballStartFrames = (AnimationFramesManager?.getBallStartFrames())!;
        self.ball = ball;
        self.ball.physicsBody?.usesPreciseCollisionDetection = true
        self.ball.physicsBody?.categoryBitMask = 2
    }
    
    init()
    {
        
    }
    
    public func setUp(ball: inout SKSpriteNode)
    {
        fireBallFrames = (AnimationFramesManager?.getFireBallFrames())!;
        ballStartFrames = (AnimationFramesManager?.getBallStartFrames())!;
        self.ball = ball;
        self.ball.physicsBody?.usesPreciseCollisionDetection = true
        self.ball.physicsBody?.categoryBitMask = 2
    }
    
    private func animateFireBall(ball_type: Int)
    {
        if (ball_type == 0) {
            ball.removeAllChildren();
        }
        else if (ball_type == 1) {
            let fireball = SKSpriteNode(imageNamed: "FireBall1");
            fireball.size = CGSize(width: 30, height: 35);
            fireball.zPosition = 0.5;
            fireball.run(SKAction.repeatForever(SKAction.animate(with: fireBallFrames, timePerFrame: 0.1)))
            ball.addChild(fireball);
        }
    }
    
    public func ordinateBall()
    {
        if let body = ball.physicsBody {
            if (body.velocity.speed() > 0.01) {
                ball.zRotation = body.velocity.angle() - angle_offset;
            }
        }
    }
    
    // This function animates and times ball properly whenever it starts
    private func startBall(down: Bool)
    {
        
        ball.isHidden = true;
        ball.position = ball_start_position
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0);
        var impulse = ballStartSpeed;
        if (down == true)
        {
            impulse = -impulse;
        }
        
        let waitAction = SKAction.wait(forDuration: 0.25);
        let unHideAction = SKAction.unhide();
        let setBallTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Ball"));
        let ballGrowAction = SKAction.animate(with: ballStartFrames, timePerFrame: 0.01)
        let startBallSequence = SKAction.sequence([waitAction, unHideAction, ballGrowAction, setBallTextureAction, waitAction]);
        
        ball.run(startBallSequence, completion: {
            self.ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulse))
        })
    }
    
}


