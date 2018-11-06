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
    public var ballspeed:CGFloat = 40.0;

    private var fireBallAFrames:[SKTexture] = [];
    private var fireBallBFrames:[SKTexture] = [];
    private var ballStartFrames:[SKTexture] = [];
    
    private var fireBallA = SKSpriteNode();
    private var fireBallB = SKSpriteNode();
    
    private var bounceAnglePivot = CGFloat.pi / 2;
    private var maximumBounceAngle = (5*CGFloat.pi) / 6;
    private var minimumBounceAngle = CGFloat.pi / 6;
    private var bounceAngle:CGFloat = 0.0;
    private var balldx:CGFloat = 0.0;
    private var balldy:CGFloat = 0.0;
    private var ball_start_position:CGPoint = CGPoint(x: 0, y: 30);
    private var ballStartSpeed:CGFloat = 40.0;
    public var ball = SKSpriteNode();
    private var angle_offset = CGFloat(Double.pi / 2);
    
    public func setUp(ball: inout SKSpriteNode)
    {
        fireBallAFrames = (AnimationFramesManager?.getFireBallAFrames())!;
        fireBallBFrames = (AnimationFramesManager?.getFireBallBFrames())!;
        ballStartFrames = (AnimationFramesManager?.getBallStartFrames())!;
        self.ball = ball;
        self.ball.physicsBody?.usesPreciseCollisionDetection = true
        self.ball.physicsBody?.categoryBitMask = 2
        
        fireBallA = SKSpriteNode(imageNamed: "FireBallA1");
        fireBallA.size = CGSize(width: 30, height: 35);
        fireBallA.zPosition = 0.5;
        fireBallA.position = CGPoint(x: 0.0, y: -5.0)
        
        fireBallB = SKSpriteNode(imageNamed: "FireBallB1");
        fireBallB.size = CGSize(width: 30, height: 35);
        fireBallB.zPosition = 0.5;
        fireBallB.position = CGPoint(x: 0.0, y: -5.0)
    }
    
    private func animateFireBall(ball_type: Int)
    {
        
        if (ball_type == 0) {
            ball.removeAllChildren();
        }
        else if (ball_type == 1 && fireBallA.parent == nil) {
            fireBallB.removeFromParent();
            
            if (!fireBallA.hasActions()) {
                fireBallA.run(SKAction.repeatForever(SKAction.animate(with: fireBallAFrames, timePerFrame: 0.2)))
            }
        
            ball.addChild(fireBallA);
        }
        else if (ball_type == 2 && fireBallB.parent == nil) {
            fireBallA.removeFromParent();
            
            if (!fireBallB.hasActions()) {
                fireBallB.run(SKAction.repeatForever(SKAction.animate(with: fireBallBFrames, timePerFrame: 0.2)))
            }
            
            ball.addChild(fireBallB);
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
    public func startBall(down: Bool)
    {
        ball.removeAllChildren();
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
            self.setFireBall();
        })
    }
    
    private func getBallReturnSpeed(paddle_speed: CGFloat) -> CGFloat
    {
        var return_speed = ballspeed;
        if (abs(paddle_speed) >= 0.15)
        {
            return_speed = return_speed + 20 * abs(paddle_speed);
            if (return_speed > 60.0) {return_speed = 60.0}
        }
        else
        {
            return_speed = return_speed - 3 * (1 - abs(paddle_speed));
            if (return_speed < 40.0) {return_speed = 40.0}
        }
        
        return return_speed;
    }
    
    public func bounceBall(_ contact: SKPhysicsContact, paddle: SKSpriteNode, paddle_speed: CGFloat) {
        let contactPoint = contact.contactPoint
        let offset = paddle.position.x - contactPoint.x;
        let dy_reflection:CGFloat = contact.bodyA.node?.name == "enemy" ? -1.0 : 1.0;
        let return_speed = getBallReturnSpeed(paddle_speed: paddle_speed)
        
        bounceAngle = bounceAnglePivot + ((CGFloat.pi/3)*(2/(paddle.size.width))*offset);
    
        if (bounceAngle > maximumBounceAngle) {bounceAngle = maximumBounceAngle}
        else if (bounceAngle < minimumBounceAngle) {bounceAngle = minimumBounceAngle}
        
        balldy = dy_reflection*return_speed*sin(bounceAngle);
        balldx = return_speed*cos(bounceAngle);
        ballspeed = return_speed;
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0);
        ball.physicsBody?.applyImpulse(CGVector(dx: balldx, dy: balldy))
        
        setFireBall();
    }
    
    private func setFireBall()
    {
        if (ballspeed <= 48) {
            animateFireBall(ball_type: 0)
        }
        else if (48 < ballspeed && ballspeed <= 56){
            animateFireBall(ball_type: 1);
        }
        else {
            animateFireBall(ball_type: 2);
        }
    }
    
    public func resetBallAtGameOver()
    {
        
    }
}


