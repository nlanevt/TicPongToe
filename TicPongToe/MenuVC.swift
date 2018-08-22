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

var player:NSManagedObject? = nil;
var players:[NSManagedObject] = [];
var MenuViewControl:MenuVC? = nil;

var HighScore:Int64 = 0;
var NumberOfGamesWon:Int64 = 0;
var NumberOfGamesPlayed:Int64 = 0;
var isPurchased = false;

var IAPFullGameID = "iap_full_game_purchase";

enum gameType {
    case duel
    case high_score
}

class MenuVC : UIViewController {
    private var menuScene:MenuScene? = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (MenuViewControl == nil)
        {
            MenuViewControl = self;
            loadScores(); // Get the scores from CORE Data
            if let view = self.view as! SKView? {
                // Load the SKScene from 'GameScene.sks'
                if let scene = SKScene(fileNamed: "MenuScene") {
                    
                    // Set the scale mode to scale to fit the window
                    scene.scaleMode = .aspectFit
                    
                    menuScene = scene as? MenuScene;
                    IAPView.isHidden = true;
                    // Present the scene
                    view.presentScene(scene)
                    
                }
            }
        }
        
        MenuViewControl?.YourScoreLabel = self.YourScoreLabel;
        MenuViewControl?.ScoreLabel = self.ScoreLabel;
        MenuViewControl?.GameOverLabel = self.GameOverLabel;
        MenuViewControl?.ContinueGameButton = self.ContinueGameButton;
        MenuViewControl?.QuitGameButton = self.QuitGameButton;
        MenuViewControl?.ReturnHomeHighScoreButton = self.ReturnHomeHighScoreButton;
        MenuViewControl?.ReturnHomeDuelButton = self.ReturnHomeDuelButton;
    }
    
    @IBOutlet weak var YourScoreLabel: UILabel!
    @IBOutlet weak var ScoreLabel: UILabel!
    @IBOutlet weak var GameOverLabel: UILabel!
    
    @IBOutlet weak var ContinueGameButton: UIButton!
    @IBOutlet weak var QuitGameButton: UIButton!

    @IBOutlet weak var ReturnHomeHighScoreButton: UIButton!
    @IBOutlet weak var ReturnHomeDuelButton: UIButton!
    
    @IBOutlet weak var IAPView: UIView!
    
    @IBAction func Duel(_ sender: Any) {
        //IncreaseNumberOfGamesPlayed()
        //checkAndDisplayIAP()
        IAPView.isHidden = false;
        IAPController?.NetworkActivityMonitor.startAnimating();
        IAPController?.InformationText.text = "Hello World!";
        //moveToGame(game : .duel);
    }
    
    @IBAction func High_Score(_ sender: Any) {
        checkAndDisplayIAP()
        //IncreaseNumberOfGamesPlayed()
        //moveToGame(game : .high_score);
    }
    
    @IBAction func ContinueGame(_ sender: Any) {
        GameViewControl?.pauseGame(pause: false);
    }
    
    @IBAction func QuitGame(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        GameViewControl = nil;
    }
    
    @IBAction func ReturnHomeHighScore(_ sender: Any) {
        returnHome();
    }
    
    @IBAction func ReturnHomeDuel(_ sender: Any) {
        returnHome();
    }
    
    func moveToGame(game : gameType) {
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
        }
        
        print("HighScore: \(HighScore), NumberOfGamesWon: \(NumberOfGamesWon), NumberOfGamesPlayed: \(NumberOfGamesPlayed), isPurchased: \(isPurchased)")
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
    
    private func returnHome()
    {
        self.navigationController?.popViewController(animated: true)
        GameViewControl = nil;
        MenuViewControl?.updateMenuSceneLabels();
    }
    
    private func IncreaseNumberOfGamesPlayed()
    {
        NumberOfGamesPlayed = NumberOfGamesPlayed + 1;
        deleteCoreData();
        save(high_score: HighScore, games_won: NumberOfGamesWon, games_played: NumberOfGamesPlayed, is_purchased: isPurchased)
    }
    
    private func checkAndDisplayIAP()
    {
        if (NumberOfGamesPlayed > 1 && isPurchased == false)
        {
            ControlIAPView(show: true);
            IAPController?.FetchAndValidateReciept();
        }
    }
    
    func ControlIAPView(show: Bool)
    {
        if (show == true)
        {
            IAPView.isHidden = false;
            IAPView.alpha = 0.0;
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.tag = 101;
            blurEffectView.translatesAutoresizingMaskIntoConstraints = false
            blurEffectView.alpha = 0.0;
            self.view?.insertSubview(blurEffectView, at: 3)
            NSLayoutConstraint.activate([
                blurEffectView.heightAnchor.constraint(equalTo: (self.view?.heightAnchor)!),
                blurEffectView.widthAnchor.constraint(equalTo: (self.view?.widthAnchor)!),
                ])
            UIView.animate(withDuration: 0.25, animations: {
                blurEffectView.alpha = 1.0;
                self.IAPView.alpha = 1.0
            })
        }
        else
        {
            UIView.animate(withDuration: 0.25, animations: {
                self.view?.viewWithTag(101)?.alpha = 0.0;
                self.IAPView.alpha = 0.0;
            }) { _ in
                self.view?.viewWithTag(101)?.removeFromSuperview();
            }
            IAPView.isHidden = true;
        }
    }
    
}
