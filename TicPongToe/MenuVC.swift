//
//  MenuVC.swift
//  TicPongToe
//
//  Created by Nathan Lane on 4/22/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CoreData
import GameKit
import GoogleMobileAds //MARK

var player:NSManagedObject? = nil;
var players:[NSManagedObject] = [];
var MenuViewControl:MenuVC? = nil;
var AnimationFramesManager:AnimationFramesHelper? = nil;

var HighScore:Int64 = 0;
var NumberOfGamesWon:Int64 = 0;
var NumberOfGamesPlayed:Int64 = 0;
var isPurchased = false;

var HighScoreButtonPosition:CGPoint? = nil;
var DuelButtonPosition:CGPoint? = nil;
var LeaderboardButtonPosition:CGPoint? = nil;

var ReturnHomeHighScoreButtonPosition:CGPoint? = nil;
var ReturnHomeDuelButtonPosition:CGPoint? = nil;

var homescreen = false;

var ad_counter = 0;
var ad_trigger = 2;

enum gameType {
    case duel
    case high_score
}

class MenuVC : UIViewController, GKGameCenterControllerDelegate, GADInterstitialDelegate {
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    let LEADERBOARD_ID = "com.ticpongtoe.highscore"
    
    private var menuScene:MenuScene? = nil;
    public var running = false;
    
    public var interstitial: GADInterstitial!
    public var request: GADRequest!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the GC authentication controller
        authenticateLocalPlayer()
        
