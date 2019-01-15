//
//  AI.swift
//  TicPongToe
//
//  Created by Nathan Lane on 5/22/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

enum chase_method {
    case close_left_edge
    case far_left_edge
    case close_right_edge
    case far_right_edge
    case center
}

class AI {
    private var level:Int64 = 0;
    private var speed = 0.0;
    private var lives = 0;
    private var difficulty = 0;
    private var high_score:Int64 = 0;
    private var enemy_score = 0;
    private var player_score = 0;
    private var ball:SKSpriteNode?
    private var ai:SKSpriteNode?
    private var chase = chase_method.center;
    private var paddle_width = CGFloat.init(100);
    private var rows = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]];
    private var O = 5;
    private var X = 1;
    private var fast_ball = 0;
    private var fast_ball_probability:UInt32 = 3;
    private var fast_ball_position:CGFloat = 0.0;
    private var viewSize:CGSize = CGSize(width: 0, height: 0);
    public var enemy_hit_ball = false;
    
    private var offset1:CGFloat = 150;
    private var offset2:CGFloat = 250;
    
    private var intensity:CGFloat = 0.03;
    private var ai_lives = 6;
    private var ai_lives_amount = 6;
    
    private var ai_lives_y_position:CGFloat = 235.0;
    private var ai_lives_z_position:CGFloat = -1.0;
    private var ai_lives_array:[SKSpriteNode] = [];
    private var ai_life_texture:SKTexture = SKTexture.init(imageNamed: "AILife");
    private var ai_life_size:CGSize = CGSize.init(width: 7, height: 20);
    
    private var game_scene:GameScene? = nil;
    
    func setPaddleValues(ball: SKSpriteNode, ai: SKSpriteNode)
    {
        self.ball = ball;
        self.ai = ai;
    }
    
    func setFrameSize(view_size: CGSize)
    {
        viewSize = view_size;
        offset1 = viewSize.height*0.26;
        offset2 = viewSize.height*0.44;
    }
    
    func setScene(scene: GameScene) {
        game_scene = scene;
        viewSize = (game_scene?.frame.size)!;
        offset1 = viewSize.height*0.26;
        offset2 = viewSize.height*0.44;
    }
    
    func setSpeed(s: Double) {
        speed = s;
    }
    
    func getSpeed() -> Double {
        return speed;
    }
    
    // Gets the amount of lives limit for that level.
    func getLivesAmount() -> Int {
        return ai_lives_amount;
    }
    
    // Gets the amount of lives the ai has left. 
    func getLives() -> Int {
        return ai_lives;
    }
    
    /*
     * Returns true if the AI has no more lives.
    */
    public func decreaseLife() -> Bool{
        var result = false;
        ai_lives = ai_lives - 1;
        removeLifeAnimation();
        game_scene?.level_controller.startObstacleWave();
        if (ai_lives <= 0) {
            result = true
            ai_lives = ai_lives_amount;
        }
        return result;
    }
    
    // Increases lives amount
    // Max number of lives is 21. 
    public func increaseLivesAmount() {
        ai_lives_amount = ai_lives_amount < 21 ? ai_lives_amount + 1 : ai_lives_amount
        ai_lives = ai_lives_amount;
    }
    
    public func growLives() {
        if (currentGameType == .high_score) {
            var wait_time:TimeInterval = 0.0;
            for i in 0..<ai_lives {
                let lifeNode = SKSpriteNode(imageNamed: "AILife");
                lifeNode.isHidden = true;
                lifeNode.size = ai_life_size;
                lifeNode.position = CGPoint(x: 150 - CGFloat(1 + i*10), y: ai_lives_y_position)
                lifeNode.zPosition = ai_lives_z_position;
                ai_lives_array.append(lifeNode);
                game_scene?.addChild(ai_lives_array[i]);
                growLife(lifeNode: lifeNode, wait_time: wait_time);
                wait_time = wait_time + 0.2;
            }
        }
    }
    
    private func growLife(lifeNode: SKSpriteNode, wait_time: TimeInterval) {
        var growth_frames = AnimationFramesManager?.lifeGrowFrames;
        let actionSequence = SKAction.sequence([SKAction.setTexture(growth_frames![0]), SKAction.wait(forDuration: wait_time), SKAction.unhide(), SKAction.animate(with: growth_frames!, timePerFrame: 0.01), SKAction.setTexture(ai_life_texture)])
        lifeNode.run(actionSequence);
    }
    
    public func growLife() {
        print("power up: enemy grow life.");
        if (ai_lives >= ai_lives_amount) {return}
        
        let lifeNode = SKSpriteNode(imageNamed: "AILife");
        lifeNode.isHidden = true;
        lifeNode.size = ai_life_size;
        lifeNode.position = CGPoint(x: 150 - CGFloat(1 + ai_lives*10), y: ai_lives_y_position)
        lifeNode.zPosition = ai_lives_z_position;
        ai_lives_array.append(lifeNode);
        game_scene?.addChild(ai_lives_array[ai_lives]);
        growLife(lifeNode: lifeNode, wait_time: 0.0);
        ai_lives = ai_lives + 1;
    }
    
    //This method pops the last life in the ai lives array, animates its death, then removes it.
    public func removeLifeAnimation() {
        let deathSequence = SKAction.sequence([SKAction.animate(with: (AnimationFramesManager?.lifeShrinkFrames)!, timePerFrame: 0.01), SKAction.hide()])
        var lifeNode = ai_lives_array.popLast();
        lifeNode?.run(deathSequence, completion: {lifeNode?.removeFromParent(); lifeNode = nil});
    }
    
    public func removeAllLives() {
        while (!ai_lives_array.isEmpty) {
            removeLifeAnimation();
        }
    }
    
    public func setLevel(level: Int64) {
        self.level = level;
    }
    
    // Determine what position on the board the AI will choose
    func selectBoardPosition(board: inout [Int]) -> Int
    {
        var position = 0;
        var b = [0, 0, 0];
        let selections = rows.shuffled();
        for r in selections {
            b = [board[r[0]], board[r[1]], board[r[2]]];
            if (b == [0, O, O]) {return r[0]}
            else if (b == [O, O, 0]) {return r[2]}
            else if (b == [O, 0, O]){return r[1]}
        }
        
        for r in selections {
            b = [board[r[0]], board[r[1]], board[r[2]]];
            if (b == [0, X, X]) {return r[0]}
            else if (b == [X, X, 0]) {return r[2]}
            else if (b == [X, 0, X]){return r[1]}
        }
        
        for r in selections {
            b = [board[r[0]], board[r[1]], board[r[2]]];
            if (b == [0, 0, O]) {return r[Int(arc4random_uniform(2))]}
            else if (b == [O, 0, 0]) {return r[Int(arc4random_uniform(2))+1]}
            else if (b == [0, O, 0])
            {
                position = Int(arc4random_uniform(2));
                if (position == 1) {position = 2}
                return r[position]
            }
        }
        
        // If board is completely empty
        while (true)
        {
            position = Int(arc4random_uniform(9))
            if board[position] == 0
            {
                return position;
            }
        }
        
    }
    
    func setNewChaseMethod()
    {
        //fast_ball = Int(arc4random_uniform(fast_ball_probability))
        // fast_ball must be randomly set to 0 in order to occur;
        // right now it is set to 1 because it is disabled.
        fast_ball = 1;
        var rand = 0;
        if ((ai?.size.width)! < paddle_width)
        {
            rand = Int(arc4random_uniform(3))
            switch rand {
            case 0:
                chase = chase_method.center;
                break
            case 1:
                chase = chase_method.close_left_edge;
                break
            case 2:
                chase = chase_method.close_right_edge;
                break
            default:
                chase = chase_method.center;
                break;
            }
        }
        else
        {
            rand = Int(arc4random_uniform(5));
            switch rand {
            case 0:
                chase = chase_method.center;
                break
            case 1:
                chase = chase_method.close_left_edge;
                break
            case 2:
                chase = chase_method.far_left_edge;
                break
            case 3:
                chase = chase_method.close_right_edge;
                break
            case 4:
                chase = chase_method.far_right_edge;
                break
            default:
                chase = chase_method.center;
                break;
            }
            
        }
        self.setDifficulty();
    }
    
    private func setDifficulty() {
        let rand = Int(arc4random_uniform(5));

        if (currentGameType == gameType.high_score) {
            if (level <= 3) {
                intensity = 0.08;
            }
            else if (level <= 6) {
                if (rand < 3) {intensity = 0.07}
                else {intensity = 0.08}
            }
            else if (level <= 9) {
                intensity = 0.07;
            }
            else if (level <= 12) {
                if (rand == 0) {intensity = 0.5}
                else if (rand < 3) {intensity = 0.6}
                else {intensity = 0.7}
            }
            else if (level <= 15) {
                if (rand < 3) {intensity = 0.5}
                else {intensity = 0.6}
            }
            else if (level <= 18){
                if (rand == 0) {intensity = 0.3}
                else if (rand < 3) {intensity = 0.5}
                else {intensity = 0.55}
                
            }
            else if (level <= 21) {
                if (rand == 0) {intensity = 0.3}
                else if (rand < 3) {intensity = 0.4}
                else {intensity = 0.5}
            }
            else if (level <= 24) {
                if (rand < 2) {intensity = 0.3}
                else {intensity = 0.4}
            }
            else if (level <= 27) {
                if (rand < 2) {intensity = 0.3}
                else {intensity = 0.4}
            }
            else if (level <= 30) {
                if (rand < 3) {intensity = 0.3}
                else {intensity = 0.4}
            }
            else {
                intensity = 0.3;
            }
        }
        else {
            if (rand == 0) {intensity = 0.03}
            else if (rand < 3) {intensity = 0.04}
            else {intensity = 0.05}
        }
    }
    
    public func move()
    {
        let offset = (ai?.position.y)! - (ball?.position.y)!;
        if (offset < offset1 && !enemy_hit_ball)
        {
            if (fast_ball == 0)
            {
                fastBallHit(offset: offset)
            }
            else
            {
                speed = Double(intensity + (0.07)*(offset/offset1));
                switch chase {
                case .center:
                    chaseCenter();
                    break
                case .close_left_edge:
                    chaseCloseLeftEdge();
                    break
                case .far_left_edge:
                    chaseFarLeftEdge();
                    break
                case .close_right_edge:
                    chaseCloseRightEdge();
                    break
                case .far_right_edge:
                    chaseFarRightEdge();
                    break
                }
            }
        }
        else if (offset >= offset1 && offset < offset2 && !enemy_hit_ball)
        {
            speed = 0.1;
            chaseCenter();
        }
        else
        {
            speed = 0.7;
            chaseCenter();
        }
    }
    
    private func chaseCloseLeftEdge()
    {
        ai?.run(SKAction.moveTo(x: (ball!.position.x + (ai!.size.width/4)), duration: speed))
    }
    
    private func chaseFarLeftEdge()
    {
        ai?.run(SKAction.moveTo(x: (ball!.position.x + (ai!.size.width/3)), duration: speed))
    }
    
    private func chaseCloseRightEdge()
    {
        ai?.run(SKAction.moveTo(x: (ball!.position.x - (ai!.size.width/4)), duration: speed))
    }
    
    private func chaseFarRightEdge()
    {
        ai?.run(SKAction.moveTo(x: (ball!.position.x - (ai!.size.width/3)), duration: speed))
    }
    
    private func chaseCenter()
    {
        ai?.run(SKAction.moveTo(x: ball!.position.x, duration: speed))
    }
    
    /*
     * Currently not in use.
     */
    private func fastBallHit(offset: CGFloat)
    {
        var position:CGFloat = 0.0
        var speed = 0.0
        let x_offset = ball!.position.x < (ai?.position.x)!
        
        if (offset < 20)
        {
            if (fast_ball_position == 0.0)
            {
                fast_ball_position = ball!.position.x;
            }
            
            if (x_offset)
            {
                position = fast_ball_position - 20;
            }
            else
            {
                position = fast_ball_position + 20;
            }
            speed = 0.02;
        }
        else
        {
            if (fast_ball_position != 0.0)
            {
                fast_ball_position = 0.0;
            }
            
            if (x_offset)
            {
                position = ball!.position.x + 20;
            }
            else
            {
                position = ball!.position.x - 20;
            }
            speed = 0.1;
        }
        
        ai?.run(SKAction.moveTo(x: position, duration: speed))
    }
}
