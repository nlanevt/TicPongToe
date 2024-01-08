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
var HighestLevel:Int64 = 0;

weak var GameViewControl:GameViewController? = nil;

class MenuVC : UIViewController, GKGameCenterControllerDelegate, GADBannerViewDelegate {
    var isLeaderboardEnabled = true; //MARK: turn this to true before submission to enable sending data to Leaderboard
    var isSavingEnabled = true; //MARK: Turn this to true before submission to enable saving Core Data
    var areAdsEnabled = true; //MARK: Turn this to true before submission to allow ads to show.
    var areRealAdsEnabled = true; //MARK: Turn this to true before submission to enable using Real Ads.
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
    let LB_HIGHSCORE_ID = "com.ticpongtoe.highscore"
    let LB_HIGHESTLEVEL_ID = "com.ticpongtoe.highestlevel"
    
    public var menuScene:MenuScene? = nil;
    public var running = false; //TODO: 'running' does literally nothing. may need to be removed in the future.
    private var homescreen = false;
    
    //Ad information
    private var banner: GADBannerView!
    private var BANNER_AD_ID = "ca-app-pub-2893925630884266/5717842874";
    private var BANNER_TEST_ID = "ca-app-pub-3940256099942544/2934735716";
    
    let buttonSound = URL(fileURLWithPath: Bundle.main.path(forResource: "ButtonSound", ofType: "wav")!)
    var audioPlayer = AVAudioPlayer()
    
    @IBOutlet weak var YourScoreLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var GameOverLabel: UILabel!
    @IBOutlet weak var GameOverLabelImage: UIImageView!
    
    @IBOutlet weak var ContinueGameButton: UIButton!
    @IBOutlet weak var QuitGameButton: UIButton!
    @IBOutlet weak var ReturnHomeButton: FloatingButton!
    
    @IBOutlet weak var PlayGameButton: FloatingButton!
    @IBOutlet weak var LeaderboardButton: FloatingButton!
    
