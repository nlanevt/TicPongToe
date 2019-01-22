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
    
    private var obstacles = [SKSpriteNode](); //Need to replace SKSpriteNode with Obstacle class. This is used to contain all Obstacles currently active on Stage.
    private var ob_queue = [obstacleType](); //The Queue of obstacles that are waiting to be added. Whether or not they are added (thus leaving the queue and going into the obstacles list) is dependent on how many obstacles are allowed on the level at a given time.
    private var ob_wave_trigger = [Int](); // List of what levels the next wave of obstacles will load.
    private var ob_wave_amount = [Int](); // List of what amount of obstacles can exist on the board during a given wave.
    private var ob_waves = [[obstacleType]](); // List of what enemies will be added per wave.
    private var ob_wave_wait_times = [TimeInterval](); // Wait time between waves.
    private var ob_wave_iterator = 0; // Iterator for ob_waves, ob_wave_trigger and ob_wave_amount lists.
    
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
        
        if (!power_ups.isEmpty) {
            for power_up in power_ups {power_up.disappear()}
        }
        power_ups.removeAll();
        pu_wave_iterator = 0;
        pu_waves.removeAll();
        
        if (!obstacles.isEmpty) {
            for obstacle in obstacles {/*obstacle.disappear();*/}
        }
        ob_wave_iterator = ai.getLivesAmount();
        ob_waves.removeAll();
        obstacles.removeAll();
        ob_queue.removeAll();
        ob_wave_trigger.removeAll();
        ob_wave_amount.removeAll();
        
        switch level_counter {
        case 1:
            pu_waves = [[.health_booster], [.health_booster, .fast_ball], [.health_booster]];
            pu_wave_wait_times = [10, 5, 5];
            ob_waves = [[.batter_bro]];
            ob_wave_trigger = [2];
            ob_wave_amount = [1];
            break;
        case 2:
            pu_waves = [[.health_booster, .fast_ball], [.health_booster, .fast_ball], [.health_booster]];
            pu_wave_wait_times = [10, 10, 10];
            ob_waves = [[.batter_bro],[.rouge_rookie]];
            ob_wave_trigger = [4, 2];
            ob_wave_amount = [2, 2];
            break;
        default:
            break;
        }
        
        startPowerUpWave();
    }
    
    private func startPowerUpWave() {
        // Don't run if pu_wave_iterator is too big - i.e. don't run any more waves once you get through all of the waves in pu_waves.
        if (pu_wave_iterator >= pu_waves.count) {return}
        
        for pu_type in pu_waves[pu_wave_iterator] {
            let power_up = PowerUpNode(power_up_type: pu_type);
            power_up.position = game_scene.squaresArray[Int(arc4random_uniform(UInt32(game_scene.squaresArray.count)))].position;
            power_up.zPosition = -1.5;
            game_scene.addChild(power_up);
            power_ups.append(power_up);
            power_up.appear(wait_time: pu_wave_wait_times[pu_wave_iterator]);
            //print("\npower up: \(i), \(pu_waves[pu_wave_iterator][i]), \(power_ups.count)");
        }
        print("power up: # waves \(pu_waves.count), power_ups.count \(power_ups.count), wave \(pu_wave_iterator)");
        pu_wave_iterator = pu_wave_iterator + 1;
    }
    
    // This occurs only when AI is scored on.
    public func startObstacleWave() {
        if (ob_wave_iterator >= ob_waves.count ||
            ai.getLives() != ob_wave_trigger[ob_wave_iterator]) {return}
        
        for ob_type in ob_waves[ob_wave_iterator] {
            ob_queue.append(ob_type);
        }
        
        ob_wave_iterator = ob_wave_iterator + 1;
        addObstaclesToStage();
    }
    
    // This occurs when a wave starts OR when an obstacle is removed from the stage at the completion of its disappear action.
    private func addObstaclesToStage() {
        if (ob_wave_iterator <= 0 || ob_wave_iterator > ob_waves.count) {return}
        
        let amount_to_add = obstacles.count - ob_wave_amount[ob_wave_iterator-1];
        if (amount_to_add >= 0) {return}
    
        var i = 0;
        while (i < amount_to_add && i < ob_queue.count) {
            instantiateObstacle(obstacle_type: ob_queue.removeFirst());
            i = i + 1;
        }
        
    }
    
    private func instantiateObstacle(obstacle_type: obstacleType) {
        // Create Obstacles node
        // set its position accordingly.
        // set its zPosition accordingly.
        // game_scene.addChild(obstacle);
        // obstacles.append(obstacle);
        // obstacle.appear(wait_time: ob_wave_wait_times[ob_wave_iterator]);
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
    
    
    public func checkPlayerStageSelect(paddle: Paddle, square: SKSpriteNode) {
        print("power up checking stage");
    
        selectPowerUp(paddle: paddle, square: square);
        
        if (!obstacles.isEmpty) {
            var i = 0;
            var obstacle:SKSpriteNode!
            while (i < obstacles.count) {
                obstacle = obstacles[i];
                if (square.frame.intersects(obstacle.frame) /* && obstacle.isSelectable()*/) {
                    
                    /* obstacle.hit(completion: {
                            self.addObstaclesToStage();
                       })*/
                    // if (obstacle.getHealth() <= 0) {obstacles.remove(i)} else {i = i+1}
                }
                else {
                    i = i + 1;
                }
            }
        }
    }
    
    public func checkEnemyStageSelect(paddle: Paddle, square: SKSpriteNode) {
        selectPowerUp(paddle: paddle, square: square);
    }
    
    private func selectPowerUp(paddle: Paddle, square: SKSpriteNode) {
        // Check, Use and Remove Power up.
        if (!power_ups.isEmpty) {
            for power_up in power_ups {
                if (square.frame.intersects(power_up.frame) && power_up.isSelectable()) {
                    power_up.select(by: paddle, completion: {
                        if (power_up == self.power_ups.last) {
                            self.startPowerUpWave();
                        }
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
