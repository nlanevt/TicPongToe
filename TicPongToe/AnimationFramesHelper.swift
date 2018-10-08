//
//  AnimationFramesHelper.swift
//  TicPongToe
//
//  Created by Nathan Lane on 8/23/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit

class AnimationFramesHelper {
    private var paddleDeathFrames: [SKTexture] = [];
    private var paddle96ShrinkFrames: [SKTexture] = [];
    private var paddle72ShrinkFrames: [SKTexture] = [];
    private var paddle48ShrinkFrames: [SKTexture] = [];
    private var paddle24GrowFrames: [SKTexture] = [];
    private var paddle48GrowFrames: [SKTexture] = [];
    private var paddle72GrowFrames: [SKTexture] = [];
    private var ballStartFrames: [SKTexture] = [];
    private var lifeShrinkFrames:[SKTexture] = [];
    private var lifeGrowFrames:[SKTexture] = [];
    private var hitWallFrames:[SKTexture] = [];
    private var hitPaddleFrames:[SKTexture] = [];
    private var paddleGrowthFrames:[SKTexture] = [];
    private var fireBallFrames:[SKTexture] = [];
    
    private var sceneHeight:CGFloat = 0.0;
    private var backgroundNodeA1:SKSpriteNode? = nil;
    private var backgroundNodeA2:SKSpriteNode? = nil;
    
    init()
    {
        paddleDeathFrames = buildAnimation(textureAtlasName: "Paddle96Death");
        paddle96ShrinkFrames = buildAnimation(textureAtlasName: "Paddle96Shrink");
        paddle72ShrinkFrames = buildAnimation(textureAtlasName: "Paddle72Shrink");
        paddle48ShrinkFrames = buildAnimation(textureAtlasName: "Paddle48Shrink");
        paddle24GrowFrames = paddle48ShrinkFrames.reversed();
        paddle48GrowFrames = paddle72ShrinkFrames.reversed();
        paddle72GrowFrames = paddle96ShrinkFrames.reversed();
        ballStartFrames = buildAnimation(textureAtlasName: "BallStart");
        lifeShrinkFrames = buildAnimation(textureAtlasName: "LifeShrink");
        lifeGrowFrames = lifeShrinkFrames.reversed();
        hitWallFrames = buildAnimation(textureAtlasName: "HitWallAnimation");
        hitPaddleFrames = buildAnimation(textureAtlasName: "HitPaddleAnimation");
        paddleGrowthFrames = buildAnimation(textureAtlasName: "PaddleGrowth").reversed();
        fireBallFrames = buildAnimation(textureAtlasName: "FireBall");
    }
    
    public func getFireBallFrames() -> [SKTexture]
    {
        return fireBallFrames;
    }
    
    public func getPaddleGrowthFrames() -> [SKTexture]
    {
        return paddleGrowthFrames;
    }
    
    public func getPaddleDeathFrames() -> [SKTexture]
    {
        return paddleDeathFrames;
    }
    
    public func getHitPaddleFrames() -> [SKTexture]
    {
        return hitPaddleFrames;
    }
    
    public func getHitWallFrames() -> [SKTexture]
    {
        return hitWallFrames;
    }
    
    public func getLifeGrowFrames() -> [SKTexture]
    {
        return lifeGrowFrames;
    }
    
    public func getLifeShrinkFrames() -> [SKTexture]
    {
        return lifeShrinkFrames
    }
    
    public func getBallStartFrames() -> [SKTexture]
    {
        return ballStartFrames
    }
    
    public func getPaddle72GrowFrames() -> [SKTexture]
    {
        return paddle72GrowFrames;
    }
    
    public func getPaddle48GrowFrames() -> [SKTexture]
    {
        return paddle48GrowFrames;
    }
    
    public func getPaddle24GrowFrames() -> [SKTexture]
    {
        return paddle24GrowFrames;
    }
    
    public func getPaddle48ShrinkFrames() -> [SKTexture]
    {
        return paddle48ShrinkFrames;
    }
    
    public func getPaddle96ShrinkFrames() -> [SKTexture]
    {
        return paddle96ShrinkFrames;
    }
    
    public func getPaddle72ShrinkFrames() -> [SKTexture]
    {
        return paddle72ShrinkFrames
    }
    
    private func buildAnimation(textureAtlasName: String) -> [SKTexture]
    {
        let atlas = SKTextureAtlas(named: textureAtlasName);
        var frames: [SKTexture] = [];
        let numImages = atlas.textureNames.count
        for i in 1...numImages {
            let name = "\(textureAtlasName)\(i)"
            frames.append(atlas.textureNamed(name))
        }
        
        return frames;
    }
}