        if (MenuViewControl == nil)
        {
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
            
            interstitial = createAndLoadInterstitial(); // MARK
            
            MenuViewControl = self;
            loadScores(); // Get the scores from CORE Data
            AnimationFramesManager = AnimationFramesHelper();
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                if let scene = SKScene(fileNamed: "MenuScene") {
                    
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    
                    menuScene = scene as? MenuScene;
                    // Present the scene
                    view.presentScene(scene)
                }
            }
            MenuViewControl?.HighScoreButton = self.HighScoreButton;
            MenuViewControl?.DuelButton = self.DuelButton;
            MenuViewControl?.LeaderboardButton = self.LeaderboardButton;
            HighScoreButtonPosition = self.HighScoreButton.frame.origin;
            DuelButtonPosition = self.DuelButton.frame.origin;
            LeaderboardButtonPosition = self.LeaderboardButton.frame.origin;
            MenuViewControl?.AnimateButtons();
            homescreen = true;
        }
        
        MenuViewControl?.YourScoreLabel = self.YourScoreLabel;
        MenuViewControl?.ScoreLabel = self.ScoreLabel;
        MenuViewControl?.GameOverLabel = self.GameOverLabel;
        MenuViewControl?.ContinueGameButton = self.ContinueGameButton;
        MenuViewControl?.QuitGameButton = self.QuitGameButton;
        
        MenuViewControl?.ReturnHomeHighScoreButton = self.ReturnHomeHighScoreButton;
        MenuViewControl?.ReturnHomeDuelButton = self.ReturnHomeDuelButton;
        
        //print("Menu View Control ViewDidLoad");
    }
    
    @IBOutlet weak var YourScoreLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var GameOverLabel: UILabel!
    
    @IBOutlet weak var ContinueGameButton: UIButton!
    @IBOutlet weak var QuitGameButton: UIButton!

    @IBOutlet weak var ReturnHomeHighScoreButton: UIButton!
    @IBOutlet weak var ReturnHomeDuelButton: UIButton!
    
    @IBOutlet weak var HighScoreButton: UIButton!
    @IBOutlet weak var DuelButton: UIButton!
    @IBOutlet weak var LeaderboardButton: UIButton!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func CheckLeaderboard(_ sender: Any) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .default;
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
    }
    
    @IBAction func Duel(_ sender: Any) {
        MenuViewControl?.running = false;
        IncreaseNumberOfGamesPlayed()
        moveToGame(game : .duel);
    }
    
    @IBAction func High_Score(_ sender: Any) {
        MenuViewControl?.running = false;
        IncreaseNumberOfGamesPlayed()
        moveToGame(game : .high_score);
    }
    
    @IBAction func ContinueGame(_ sender: Any) {
        GameViewControl?.pauseGame(pause: false);
    }
    
    @IBAction func QuitGame(_ sender: Any) {
        returnHome();
    }
    
    @IBAction func ReturnHomeHighScore(_ sender: Any) {
        returnHome();
    }
    
    @IBAction func ReturnHomeDuel(_ sender: Any) {
        returnHome();
    }
    
    func moveToGame(game : gameType) {
        self.view.layer.removeAllAnimations()
        homescreen = false;
        menuScene?.stopMenuAnimations(); // Doesn't really do anything
        let gameVC = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as! GameViewController;
        currentGameType = game;
        self.navigationController?.pushViewController(gameVC, animated: true)
    }
    
    public func setUpPauseView()
    {
        YourScoreLabel.isHidden = true;
        ScoreLabel.isHidden = true;
        GameOverLabel.isHidden = true;
        ReturnHomeHighScoreButton.isHidden = true;
        ReturnHomeDuelButton.isHidden = true;
        ContinueGameButton.isHidden = false;
        QuitGameButton.isHidden = false;
    }
    
    public func setUpEndGameView()
    {
        ContinueGameButton.isHidden = true;
        QuitGameButton.isHidden = true;
        if (currentGameType == gameType.high_score)
        {
            YourScoreLabel.isHidden = false;
            ScoreLabel.isHidden = false;
            GameOverLabel.isHidden = false;
            ReturnHomeHighScoreButton.isHidden = false;
            self.animateButtonFloat(button: ReturnHomeHighScoreButton, delay: 0.2)
            ReturnHomeDuelButton.isHidden = true;
            ContinueGameButton.isHidden = true;
            QuitGameButton.isHidden = true;
            GameOverLabel.text = "GAME OVER";
        }
        else
        {
            GameOverLabel.isHidden = false;
            ReturnHomeHighScoreButton.isHidden = true;
            ReturnHomeDuelButton.isHidden = false;
            self.animateButtonFloat(button: ReturnHomeDuelButton, delay: 0.2)
            YourScoreLabel.isHidden = true;
            ScoreLabel.isHidden = true;
            ContinueGameButton.isHidden = true;
            QuitGameButton.isHidden = true;
            // Game Over Label text to show "You Lose" or "You won" is manipulated in GameScene.swift
        }
    }
    
    public func updateMenuSceneLabels()
    {
        menuScene?.updateLabels()
    }
    
    public func loadScores()
    {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Player")
        
        //3
        do {
            players = try managedContext.fetch(fetchRequest);
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // If there are no records in Core Data for the player yet, create one.
        if (players.isEmpty)
        {
            
            HighScore = 0;
            NumberOfGamesWon = 0;
            NumberOfGamesPlayed = 0;
            isPurchased = false;
            save(high_score: HighScore, games_won: NumberOfGamesWon, games_played: NumberOfGamesPlayed, is_purchased: isPurchased)
        }
        else if (players.count > 1) // if there is for some reason more than one record
        {
            player = players.last;
            HighScore = (player?.value(forKeyPath: "high_score") as? Int64)!;
            NumberOfGamesWon = (player?.value(forKeyPath: "games_won") as? Int64)!;
            NumberOfGamesPlayed = (player?.value(forKeyPath: "games_played") as? Int64)!;
            isPurchased = (player?.value(forKeyPath: "is_purchased") as? Bool)!;
            deleteCoreData();
            save(high_score: HighScore, games_won: NumberOfGamesWon, games_played: NumberOfGamesPlayed, is_purchased: isPurchased)
            loadScores();
        }
        else
        {
            player = players.last;
            HighScore = (player?.value(forKeyPath: "high_score") as? Int64)!;
            NumberOfGamesWon = (player?.value(forKeyPath: "games_won") as? Int64)!;
            NumberOfGamesPlayed = (player?.value(forKeyPath: "games_played") as? Int64)!;
            isPurchased = (player?.value(forKeyPath: "is_purchased") as? Bool)!;
        }
    }
    
    public func deleteCoreData()
    {
        if (!players.isEmpty)
        {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            
            for index in 0 ..< players.count
            {
                managedContext.delete(players[index])
            }
            
            players.removeAll();
            
            do {
                try managedContext.save()
            } catch _ {
            }
        }
    }
    
    public func save(high_score: Int64, games_won: Int64, games_played: Int64, is_purchased: Bool) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Player", in: managedContext)!
        
        let player = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        player.setValue(high_score, forKeyPath: "high_score")
        player.setValue(games_won, forKeyPath: "games_won")
        player.setValue(games_played, forKeyPath: "games_played")
        player.setValue(is_purchased, forKeyPath: "is_purchased")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    public func addScoreToLeaderBoard(score: Int64) {
        
        if (self.gcEnabled)
        {
            let ScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
            ScoreInt.value = Int64(HighScore)
            GKScore.report([ScoreInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Your high score was submitted to the High Score Leaderboard!")
                }
            }
        }
    }
    
    private func returnHome()
    {
        self.navigationController?.popViewController(animated: true);
        
        homescreen = true;
        GameViewControl = nil;
    
        MenuViewControl?.updateMenuSceneLabels();
        menuScene?.startMenuAnimations();
        MenuViewControl?.AnimateButtons();
        MenuViewControl?.showAd(); // needs to occur after MenuViewControl?.AnimateButtons(); otherwise there will be an issue where 'running' boolean will be set to true, causing the animations to run when they shouldn't, freezing the buttons after dismissing the ad.
    }
    
    private func IncreaseNumberOfGamesPlayed()
    {
        NumberOfGamesPlayed = NumberOfGamesPlayed + 1;
        deleteCoreData();
        save(high_score: HighScore, games_won: NumberOfGamesWon, games_played: NumberOfGamesPlayed, is_purchased: isPurchased)
    }
    
    // MARK: - AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error as Any)
                    } else { self.gcDefaultLeaderBoard = leaderboardIdentifer! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error as Any)
            }
        }
    }
    
    // Delegate to dismiss the GC controller
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
    public func repositionButtons()
    {
        // If Button Positions have already been documented, then don't set them again. Can cause problems.
        if (HighScoreButtonPosition == nil ||
            DuelButtonPosition == nil ||
            LeaderboardButtonPosition == nil) {return}
        
        self.HighScoreButton.frame.origin = HighScoreButtonPosition!;
        self.DuelButton.frame.origin = DuelButtonPosition!;
        self.LeaderboardButton.frame.origin = LeaderboardButtonPosition!;
    }
    
    private func AnimateButtons()
    {
        //print("Running Home Screen Animations");
        running = true; // Should only be the MenuViewControl calling this.
        self.repositionButtons();
        UIView.animate(withDuration: 1.0, delay: 0,
                       options: [.repeat, .autoreverse, .curveEaseInOut, .allowUserInteraction],
                       animations: {
                        if (self.HighScoreButton != nil) {
                            self.HighScoreButton.center.y += 9;
                        }
        }, completion: {(complete: Bool) in
            self.HighScoreButton.frame.origin = HighScoreButtonPosition!;
            self.running = false;
            //print("Hello World High Score button completion: \(self.HighScoreButton.frame.origin)");
            return;
        })
        
        UIView.animate(withDuration: 1.0, delay: 0.3,
                       options: [.repeat, .autoreverse, .curveEaseOut, .curveEaseIn, .allowUserInteraction],
                       animations: {
                        if (self.DuelButton != nil)
                        {
                            self.DuelButton.center.y += 9;
                        }
                        
        }, completion: {(complete: Bool) in
            self.DuelButton.frame.origin = DuelButtonPosition!;
            self.running = false;
            //print("Hello World Duel button completion: \(self.DuelButton.frame.origin)");
            return;
        })
        
        UIView.animate(withDuration: 1.0, delay: 0.5,
                       options: [.repeat, .autoreverse, .curveEaseOut, .curveEaseIn, .allowUserInteraction],
                       animations: {
                        if (self.LeaderboardButton != nil)
                        {
                            self.LeaderboardButton.center.y += 9;
                        }
                        
        }, completion: {(complete: Bool) in
            self.LeaderboardButton.frame.origin = LeaderboardButtonPosition!;
            self.running = false;
            //print("Hello World Leaderboard Button completion: \(self.LeaderboardButton.frame.origin)");
            return;
        })
    }
    
    public func animateButtonFloat(button: UIButton?, delay: Double)
    {
        if (ReturnHomeHighScoreButtonPosition == nil && button == self.ReturnHomeHighScoreButton)
        {
            ReturnHomeHighScoreButtonPosition = button?.frame.origin;
        }
        else if (ReturnHomeDuelButtonPosition == nil && button == ReturnHomeDuelButton)
        {
            ReturnHomeDuelButtonPosition = button?.frame.origin;
        }
        
        
        UIView.animate(withDuration: 1.0, delay: delay,
                       options: [.repeat, .autoreverse, .curveEaseOut, .curveEaseIn, .allowUserInteraction],
                       animations: {
                        if (button != nil)
                        {
                            button?.center.y += 7;
                        }
                        
        }, completion: {(complete: Bool) in
            if (button == self.ReturnHomeHighScoreButton) {
                button?.frame.origin = ReturnHomeHighScoreButtonPosition!;
            }
            else {
                button?.frame.origin = ReturnHomeDuelButtonPosition!;
            }
            return;
        })
    }
    
    private func animateLabelFlash(label: UILabel?, delay: Double)
    {
        UIView.animate(withDuration: 1.5, delay: delay,
                       options: [.repeat, .autoreverse, .curveEaseOut, .curveEaseIn, .allowUserInteraction],
                       animations: {
                        if (label != nil)
                        {
                            
                        }
                        
        }, completion: nil)
    }
    
    @objc func applicationDidBecomeActive(notification: NSNotification) {
        if (MenuViewControl?.running == false && homescreen == true)
        {
            //print("Menu View Control Become Active");
            if (MenuViewControl?.interstitial.hasBeenUsed == false && MenuViewControl?.interstitial.isReady == false)
            {
                MenuViewControl?.request = GADRequest();
                MenuViewControl?.interstitial.load(request);
            }
            
            MenuViewControl?.AnimateButtons();
        }
    }
    
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        MenuViewControl?.running = false;
    }
    
    public func showAd()
    {
        ad_counter = ad_counter + 1;
        if (ad_counter >= ad_trigger)
        //if (ad_counter == ad_counter)
        {
            if interstitial.isReady {
                running = false; // should only be the MenuViewControl calling this.
                ad_counter = 0;
                ad_trigger = Int(arc4random_uniform(2)) + 1;
                interstitial.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
                request = GADRequest();
                interstitial.load(request);
            }
        }
    }
    
    public func createAndLoadInterstitial() -> GADInterstitial {
        //print("loading interstitial ad")
        request = GADRequest();
        
        // Possibley will be used later for localizing ads.
        /*if let currentLocation = locationManager.location {
            request.setLocationWithLatitude(CGFloat(currentLocation.coordinate.latitude),
                                            longitude: CGFloat(currentLocation.coordinate.longitude),
                                            accuracy: CGFloat(currentLocation.horizontalAccuracy))
        }*/
        
        // The Real Home Screen Full Page Promo ID: ca-app-pub-2893925630884266/1391968647
        // The Test ID: ca-app-pub-3940256099942544/4411468910
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-2893925630884266/1391968647");
        interstitial.delegate = self
        interstitial.load(request);
        
        return interstitial;
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial();
        
        // Needed in the event that ad is still open when the user exists the app then re-enters it. The animation buttons still need to be run.
        if (MenuViewControl?.running == false && homescreen == true) {MenuViewControl?.AnimateButtons()}
    }
}
