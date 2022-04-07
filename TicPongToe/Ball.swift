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

class Ball : SKSpriteNode {
    public var ballspeed:CGFloat = 40.0;
    public var ball_speed_minimum:CGFloat = 40.0;
    public var ball_speed_maximum:CGFloat = 75.0;
    
    private var noFastBallSpeed:CGFloat = 40.0;

    private var fireBallAFrames:[SKTexture] = [];
    private var fireBallBFrames:[SKTexture] = [];
    private var fireBallCFrames:[SKTexture] = [];
    private var ballStartFrames:[SKTexture] = [];
    private var squashedBallPaddleBottomTexture:SKTexture = SKTexture.init(imageNamed: "SquashedBallPaddleBottom");
    private var squashedBallPaddleTopTexture:SKTexture = SKTexture.init(imageNamed: "SquashedBallPaddleTop");
    private var squashedBallWallLeftTexture:SKTexture = SKTexture.init(imageNamed: "SquashedBallWallLeft");
    private var squashedBallWallRightTexture:SKTexture = SKTexture.init(imageNamed: "SquashedBallWallRight");
    private var defaultBallTexture:SKTexture = SKTexture.init(imageNamed: "Ball");
    
    private var fireBallA = SKSpriteNode();
    private var fireBallB = SKSpriteNode();
    private var fireBallC = SKSpriteNode();
    
    private var bounceAnglePivot = CGFloat.pi / 2;
    private var maximumBounceAngle = (5*CGFloat.pi) / 6;
    private var minimumBounceAngle = CGFloat.pi / 6;
    private var bounceAngle:CGFloat = 0.0;
    private var balldx:CGFloat = 0.0;
    private var balldy:CGFloat = 0.0;
    private var ball_start_position:CGPoint = CGPoint(x: 0, y: 30);
    private var ball_size:CGSize = CGSize(width: 20, height: 20);
    private var ballStartSpeed:CGFloat = 40.0;
    private var angle_offset = CGFloat(Double.pi / 2);
    
    private var default_size:CGSize = CGSize(width: 20.0, height: 20.0)
    private var squashed_paddle_size:CGSize = CGSize(width: 20.0, height: 20.0);
    private var squashed_wall_size:CGSize = CGSize(width: 20.0, height: 20.0);
    private var can_ordinate = true;
    private var fastBallPaddle:Paddle?;
    
    init () {
        super.init(texture: defaultBallTexture, color: .clear, size: ball_size);
        // All the speed settings get set to the minimum ball speed upon
        // start of the ball.
        ballspeed = ball_speed_minimum;
        noFastBallSpeed = ball_speed_minimum;
        ballStartSpeed = ball_speed_minimum;
        
        self.position = ball_start_position
        self.physicsBody?.usesPreciseCollisionDetection = true
        
        /*self.physicsBody = SKPhysicsBody(circleOfRadius: self.size.width/2);
        self.physicsBody?.isDynamic = true;
        self.physicsBody?.restitution = 1;
        self.physicsBody?.mass = 0.0566371232271194;
        self.physicsBody?.categoryBitMask = 2;
        self.physicsBody?.collisionBitMask = 55;*/
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
     Setting animations must come after init since the ANimationFramesManager doesn't buildFrames()
     until the after init() is called. This is due to ball existing in the GameScene.sks
     */
    public func setAnimationFrames() {
        fireBallAFrames = (AnimationFramesManager?.getFireBallAFrames())!;
        fireBallBFrames = (AnimationFramesManager?.getFireBallBFrames())!;
        fireBallCFrames = (AnimationFramesManager?.fireBallCFrames)!;
        ballStartFrames = (AnimationFramesManager?.getBallStartFrames())!;
        fireBallA = SKSpriteNode(imageNamed: "FireBallA1");
        fireBallA.size = CGSize(width: 30, height: 35);
        fireBallA.zPosition = 0.5;
        fireBallA.position = CGPoint(x: 0.0, y: -5.0)
        
        fireBallB = SKSpriteNode(imageNamed: "FireBallB1");
        fireBallB.size = CGSize(width: 30, height: 35);
        fireBallB.zPosition = 0.5;
        fireBallB.position = CGPoint(x: 0.0, y: -5.0)
        
        fireBallC = SKSpriteNode(imageNamed: "FireBallC1");
        fireBallC.size = CGSize(width: 30, height: 35);
        fireBallC.zPosition = 0.5;
        fireBallC.position = CGPoint(x: 0.0, y: -5.0)
    }
    
    private func animateFireBall(ball_type: Int)
    {
        if (ball_type == 0) {
            self.removeAllChildren();
        }
        else if (ball_type == 1 && fireBallA.parent == nil) {
            fireBallB.removeFromParent();
            fireBallC.removeFromParent();
            
            if (!fireBallA.hasActions()) {
                fireBallA.run(SKAction.repeatForever(SKAction.animate(with: fireBallAFrames, timePerFrame: 0.2)))
            }
        
            self.addChild(fireBallA);
        }
        else if (ball_type == 2 && fireBallB.parent == nil) {
            fireBallA.removeFromParent();
            fireBallC.removeFromParent();
            
            if (!fireBallB.hasActions()) {
                fireBallB.run(SKAction.repeatForever(SKAction.animate(with: fireBallBFrames, timePerFrame: 0.2)))
            }
            
            self.addChild(fireBallB);
        }
        else if (ball_type == 3 && fireBallC.parent == nil) {
            fireBallA.removeFromParent();
            fireBallB.removeFromParent();
            
            if (!fireBallC.hasActions()) {
                fireBallC.run(SKAction.repeatForever(SKAction.animate(with: fireBallCFrames, timePerFrame: 0.2)))
            }
            
            self.addChild(fireBallC);
        }
    }
    
    public func ordinateBall()
    {
        if let body = self.physicsBody {
            if (body.velocity.speed() > 0.01 && can_ordinate) {
                self.zRotation = body.velocity.angle() - angle_offset;
            }
        }
    }
    
    // This function animates and times ball properly whenever it starts
    public func startBall(down: Bool)
    {
        self.removeAllChildren();
        self.isHidden = true;
        self.position = ball_start_position
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0);
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
        
        self.run(startBallSequence, completion: {[weak self] in
            self!.physicsBody?.applyImpulse(CGVector(dx: 0, dy: impulse))
            self!.setFireBall();
        })
    }
    
