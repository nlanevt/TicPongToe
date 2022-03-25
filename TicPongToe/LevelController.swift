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
    private var pu_waves = [[powerUpType]]();
    private var pu_wave_wait_times = [TimeInterval]();
    private var pu_wave_iterator = 0;
    
    private var ai_intensity:[Double] = [0.08];
    
    private var player:Paddle!;

    init(ai: AI, scroller: InfiniteScrollingBackground, game_scene: GameScene, ball_manager: Ball, player: Paddle) {
        self.ai = ai;
        self.scroller = scroller;
        self.game_scene = game_scene;
        self.ball_manager = ball_manager;
        self.ai.setLevel(level: level_counter);
        self.player = player;
    }
    
    /*
     Note: 0.03 is impossibly difficult; 0.04 is very difficult
     */
    public func setLevelValues() {
        
        if (level_counter == 1) {
            ai_intensity = [0.10, 0.09];
            pu_waves = [[.health_booster, .full_replenish, .big_boy_booster],
                        [.super_fast_ball, .big_boy_booster],
                        [.full_replenish, .big_boy_booster]];
            pu_wave_wait_times = [10, 5, 5];
        }
        else if (1 < level_counter && level_counter < 4) {
            ai_intensity = [0.10, 0.09];
            pu_waves = [[.super_health_booster, .fast_ball, .super_fast_ball],
                        [.full_replenish, .fast_ball, .big_boy_booster],
                        [.health_booster, .big_boy_booster]];
            pu_wave_wait_times = [10, 10, 10];
        }
        else if (4 <= level_counter && level_counter < 7) {
            ai_intensity = [0.08, 0.07];
        }
        else if (7 <= level_counter && level_counter < 11) {
            ai_intensity = [0.08, 0.07, 0.06];
        }
        else if (12 <= level_counter && level_counter < 16) {
            ai_intensity = [0.07, 0.06];
        }
        else if (16 <= level_counter && level_counter < 21) {
            ai_intensity = [0.07, 0.06, 0.05];
        }
        else if (21 <= level_counter && level_counter < 26) {
            ai_intensity = [0.06, 0.0];
        }
        else if (26 <= level_counter && level_counter < 31) {
            ai_intensity = [0.08, 0.07, 0.06];
        }
        else if (31 <= level_counter && level_counter < 36) {
            ai_intensity = [0.08, 0.07, 0.06];
        }
        else if (36 <= level_counter && level_counter < 41) {
            ai_intensity = [0.08, 0.07, 0.06];
        }
        else if (41 <= level_counter && level_counter < 46) {
            ai_intensity = [0.08, 0.07, 0.06];
        }
        else if (46 <= level_counter && level_counter < 51) {
            ai_intensity = [0.08, 0.07, 0.06];
        }
        else {
            ai_intensity = [0.05, 0.04, 0.03];
        }
    }
    
    public func getAIIntensity() -> [Double] {
        return ai_intensity;
    }
    
    public func startPowerUpWave() {
        // Don't run if pu_wave_iterator is too big - i.e. don't run any more waves once you get through all of the waves in pu_waves.
        // Also, don't run if there are still power ups from the previous wave left.
        if (pu_wave_iterator >= pu_waves.count || !power_ups.isEmpty) {return}
        
        for pu_type in pu_waves[pu_wave_iterator] {
            if (power_ups.count > game_scene.squaresArray.count) {break}; // Don't allow more than 6 powerups per wave.
            let power_up = PowerUpNode(power_up_type: pu_type);
            power_up.setCenterPosition(position: getFreePowerUpPosition());
            power_up.zPosition = -1.5;
            game_scene.addChild(power_up);
            power_ups.append(power_up);
            power_up.appear(wait_time: pu_wave_wait_times[pu_wave_iterator]);
        }
        print("power up: # of waves \(pu_waves.count), power_ups.count \(power_ups.count), wave \(pu_wave_iterator+1)");
        pu_wave_iterator = pu_wave_iterator + 1;
    }
    
    private func getFreePowerUpPosition() -> CGPoint {
        var position = CGPoint();
        var possible_positions = [CGPoint]();
        
        for square in game_scene.squaresArray {
            possible_positions.append(square.position);
        }
        
        while (possible_positions.count > 0) {
            let rand_pos = Int(arc4random_uniform(UInt32(possible_positions.count)))
            position = possible_positions[rand_pos];
            var isFree = true;
            
            for power_up in power_ups {
                if position.equalTo(power_up.getCenterPosition()) {
                    isFree = false;
                }
            }
            
            if (isFree) {
                return position;
            }
            possible_positions.remove(at: rand_pos);
        }
        
        return position;
    }
    
    
    public func clearLevelItems() {
        if (!power_ups.isEmpty) {
            for power_up in power_ups {power_up.disappear()}
        }
        power_ups.removeAll();
        pu_wave_iterator = 0;
        pu_waves.removeAll();
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
    
    public func checkPlayerStageSelect(paddle: Paddle, square: SKSpriteNode) {
        selectPowerUp(paddle: paddle, square: square);
    }
    
    public func checkEnemyStageSelect(paddle: Paddle, square: SKSpriteNode) {
        selectPowerUp(paddle: paddle, square: square);
    }
    
    private func selectPowerUp(paddle: Paddle, square: SKSpriteNode) {
        // Check, Use and Remove Power up.
        if (!power_ups.isEmpty) {
            var i = 0;
            var power_up:PowerUpNode!
            while (i < power_ups.count) {
                power_up = power_ups[i];
                if (square.frame.intersects(power_up.frame) && power_up.isSelectable()) {
                    power_up.select(by: paddle, completion: {});
                    
                    power_ups.remove(at: i);
                    
                    if (power_ups.isEmpty) {
                        self.startPowerUpWave();
                    }
                }
                else {
                    i = i + 1;
                }
            }
        }
    }
}
