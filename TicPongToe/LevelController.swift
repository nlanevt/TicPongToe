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
    private weak var game_scene:GameScene!
    private var scroller:InfiniteScrollingBackground? = nil;
    
    private var level_counter:Int64 = 1;
    
    private var ai_lives_amount = 3;
    private var ai_intensity:[Double] = [0.08];
    private var ai_may_select_powerup = false;
    
    private var power_ups = [PowerUpNode]();
    private var pu_waves = [[powerUpType]]();
    private var pu_wave_wait_times = [TimeInterval]();
    private var pu_wave_iterator = 0;

    init(scroller: InfiniteScrollingBackground, game_scene: GameScene) {
        self.scroller = scroller;
        self.game_scene = game_scene;
    }
    
    
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
            let wait_time = pu_waves.count != pu_wave_wait_times.count ? 10 : pu_wave_wait_times[pu_wave_iterator];
            power_up.appear(wait_time: wait_time);
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
        if (level_counter < 30 && (scroller?.speed)! <= CGFloat(6.0)) {
            scroller?.speed = (scroller?.speed)! + 0.1;
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
    
    private func assignLevelDetails(aiLivesAmount: Int, aiIntensity: [Double], puWaves: [[powerUpType]], puWaveTimes: [TimeInterval], canSelectPowerUp: Bool) {
        ai_lives_amount = aiLivesAmount;
        ai_intensity = aiIntensity;
        pu_waves = puWaves;
        pu_wave_wait_times = puWaveTimes;
        ai_may_select_powerup = canSelectPowerUp;
    }
    
    private func getRandomPowerups(numberOfWaves: Int) -> [[powerUpType]] {
        var health_count = 0; // Limits how many health items are set in the random waves.
        var puWaves = [[powerUpType]]();
        for _ in 0..<numberOfWaves {
            let randAmount =  Int.random(in: 2..<5)
            var wave = [powerUpType]();
            for _ in 0..<randAmount {
                var power_up = powerUpType.allCases.randomElement() ?? powerUpType.fast_ball
                if (power_up == .health_booster || power_up == .super_health_booster || power_up == .full_replenish) {
                    if (health_count >= 4) {
                        if (power_up == .health_booster) {power_up = .fast_ball}
                        else if (power_up == .super_health_booster) {power_up = .super_fast_ball}
                        else {power_up = .big_boy_booster}
                    }
                    else {
                        health_count = health_count + 1;
                    }
                }
                wave.append(power_up)
            }
            puWaves.append(wave);
        }
        
        return puWaves;
    }
    
    /*
     Note: 0.03 intensity is impossibly difficult; 0.04 is very difficult
     */
    public func setLevelValues() {
        
        if (level_counter == 1) {
            assignLevelDetails(aiLivesAmount: 3,
                               aiIntensity: [0.10, 0.09],
                               puWaves: [[.fast_ball, .health_booster],
                                         [.big_boy_booster, .health_booster],
                                         [.fast_ball, .big_boy_booster, .super_health_booster]],
                               puWaveTimes: [10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter <= 3) {
            assignLevelDetails(aiLivesAmount: 3,
                               aiIntensity: [0.10, 0.09],
                               puWaves: [[.big_boy_booster, .health_booster],
                                         [.fast_ball, .health_booster],
                                         [.big_boy_booster, .super_fast_ball, .health_booster]],
                               puWaveTimes: [10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter <= 6) {
            assignLevelDetails(aiLivesAmount: 4,
                               aiIntensity: [0.09, 0.08],
                               puWaves: [[.fast_ball, .full_replenish],
                                         [.big_boy_booster, .super_fast_ball],
                                         [.super_big_boy_booster, .super_health_booster],
                                         [.fast_ball]],
                               puWaveTimes: [10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter <= 9) {
            assignLevelDetails(aiLivesAmount: 5,
                               aiIntensity: [0.09, 0.08],
                               puWaves: [[.fast_ball, .big_boy_booster, .super_health_booster],
                                         [.big_boy_booster, .super_fast_ball],
                                         [.super_big_boy_booster, .fast_ball, .health_booster],
                                         [.big_boy_booster],
                                         [.super_fast_ball, .health_booster]],
                               puWaveTimes: [10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter == 10) {
            assignLevelDetails(aiLivesAmount: 6,
                               aiIntensity: [0.08, 0.07],
                               puWaves: [[.fast_ball, .fast_ball, .big_boy_booster, .super_health_booster],
                                         [.big_boy_booster, .super_fast_ball, .super_fast_ball, .fast_ball],
                                         [.super_big_boy_booster, .fast_ball, .big_boy_booster, .super_health_booster],
                                         [.big_boy_booster, .big_boy_booster, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .fast_ball, .fast_ball, .fast_ball],
                                         [.super_fast_ball, .super_big_boy_booster, .fast_ball, .big_boy_booster, .full_replenish]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: true)
        }
        else if (level_counter <= 15) {
            assignLevelDetails(aiLivesAmount: 6,
                               aiIntensity: [0.09, 0.07],
                               puWaves: [[.fast_ball, .super_health_booster],
                                         [.big_boy_booster, .super_fast_ball],
                                         [.super_big_boy_booster, .fast_ball, .health_booster],
                                         [.super_fast_ball, .super_big_boy_booster],
                                         [.big_boy_booster, .big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .full_replenish]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter <= 19) {
            assignLevelDetails(aiLivesAmount: 6,
                               aiIntensity: [0.10, 0.09, 0.08],
                               puWaves: [[.fast_ball, .health_booster, .health_booster],
                                         [.big_boy_booster, .health_booster, .health_booster],
                                         [.super_fast_ball, .health_booster, .health_booster],
                                         [.super_big_boy_booster, .health_booster, .health_booster],
                                         [.fast_ball, .health_booster, .health_booster],
                                         [.super_health_booster, .health_booster, .health_booster]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter == 20) {
            assignLevelDetails(aiLivesAmount: 7,
                               aiIntensity: [0.08, 0.06],
                               puWaves: [[.fast_ball, .fast_ball, .big_boy_booster, .super_health_booster],
                                         [.big_boy_booster, .super_fast_ball, .super_fast_ball, .fast_ball],
                                         [.super_big_boy_booster, .fast_ball, .big_boy_booster, .fast_ball],
                                         [.big_boy_booster, .big_boy_booster, .fast_ball, .fast_ball],
                                         [.fast_ball, .fast_ball, .fast_ball, .fast_ball],
                                         [.super_fast_ball, .super_big_boy_booster, .fast_ball, .big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: true)
        }
        else if (level_counter <= 25) {
            assignLevelDetails(aiLivesAmount: 7,
                               aiIntensity: [0.08, 0.07],
                               puWaves: [[.super_fast_ball, .fast_ball, .super_health_booster],
                                         [.big_boy_booster, .super_big_boy_booster, .super_fast_ball],
                                         [.super_big_boy_booster, .super_big_boy_booster],
                                         [.super_fast_ball, .super_big_boy_booster, .health_booster],
                                         [.big_boy_booster, .fast_ball],
                                         [.super_fast_ball, .super_fast_ball],
                                         [.full_replenish, .full_replenish]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter <= 29) {
            assignLevelDetails(aiLivesAmount: 7,
                               aiIntensity: [0.10, 0.08, 0.07],
                               puWaves: [[.fast_ball, .fast_ball, .health_booster],
                                         [.big_boy_booster, .big_boy_booster, .health_booster],
                                         [.super_fast_ball, .super_fast_ball, .health_booster],
                                         [.super_big_boy_booster, .super_big_boy_booster, .health_booster],
                                         [.fast_ball, .big_boy_booster, .health_booster],
                                         [.super_fast_ball, .super_big_boy_booster, .health_booster],
                                         [.fast_ball, .health_booster]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter == 30) {
            assignLevelDetails(aiLivesAmount: 8,
                               aiIntensity: [0.07, 0.06],
                               puWaves: [[.fast_ball, .fast_ball, .fast_ball, .fast_ball],
                                         [.big_boy_booster, .big_boy_booster, .super_big_boy_booster],
                                         [.fast_ball, .big_boy_booster, .super_health_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.super_big_boy_booster, .fast_ball],
                                         [.big_boy_booster, .fast_ball, .super_health_booster],
                                         [.super_fast_ball, .super_fast_ball, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .big_boy_booster, .super_fast_ball, .full_replenish]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: true)
        }
        else if (level_counter <= 35) {
            assignLevelDetails(aiLivesAmount: 8,
                               aiIntensity: [0.08, 0.06],
                               puWaves: [[.super_fast_ball, .super_fast_ball, .super_health_booster],
                                         [.super_big_boy_booster, .super_big_boy_booster, .super_fast_ball],
                                         [.fast_ball, .fast_ball, .fast_ball],
                                         [.super_fast_ball, .super_big_boy_booster],
                                         [.big_boy_booster, .super_fast_ball, .super_health_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.fast_ball, .super_fast_ball, .super_big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .big_boy_booster]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter <= 39) {
            assignLevelDetails(aiLivesAmount: 8,
                               aiIntensity: [0.09, 0.08, 0.06],
                               puWaves: [[.big_boy_booster, .fast_ball, .health_booster],
                                         [.super_fast_ball, .super_big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .health_booster],
                                         [.super_big_boy_booster, .super_fast_ball],
                                         [.fast_ball, .big_boy_booster, .health_booster],
                                         [.fast_ball, .fast_ball],
                                         [.big_boy_booster, .health_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter == 40) {
            assignLevelDetails(aiLivesAmount: 9,
                               aiIntensity: [0.07, 0.06, 0.05],
                               puWaves: [[.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.big_boy_booster, .fast_ball, .super_big_boy_booster, .super_fast_ball],
                                         [.fast_ball, .big_boy_booster, .big_boy_booster, .super_health_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.big_boy_booster, .fast_ball, .fast_ball, .fast_ball],
                                         [.big_boy_booster, .fast_ball, .super_fast_ball, .super_health_booster],
                                         [.super_fast_ball, .super_fast_ball, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .fast_ball, .fast_ball, .fast_ball],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .full_replenish]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: true)
        }
        else if (level_counter <= 45) {
            assignLevelDetails(aiLivesAmount: 9,
                               aiIntensity: [0.08, 0.05],
                               puWaves: [[.fast_ball, .big_boy_booster, .super_health_booster],
                                         [.super_big_boy_booster, .super_fast_ball, .super_fast_ball],
                                         [.fast_ball, .fast_ball, .fast_ball],
                                         [.super_fast_ball, .super_fast_ball, .super_big_boy_booster],
                                         [.big_boy_booster, .fast_ball, .super_health_booster],
                                         [.big_boy_booster, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .super_fast_ball, .super_big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .fast_ball, .big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_health_booster]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter <= 49) {
            assignLevelDetails(aiLivesAmount: 9,
                               aiIntensity: [0.08, 0.07, 0.05],
                               puWaves: [[.big_boy_booster, .fast_ball, .fast_ball, .health_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.super_big_boy_booster, .super_fast_ball, .health_booster],
                                         [.fast_ball, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .fast_ball, .fast_ball],
                                         [.big_boy_booster, .big_boy_booster, .health_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.fast_ball, .fast_ball, .fast_ball]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter == 50) {
            assignLevelDetails(aiLivesAmount: 10,
                               aiIntensity: [0.07, 0.05],
                               puWaves: [[.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_health_booster],
                                         [.big_boy_booster, .fast_ball, .super_big_boy_booster, .super_fast_ball],
                                         [.fast_ball, .big_boy_booster, .big_boy_booster, .fast_ball],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.big_boy_booster, .fast_ball, .fast_ball, .fast_ball, .super_health_booster],
                                         [.big_boy_booster, .fast_ball, .super_fast_ball, .super_big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .fast_ball, .fast_ball, .fast_ball],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.fast_ball, .super_fast_ball, .super_health_booster, .full_replenish]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: true)
        }
        else if (level_counter <= 55) {
            assignLevelDetails(aiLivesAmount: 10,
                               aiIntensity: [0.08, 0.04],
                               puWaves: [[.fast_ball, .big_boy_booster, .super_health_booster],
                                         [.super_big_boy_booster, .super_fast_ball, .super_fast_ball],
                                         [.fast_ball, .fast_ball, .fast_ball, .health_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_big_boy_booster],
                                         [.big_boy_booster, .fast_ball, .super_health_booster],
                                         [.big_boy_booster, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .super_fast_ball, .super_big_boy_booster, .health_booster],
                                         [.fast_ball, .fast_ball, .big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_health_booster],
                                         [.health_booster]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter <= 59) {
            assignLevelDetails(aiLivesAmount: 10,
                               aiIntensity: [0.08, 0.05, 0.04],
                               puWaves: [[.big_boy_booster, .fast_ball, .fast_ball, .super_health_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.super_big_boy_booster, .super_fast_ball],
                                         [.fast_ball, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .fast_ball, .fast_ball],
                                         [.big_boy_booster, .big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.fast_ball, .fast_ball, .fast_ball],
                                         [.super_fast_ball, .super_health_booster]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: false)
        }
        else if (level_counter == 60) {
            assignLevelDetails(aiLivesAmount: 11,
                               aiIntensity: [0.06, 0.05, 0.04],
                               puWaves: [[.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_health_booster],
                                         [.big_boy_booster, .fast_ball, .super_big_boy_booster, .super_fast_ball],
                                         [.fast_ball, .big_boy_booster, .big_boy_booster, .fast_ball],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.big_boy_booster, .fast_ball, .fast_ball, .fast_ball],
                                         [.big_boy_booster, .fast_ball, .super_fast_ball, .super_big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .big_boy_booster, .big_boy_booster],
                                         [.fast_ball, .fast_ball, .fast_ball, .fast_ball],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball],
                                         [.fast_ball, .big_boy_booster],
                                         [.super_fast_ball, .super_fast_ball, .super_fast_ball, .super_fast_ball]],
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: true)
        }
        else {
            assignLevelDetails(aiLivesAmount: 11,
                               aiIntensity: [0.07, 0.05, 0.04],
                               puWaves: getRandomPowerups(numberOfWaves: 11),
                               puWaveTimes: [10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10],
                               canSelectPowerUp: arc4random_uniform(3) == 1 ? true : false)
        }
    }
}