    public func hideBall() {
        self.isHidden = true;
        self.position = ball_start_position
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0);
    }
    
    private func getBallReturnSpeed(paddle_speed: CGFloat) -> CGFloat
    {
        var return_speed = noFastBallSpeed;
        
        
        if (abs(paddle_speed) >= 0.15)
        {
            return_speed = return_speed + 20 * abs(paddle_speed);
            if (return_speed > ball_speed_maximum) {return_speed = ball_speed_maximum}
        }
        else
        {
            return_speed = return_speed - 7 * (1 - abs(paddle_speed));
            if (return_speed < ball_speed_minimum) {return_speed = ball_speed_minimum}
        }
        
        return return_speed;
    }
    
    public func bounceBall(_ contact: SKPhysicsContact, paddle: Paddle, paddle_speed: CGFloat) {
        let contactPoint = contact.contactPoint
        let offset = paddle.position.x - contactPoint.x;
        let dy_reflection:CGFloat = contact.bodyA.node?.name == "enemy" ? -1.0 : 1.0;
        let return_speed = paddle.checkIfFastBall() ? paddle.getFastBallSpeed() : getBallReturnSpeed(paddle_speed: paddle_speed)
        bounceAngle = bounceAnglePivot + ((CGFloat.pi/3)*(2/(paddle.size.width))*offset);
    
        if (bounceAngle > maximumBounceAngle) {bounceAngle = maximumBounceAngle}
        else if (bounceAngle < minimumBounceAngle) {bounceAngle = minimumBounceAngle}
        
        balldy = dy_reflection*return_speed*sin(bounceAngle);
        balldx = return_speed*cos(bounceAngle);
        
        ballspeed = return_speed;
        noFastBallSpeed = paddle.checkIfFastBall() ? noFastBallSpeed : return_speed;
        
        self.physicsBody?.velocity = CGVector(dx: 0, dy: 0);
        self.physicsBody?.applyImpulse(CGVector(dx: balldx, dy: balldy))
        
        setFireBall();
    }
    
    private func setFireBall()
    {
        
        if (ballspeed <= 48.0) {
            animateFireBall(ball_type: 0)
        }
        else if (48.0 < ballspeed && ballspeed <= 56.0){
            animateFireBall(ball_type: 1);
        }
        else if (56.0 < ballspeed && ballspeed <= 65.0) {
            animateFireBall(ball_type: 2);
        }
        else {
            animateFireBall(ball_type: 3);
        }
    }
}


