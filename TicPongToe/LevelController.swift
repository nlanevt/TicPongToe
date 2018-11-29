//
//  LevelController.swift
//  TicPongToe
//
//  Created by Nathan Lane on 11/26/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

/*
** The Level class determines the creation of obstacles and powerups and the increase in scroller speed.
*/
class LevelController {
    private var level_counter:Int64 = 1;
    private var ai = AI();
    private var scroller:InfiniteScrollingBackground? = nil;
    private var ball_manager = Ball();
    private var game_scene:GameScene!
    
    init(ai: AI, scroller: InfiniteScrollingBackground, game_scene: GameScene, ball_manager: Ball) {
        self.ai = ai;
        self.scroller = scroller;
        self.game_scene = game_scene;
        self.ball_manager = ball_manager;
        self.ai.setLevel(level: level_counter);
    }
    
    init() {
        
    }
    
    public func increaseLevel() {
        level_counter = level_counter + 1;
        ai.setLevel(level: level_counter);
        
        // level < 50 doesn't really make sense and may be unnecessary; but leaving it here for now since it might come to use later with new scroller additions
        if (level_counter < 50 && (scroller?.speed)! <= CGFloat(6.0)) {
            scroller?.speed = (scroller?.speed)! + 0.25;
        }
    }
    
    public func getLevel() -> Int64 {
        return level_counter;
    }
    
    // Used when user touches the board area.
    // Used to determine if you have touched the powerups / obstacles
    public func checkBoardTouch() {
        
    }
    
    // Used in the game_scenes update method.
    // Used to determine if you have hit the powerups / obstacles with the ball
    public func update() {
        
    }
}