   // @IBOutlet weak var MenuTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var TitleImage: UIImageView!
    
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
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(didBecomeActive),
                name: NSNotification.Name.UIApplicationDidBecomeActive,
                object: nil)
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(willEnterForeground),
                name: NSNotification.Name.UIApplicationWillEnterForeground,
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
            
            MenuViewControl?.PlayGameButton = self.PlayGameButton;
            MenuViewControl?.LeaderboardButton = self.LeaderboardButton;
            MenuViewControl?.TitleImage = self.TitleImage;
            
            homescreen = true;
            createAndLoadBanner();
            
            MenuViewControl?.PlayGameButton.setDelay(delay: 0.0);
            MenuViewControl?.LeaderboardButton.setDelay(delay: 0.5);
        }
        
        MenuViewControl?.YourScoreLabel = self.YourScoreLabel;
        MenuViewControl?.ScoreLabel = self.ScoreLabel;
        MenuViewControl?.GameOverLabel = self.GameOverLabel;
        MenuViewControl?.GameOverLabelImage = self.GameOverLabelImage;
        MenuViewControl?.ContinueGameButton = self.ContinueGameButton;
        MenuViewControl?.QuitGameButton = self.QuitGameButton;
        
        MenuViewControl?.ReturnHomeButton = self.ReturnHomeButton;
        
        if (MenuViewControl?.YourScoreLabel != nil) {
            MenuViewControl?.YourScoreLabel.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.QuitGameButton != nil) {
            MenuViewControl?.QuitGameButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.ContinueGameButton != nil) {
            MenuViewControl?.ContinueGameButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.ReturnHomeButton != nil) {
            MenuViewControl?.ReturnHomeButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize3", comment: "The localized font size")) as NSString).floatValue))
        }
        
        if (MenuViewControl?.PlayGameButton != nil) {
            MenuViewControl?.PlayGameButton.titleLabel?.font = UIFont(name: String.localizedStringWithFormat(NSLocalizedString("fontName", comment: "The localized font")), size: CGFloat((String.localizedStringWithFormat(NSLocalizedString("fontSize1", comment: "The localized font size")) as NSString).floatValue))
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
        present(gcVC, animated: true, completion: nil)
    }
    
    @IBAction func High_Score(_ sender: Any) {
        MenuViewControl?.running = false;
        runButtonSound();
        moveToGame();
    }
    
    @IBAction func ContinueGame(_ sender: Any) {
        GameViewControl?.pauseGame(pause: false);
    }
    
    @IBAction func QuitGame(_ sender: Any) {
        MenuViewControl?.SaveDataAndUpdateLeaderboard();
        returnToMenu();
    }
    
    @IBAction func ReturnHome(_ sender: Any) {
        returnToMenu();
    }
    
    func moveToGame() {
        self.view.layer.removeAllAnimations()
        homescreen = false;
        GameViewControl = self.storyboard?.instantiateViewController(withIdentifier: "gameVC") as? GameViewController;
        self.navigationController?.pushViewController(GameViewControl!, animated: true)
    }
    
    public func setUpPauseView()
    {
        YourScoreLabel.isHidden = true;
        ScoreLabel.isHidden = true;
        GameOverLabelImage.isHidden = true;
        GameOverLabel.isHidden = true;
        ReturnHomeButton.isHidden = true;
        ContinueGameButton.isHidden = false;
        QuitGameButton.isHidden = false;
    }
    
    public func setUpEndGameView()
    {
        ContinueGameButton.isHidden = true;
        QuitGameButton.isHidden = true;
        YourScoreLabel.isHidden = false;
        ScoreLabel.isHidden = false;
        GameOverLabelImage.isHidden = false;
        GameOverLabel.isHidden = true;
        ReturnHomeButton.isHidden = false;
        MenuViewControl?.ReturnHomeButton.AnimateButton();
        ContinueGameButton.isHidden = true;
        QuitGameButton.isHidden = true;
    }
    
    public func SaveDataAndUpdateLeaderboard() {
        MenuViewControl?.addScoreToLeaderBoard(score: HighScore)
        MenuViewControl?.addLevelToLeaderBoard(level: HighestLevel)
        MenuViewControl?.deleteCoreData(); // Remove any current core data.
        MenuViewControl?.save(high_score: HighScore, highest_level: HighestLevel) // Save new info to Core Data
        MenuViewControl?.loadScores();
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
            HighestLevel = 0;
            save(high_score: HighScore, highest_level: HighestLevel)
        }
        else if (players.count > 1) // if there is for some reason more than one record
        {
            player = players.last;
            HighScore = (player?.value(forKeyPath: "high_score") as? Int64)!;
            HighestLevel = (player?.value(forKeyPath: "highest_level") as? Int64)!;
            deleteCoreData();
            save(high_score: HighScore, highest_level: HighestLevel)
            loadScores();
        }
        else
        {
            //print("Player data loaded");
            player = players.last;
            HighScore = (player?.value(forKeyPath: "high_score") as? Int64)!;
            HighestLevel = (player?.value(forKeyPath: "highest_level") as? Int64)!;
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
    
    public func save(high_score: Int64, highest_level: Int64) {
        
        if (!isSavingEnabled) {return}
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        // 1
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "Player", in: managedContext)!
        
        let player = NSManagedObject(entity: entity, insertInto: managedContext)
        
        // 3
        player.setValue(high_score, forKeyPath: "high_score")
        player.setValue(highest_level, forKey: "highest_level")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    public func addScoreToLeaderBoard(score: Int64) {
        if (self.gcEnabled && self.isLeaderboardEnabled)
        {
            let ScoreInt = GKScore(leaderboardIdentifier: LB_HIGHSCORE_ID)
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
    
    public func addLevelToLeaderBoard(level: Int64) {
        if (self.gcEnabled && self.isLeaderboardEnabled)
        {
            let ScoreInt = GKScore(leaderboardIdentifier: LB_HIGHESTLEVEL_ID)
            ScoreInt.value = Int64(HighestLevel)
            GKScore.report([ScoreInt]) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    print("Your highest level was submitted to the Highest Level Leaderboard!")
                }
            }
        }
    }
    
    private func returnToMenu()
    {
        self.navigationController?.popViewController(animated: true);
        homescreen = true;
        GameViewControl?.cleanGameScene();
        GameViewControl = nil;
        AnimationFramesManager?.cleanGameSceneAnimations();
        MenuViewControl!.menuScene?.updateLabels()
        MenuViewControl!.menuScene?.startMenuAnimations();
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
    
    //TODO: THe shit below needs to be replaced with something more efficient.
    @objc func willEnterForeground() {
        
    }
    
    //TODO: THe shit below needs to be replaced with something more efficient.
    @objc func didBecomeActive() {
        
    }
    
    //TODO: THe shit below needs to be replaced with something more efficient.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MenuViewControl?.PlayGameButton.topAnchor.constraint(equalTo: (MenuViewControl?.TitleImage.bottomAnchor)!, constant: 52).isActive = true
        MenuViewControl?.PlayGameButton.AnimateButton();
        MenuViewControl?.LeaderboardButton.AnimateButton();
    }
    
    private func createAndLoadBanner() {
        //instantiate the banner with random ad size.
        if (!homescreen || !areAdsEnabled) {return} // here to deal with the banner showing up on the pause view, since pause view is also a MenuVC
        banner = GADBannerView(adSize: Int(arc4random_uniform(UInt32(2))) > 0 ? GADAdSizeMediumRectangle : GADAdSizeLargeBanner)
        banner.delegate = self;
        banner.adUnitID = areRealAdsEnabled ? BANNER_AD_ID : BANNER_TEST_ID;
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
                              toItem: view.safeAreaLayoutGuide,
                              attribute: .bottom,
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
    
    private func runButtonSound() {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: buttonSound)
            audioPlayer.play()
        } catch {
            // couldn't load file :(
        }
    }
}
