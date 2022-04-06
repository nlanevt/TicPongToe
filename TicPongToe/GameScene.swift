//
//  GameScene.swift
//  Tic-Pong-Toe
//
//  Created by Nathan Lane on 2/19/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import SpriteKit
import GameplayKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    private var ballmanager = Ball();
    private var ball = SKSpriteNode();
    
    private var enemy:Paddle = Paddle(direction_down: true);
    private var main:Paddle = Paddle(direction_down: false);
    private var main_boundary_position:CGFloat = -194;
    private var enemy_boundary_position:CGFloat = 247;
    
    public var score: Int64 = 0;
    public var level_controller:LevelController!
    
    public var life = 6;
    private var max_lives = 6;
    public var player_score_counter:Int64 = 0;
    public var enemy_score_counter:Int64 = 0;
    
    private var high_score = SKLabelNode();
    private var player_score_animation = SKLabelNode();
    private var player_score = SKLabelNode();
    private var enemy_score_animation = SKLabelNode();
    private var enemy_score = SKLabelNode();
    private var player_won = false;
    public var game_over = false;
    
    private var square1 = SKSpriteNode();
    private var square2 = SKSpriteNode();
    private var square3 = SKSpriteNode();
    private var square4 = SKSpriteNode();
    private var square5 = SKSpriteNode();
    private var square6 = SKSpriteNode();
    private var square7 = SKSpriteNode();
    private var square8 = SKSpriteNode();
    private var square9 = SKSpriteNode();
    public var squaresArray = [SKSpriteNode]();
    
    private var animationSquare1 = SKSpriteNode();
    private var animationSquare2 = SKSpriteNode();
    private var animationSquare3 = SKSpriteNode();
    private var animationSquare4 = SKSpriteNode();
    private var animationSquare5 = SKSpriteNode();
    private var animationSquare6 = SKSpriteNode();
    private var animationSquare7 = SKSpriteNode();
    private var animationSquare8 = SKSpriteNode();
    private var animationSquare9 = SKSpriteNode();
    private var animationSquaresArray = [SKSpriteNode]();
    
    private var XTexture:SKTexture = SKTexture.init(imageNamed: "X");
    private var CircleTexture:SKTexture = SKTexture.init(imageNamed: "Circle");
    private var XAnimationTexture:SKTexture = SKTexture.init(imageNamed: "XAnimation");
    private var CircleAnimationTexture:SKTexture = SKTexture.init(imageNamed: "CircleAnimation");
    private var XWinTexture:SKTexture = SKTexture.init(imageNamed: "XWin");
    private var CircleWinTexture:SKTexture = SKTexture.init(imageNamed: "CircleWin");
    
    private let squares_alpha:CGFloat = 1.0;
    private let animation_squares_alpha:CGFloat = 1.0;
    private let animation_squares_default_size:CGFloat = 200;
    private let animation_squares_hit_size:CGFloat = 250;
    private var tictactoeboard = [Int]();
    private var boardCombinations = [[Int]]();
    
    private var players_turn = false;
    private var player_starts = false;
    private var board_hits = 0;

    private var timer_node = SKSpriteNode();
    private var timerLabel = SKLabelNode();
    private var seconds = 10;
    private var timer = Timer();
    private var isTimerRunning = false;

    private var main_paddle_move_boundary:CGFloat = -175;
    private var enemy_is_dead = false; // Used when paddle is complete deleted and user scores.
    private var hitWallFrames:[SKTexture] = [];
    private var hitPaddleFrames:[SKTexture] = [];
    
    public var ai:AI!
    
    private var animation_on = false;
    
    private var pauseButton = SKSpriteNode();
    private var pauseButtonGrid = SKSpriteNode();
    private var pauseButtonTexture:SKTexture = SKTexture.init(imageNamed: "pauseButton");
    private var pauseButtonAnimationTexture:SKTexture = SKTexture.init(imageNamed: "pauseButtonAnimation");
    
    private var lives:[SKSpriteNode] = [];
    private var lifeTexture:SKTexture = SKTexture.init(imageNamed: "Life");
    private var lifeSize:CGSize = CGSize.init(width: 24, height: 24);
    
    private var gameFrame = SKSpriteNode();
    
    private var scroller : InfiniteScrollingBackground?
    
    private var topLevelLabel = SKLabelNode();
    private var centerLevelLabel = SKLabelNode();
    private var pending_round = false;
    
    deinit {
        print("Deinit GameScene")
        self.removeAllActions()
        self.removeAllChildren()
    }
    
    override func didMove(to view: SKView)
    {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.black;
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        // Build animation frames
        AnimationFramesManager?.buildGameFrames();
        hitWallFrames = (AnimationFramesManager?.getHitWallFrames())!;
        hitPaddleFrames = (AnimationFramesManager?.getHitPaddleFrames())!;
        
        high_score = self.childNode(withName: "high_score") as! SKLabelNode;
        player_score = self.childNode(withName: "player_score") as! SKLabelNode;
        enemy_score = self.childNode(withName: "enemy_score") as! SKLabelNode;
        player_score_animation = self.childNode(withName: "player_score_animation") as! SKLabelNode;
        player_score_animation.alpha = 0.0;
        player_score_animation.fontColor = UIColor.yellow;
        enemy_score_animation = self.childNode(withName: "enemy_score_animation") as! SKLabelNode;
        enemy_score_animation.alpha = 0.0;
        enemy_score_animation.fontColor = UIColor.yellow;
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ballmanager.setUp(ball: &ball);
        
        enemy = self.childNode(withName: "enemy") as! Paddle
        main = self.childNode(withName: "main") as! Paddle
        
        timerLabel = self.childNode(withName: "timer") as! SKLabelNode;
        
        square1 = self.childNode(withName: "square1") as! SKSpriteNode
        square2 = self.childNode(withName: "square2") as! SKSpriteNode
        square3 = self.childNode(withName: "square3") as! SKSpriteNode
        square4 = self.childNode(withName: "square4") as! SKSpriteNode
        square5 = self.childNode(withName: "square5") as! SKSpriteNode
        square6 = self.childNode(withName: "square6") as! SKSpriteNode
        square7 = self.childNode(withName: "square7") as! SKSpriteNode
        square8 = self.childNode(withName: "square8") as! SKSpriteNode
        square9 = self.childNode(withName: "square9") as! SKSpriteNode
        squaresArray = [square1, square2, square3, square4, square5, square6, square7, square8, square9];

        animationSquare1 = self.childNode(withName: "animationSquare1") as! SKSpriteNode
        animationSquare2 = self.childNode(withName: "animationSquare2") as! SKSpriteNode
        animationSquare3 = self.childNode(withName: "animationSquare3") as! SKSpriteNode
        animationSquare4 = self.childNode(withName: "animationSquare4") as! SKSpriteNode
        animationSquare5 = self.childNode(withName: "animationSquare5") as! SKSpriteNode
        animationSquare6 = self.childNode(withName: "animationSquare6") as! SKSpriteNode
        animationSquare7 = self.childNode(withName: "animationSquare7") as! SKSpriteNode
        animationSquare8 = self.childNode(withName: "animationSquare8") as! SKSpriteNode
        animationSquare9 = self.childNode(withName: "animationSquare9") as! SKSpriteNode
        animationSquaresArray = [animationSquare1, animationSquare2, animationSquare3, animationSquare4, animationSquare5, animationSquare6, animationSquare7, animationSquare8, animationSquare9];
        
        topLevelLabel = self.childNode(withName: "TopLevelLabel") as! SKLabelNode;
        centerLevelLabel = self.childNode(withName: "CenterLevelLabel") as! SKLabelNode;
        
        boardCombinations = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]];
        
        pauseButton = self.childNode(withName: "pauseButton") as! SKSpriteNode
        pauseButtonGrid = self.childNode(withName: "pauseButtonGrid") as! SKSpriteNode
        
        gameFrame = self.childNode(withName: "Frame") as! SKSpriteNode
        
        timer_node = self.childNode(withName: "TimerNode") as! SKSpriteNode;

        main.setAnimationFrames();
        enemy.setAnimationFrames();
        
        MenuViewControl?.setUpPauseView();
        
        //----Initiating Starry Background Animation------------
        let images = [UIImage(named: "BackgroundStarAnimationA")!, UIImage(named: "BackgroundStarAnimationA")!]
        
        // Initializing InfiniteScrollingBackground's Instance:
        scroller = InfiniteScrollingBackground(images: images, scene: self, scrollDirection: .bottom, transitionSpeed: 18)
        scroller?.scroll()
        scroller?.zPosition = -3
        
        level_controller = LevelController.init(scroller: scroller!, game_scene: self);
        ai = AI(scene: self, level_controller: level_controller, ball: ball, ai: enemy);
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        border.categoryBitMask = 4;
        self.physicsBody = border
        
        // Run the relevant game type
        startGame();
    }
    
    private func startGame()
    {
        //level = 1;
        score = 0;
        life = max_lives;
        tictactoeboard = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        players_turn = false;
        player_starts = false;
        player_won = false;
        game_over = false;
        //timerLabel.text = "\(seconds)";
        resetTimer();
        if (currentGameType == gameType.high_score)
        {
            pending_round = true;
            high_score.isHidden = false;
            player_score.isHidden = true;
            enemy_score.isHidden = true;
            player_score_animation.isHidden = true;
            enemy_score_animation.isHidden = true;
            high_score.text = "\(score)";
            ball.isHidden = true;
            
            self.startLevel { [weak self] in
                self!.ai.growLives();
                self!.pending_round = false;
                self!.startBall(down: false)
                self!.ai.setNewChaseMethod();
                self!.runTimer();
            }
            
            for i in 0..<Int(life/2) {
                let lifeNode = SKSpriteNode(texture: lifeTexture, size: lifeSize);
                
                lifeNode.position = CGPoint(x: pauseButton.position.x + CGFloat(30 + i*28), y: pauseButton.position.y)
                lifeNode.zPosition = pauseButton.zPosition;
                lives.append(lifeNode);
                self.addChild(lives[i]);
            }
        }
        else // Play Duel!!!
        {
            high_score.isHidden = true;
            player_score.isHidden = false;
            enemy_score.isHidden = false;
            player_score_animation.isHidden = false;
            enemy_score_animation.isHidden = false;
            player_score.text = "\(player_score_counter)";
            enemy_score.text = "\(enemy_score_counter)";
            player_score_animation.text = "\(player_score_counter)";
            enemy_score_animation.text = "\(enemy_score_counter)";
            
            startBall(down: false)
            ai.setNewChaseMethod();
            runTimer();
        }
    }
    
    private func startLevel(completion: @escaping ()->Void) {
        let centerLabelfadeIn = SKAction.fadeIn(withDuration: 0.25);
        let centerWait = SKAction.wait(forDuration: 3.0);
        let fadeOut = SKAction.fadeOut(withDuration: 0.25);
        /*var centerLabelFloatUp = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 0.25)
        var centerLabelFloatDown = centerLabelFloatUp.reversed();
        var centerLabelFloatingSequence = SKAction.repeatForever(SKAction.sequence([centerLabelFloatUp, centerLabelFloatDown]))*/
        
        let centerFadeAction = SKAction.sequence([SKAction.unhide(), centerLabelfadeIn, centerWait, fadeOut, SKAction.hide()])
        
        let topLabelFloatUp = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 0.75)
        let topLabelFloatDown = topLabelFloatUp.reversed();
        let topLabelFloatingAction = SKAction.repeatForever(SKAction.sequence([topLabelFloatUp, topLabelFloatDown]))
        let topFadeIn = SKAction.group([SKAction.unhide(), topLabelFloatingAction, SKAction.fadeAlpha(to: 0.25, duration: 0.5)]);
        let topFadeOut = SKAction.group([topLabelFloatingAction, fadeOut, SKAction.hide()]);
        
        if (topLevelLabel.isHidden == false) {
            // fade out top level label
            topLevelLabel.run(topFadeOut);
        }
        
        topLevelLabel.text = "LEVEL \(level_controller.getLevel())";
        topLevelLabel.isHidden = true;
        topLevelLabel.alpha = 0.0;
        centerLevelLabel.text = "LEVEL \(level_controller.getLevel())";
        centerLevelLabel.isHidden = false;
        centerLevelLabel.alpha = 0.0;
        
        //Clean up Powerup item data, Set level values, and start the first powerup wave.
        level_controller.clearLevelItems();
        level_controller.setLevelValues();
        level_controller.startPowerUpWave();
        
        centerLevelLabel.run(centerFadeAction, completion: {
           // self.topLevelLabel.run(topFadeIn);
            completion();
        })
    }
    
    // TODO: Adjust Level class values from this function.
    private func increaseLevel() {
        
        pending_round = true;
        endTicTacToeGame(quick_fade: false, completion: {
            [weak self] in
            self!.resetBoard();
            self!.switchStartingPlayer();
            self!.animation_on = true;
        });
        
        level_controller.increaseLevel();
        ai.setLivesAmount();
        
        startLevel(completion: {[weak self] in
            self!.pending_round = false;
            self!.resetBoard();
            self!.startBall(down: false)
            self!.ai.setNewChaseMethod();
            self!.resetTimer();
            self!.fadeInTimer(completion: {
                self!.runTimer();
            })
            
            // Grow enemy paddle to start the (new) level
            if (self!.enemy_is_dead) {
                self!.enemy.animateGrowth(completion: {self!.enemy_is_dead = false})
            }
            
            self!.ai.growLives();
            
            self!.animation_on = false;
        })
    }
    
    // This function animates and times ball properly whenever it starts
    // Ball
    private func startBall(down: Bool)
    {
        if (game_over) {return};
        ai.enemy_hit_ball = down;
        ballmanager.startBall(down: down);
    }
    
    private func endGame()
    {
        // Remove the paddles through the paddle death animation
        // Remove the X/O's through a fadeout animation
        // Ensure that ball can bounce around where-ever
        // Ensure that the ai lives aren't present on the screen
        game_over = true;
        stopTimer();

        endTicTacToeGame(quick_fade: false, completion: {
            [weak self] in
            self!.resetBoard();
            self!.clearBoard();
        }); // remove x/o's from game.
        
        if (!main.isHidden)
        {
            main.animateRemoval()
        }
        
        if (!enemy.isHidden)
        {
            enemy.animateRemoval();
        }

        // MARK: Deactivate below to ensure no new scores get saved
        if (currentGameType == gameType.high_score)
        {
            ai.removeAllLives(); // Remove all remaining ai_lives from the screen
            level_controller.clearLevelItems(); //Ensures powerups disappear once the game is over.
            
            if (score > HighScore)
            {
                HighScore = score;
            }
            MenuViewControl?.ScoreLabel.text = "\(score)";
            MenuViewControl?.addScoreToLeaderBoard(score: HighScore);
        }
        else
        {
            if (player_won)
            {
                MenuViewControl?.GameOverLabel.text = "YOU WON!";
                NumberOfGamesWon = NumberOfGamesWon + 1;
            }
            else
            {
                MenuViewControl?.GameOverLabel.text = "YOU LOSE";
            }
        }
        
        MenuViewControl?.deleteCoreData(); // Remove any current core data.
        MenuViewControl?.save(high_score: HighScore, games_won: NumberOfGamesWon, games_played: NumberOfGamesPlayed, is_purchased: isPurchased) // Save new info to Core Data
        MenuViewControl?.loadScores();
        GameViewControl?.endGame(); // load game over screen
    }
    
    // Type is the type of game that was scored.
    // Type == 0 is Pong
    // Type == 1 is Tic-Tac-Toe
    private func setScore(playerWhoWon: SKSpriteNode, amount: Int64, type: Int)
    {
        if (currentGameType == gameType.high_score)
        {
            if (playerWhoWon == main && type == 0)
            {
                // run increase score animation
                var score_counter = score;
                score = score + amount;
                let waitAction = SKAction.wait(forDuration: 0.01);
                let increaseScoreAction = SKAction.run({
                    [weak self] in
                    self!.high_score.fontColor = UIColor.yellow;
                    score_counter = score_counter + 1;
                    self!.high_score.text = "\(score_counter)";
                })
                
                /* Start Score Increase Animation */
                let repeatScoreIncreaseAction = SKAction.repeat(SKAction.sequence([increaseScoreAction, waitAction]), count: Int(amount));
                high_score.run(repeatScoreIncreaseAction, completion: {
                    [weak self] in
                    self!.high_score.fontColor = UIColor.white;
                });
                /* End Score Increase Animation */
                
                /* +Score sign animation */
                let scorelabelnode = SKLabelNode(fontNamed: "RixVideoGame3D");
                scorelabelnode.alpha = 1.0;
                scorelabelnode.zPosition = 1.0;
                scorelabelnode.fontColor = UIColor.init(red: 73, green: 170, blue: 16);
                scorelabelnode.fontSize = 32;
                scorelabelnode.horizontalAlignmentMode = .center;
                scorelabelnode.verticalAlignmentMode = .top;
                scorelabelnode.text = "+\(amount)";
                scorelabelnode.position = ballmanager.ball.position.x > abs(120) ?  CGPoint(x: sign(Double(ballmanager.ball.position.x))*120, y: 245.0) : CGPoint(x: ballmanager.ball.position.x, y: 245.0)
                self.addChild(scorelabelnode);
                
                let moveVector = ballmanager.ball.position.x < 0 ? CGVector(dx: 4, dy: -6) : CGVector(dx: -4, dy: -6);
                let scoreLabelActionSequence = SKAction.sequence([SKAction.move(by: moveVector, duration: 1.0), SKAction.fadeOut(withDuration: 0.25)]);
                
                scorelabelnode.run(scoreLabelActionSequence, completion: {scorelabelnode.removeFromParent()});
                /* End +Score sign animation */
                
                // Decreases the ai's life and checks to see if ai's life is depleted. IF it is we increase the level
                if (ai.decreaseLife()) {
                    self.increaseLevel();
                }
                
            }
            else if (type == 0) // Enemy scored a pong score, not a tic-tac-toe score (which shouldn't take away the players life). Only a Pong score does that.
            {
                removeLife();
            }
            
            if (life == 0)
            {
                endGame();
            }
            
            high_score.text = "\(score)";
        }
        else if (type == 0) // i.e. It is Duel and its a pong score, not a tic tac toe score
        {
            if (playerWhoWon == main)
            {
                player_score_counter = player_score_counter + 1
                player_score.text = "\(player_score_counter)";
                player_score_animation.text = "\(player_score_counter)";
                
                player_score_animation.alpha = 1.0;
                player_score_animation.run(SKAction.fadeOut(withDuration: 1.0));
            }
            else
            {
                enemy_score_counter = enemy_score_counter + 1
                enemy_score.text = "\(enemy_score_counter)";
                enemy_score_animation.text = "\(enemy_score_counter)";
                enemy_score_animation.alpha = 1.0;
                enemy_score_animation.run(SKAction.fadeOut(withDuration: 1.0));
            }
            
            if (player_score_counter == 11)
            {
                player_won = true;
                endGame();
            }
            
            if (enemy_score_counter == 11)
            {
                player_won = false;
                endGame();
            }
        }
    }
    
    
    // Type is the type of game that was scored.
    // Type == 0 is Pong
    // Type == 1 is Tic-Tac-Toe
    private func addScore(playerWhoWon: SKSpriteNode, type: Int)
    {
        if (game_over) {return} // don't add scores or do anything if game is over
        
        if (type == 0) // pong score
        {
            if playerWhoWon == main
            {
                setScore(playerWhoWon: main, amount: calculateScore(), type: 0)
                
                if (!enemy_is_dead) {
                    enemy_is_dead = true;
                    enemy.animateDeath(completion: {
                        [weak self] in
                        if (self!.game_over) {
                            self!.enemy.isHidden = true;
                            self!.enemy.physicsBody = nil;
                        }
                        else if (!self!.pending_round) {
                            self!.enemy.animateGrowth(completion: {
                                self!.enemy_is_dead = false;
                            })
                        }
                    })
                }
                
                
                if (!pending_round) {
                    startBall(down: true)
                }

            }
            else if playerWhoWon == enemy
            {
                setScore(playerWhoWon: enemy, amount: 0, type: 0)
                startBall(down: false)
                main.animateDeath(completion: {
                    [weak self] in
                    // Grow paddle
                    if (self!.game_over)
                    {
                        self!.main.isHidden = true;
                        self!.main.physicsBody = nil;
                    }
                    else {
                        self!.main.animateGrowth(completion: {})
                    }
                })
            }
        }
        else if (type == 1) // tic tac toe score
        {
            if playerWhoWon == main
            {
                enemy.shrink();
                
                if (main.size.width < Paddle.default_paddle_width)
                {
                    main.grow();
                }
                
                // Get extra points for completely removing the enemy paddle
                if (enemy.size.width == 0)
                {
                    setScore(playerWhoWon: main, amount: 0, type: 1)
                    if (!enemy_is_dead) {
                        enemy_is_dead = true;
                        enemy.animateDeath(completion: {
                            [weak self] in
                            if (self!.game_over) {
                                self!.enemy.isHidden = true;
                                self!.enemy.physicsBody = nil;
                            }
                            else if (!self!.pending_round) {
                                self!.enemy.animateGrowth(completion: {self!.enemy_is_dead = false})
                            }
                        })
                    }
                }
                else
                {
                    setScore(playerWhoWon: main, amount: 0, type: 1)
                }
            }
            else if (playerWhoWon == enemy)
            {
                // Shrink main paddle
                main.shrink();
                
                if (enemy.size.width < Paddle.default_paddle_width)
                {
                    enemy.grow();
                }
                
                // remove life from player
                if (main.size.width == 0)
                {
                    setScore(playerWhoWon: enemy, amount: 0, type: 1)
                    main.animateDeath(completion: {// Grow paddle
                        [weak self] in
                        if (self!.game_over)
                        {
                            self!.main.isHidden = true;
                            self!.main.physicsBody = nil;
                        }
                        else {
                            self!.main.animateGrowth(completion: {})
                        }
                    })
                }
            }
        }
        
        // Set new way of moving enemy paddle
        ai.setNewChaseMethod();
        
        // Score needs to be animated properly when changed.
    }
    
    private func calculateScore() -> Int64 {
        var score_counter:Int64 = 100;
        if (enemy.size.width == 72) {
            score_counter = score_counter + 25;
        }
        else if (enemy.size.width == 48) {
            score_counter = score_counter + 50;
        }
        else if (enemy.size.width == 24) {
            score_counter = score_counter + 100;
        }
        else if (enemy_is_dead == true) {
            score_counter = score_counter + 200;
        }
        
        if (ballmanager.ballspeed >= 50) { // You need the ball to go fast if you want the extra points
            score_counter = score_counter + Int64(ballmanager.ballspeed);
        }
        
        return score_counter;
    }
    
    /*
        This function generates the frames depending on what is passed in
        If you pass in "Paddle96Death" it will generate the frames for that animation
     */
    private func buildAnimation(textureAtlasName: String) -> [SKTexture]
    {
        let atlas = SKTextureAtlas(named: textureAtlasName);
        var frames: [SKTexture] = [];
        let numImages = atlas.textureNames.count
        for i in 1...numImages {
            let name = "\(textureAtlasName)\(i)"
            frames.append(atlas.textureNamed(name))
        }
        
        return frames;
    }
    
    private func animateScoreExplosion() {
        var scoreExplosionFrames:[SKTexture] = [];
        
        var explosion_position:CGFloat = 0.0;
        var explosion_zRotation:CGFloat = 0.0;
        if (ballmanager.ball.position.y <= main.position.y) {
            scoreExplosionFrames = (AnimationFramesManager?.scoreExplosionAFrames)!;
        
            explosion_position = main_boundary_position + (scoreExplosionFrames[0].size().height / 2);
            
        }
        else if (ballmanager.ball.position.y >= enemy.position.y) {
            scoreExplosionFrames = (AnimationFramesManager?.scoreExplosionBFrames)!;
            explosion_zRotation = CGFloat.pi;
            explosion_position = enemy_boundary_position - (scoreExplosionFrames[0].size().height / 2);
        }
        else {
            return;
        }
        
        var explosionNode:SKSpriteNode? = SKSpriteNode(texture: scoreExplosionFrames[0], size: scoreExplosionFrames[0].size());
        explosionNode?.zPosition = 0.0;
        explosionNode?.position.x = ballmanager.ball.position.x;
        explosionNode?.zRotation = explosion_zRotation;
        explosionNode?.position.y = explosion_position;
                
        self.addChild(explosionNode!);
        explosionNode?.run(SKAction.animate(with: scoreExplosionFrames, timePerFrame: 0.05), completion: {
            explosionNode?.removeFromParent();
            explosionNode = nil;
        })
    }
    
    private func animateHitWall(contact_point: CGPoint)
    {
        if (contact_point.y < main.position.y || contact_point.y > enemy.position.y) {return}
        
        var hitWallNode:SKSpriteNode? = SKSpriteNode(texture: hitWallFrames[0], size: hitWallFrames[0].size());
        
        hitWallNode?.zPosition = 0.0;
        hitWallNode?.position.y = contact_point.y;
        if (contact_point.x > 0) {
            hitWallNode?.position.x = contact_point.x - 2
        }
        else {
            hitWallNode?.position.x = contact_point.x + 2;
        }
        
        // Use small wall hit explosion
        if (ballmanager.ballspeed >= 42 && ballmanager.ballspeed < 48) {
            let hitWallSparkNode = SKSpriteNode(texture: hitPaddleFrames[0], size: hitPaddleFrames[0].size());
            hitWallSparkNode.position = (hitWallNode?.position)!;
            hitWallSparkNode.zPosition = (hitWallNode?.zPosition)!;
            self.addChild(hitWallSparkNode);
            hitWallSparkNode.run(SKAction.animate(with: hitPaddleFrames, timePerFrame: 0.025), completion: {
                hitWallSparkNode.removeFromParent();
            })
        }
        else {
            // if the ballspeed >= 48 and < 55 use the medium hit explosion
            var frames = AnimationFramesManager?.hitWallBFrames;
            
            // otherwise if ballspeed >= 55 use the big hit explosion
            if (ballmanager.ballspeed >= 55) {
                frames = AnimationFramesManager?.hitWallCFrames;
            }
            
            
            let hitWallBNode = SKSpriteNode(texture: frames?[0], size: (frames?[0].size())!);
            hitWallBNode.zPosition = 0.0;
            hitWallBNode.position.y = contact_point.y;
            if (contact_point.x > 0) {
                hitWallBNode.position.x = contact_point.x - 2 - ((frames![0].size().width) / 2);
                hitWallBNode.zRotation = CGFloat.pi;
            }
            else {
                hitWallBNode.position.x = contact_point.x + 2 + ((frames![0].size().width) / 2);
            }
            
            self.addChild(hitWallBNode);
            hitWallBNode.run(SKAction.animate(with: frames!, timePerFrame: 0.025), completion: {
                hitWallBNode.removeFromParent();
            })
            
            return;
        }
        
        self.addChild(hitWallNode!);
        hitWallNode?.run(SKAction.animate(with: hitWallFrames, timePerFrame: 0.01), completion: {
            hitWallNode?.removeFromParent();
            hitWallNode = nil;
        })
    }
    
    private func animateHitPaddle(contact_point: CGPoint)
    {
        // < 48 use small
        // >= 48 and < 55 use medium
        // >= 55 use big
        var hitPaddleNode = SKSpriteNode(texture: hitPaddleFrames[0], size: hitPaddleFrames[0].size());
        hitPaddleNode.zPosition = 0.0;
        hitPaddleNode.position = contact_point
        
        if (ballmanager.ballspeed < 48) {
            self.addChild(hitPaddleNode);
            hitPaddleNode.run(SKAction.animate(with: hitPaddleFrames, timePerFrame: 0.025), completion: {
                hitPaddleNode.removeFromParent();
            })
        }
        else if (ballmanager.ballspeed >= 48 && ballmanager.ballspeed < 55) {
            hitPaddleNode = SKSpriteNode(texture: AnimationFramesManager?.hitPaddleBFrames?[0], size: (AnimationFramesManager?.hitPaddleBFrames?[0].size())!);
            hitPaddleNode.zPosition = 0.0;
            hitPaddleNode.position = contact_point
            self.addChild(hitPaddleNode);
            hitPaddleNode.run(SKAction.animate(with: (AnimationFramesManager?.hitPaddleBFrames)!, timePerFrame: 0.05), completion: {
                hitPaddleNode.removeFromParent();
            })
        }
        else {
            hitPaddleNode = SKSpriteNode(texture: AnimationFramesManager?.hitPaddleCFrames?[0], size:CGSize(width: (AnimationFramesManager?.hitPaddleCFrames?[0].size().width)! / 2, height: (AnimationFramesManager?.hitPaddleCFrames?[0].size().height)! / 2));
            hitPaddleNode.zPosition = 0.0;
            hitPaddleNode.position.x = contact_point.x;
            hitPaddleNode.position.y = contact_point.y + (hitPaddleNode.size.height/2);
            
            if (ballmanager.ball.position.y >= 0) {
                hitPaddleNode.zRotation = .pi;
                hitPaddleNode.position.y = contact_point.y - (hitPaddleNode.size.height/2);
            }
            
            self.addChild(hitPaddleNode);
            hitPaddleNode.run(SKAction.animate(with: (AnimationFramesManager?.hitPaddleCFrames)!, timePerFrame: 0.04), completion: {
                hitPaddleNode.removeFromParent();
            })
        }
    }
    
    private func removeLife() {
        if (life <= 0) {return}
        
        let index = (life / 2) + (life % 2) - 1 // Gets the proper life node in the lives array
        
        var frames = AnimationFramesManager?.lifeDeathAFrames;
        
        // If it is not 0 then that means we are removing the second half of the heart.
        if (life % 2 != 0) {frames = AnimationFramesManager?.lifeDeathBFrames}
        
        // run remove life animation
        let shrinkAction = SKAction.animate(with: frames!, timePerFrame: 0.1);
        let finalTexture = SKAction.setTexture((frames?.last)!)
        var shrinkSequence:[SKAction] = []
        
        for _ in 0 ..< 8 {shrinkSequence.append(shrinkAction)}
        
        shrinkSequence.append(finalTexture)
        
        lives[index].run(SKAction.sequence(shrinkSequence));
        life = life - 1; // remove life from player
    }
    
    public func growLife(amount: Int) -> Bool {
        if (life >= max_lives) {return false}
        
        var life_counter = life;
        if (life + amount > max_lives) {
            life = max_lives;
        }
        else {
            life = life + amount;
        }
        
        while (life_counter < life) {
            life_counter = life_counter + 1;
            let index = (life_counter / 2) + (life_counter % 2) - 1;
            var frames = AnimationFramesManager?.lifeGrowAFrames;
            
            if (life_counter % 2 == 0) {
                frames = AnimationFramesManager?.lifeGrowBFrames
            }
            else if (life_counter + 1 <= life) {
                frames = AnimationFramesManager?.lifeGrowFullFrames
                life_counter = life_counter + 1;
            }
            
            // create and run grow life animation
            let growAction = SKAction.animate(with: frames!, timePerFrame: 0.1);
            let finalTexture = SKAction.setTexture((frames?.last)!) //MARK: May need to replace frames?.last with the lives texture
            var growthSequence:[SKAction] = []
            
            for _ in 0 ..< 8 {growthSequence.append(growAction)}
            
            growthSequence.append(finalTexture)
            
            lives[index].run(SKAction.sequence(growthSequence));
        }
        
        return true;
    }
    
    public func getLivesLeft() -> Int {
        return max_lives - life;
    }
    
    public func runTimer() {
        if (!game_over && !pending_round && !isTimerRunning)
        {
            isTimerRunning = true;
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(GameScene.updateTimer)), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        timerLabel.text = "\(seconds)" //This will update the label.
        if (seconds >= 0) {
            timer_node.isHidden = false;
            timer_node.texture = AnimationFramesManager?.timerImageFrames?[10-seconds]; //MARK hardcoded 10, which is infact the length of the timerImageframes array.
        }
        else {
            timer_node.isHidden = true;
        }
    }
    
    public func stopTimer()
    {
        isTimerRunning = false;
        timer.invalidate()
        //moon_timer.isPaused = true; //MARK
    }
    
    private func resetTimer()
    {
        isTimerRunning = false;
        stopTimer();
        seconds = 10;
        timerLabel.text = "\(seconds)"
        timer_node.texture = AnimationFramesManager?.timerImageFrames?[10-seconds]; //MARK hardcoded 10, which is infact the length of the timerImageframes array.
    }
    
    private func fadeOutTimer() {
        let fadeoutAction = SKAction.fadeOut(withDuration: 0.25);
        stopTimer()
        timerLabel.run(fadeoutAction);
        timer_node.run(fadeoutAction); //MARK
    }
    
    private func fadeInTimer(completion: @escaping ()->Void) {
        let fadeinAction = SKAction.fadeIn(withDuration: 0.25)
        timerLabel.run(fadeinAction, completion: {completion()});
        timer_node.run(fadeinAction, completion: {completion()}); //MARK
    }
    
    private func resetBoard()
    {
        for i in 0 ..< tictactoeboard.count {
            tictactoeboard[i] = 0;
        }
        
        board_hits = 0;
        square1.alpha = 0.0;
        square2.alpha = 0.0;
        square3.alpha = 0.0;
        square4.alpha = 0.0;
        square5.alpha = 0.0;
        square6.alpha = 0.0;
        square7.alpha = 0.0;
        square8.alpha = 0.0;
        square9.alpha = 0.0;
    }
    
    private func checkBoard(paddle: SKSpriteNode)
    {
        var check = 0;
        var temp:SKSpriteNode = enemy;
        var verification = 15;
        
        if (paddle == main)
        {
            verification = 3;
            temp = main;
        }
        
        for i in 0..<boardCombinations.count {
            for j in 0..<boardCombinations[i].count {
                check = check + tictactoeboard[boardCombinations[i][j]];
            }
            if (check == verification)
            {
                winRoundAnimation(player: temp, winning_squares: boardCombinations[i]);
                return;
            }
            check = 0;
        }
        
        if (!pending_round) {
            resetTimer();
            runTimer();
        }
    }
    
    private func winRoundAnimation(player: SKSpriteNode, winning_squares: [Int])
    {
        addScore(playerWhoWon: player, type: 1);
        if (animation_on == false) {
            animation_on = true;
            fadeOutTimer();
            var texture:SKTexture;
            var winningTexture:SKTexture;
            let fadeoutAction = SKAction.fadeOut(withDuration: 0.2);
            var wait_time = 0.0;
            if (player == main)
            {
                texture = XTexture;
                winningTexture = XWinTexture;
            }
            else
            {
                texture = CircleTexture;
                winningTexture = CircleWinTexture;
            }
            
            for i in 0..<squaresArray.count {
                if (squaresArray[i] != squaresArray[winning_squares[0]] &&
                    squaresArray[i] != squaresArray[winning_squares[1]] &&
                    squaresArray[i] != squaresArray[winning_squares[2]])
                {
                    if (squaresArray[i].hasActions())
                    {
                        squaresArray[i].removeAllActions();
                    }
                    
                    squaresArray[i].run(SKAction.sequence([SKAction.wait(forDuration: wait_time), fadeoutAction]));
                    
                    if (squaresArray[i].alpha > 0)
                    {
                        wait_time = wait_time + 0.1;
                    }
                }
            }
            
            
            
            wait_time = wait_time + 0.25;
            for i in 0..<winning_squares.count {
                squaresArray[winning_squares[i]].alpha = 1.0
                squaresArray[winning_squares[i]].texture = winningTexture;
                
                if (squaresArray[winning_squares[i]].hasActions())
                {
                    squaresArray[winning_squares[i]].removeAllActions();
                }
                
                if (i < 2)
                {
                    squaresArray[winning_squares[i]].run(SKAction.sequence([SKAction.wait(forDuration: wait_time), fadeoutAction]), completion: {[weak self] in
                        self!.squaresArray[winning_squares[i]].texture = texture;
                    });
                }
                else
                {
                    squaresArray[winning_squares[i]].run(SKAction.sequence([SKAction.wait(forDuration: wait_time), fadeoutAction]), completion: {[weak self] in
                        self!.squaresArray[winning_squares[i]].texture = texture;
                        if (!self!.pending_round && !self!.game_over) {
                            self!.resetBoard();
                            self!.switchStartingPlayer();
                            self!.resetTimer();
                            self!.fadeInTimer {
                                self!.runTimer();
                            }
                        }
                        self!.animation_on = false;
                    });
                }
                wait_time = wait_time + 0.1;
            }
        }
    }
    
    private func setSquare(square: SKSpriteNode, animation_square: SKSpriteNode, player: SKSpriteNode)
    {
        if (player == main)
        {
            square.texture = XTexture;
            animation_square.texture = XAnimationTexture;
        }
        else
        {
            square.texture = CircleTexture;
            animation_square.texture = CircleAnimationTexture;
        }
        animation_square.alpha = animation_squares_alpha;
        animation_square.run(SKAction.fadeOut(withDuration: 0.25));
        square.run(SKAction.fadeIn(withDuration: 0.25));
    }
    
    // Sets the board based off of where the player touches it
    // Utilizes the square skspritenodes
    private func playerSetBoard(location: CGPoint)
    {
        if (!animation_on && !pending_round)
        {
            for i in 0..<squaresArray.count {
                if squaresArray[i].contains(location) && tictactoeboard[i] == 0 {
                    tictactoeboard[i] = 1;
                    setSquare(square: squaresArray[i], animation_square: animationSquaresArray[i], player: main);
                    board_hits = board_hits + 1;
                    switchPlayers();
                    checkBoard(paddle: main);
                    level_controller.checkStageSelect(paddle: main, square: squaresArray[i])
                    return;
                }
            }
        }
    }
    
    private func enemySetBoard()
    {
        // Current logic for deciding tic tac toe spot against player.
        
        if (!animation_on && !pending_round)
        {
            animation_on = true;
            let position = ai.selectBoardPosition(board: &tictactoeboard)
            tictactoeboard[position] = 5;
            
            for i in 0..<squaresArray.count {
                if (position == i)
                {
                    squaresArray[i].run(SKAction.wait(forDuration: 0.25), completion: {[weak self] in
                        self!.animation_on = false;
                        self!.setSquare(square: self!.squaresArray[i], animation_square: self!.animationSquaresArray[i], player: self!.enemy);
                        self!.board_hits = self!.board_hits + 1;
                        self!.switchPlayers();
                        self!.checkBoard(paddle: self!.enemy);
                        self!.level_controller.checkStageSelect(paddle: self!.enemy, square: self!.squaresArray[i])
                    })
                    return;
                }
            }
        }
        
    }
    
    private func switchPlayers()
    {
        if (players_turn == true)
        {
            players_turn = false;
        }
        else
        {
            players_turn = true;
        }
    }
    
    private func switchStartingPlayer()
    {
        if (player_starts == true)
        {
            player_starts = false;
            players_turn = false;
        }
        else
        {
            player_starts = true;
            players_turn = true;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!game_over)
        {
            for touch in touches
            {
                let location = touch.location(in: self)
                
                // Move the players paddle
                if location.y <= main_paddle_move_boundary
                {
                    main.run(SKAction.moveTo(x: location.x, duration: 0.01))
                }
                
                // set the board
                if (location.y > main_paddle_move_boundary)
                {
                    /*if (main.hasItems()) { //TODO: Items not enabled
                        main.itemsSelected(location: location);
                    }*/
                    if (players_turn && !self.isPaused) {
                        playerSetBoard(location: location);
                    }
                }
                
                // pause the game
                if (self.isPaused == false && pauseButtonGrid.contains(location))
                {
                    pauseGame()
                }
                
            }
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (!game_over)
        {
            for touch in touches
            {
                let location = touch.location(in: self)
                if location.y <= main_paddle_move_boundary
                {
                    main.run(SKAction.moveTo(x: location.x, duration: 0.01))
                }
            }
        }
        
    }
    
    private func clearBoard() {
        
        for square in squaresArray {
            if square.alpha > 0 && !square.hasActions() {
                square.run(SKAction.fadeOut(withDuration: 0.25), completion: {
                    [weak self] in
                    self!.resetBoard()
                })
            }
        }
        
        if (!ball.isHidden && !game_over) {
            ballmanager.hideBall();
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
            if (!game_over)
            {
                ai.move();
                
                // Check to see if ball went past the paddles
                if (ball.position.y < main_boundary_position) {
                    
                    
                    if (ball.position.y <= main.position.y - 70) {
                        animateScoreExplosion();
                        addScore(playerWhoWon: enemy, type: 0)}
                    
                }
                else if (ball.position.y >= enemy_boundary_position) {
                    if (ball.position.y >= enemy.position.y + 20) {
                        animateScoreExplosion();
                        addScore(playerWhoWon: main, type: 0)}
                }
                
                // Manage Tic Tac Toe board
                if (pending_round) {
                    clearBoard();
                }
                else {
                    if (players_turn == false && board_hits < 9 && !pending_round) {
                        enemySetBoard();
                    }
                    else if (board_hits == 9) {
                        endTicTacToeGame(quick_fade: false, completion: {[weak self] in
                            self!.resetBoard();
                            self!.switchStartingPlayer();
                            if (!self!.pending_round && !self!.game_over) {
                                self!.resetTimer();
                                self!.fadeInTimer(completion: {
                                    self!.runTimer();
                                })
                            }
                        });
                    }
                    
                    if (seconds == 0 && isTimerRunning) {
                        addScore(playerWhoWon: enemy, type: 1)
                        endTicTacToeGame(quick_fade: true, completion: {[weak self] in
                            self!.resetBoard();
                            self!.switchStartingPlayer();
                            if (!self!.pending_round && !self!.game_over) {
                                self!.resetTimer();
                                self!.fadeInTimer(completion: {
                                    self!.runTimer();
                                })
                            }
                        });
                    }
                }
                
                //Deals with bug for when ball weirdly goes out of boundaries.
                if (!self.frame.contains(ball.position)) {
                    if (ball.position.y < 0) {
                        self.startBall(down: true)
                    }
                    else {
                        self.startBall(down: false)
                    }
                }
            }
            else {
                clearBoard();
            }
    }
    
    private func endTicTacToeGame(quick_fade: Bool, completion: @escaping ()->Void) {
        if (!animation_on || pending_round) {
            animation_on = true;
            let fadeoutAction = SKAction.fadeOut(withDuration: 0.25);
            var wait_time = 0.0;
            var actionSequence:SKAction;
            fadeOutTimer();
            
            for (index, squares) in squaresArray.enumerated() {
                
                if (quick_fade)
                {
                    actionSequence = fadeoutAction;
                }
                else
                {
                    actionSequence = SKAction.sequence([SKAction.wait(forDuration: wait_time), fadeoutAction]);
                }
                
                if (index != 8)
                {
                    squares.run(actionSequence);
                }
                else
                {
                    squares.run(actionSequence, completion: {[weak self] in
                        self!.animation_on = false;
                        completion();
                    })
                }
                wait_time = wait_time + 0.1;
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        //print("bit mask A: \(contact.bodyA.categoryBitMask), bit mask B: \(contact.bodyB.categoryBitMask)")
        // Contact between ball and paddles
        if (contact.bodyA.categoryBitMask == 1) && (contact.bodyB.categoryBitMask == 2) {
            
            if (contact.bodyA.node?.name == "main")
            {
                main.updateSpeed();
                ballmanager.bounceBall(contact, paddle: main, paddle_speed: main.paddle_speed)
            }
            else
            {
                enemy.updateSpeed()
                ballmanager.bounceBall(contact, paddle: enemy, paddle_speed: enemy.paddle_speed)
            }
            
            animateHitPaddle(contact_point: contact.contactPoint);
        }
        // Contact between ball and wall
        else if (contact.bodyA.categoryBitMask == 4) && (contact.bodyB.categoryBitMask == 2)
        {
            animateHitWall(contact_point: contact.contactPoint)
        }
    }
    
    override func didSimulatePhysics() {
        ballmanager.ordinateBall();
        main.updateSpeed();
        enemy.updateSpeed();
    }
    
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA.node?.name == "main") &&
            (contact.bodyB.node?.name == "ball")
        {
            ai.setNewChaseMethod();
            ai.enemy_hit_ball = false;
        }
        else if (contact.bodyA.node?.name == "enemy") &&
            (contact.bodyB.node?.name == "ball")
        {
            ai.enemy_hit_ball = true;
        }
    }
    
    @objc func doubleTapped() {
        if (self.isPaused == true)
        {
            GameViewControl?.pauseGame(pause: false);
            //(self.view?.window?.rootViewController as? GameViewController)?.pauseGame(pause: false);
        }
    }
    
    private func pauseGame()
    {
        if (self.isPaused == false && self.game_over == false) {
            pauseButton.run(SKAction.sequence([SKAction.setTexture(pauseButtonAnimationTexture), SKAction.wait(forDuration: 0.25)]), completion: {[weak self] in
                GameViewControl?.pauseGame(pause: true)
                //(self.view?.window?.rootViewController as? GameViewController)?.pauseGame(pause: false);
                self!.pauseButton.texture = self!.pauseButtonTexture;
            });
        }
    }
}
