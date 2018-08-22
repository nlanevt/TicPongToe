//
//  IAPViewController.swift
//  TicPongToe
//
//  Created by Nathan Lane on 8/20/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit
import GameplayKit

var IAPController:IAPViewController? = nil;

class IAPViewController: UIViewController {
    
    
    @IBOutlet weak var NetworkActivityMonitor: UIActivityIndicatorView!
    @IBOutlet weak var InformationText: UILabel!
    @IBOutlet weak var ContinueButtonOutlet: UIButton!
    @IBOutlet weak var PurchaseButtonOutlet: UIButton!
    
    private var fullGamePrice:String? = nil;
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        IAPController = nil;
        IAPController = self;
        //NetworkActivityMonitor.startAnimating()
        retrieveProductInformation();
        PurchaseButtonOutlet.isHidden = true;
        
    }
    
    @IBAction func PurchaseButton(_ sender: Any) {
        
    }
    
    @IBAction func ContinueButton(_ sender: Any) {
        MenuViewControl?.ControlIAPView(show: false);
    }
    
    func FetchAndValidateReciept()
    {
        NetworkActivityMonitor.startAnimating()
        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
            self.NetworkActivityMonitor.stopAnimating();
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
                self.verifyReceipt();
            case .error(let error):
                print("Fetch receipt failed: \(error)")
                self.displayPurchaseInformation();
            }
        }
    }
    
    func verifyReceipt()
    {
        NetworkActivityMonitor.startAnimating()
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "your-shared-secret")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            self.NetworkActivityMonitor.stopAnimating();
            switch result {
            case .success(let receipt):
                print("Verify receipt success: \(receipt)")
            case .error(let error):
                print("Verify receipt failed: \(error)")
            }
        }
    }
    
    func displayPurchaseInformation()
    {
        PurchaseButtonOutlet.isHidden = false;
        InformationText.isHidden = false;
        InformationText.text = "You have played \(NumberOfGamesPlayed) Rounds. Purchase Full Access for \(fullGamePrice ?? "0.99")!"
    }
    
    func retrieveProductInformation()
    {
        SwiftyStoreKit.retrieveProductsInfo(["com.NathanALane.TicPongToe." + IAPFullGameID]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                self.fullGamePrice = priceString;
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(result.error)")
            }
        }
    }
}
