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
    private var game_scene:GameScene!       //   4  5  6  7   8   9   10  11  12  13  14  15  16  17  18  19  20  21
    private var ai_lives_increase_array:[Int] = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54];
    
    private var power_ups = [PowerUpNode]();
    private var pu_waves = [[Int]]();
    private var pu_wave_wait_times = [TimeInterval]();
    private var pu_wave_iterator = 0;
    private var player:Paddle!;
    
    init(ai: AI, scroller: InfiniteScrollingBackground, game_scene: GameScene, ball_manager: Ball, player: Paddle) {
        self.ai = ai;
        self.scroller = scroller;
        self.game_scene = game_scene;
        self.ball_manager = ball_manager;
        self.ai.setLevel(level: level_counter);
        self.player = player;
    }
    
    init() {
        
    }
    
    public func startLevel() {
        pu_wave_iterator = 0;
        if (level_counter == 1) {
            pu_waves = [[1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]];
            pu_wave_wait_times = [10, 10, 15];
            startPowerUpWave();
        }
    }
    
    public func startPowerUpWave() {
        for pu in pu_waves[pu_wave_iterator] {
            if (pu > 0) {
                let power_up = PowerUpNode(power_up_type: .health_booster);
                power_up.position = CGPoint(x: 0, y: 0);
                power_up.zPosition = -1.5;
                game_scene.addChild(power_up);
                power_ups.append(power_up);
                power_up.appear(wait_time: pu_wave_wait_times[pu_wave_iterator]);
            }
        }

    }
    
    public func increaseLevel() {
        level_counter = level_counter + 1;
        ai.setLevel(level: level_counter);
        
        // level < 50 doesn't really make sense and may be unnecessary; but leaving it here for now since it might come to use later with new scroller additions
        if (level_counter < 50 && (scroller?.speed)! <= CGFloat(6.0)) {
            scroller?.speed = (scroller?.speed)! + 0.25;
        }
        
        for i in ai_lives_increase_array {
            if level_counter == i {
                ai.increaseLivesAmount();
                break;
            }
        }
    }
    
    public func getLevel() -> Int64 {
        return level_counter;
    }
    
    // Used when user touches the board area.
    // Used to determine if you have touched the powerups / obstacles
    public func checkBoardTouch() {
        
    }
    
    
    public func checkPlayerStageSelect(square: SKSpriteNode) {
        print("power up checking stage");
        
        if (!power_ups.isEmpty) {
            for power_up in power_ups {
                if (square.frame.intersects(power_up.frame) && power_up.isSelectable()) {
                    power_up.select(by: player, completion: {
                        self.startPowerUpWave();
                        power_up.removeFromParent();
                    });
                }
            }
        }
    }
    
    // Used in the game_scenes update method.
    // Used to determine if you have hit the powerups / obstacles with the ball
    public func update() {
        
    }
}
