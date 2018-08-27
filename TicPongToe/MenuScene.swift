//
//  MenuScene.swift
//  TicPongToe
//
//  Created by Nathan Lane on 8/1/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import UIKit

class MenuScene: SKScene, SKPhysicsContactDelegate {
    
    private var HighScoreLabel = SKLabelNode();
    private var GamesWonLabel = SKLabelNode();
    private var menuFrame = SKSpriteNode();
    private var menuAnimationAFrames:[SKTexture] = [];
    private var menuAnimationBFrames:[SKTexture] = [];
    private var menuAnimationCFrames:[SKTexture] = [];
    private var menuAnimationDFrames:[SKTexture] = [];
    
    
    override func didMove(to view: SKView)
    {
        super.didMove(to: view);
        
        HighScoreLabel = self.childNode(withName: "HighScoreLabel") as! SKLabelNode;
        GamesWonLabel = self.childNode(withName: "GamesWonLabel") as! SKLabelNode;
        menuFrame = self.childNode(withName: "MenuFrame") as! SKSpriteNode
        
        menuAnimationAFrames = (AnimationFramesManager?.getMenuAnimationAFrames())!
        menuAnimationBFrames = (AnimationFramesManager?.getMenuAnimationBFrames())!
        menuAnimationCFrames = (AnimationFramesManager?.getMenuAnimationCFrames())!
        menuAnimationDFrames = (AnimationFramesManager?.getMenuAnimationDFrames())!
        
        updateLabels();
        
        
        self.physicsWorld.contactDelegate = self;
        let border = SKPhysicsBody(edgeLoopFrom: self.frame);
        border.friction = 0;
        border.restitution = 1;
        self.physicsBody = border;
        
        animateBackground(frames: menuAnimationAFrames);
        animateBackground(frames: menuAnimationBFrames);
        animateBackground(frames: menuAnimationCFrames);
        animateBackground(frames: menuAnimationDFrames);
        
        self.backgroundColor = SKColor.black;
    }
    
    public func updateLabels()
    {
        HighScoreLabel.text = "\(HighScore)";
        GamesWonLabel.text = "\(NumberOfGamesWon)";
       
    }
    
    public func setHighScoreLabel(score: Int64)
    {
        HighScoreLabel.text = "\(score)";
    }
    
    public func setGamesWonLabel(score: Int64)
    {
        GamesWonLabel.text = "\(score)";
    }
    
    private func animateBackground(frames: [SKTexture])
    {
        let frameNode = SKSpriteNode(texture: frames[0], size: frames[0].size());
        frameNode.position = menuFrame.position;
        frameNode.zPosition = menuFrame.zPosition;
        self.addChild(frameNode);
        frameNode.run(SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.025)));
    }
}
