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
import GoogleMobileAds

var player:NSManagedObject? = nil;
var players:[NSManagedObject] = [];
var MenuViewControl:MenuVC? = nil;
var AnimationFramesManager:AnimationFramesHelper? = nil;

var HighScore:Int64 = 0;
var NumberOfGamesWon:Int64 = 0;
var NumberOfGamesPlayed:Int64 = 0;
var isPurchased = false;

weak var GameViewControl:GameViewController? = nil;
var currentGameType = gameType.high_score;

enum gameType {
    case duel
    case high_score
}

class MenuVC : UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate {
    /* Variables */
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    let LEADERBOARD_ID = "com.ticpongtoe.highscore"
    
    public var menuScene:MenuScene? = nil;
    public var running = false; //TODO: 'running' does literally nothing. may need to be removed in the future.
    private var homescreen = false;
    
    //Ad information
    private var banner: GADBannerView!
    private var BANNER_AD_ID = "ca-app-pub-2893925630884266/5717842874";
    private var BANNER_TEST_ID = "ca-app-pub-3940256099942544/2934735716";
    
    @IBOutlet weak var YourScoreLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var GameOverLabel: UILabel!
    @IBOutlet weak var GameOverLabelImage: UIImageView!
    
    @IBOutlet weak var ContinueGameButton: UIButton!
    @IBOutlet weak var QuitGameButton: UIButton!

    @IBOutlet weak var ReturnHomeHighScoreButton: FloatingButton!
    @IBOutlet weak var ReturnHomeDuelButton: FloatingButton!
    
    @IBOutlet weak var HighScoreButton: FloatingButton!
    @IBOutlet weak var DuelButton: FloatingButton!
    @IBOutlet weak var LeaderboardButton: FloatingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Call the GC authentication controller
        authenticateLocalPlayer()
        
        if (MenuViewControl == nil)
        {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationDidEnterBackground(notification:)),
                name: NSNotification.Name.UIApplicationDidEnterBackground,
                object: nil)
                        
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
            
            homescreen = true;
            createAndLoadBanner();
            
            MenuViewControl?.HighScoreButton.setDelay(delay: 0.0);
            MenuViewControl?.DuelButton.setDelay(delay: 0.25);
            MenuViewControl?.LeaderboardButton.setDelay(delay: 0.5);
        }
        
        MenuViewControl?.YourScoreLabel = self.YourScoreLabel;
        MenuViewControl?.ScoreLabel = self.ScoreLabel;
        MenuViewControl?.GameOverLabel = self.GameOverLabel;
        MenuViewControl?.GameOverLabelImage = self.GameOverLabelImage;
        MenuViewControl?.ContinueGameButton = self.ContinueGameButton;
        MenuViewControl?.QuitGameButton = self.QuitGameButton;
        
        MenuViewControl?.ReturnHomeHighScoreButton = self.ReturnHomeHighScoreButton;
        MenuViewControl?.ReturnHomeDuelButton = self.ReturnHomeDuelButton;
        
        if (MenuViewControl?.YourScoreLabel != nil) {
            MenuViewControl?.YourScoreLabel.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.QuitGameButton != nil) {
            MenuViewControl?.QuitGameButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.ContinueGameButton != nil) {
            MenuViewControl?.ContinueGameButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.ReturnHomeHighScoreButton != nil) {
            MenuViewControl?.ReturnHomeHighScoreButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.ReturnHomeDuelButton != nil) {
            MenuViewControl?.ReturnHomeDuelButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.HighScoreButton != nil) {
            MenuViewControl?.HighScoreButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize1", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.DuelButton != nil) {
            MenuViewControl?.DuelButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize1", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.LeaderboardButton != nil) {
            MenuViewControl?.LeaderboardButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize1", comment: "The localized font size")) as NSString).floatValue))
        }
        
    }
    
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
        GameViewControl = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as? GameViewController;
        currentGameType = game;
        self.navigationController?.pushViewController(GameViewControl!, animated: true)
    }
    
    public func setUpPauseView()
    {
        YourScoreLabel.isHidden = true;
        ScoreLabel.isHidden = true;
        GameOverLabelImage.isHidden = true;
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
            GameOverLabelImage.isHidden = false;
            GameOverLabel.isHidden = true;
            ReturnHomeHighScoreButton.isHidden = false;
            MenuViewControl?.ReturnHomeHighScoreButton.AnimateButton();
            ReturnHomeDuelButton.isHidden = true;
            ContinueGameButton.isHidden = true;
            QuitGameButton.isHidden = true;
        }
        else
        {
            GameOverLabelImage.isHidden = true;
            GameOverLabel.isHidden = false;
            ReturnHomeHighScoreButton.isHidden = true;
            ReturnHomeDuelButton.isHidden = false;
            MenuViewControl?.ReturnHomeDuelButton.AnimateButton();
            YourScoreLabel.isHidden = true;
            ScoreLabel.isHidden = true;
            ContinueGameButton.isHidden = true;
            QuitGameButton.isHidden = true;
            // Game Over Label text to show "You Lose" or "You won" is manipulated in GameScene.swift
        }
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
            //print("Player data loaded");
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
        GameViewControl?.cleanGameScene();
        GameViewControl = nil;
        AnimationFramesManager?.cleanGameSceneAnimations();
        
        MenuViewControl!.menuScene?.updateLabels()
        MenuViewControl!.menuScene?.startMenuAnimations();
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
    
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        MenuViewControl?.running = false;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MenuViewControl?.HighScoreButton.AnimateButton();
        MenuViewControl?.DuelButton.AnimateButton();
        MenuViewControl?.LeaderboardButton.AnimateButton();
    }
    
    private func createAndLoadBanner() {
        //instantiate the banner with random ad size.
        if (!homescreen) {return} // here to deal with the banner showing up on the pause view, since pause view is also a MenuVC
        banner = GADBannerView(adSize: Int(arc4random_uniform(UInt32(2))) > 0 ? GADAdSizeMediumRectangle : GADAdSizeLargeBanner)
        banner.delegate = self;
        banner.adUnitID = BANNER_TEST_ID;
        banner.rootViewController = self;
        banner.load(GADRequest())
    }
    
    private func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
          [NSLayoutConstraint(item: bannerView,
                              attribute: .bottom,
                              relatedBy: .equal,
                              toItem: bottomLayoutGuide,
                              attribute: .top,
                              multiplier: 1,
                              constant: 0),
           NSLayoutConstraint(item: bannerView,
                              attribute: .centerX,
                              relatedBy: .equal,
                              toItem: view,
                              attribute: .centerX,
                              multiplier: 1,
                              constant: 0)
          ])
    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      bannerView.alpha = 0
      addBannerViewToView(banner);
      UIView.animate(withDuration: 1, animations: {
        bannerView.alpha = 1
      })
    }
}
