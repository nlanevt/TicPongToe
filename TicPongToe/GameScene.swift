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
    public var viewController: GameViewController!
    
    private var ballmanager = Ball();
    private var ball = SKSpriteNode();
    private var enemy = SKSpriteNode();
    private var main = SKSpriteNode();
    private var paddle_physics_height:CGFloat = 15.0;
    private var main_boundary_position:CGFloat = -194;
    private var enemy_boundary_position:CGFloat = 247;
    
    public var score: Int64 = 0;
    private var level: Int64 = 1;
    
    private var score_increase_array:[Int64] = [250, 500, 1000, 2000, 5000, 10000]
    private var score_increase_iterator = 0;
    
    public var life = 7;
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
    private var squaresArray = [SKSpriteNode]();
    
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

    private var timerLabel = SKLabelNode();
    private var seconds = 10;
    private var timer = Timer();
    private var isTimerRunning = false;

    // Paddle Physics Variables
    private var main_paddle_speed = CGFloat.init(0);
    private var main_previous_position = CGFloat.init(0);
    private var main_paddle_move_boundary:CGFloat = -175;
    
    private var enemy_is_dead = false; // Used when paddle is complete deleted and user scores.
    private var enemy_paddle_speed = CGFloat.init(0);
    private var enemy_previous_position = CGFloat.init(0);
    private var paddle_width = CGFloat.init(96);
    private var paddle_size_decrement:CGFloat = 24;
    
    private var paddleDeathFrames: [SKTexture] = [];
    private var paddle96ShrinkFrames: [SKTexture] = [];
    private var paddle72ShrinkFrames: [SKTexture] = [];
    private var paddle48ShrinkFrames: [SKTexture] = [];
    private var paddle24GrowFrames: [SKTexture] = [];
    private var paddle48GrowFrames: [SKTexture] = [];
    private var paddle72GrowFrames: [SKTexture] = [];
    private var ballStartFrames: [SKTexture] = [];
    private var lifeShrinkFrames:[SKTexture] = [];
    private var lifeGrowFrames:[SKTexture] = [];
    private var hitWallFrames:[SKTexture] = [];
    private var hitPaddleFrames:[SKTexture] = [];
    private var paddleGrowthFrames:[SKTexture] = [];
    
    var ai = AI();
    
    private var player_ball_hit = SKSpriteNode();
    
    private var animation_on = false;
    
    private var pauseButton = SKSpriteNode();
    private var pauseButtonGrid = SKSpriteNode();
    private var pauseButtonTexture:SKTexture = SKTexture.init(imageNamed: "pauseButton");
    private var pauseButtonAnimationTexture:SKTexture = SKTexture.init(imageNamed: "pauseButtonAnimation");
    
    private var lives:[SKSpriteNode] = [];
    private var lifeTexture:SKTexture = SKTexture.init(imageNamed: "Life");
    private var lifeSize:CGSize = CGSize.init(width: 7, height: 24);
    
    private var gameFrame = SKSpriteNode();
    
    private var scroller : InfiniteScrollingBackground?
    
    override func didMove(to view: SKView)
    {
        super.didMove(to: view)
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = SKColor.black;
        let tap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
        
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
        
        enemy = self.childNode(withName: "enemy") as! SKSpriteNode
        applyPhysicsBodyToPaddle(paddle: enemy);
        
        main = self.childNode(withName: "main") as! SKSpriteNode
        applyPhysicsBodyToPaddle(paddle: main);
        
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
        
        boardCombinations = [[0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]];
        
        pauseButton = self.childNode(withName: "pauseButton") as! SKSpriteNode
        pauseButtonGrid = self.childNode(withName: "pauseButtonGrid") as! SKSpriteNode
        
        gameFrame = self.childNode(withName: "Frame") as! SKSpriteNode
        
        // Build animation frames
        paddleDeathFrames = (AnimationFramesManager?.getPaddleDeathFrames())!;
        paddle96ShrinkFrames = (AnimationFramesManager?.getPaddle96ShrinkFrames())!;
        paddle72ShrinkFrames = (AnimationFramesManager?.getPaddle72ShrinkFrames())!;
        paddle48ShrinkFrames = (AnimationFramesManager?.getPaddle48ShrinkFrames())!;
        paddle24GrowFrames = (AnimationFramesManager?.getPaddle24GrowFrames())!;
        paddle48GrowFrames = (AnimationFramesManager?.getPaddle48GrowFrames())!;
        paddle72GrowFrames = (AnimationFramesManager?.getPaddle72GrowFrames())!;
        ballStartFrames = (AnimationFramesManager?.getBallStartFrames())!;
        lifeShrinkFrames = (AnimationFramesManager?.getLifeShrinkFrames())!;
        lifeGrowFrames = (AnimationFramesManager?.getLifeGrowFrames())!;
        hitWallFrames = (AnimationFramesManager?.getHitWallFrames())!;
        hitPaddleFrames = (AnimationFramesManager?.getHitPaddleFrames())!;
        paddleGrowthFrames = (AnimationFramesManager?.getPaddleGrowthFrames())!;
        
        // Switch game types. Currently we are just using easy, medium and hard as types.
        ai.setPaddleValues(ball: ball, ai: enemy);
        ai.setFrameSize(view_size: self.frame.size);
        ai.setLevel(level: level);
        
        MenuViewControl?.setUpPauseView();
        
        //----Initiating Starry Background Animation------------
        let images = [UIImage(named: "BackgroundStarAnimationA")!, UIImage(named: "BackgroundStarAnimationA")!]
        
        // Initializing InfiniteScrollingBackground's Instance:
        scroller = InfiniteScrollingBackground(images: images, scene: self, scrollDirection: .bottom, transitionSpeed: 18)
        scroller?.scroll()
        scroller?.zPosition = -3
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        border.categoryBitMask = 3;
        self.physicsBody = border
        
        // Run the relevant game type
        startGame();
    }
    
    private func applyPhysicsBodyToPaddle(paddle: SKSpriteNode)
    {
        if (paddle == main)
        {
            main.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: main.size.width, height: paddle_physics_height));
            main.physicsBody?.categoryBitMask = 1
            main.physicsBody?.collisionBitMask = 2
            main.physicsBody?.contactTestBitMask = 1
            main.physicsBody?.mass = 0.266666680574417;
            main.physicsBody?.linearDamping = 0.1;
            main.physicsBody?.angularDamping = 0.1;
            main.physicsBody?.isDynamic = false;
            main.physicsBody?.usesPreciseCollisionDetection = true
        }
        else if (paddle == enemy)
        {
            enemy.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: enemy.size.width, height: paddle_physics_height));
            enemy.physicsBody?.categoryBitMask = 1
            enemy.physicsBody?.collisionBitMask = 2
            enemy.physicsBody?.contactTestBitMask = 2
            enemy.physicsBody?.mass = 0.266666680574417;
            enemy.physicsBody?.linearDamping = 0.1;
            enemy.physicsBody?.angularDamping = 0.1;
            enemy.physicsBody?.isDynamic = false;
            enemy.physicsBody?.usesPreciseCollisionDetection = true
        }
    }
    
    private func startGame()
    {
        level = 1;
        score = 0;
        life = 7;
        tictactoeboard = [0, 0, 0, 0, 0, 0, 0, 0, 0];
        players_turn = false;
        player_starts = false;
        player_won = false;
        game_over = false;
        timerLabel.text = "\(seconds)";
        if (currentGameType == gameType.high_score)
        {
            high_score.isHidden = false;
            player_score.isHidden = true;
            enemy_score.isHidden = true;
            player_score_animation.isHidden = true;
            enemy_score_animation.isHidden = true;
            high_score.text = "\(score)";
            
            for i in 0..<life {
                let lifeNode = SKSpriteNode(texture: lifeTexture, size: lifeSize);
                lifeNode.position = CGPoint(x: pauseButton.position.x + CGFloat(25 + i*10), y: pauseButton.position.y)
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
        }
        
        //Add animation for starting at Level 1
        startBall(down: false)
        ai.setNewChaseMethod();
        runTimer();
    }
    
    private func increaseLevel() {
        level = level + 1;
        ai.setLevel(level: level);
        var newTransitionSpeed = (scroller?.transitionSpeed)!;
        
        if (level < 50) {
            scroller?.speed = (scroller?.speed)! + 0.5;
        }
        
        
        
        print("Game Level: \(level), scroller speed: \(scroller?.transitionSpeed)")
        
    }
    
    // This function animates and times ball properly whenever it starts
    // Ball
    private func startBall(down: Bool)
    {
        if (game_over) {return};
        ai.enemy_hit_ball = down;
        ballmanager.startBall(down: true);
    }
    
    private func endGame()
    {
        // Remove the paddles through the paddle death animation
        // Remove the X/O's through a fadeout animation
        // Ensure that ball can bounce around where-ever
        game_over = true;
        stopTimer();
        timerLabel.text = "";
        endTicTacToeGame(isTimeOut: false); // remove x/o's from game.
        
        if (!main.isHidden)
        {
            animatePaddleRemoval(paddle: main)
        }
        
        if (!enemy.isHidden)
        {
            animatePaddleRemoval(paddle: enemy)
        }

        // Deactivated below to ensure no new scores get saved
        /*if (currentGameType == gameType.high_score)
        {
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
        }*/
        
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
            if (playerWhoWon == main)
            {
                // run increase score animation
                var score_counter = score;
                score = score + amount;
                let waitAction = SKAction.wait(forDuration: 0.01);
                let increaseScoreAction = SKAction.run({
                    self.high_score.fontColor = UIColor.yellow;
                    score_counter = score_counter + 1;
                    self.high_score.text = "\(score_counter)";
                })
                let repeatScoreIncreaseAction = SKAction.repeat(SKAction.sequence([increaseScoreAction, waitAction]), count: Int(amount));
                high_score.run(repeatScoreIncreaseAction, completion: {
                    self.high_score.fontColor = UIColor.white;
                    self.growLife();
                });
                
                if (type == 0) {
                    if (ai.decreaseLife() == true) {
                        increaseLevel();
                    }
                }
            }
            else if (type == 0) // Enemy scored a pong score, not a tic-tac-toe score (which shouldn't take away the players life). Only a Pong score does that.
            {
                life = life - 1; // remove life from player
                
                // run remove life animation
                if (life >= 0)
                {
                    var lifeNode = lives.popLast();
                    let shrinkAction = SKAction.animate(with: lifeShrinkFrames, timePerFrame: 0.025);
                    lifeNode?.run(shrinkAction, completion: {lifeNode = nil});
                }
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
                var score_counter = calculateScore()
                setScore(playerWhoWon: main, amount: score_counter, type: 0)
                startBall(down: true)
                animatePaddleDeath(paddle: enemy);
            }
            else if playerWhoWon == enemy
            {
                setScore(playerWhoWon: enemy, amount: 0, type: 0)
                startBall(down: false)
                animatePaddleDeath(paddle: main);
            }
        }
        else if (type == 1) // tic tac toe score
        {
            if playerWhoWon == main
            {
                shrinkPaddle(paddle: enemy)
                
                if (main.size.width < paddle_width)
                {
                    growPaddle(paddle: main)
                }
                
                // Get extra points for completely removing the enemy paddle
                if (enemy.size.width == 0)
                {
                    setScore(playerWhoWon: main, amount: 0, type: 1)
                    animatePaddleDeath(paddle: enemy);
                }
                else
                {
                    setScore(playerWhoWon: main, amount: 0, type: 1)
                }
            }
            else if playerWhoWon == enemy
            {
                // Shrink main paddle
                shrinkPaddle(paddle: main)
                
                if (enemy.size.width < paddle_width)
                {
                    growPaddle(paddle: enemy)
                }
                
                // remove life from player
                if (main.size.width == 0)
                {
                    setScore(playerWhoWon: enemy, amount: 0, type: 1)
                    animatePaddleDeath(paddle: main);
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
        
        if (ballmanager.ballspeed >= 50) {
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
    
    /*
     * Completely removes paddle, except doesn't delete the node
     * Used when the game is over.
    */
    private func animatePaddleRemoval(paddle: SKSpriteNode)
    {
        let deathAction = SKAction.animate(with: paddleDeathFrames, timePerFrame: 0.025);
        paddle.size.width = 256;
        paddle.run(deathAction, completion: {
            paddle.isHidden = true;
            paddle.physicsBody = nil;
        })
    }
    
    /*
    ** Used when scored on and paddle is deleted and regenerated.
    */
    private func animatePaddleDeath(paddle: SKSpriteNode)
    {
        let growthAction = SKAction.animate(with: paddleGrowthFrames, timePerFrame: 0.01)
        let deathAction = SKAction.animate(with: paddleDeathFrames, timePerFrame: 0.025);
        let setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle96"));
        paddle.size.width = 256;
        if (paddle == enemy) {enemy_is_dead = true}
        paddle.run(deathAction, completion: {
            paddle.size.width = self.paddle_width;
            paddle.run(SKAction.sequence([growthAction, setFinalPaddleTextureAction]), completion: {
                if (self.game_over)
                {
                    paddle.isHidden = true;
                    paddle.physicsBody = nil;
                }
                else
                {
                    paddle.size.width = self.paddle_width
                    self.applyPhysicsBodyToPaddle(paddle: paddle);
                }
                if (paddle == self.enemy) {self.enemy_is_dead = false}
            })
        })
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
        
        if (ballmanager.ballspeed >= 45 && ballmanager.ballspeed < 50)
        {
            let hitWallSparkNode = SKSpriteNode(texture: hitPaddleFrames[0], size: hitPaddleFrames[0].size());
            hitWallSparkNode.position = (hitWallNode?.position)!;
            hitWallSparkNode.zPosition = (hitWallNode?.zPosition)!;
            self.addChild(hitWallSparkNode);
            hitWallSparkNode.run(SKAction.animate(with: hitPaddleFrames, timePerFrame: 0.025), completion: {
                hitWallSparkNode.removeFromParent();
            })
        }
        else {
            var hitWallBNode = SKSpriteNode(texture: AnimationFramesManager?.hitWallBFrames[0], size: (AnimationFramesManager?.hitWallBFrames[0].size())!);
            hitWallBNode.zPosition = 0.0;
            hitWallBNode.position.y = contact_point.y;
            if (contact_point.x > 0) {
                hitWallBNode.position.x = contact_point.x - 2 - ((AnimationFramesManager?.hitWallBFrames[0].size().width)! / 2);
                hitWallBNode.zRotation = CGFloat.pi;
            }
            else {
                hitWallBNode.position.x = contact_point.x + 2 + ((AnimationFramesManager?.hitWallBFrames[0].size().width)! / 2);
            }
            
            self.addChild(hitWallBNode);
            hitWallBNode.run(SKAction.animate(with: (AnimationFramesManager?.hitWallBFrames)!, timePerFrame: 0.025), completion: {
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
        let hitPaddleNode = SKSpriteNode(texture: hitPaddleFrames[0], size: hitPaddleFrames[0].size());
        hitPaddleNode.zPosition = 0.0;
        hitPaddleNode.position = contact_point
        
        self.addChild(hitPaddleNode);
        
        hitPaddleNode.run(SKAction.animate(with: hitPaddleFrames, timePerFrame: 0.025), completion: {
            hitPaddleNode.removeFromParent();
        })
    }
    
    // This method does the paddle shrink animation
    private func shrinkPaddle(paddle: SKSpriteNode)
    {
        var shrinkAction:SKAction? = nil;
        var setFinalPaddleTextureAction:SKAction? = nil;
        
        if (paddle.size.width == 96)
        {
            shrinkAction = SKAction.animate(with: paddle96ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle72"));
        }
        else if (paddle.size.width == 72)
        {
            shrinkAction = SKAction.animate(with: paddle72ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle48"));
        }
        else if (paddle.size.width == 48)
        {
            shrinkAction = SKAction.animate(with: paddle48ShrinkFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle24"));
        }
        else if (paddle.size.width == 24)
        {
            paddle.size.width = paddle.size.width - self.paddle_size_decrement;
            applyPhysicsBodyToPaddle(paddle: paddle);
            return;
        }
        else
        {
            return;
        }
        
        let shrinkSequence = SKAction.sequence([shrinkAction!, setFinalPaddleTextureAction!]);
        paddle.run(shrinkSequence, completion: {
            paddle.size.width = paddle.size.width - self.paddle_size_decrement;
            self.applyPhysicsBodyToPaddle(paddle: paddle);
        })
    }
    
    private func growPaddle(paddle: SKSpriteNode)
    {        
        var shrinkAction:SKAction? = nil;
        var setFinalPaddleTextureAction:SKAction? = nil;
        
        if (paddle.size.width == 72)
        {
            shrinkAction = SKAction.animate(with: paddle72GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle96"));
        }
        else if (paddle.size.width == 48)
        {
            shrinkAction = SKAction.animate(with: paddle48GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle72"));
        }
        else if (paddle.size.width == 24)
        {
            shrinkAction = SKAction.animate(with: paddle24GrowFrames, timePerFrame: 0.015);
            setFinalPaddleTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Paddle48"));
        }
        else
        {
            return;
        }
        paddle.size.width = paddle.size.width + self.paddle_size_decrement;
        let shrinkSequence = SKAction.sequence([shrinkAction!, setFinalPaddleTextureAction!]);
        paddle.run(shrinkSequence, completion: {
            self.applyPhysicsBodyToPaddle(paddle: paddle);
        })
    }
    
    private func growLife()
    {
        if (score_increase_iterator >= score_increase_array.count - 1) {return}
        
        if (score >= score_increase_array[score_increase_iterator] && life < 8)
        {
            score_increase_iterator = score_increase_iterator + 1;
            let lifeNode = SKSpriteNode(texture: lifeGrowFrames[0], size: lifeSize);
            lifeNode.position = CGPoint(x: pauseButton.position.x + CGFloat(25 + life*10), y: pauseButton.position.y)
            lifeNode.zPosition = pauseButton.zPosition;
            lives.append(lifeNode);
            self.addChild(lives[life]);
            let growAction = SKAction.animate(with: lifeGrowFrames, timePerFrame: 0.01);
            let setFinalTextureAction = SKAction.setTexture(SKTexture(imageNamed: "Life"));
            lives[life].run(SKAction.sequence([growAction, setFinalTextureAction]));
            life = life + 1;
        }
    }
    
    private func updatePaddleSpeeds()
    {
        main_paddle_speed = (main.position.x - main_previous_position)/60.0;
        main_previous_position = main.position.x;
        enemy_paddle_speed = (enemy.position.x - enemy_previous_position)/60.0;
        enemy_previous_position = enemy.position.x;
    }
    
    public func runTimer() {
        if (!game_over)
        {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(GameScene.updateTimer)), userInfo: nil, repeats: true)
        }
    }
    
    @objc private func updateTimer() {
        seconds -= 1     //This will decrement(count down)the seconds.
        timerLabel.text = "\(seconds)" //This will update the label.
    }
    
    public func stopTimer()
    {
        timer.invalidate()
    }
    
    private func resetTimer()
    {
        timer.invalidate()
        
        seconds = 10;
        timerLabel.text = "\(seconds)"
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
    
    private func checkBoard(player: SKSpriteNode)
    {
        var check = 0;
        var temp:SKSpriteNode = enemy;
        var verification = 15;
        
        if (player == main)
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
        
        resetTimer();
        runTimer();
        
    }
    
    private func winRoundAnimation(player: SKSpriteNode, winning_squares: [Int])
    {
        addScore(playerWhoWon: player, type: 1);
        if (animation_on == false) {
            animation_on = true;
            stopTimer();
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
            
            timerLabel.run(SKAction.fadeOut(withDuration: 0.25));
            
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
                    squaresArray[winning_squares[i]].run(SKAction.sequence([SKAction.wait(forDuration: wait_time), fadeoutAction]), completion: {
                        self.squaresArray[winning_squares[i]].texture = texture;
                    });
                }
                else
                {
                    squaresArray[winning_squares[i]].run(SKAction.sequence([SKAction.wait(forDuration: wait_time), fadeoutAction]), completion: {
                        self.squaresArray[winning_squares[i]].texture = texture;
                        self.resetBoard();
                        self.switchStartingPlayer();
                        self.timerLabel.alpha = 1.0;
                        self.resetTimer();
                        self.animation_on = false;
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
        if (animation_on == false)
        {
            for i in 0..<squaresArray.count {
                if squaresArray[i].contains(location) && tictactoeboard[i] == 0 {
                    tictactoeboard[i] = 1;
                    setSquare(square: squaresArray[i], animation_square: animationSquaresArray[i], player: main);
                    board_hits = board_hits + 1;
                    switchPlayers();
                    checkBoard(player: main);
                    return;
                }
            }
        }
    }
    
    private func enemySetBoard()
    {
        // Current logic for deciding tic tac toe spot against player.
        if (animation_on == false)
        {
            animation_on = true;
            let position = ai.selectBoardPosition(board: &tictactoeboard)
            tictactoeboard[position] = 5;
            
            for i in 0..<squaresArray.count {
                if (position == i)
                {
                    squaresArray[i].run(SKAction.wait(forDuration: 0.25), completion: {
                        self.animation_on = false;
                        self.setSquare(square: self.squaresArray[i], animation_square: self.animationSquaresArray[i], player: self.enemy);
                        self.board_hits = self.board_hits + 1;
                        self.switchPlayers();
                        self.checkBoard(player: self.enemy);
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
                if (location.y > main_paddle_move_boundary && players_turn == true && self.isPaused == false)
                {
                    playerSetBoard(location: location);
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
    
    override func update(_ currentTime: TimeInterval) {
            if (!game_over)
            {
                updatePaddleSpeeds();
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
                
                /*if ball.position.y <= main.position.y - 70 {
                    addScore(playerWhoWon: enemy, type: 0);
                }
                else if ball.position.y >= enemy.position.y + 10 {
                    addScore(playerWhoWon: main, type: 0);
                }*/
                
                // Manage Tic Tac Toe board
                if (players_turn == false && board_hits < 9) {
                    enemySetBoard();
                }
                else if (board_hits == 9) {
                    endTicTacToeGame(isTimeOut: false);
                }
                
                if (seconds == 0) {
                    endTicTacToeGame(isTimeOut: true);
                }
                
                if (!self.frame.contains(ball.position)) {
                    if (ball.position.y < 0) {
                        self.startBall(down: true)
                    }
                    else {
                        self.startBall(down: false)
                    }
                }
            }
    }
    
    private func endTicTacToeGame(isTimeOut: Bool) {
        if (animation_on == false || game_over == true) {
            if (isTimeOut) {addScore(playerWhoWon: enemy, type: 1)};
            
            animation_on = true;
            let fadeoutAction = SKAction.fadeOut(withDuration: 0.25);
            var wait_time = 0.0;
            var actionSequence:SKAction;
            timer.invalidate();
            timerLabel.run(fadeoutAction);
            
            for (index, squares) in squaresArray.enumerated() {
                
                if (isTimeOut)
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
                    squares.run(actionSequence, completion: {
                        self.resetBoard();
                        self.switchStartingPlayer();
                        self.timerLabel.alpha = 1.0;
                        self.resetTimer();
                        self.runTimer();
                        self.animation_on = false;
                    })
                }
                wait_time = wait_time + 0.1;
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact)
    {
        // Contact between ball and paddles
        if (contact.bodyA.categoryBitMask == 1) && (contact.bodyB.categoryBitMask == 2) {
            updatePaddleSpeeds();
            
            if (contact.bodyA.node?.name == "main")
            {
                ballmanager.bounceBall(contact, paddle: main, paddle_speed: main_paddle_speed)
            }
            else
            {
                ballmanager.bounceBall(contact, paddle: enemy, paddle_speed: enemy_paddle_speed)
            }
            
            animateHitPaddle(contact_point: contact.contactPoint);
        }
        // Contact between ball and wall
        else if (contact.bodyA.categoryBitMask == 3) && (contact.bodyB.categoryBitMask == 2)
        {
            animateHitWall(contact_point: contact.contactPoint)
        }
    }
    
    override func didSimulatePhysics() {
        ballmanager.ordinateBall();
    }
    
    private func PaddleHitAnimate(paddle: SKSpriteNode, collision_position: CGPoint, return_speed: CGFloat)
    {
        if (paddle == main)
        {
            UIView.animate(withDuration: 0.1,
            animations: {
                self.player_ball_hit.isHidden = false;
                self.player_ball_hit.alpha = 1;
                self.player_ball_hit.position = CGPoint(x: collision_position.x, y: collision_position.y + 10)
            }
            )
        }
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
        }
    }
    
    private func pauseGame()
    {
        if (self.isPaused == false && self.game_over == false) {
            pauseButton.run(SKAction.sequence([SKAction.setTexture(pauseButtonAnimationTexture), SKAction.wait(forDuration: 0.25)]), completion: {
                GameViewControl?.pauseGame(pause: true)
                self.pauseButton.texture = self.pauseButtonTexture;
            });
        }
    }
}
