//
//  GameViewController.swift
//  Tic-Pong-Toe
//
//  Created by Nathan Lane on 2/19/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

var currentGameType = gameType.high_score;
var GameViewControl:GameViewController? = nil;

class GameViewController: UIViewController {


    @IBOutlet weak var PauseView: UIView!
    private var gameScene:GameScene? = nil;
    private var gameScenePaused = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(notification:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground(notification:)),
            name: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive(notification:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit

                GameViewControl = self;
                gameScene = scene as? GameScene;
                
                PauseView.isHidden = true;
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public func pauseGame(pause: Bool)
    {
        gameScenePaused = pause;
        gameScene?.isPaused = pause;
        if (pause == true)
        {
            gameScene?.stopTimer();
            PauseView.isHidden = false;
            PauseView.alpha = 0.0;
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.tag = 100;
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
            blurEffectView.alpha = 0.0;
            gameScene?.view?.insertSubview(blurEffectView, at: 0)
            NSLayoutConstraint.activate([
                blurEffectView.heightAnchor.constraint(equalTo: (gameScene?.view?.heightAnchor)!),
                blurEffectView.widthAnchor.constraint(equalTo: (gameScene?.view?.widthAnchor)!),
                ])
            UIView.animate(withDuration: 0.25, animations: {
                blurEffectView.alpha = 1.0;
                self.PauseView.alpha = 1.0
            })
        }
        else
        {
            UIView.animate(withDuration: 0.25, animations: {
                self.gameScene?.view?.viewWithTag(100)?.alpha = 0.0;
                self.PauseView.alpha = 0.0;
            }) { _ in
                self.gameScene?.view?.viewWithTag(100)?.removeFromSuperview();
            }
            PauseView.isHidden = true;
            gameScene?.runTimer();
        }
    }
    
    public func endGame()
    {
        MenuViewControl?.setUpEndGameView();
        PauseView.isHidden = false;
        PauseView.alpha = 0.0;
        UIView.animate(withDuration: 0.25, animations: {
            self.PauseView.alpha = 1.0
        })
    }
    
    //override func applicationD
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        gameScene?.isPaused = gameScenePaused;
        
        if (!gameScenePaused && !(gameScene?.game_over)!) // if the game is not in pause mode when entering the application and the game is not over
        {
            gameScene?.runTimer();
            
        }
        else if ((gameScene?.game_over)!) // if the game is over reanimate the buttons
        {
            if (currentGameType == gameType.high_score)
            {
                MenuViewControl?.ReturnHomeHighScoreButton.AnimateButton();
            }
            else
            {
                MenuViewControl?.ReturnHomeDuelButton.AnimateButton();
            }
        }
    }
    
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        if (!gameScenePaused && !(gameScene?.game_over)!) // if game is not in pause mode when exiting the application
        {
            gameScene?.stopTimer();
            self.pauseGame(pause: true)
        }
    }
    
    @objc func applicationWillResignActive(notification: NSNotification) {
        if (!gameScenePaused && !(gameScene?.game_over)!) // if game is not in pause mode when exiting the application
        {
            gameScene?.stopTimer();
            
            self.pauseGame(pause: true)
        }
    }
    
 
}
