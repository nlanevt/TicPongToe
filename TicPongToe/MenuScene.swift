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
    
    private var HighScoreDisplayLabel = SKLabelNode();
    private var GamesWonDisplayLabel = SKLabelNode();
    private var HighScoreLabel = SKLabelNode();
    private var GamesWonLabel = SKLabelNode();
    private var menuFrame = SKSpriteNode();
    private var menuAnimationTop:SKSpriteNode? = nil;
    private var menuAnimationFrame:SKSpriteNode? = nil;
    private var running = false;
    private var scroller : InfiniteScrollingBackground?
    
    override func didMove(to view: SKView)
    {
        super.didMove(to: view);
        self.backgroundColor = SKColor.black;

        HighScoreDisplayLabel = self.childNode(withName: "HighScoreDisplayLabel") as! SKLabelNode;
        HighScoreDisplayLabel.text = String.localizedStringWithFormat(NSLocalizedString("HIGH SCORE", comment: "Your top score so far."));
        HighScoreDisplayLabel.fontName = String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font"));
        HighScoreDisplayLabel.fontSize = CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize2", comment: "The localized font size")) as NSString).floatValue);
        HighScoreLabel = self.childNode(withName: "HighScoreLabel") as! SKLabelNode;
        
        
        GamesWonDisplayLabel = self.childNode(withName: "GamesWonDisplayLabel") as! SKLabelNode;
        GamesWonDisplayLabel.text = String.localizedStringWithFormat(NSLocalizedString("GAMES WON", comment: "Your top score so far."));
        GamesWonDisplayLabel.fontName = String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font"));
        GamesWonDisplayLabel.fontSize = CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize2", comment: "The localized font size")) as NSString).floatValue);
        GamesWonLabel = self.childNode(withName: "GamesWonLabel") as! SKLabelNode;
        
        menuFrame = self.childNode(withName: "MenuFrame") as! SKSpriteNode;
        
        menuAnimationTop = SKSpriteNode(imageNamed: "MenuAnimationTopYellow");
        menuAnimationFrame = SKSpriteNode(imageNamed: "MenuAnimationFrameYellow");
        
        menuAnimationTop?.position = CGPoint(x: 0, y: 0);
        menuAnimationTop?.zPosition = 4;
        menuAnimationTop?.alpha = 0.0;
        
        menuAnimationFrame?.position = CGPoint(x: 0, y: 0);
        menuAnimationFrame?.zPosition = 4;
        menuAnimationFrame?.alpha = 0.0;
        
        self.addChild(menuAnimationTop!);
        self.addChild(menuAnimationFrame!);
        
        
        startMenuAnimations()
        
        updateLabels();
        
        //----Initiating Starry Background Animation------------
        let images = [UIImage(named: "BackgroundStarAnimationA")!, UIImage(named: "BackgroundStarAnimationA")!]
        
        // Initializing InfiniteScrollingBackground's Instance:
        scroller = InfiniteScrollingBackground(images: images, scene: self, scrollDirection: .bottom, transitionSpeed: 18)
        scroller?.scroll()
        scroller?.zPosition = -3
        
        self.physicsWorld.contactDelegate = self;
        let border = SKPhysicsBody(edgeLoopFrom: self.frame);
        border.friction = 0;
        border.restitution = 1;
        self.physicsBody = border;
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
    
    // Unused here but useful to show you how to animate something.
    private func animateBackground(frames: [SKTexture])->SKSpriteNode
    {
        let frameNode = SKSpriteNode(texture: frames[0], size: frames[0].size());
        frameNode.position = menuFrame.position;
        frameNode.zPosition = menuFrame.zPosition;
        self.addChild(frameNode);
        frameNode.run(SKAction.repeatForever(SKAction.animate(with: frames, timePerFrame: 0.025)));
        return frameNode;
    }
    
    private func animateBackground(node: SKSpriteNode)
    {
        let menuAnimationFramesAction = SKAction.sequence([
            SKAction.wait(forDuration: TimeInterval(Int(arc4random_uniform(6)))),
            SKAction.fadeIn(withDuration: 3.0),
            SKAction.fadeOut(withDuration: 3.0)]);
        node.run(menuAnimationFramesAction,
                                      completion: {
                                        self.animateBackground(node: node);
        })
    }
    
    public func stopMenuAnimations()
    {
        running = false;
    }
    
    public func startMenuAnimations()
    {
        running = true;
        animateBackground(node: menuAnimationFrame!);
        animateBackground(node: menuAnimationTop!);
    }
}
