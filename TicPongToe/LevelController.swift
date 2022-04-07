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
    private var scroller:InfiniteScrollingBackground? = nil;
    private weak var game_scene:GameScene!  //   4  5  6  7   8   9   10  11  12  13  14  15  16  17  18  19  20  21
    private var ai_lives_increase_array:[Int] = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36, 39, 42, 45, 48, 51, 54];
    private var ai_lives_amount = 3;
    private var ai_intensity:[Double] = [0.08];
    private var ai_may_select_powerup = false;
    
    private var power_ups = [PowerUpNode]();
    private var pu_waves = [[powerUpType]]();
    private var pu_wave_wait_times = [TimeInterval]();
    private var pu_wave_iterator = 0;
    
    
    
    private var player:Paddle!;

    init(scroller: InfiniteScrollingBackground, game_scene: GameScene) {
        self.scroller = scroller;
        self.game_scene = game_scene;
    }
    
    /*
     Note: 0.03 intensity is impossibly difficult; 0.04 is very difficult
     */
    public func setLevelValues() {
        
        if (level_counter == 1) {
            ai_intensity = [0.10, 0.09];
            pu_waves = [[.super_health_booster, .fast_ball, .health_booster],
                        [.super_fast_ball, .full_replenish, .big_boy_booster],
                        [.full_replenish, .big_boy_booster]];
            pu_wave_wait_times = [10, 5, 5];
            ai_may_select_powerup = true;
            ai_lives_amount = 3;
        }
        else if (level_counter <= 3) {
            ai_intensity = [0.10, 0.09];
            pu_waves = [[.super_health_booster, .fast_ball, .super_big_boy_booster],
                        [.full_replenish, .super_fast_ball, .big_boy_booster],
                        [.health_booster, .big_boy_booster]];
            pu_wave_wait_times = [10, 10, 10];
            ai_may_select_powerup = false;
            ai_lives_amount = 3;
        }
        else if (level_counter <= 6) {
            ai_intensity = [0.09, 0.08];
            pu_waves = [[.super_health_booster, .super_fast_ball, .super_big_boy_booster],
                        [.full_replenish, .fast_ball, .big_boy_booster],
                        [.health_booster, .big_boy_booster]];
            pu_wave_wait_times = [10, 10, 10];
            ai_lives_amount = 4;
        }
        else if (level_counter <= 9) {
            ai_intensity = [0.09, 0.08];
            ai_lives_amount = 5;
        }
        else if (level_counter == 10) {
            ai_lives_amount = 6;
            ai_may_select_powerup = true;
        }
        else if (level_counter <= 15) {
            ai_intensity = [0.07, 0.06];
            ai_lives_amount = 6;
        }
        else if (level_counter <= 19) {
            ai_intensity = [0.07, 0.06, 0.05];
            ai_lives_amount = 6;
        }
        else if (level_counter == 20) {
            ai_lives_amount = 7;
            ai_may_select_powerup = true;
        }
        else if (level_counter <= 25) {
            ai_intensity = [0.07, 0.06];
            ai_lives_amount = 7;
        }
        else if (level_counter <= 29) {
            ai_intensity = [0.07, 0.06, 0.05];
            ai_lives_amount = 7;
        }
        else if (level_counter == 30) {
            ai_lives_amount = 8;
            ai_may_select_powerup = true;
        }
        else if (level_counter <= 35) {
            ai_intensity = [0.07, 0.06];
            ai_lives_amount = 8;
        }
        else if (level_counter <= 39) {
            ai_intensity = [0.07, 0.06, 0.05];
            ai_lives_amount = 8;
        }
        else if (level_counter == 40) {
            ai_lives_amount = 9;
            ai_may_select_powerup = true;
        }
        else if (level_counter <= 45) {
            ai_intensity = [0.07, 0.06];
            ai_lives_amount = 9;
        }
        else if (level_counter <= 49) {
            ai_intensity = [0.07, 0.06, 0.05];
            ai_lives_amount = 9;
        }
        else if (level_counter == 50) {
            ai_lives_amount = 10;
            ai_may_select_powerup = true;
        }
        else {
            ai_intensity = [0.05, 0.04, 0.03];
        }
    }
    
   // private func assignLevelDetails(aiIntensity: [Double], puWaves: [[powerUpType]], )
    
    public func getAIIntensity() -> [Double] {
        return ai_intensity;
    }
    
    public func startPowerUpWave() {
        // Don't run if pu_wave_iterator is too big - i.e. don't run any more waves once you get through all of the waves in pu_waves.
        // Also, don't run if there are still power ups from the previous wave left.
        if (pu_wave_iterator >= pu_waves.count || !power_ups.isEmpty) {return}
        
        for pu_type in pu_waves[pu_wave_iterator] {
            if (power_ups.count > game_scene.squaresArray.count) {break}; // Don't allow more than 9 powerups per wave.
            let power_up = PowerUpNode(power_up_type: pu_type);
            power_up.setCenterPosition(position: getFreePowerUpPosition());
            let board_position = getPowerUpBoardPosition(power_up: power_up);
            if (board_position < 0) {break}; // Don't allow bad board positions to be added
            power_up.setBoardPosition(position: board_position);
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
    
    /*
     * Needed for now but may need refactoring with getFreePowerUpPosition, since it seems its doing exxcess work.
     */
    private func getPowerUpBoardPosition(power_up: PowerUpNode) -> Int {
        for (index,square) in game_scene.squaresArray.enumerated() {
            if (square.position.equalTo(power_up.getCenterPosition())) {
                return index;
            }
        }
        
        return -1;
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
        // level < 50 doesn't really make sense and may be unnecessary; but leaving it here for now since it might come to use later with new scroller additions
        if (level_counter < 50 && (scroller?.speed)! <= CGFloat(6.0)) {
            scroller?.speed = (scroller?.speed)! + 0.25;
        }
        
        for level in ai_lives_increase_array {
            if level_counter == level {
                ai_lives_amount = ai_lives_amount < 21 ? ai_lives_amount + 1 : ai_lives_amount
                break;
            }
        }
    }
    
    public func getLevel() -> Int64 {
        return level_counter;
    }
    
    public func getAILivesAmount() -> Int {
        return ai_lives_amount;
    }
    
    public func mayAISelectPowerUp() -> Bool {
        return ai_may_select_powerup;
    }
    
    public func checkStageSelect(paddle: Paddle, square: SKSpriteNode) {
        selectPowerUp(paddle: paddle, square: square);
    }
    
    public func getCurrentPowerUps() -> [PowerUpNode] {
        return power_ups;
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
