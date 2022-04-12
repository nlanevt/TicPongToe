//
//  SoundController.swift
//  TicPongToe
//
//  Created by Nathan Lane on 4/12/22.
//  Copyright © 2022 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class SoundController {
    private let bounceSound = SKAction.playSoundFileNamed("BounceSound", waitForCompletion: false);
    private let touchBoardSound = SKAction.playSoundFileNamed("TouchBoardSound", waitForCompletion: false);
    private let boardWinSound = SKAction.playSoundFileNamed("BoardWinSound", waitForCompletion: false);
    private let hitSound = SKAction.playSoundFileNamed("HitSound", waitForCompletion: false);
    
    public func runWallBounceSound(scene: GameScene) {
        scene.run(bounceSound);
    }
    
    public func runPaddleBounceSound(scene: GameScene) {
        scene.run(bounceSound);
    }
    
    public func runTouchBoardSound(scene: GameScene) {
        scene.run(touchBoardSound)
    }
    
    public func runHitSound(scene: GameScene) {
        scene.run(hitSound);
    }
    
    public func runBoardWinSound(scene: GameScene) {
        scene.run(boardWinSound);
    }
}
