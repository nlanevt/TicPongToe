//
//  IAPHelper.swift
//  TicPongToe
//
//  Created by Nathan Lane on 8/21/18.
//  Copyright © 2018 Nathan Lane. All rights reserved.
//
import UIKit
import StoreKit

//MARK: SKProductsRequestDelegate

extension IAPHelpers : SKProductsRequestDelegate
{
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
    {
        if response.products.count > 0
        {
            let validProduct : SKProduct = response.products[0]
            
            switch validProduct.productIdentifier {
                
            case PRODUCT_IDENTIFIERS.k_10_WORDS_PRODUCT_IDENTIFIER.rawValue :
                
                self.buyProduct(validProduct)
                
            case PRODUCT_IDENTIFIERS.k_20_WORDS_PRODUCT_IDENTIFIER.rawValue  :
                
                self.buyProduct(validProduct)
                
            case PRODUCT_IDENTIFIERS.k_ALL_WORDS_PRODUCT_IDENTIFIER.rawValue  :
                
                self.buyProduct(validProduct)
                
            default :
                
                self.alertThis("Sorry", message: "No products recieved from server", current: self.currentViewController)
            }
            
        } else {
            
            self.alertThis("Sorry", message: "Can't make payments, Please check in settings.", current: self.currentViewController)
        }
    }
}

extension IAPHelpers : SKRequestDelegate
{
    func requestDidFinish(request: SKRequest)
    {
        
    }
    
    func request(request: SKRequest, didFailWithError error: NSError)
    {
        self.alertThis("Sorry", message: "\(error.localizedDescription)", current: self.currentViewController)
    }
}

//MARK: SKPaymentTransactionObserver

extension IAPHelpers : SKPaymentTransactionObserver
{
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
    {
        self.handlingTransactions(transactions)
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue)
    {
        if queue.transactions.count == 0
        {
            self.alertThis("Sorry", message: "You didnt make any purchase to restiore, Please do a purchase first.", current: self.currentViewController)
        }
        else
        {
            self.handlingTransactions(queue.transactions)
        }
    }
    
    func paymentQueue(queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: NSError)
    {
        self.alertThis("Sorry", message: "\(error.localizedDescription)", current: self.currentViewController)
    }
    
}


enum PRODUCT_IDENTIFIERS : String
{
    //MARK: Product ID's
    
    case k_10_WORDS_PRODUCT_IDENTIFIER = "YOUR_PRODUCT_IDENTIFIER_10"
    case k_20_WORDS_PRODUCT_IDENTIFIER  = "YOUR_PRODUCT_IDENTIFIER_20"
    case k_ALL_WORDS_PRODUCT_IDENTIFIER  = "YOUR_PRODUCT_IDENTIFIER_ALL"
    case k_RESTORE_WORDS_PRODUCT_IDENTIFIER  = "YOUR_PRODUCT_IDENTIFIER_RESTOREE"
}

enum USER_DEFAULTS_IDENTIFIERS : String
{
    case TEN_WORDS_PRODUCT_IDENTIFIER = "10_WORDS_IDENTIFIER"
    case TWENTY_WORDS_PRODUCT_IDENTIFIER  = "20_WORDS_IDENTIFIER"
    case ALL_WORDS_PRODUCT_IDENTIFIER  = "ALL_WORDS_IDENTIFIER"
}

enum ReceiptURL : String
{
    case sandbox = "https://sandbox.itunes.apple.com/verifyReceipt"
    case production = "https://buy.itunes.apple.com/verifyReceipt"
    case myServer = "your server"
    
}


protocol StoreRequestIAPPorotocol
{
    func transactionCompletedForRequest(PRODUCT_ID : String)
}

class IAPHelpers: NSObject {
    
    //MARK: Variables
    
    var delegate : StoreRequestIAPPorotocol!
    var currentViewController : UIViewController!
    
    //MARK: - Creating sharedInstance
    
    /*class var sharedInstance: IAPHelpers {
        
        struct Static {
            
            static var sharedInstance: IAPHelpers?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.sharedInstance = IAPHelpers()
        }
        
        return Static.sharedInstance!
    }*/
    
    public static let shared = IAPHelpers()
    
    override init() {
        super.init()
        
        restorePurchasedItems()
        
        SKPaymentQueue.default().add(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(IAPManager.savePurchasedItems), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    //MARK: Product Request
    
    func productRquestStarted(productReferenceName : String)
    {
        if (SKPaymentQueue.canMakePayments()) {
            
            if productReferenceName == PRODUCT_IDENTIFIERS.k_RESTORE_WORDS_PRODUCT_IDENTIFIER.rawValue
            {
                self.restorePurchases()
            }
            else
            {
                let productID : Set<String> = [productReferenceName]
                let productsRequest : SKProductsRequest = SKProductsRequest(productIdentifiers: productID)
                productsRequest.delegate = self
                productsRequest.start()
            }
        } else {
            
            // PRESENT A USER FOR UI about not being able to make payments.
        }
    }
    
    //MARK: Buy Product - Payment Section
    
    func buyProduct(product : SKProduct)
    {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
    }
    
    //MARK: Restore Transaction
    
    func restoreTransaction(transaction : SKPaymentTransaction)
    {
        self.deliverProduct(product: transaction.payment.productIdentifier)
    }
    
    //MARK: Restore Purchases
    
    func restorePurchases()
    {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    //MARK: - Showing UIAlertView
    
    func alertThis(title : String, message : String, current : UIViewController)
    {
        let alertView : UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        alertView.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: { _ in
            
        }))
        
        current.present(alertView, animated: true, completion: nil)
    }
    
    //MARK: Transaction Observer Handler
    
    func handlingTransactions(transactions : [AnyObject])
    {
        for transaction in transactions {
            
            if let paymentTransaction : SKPaymentTransaction = transaction as? SKPaymentTransaction {
                
                switch paymentTransaction.transactionState {
                    
                case .purchasing :
                    
                    print("Purchasing")
                    
                case .purchased :
                    
                    self.deliverProduct(product: paymentTransaction.payment.productIdentifier)
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                case .failed:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                case .restored:
                    
                    print("Restored")
                    self.restoreTransaction(transaction: paymentTransaction)
                    break
                    
                default:
                    
                    print("DEFAULT")
                    
                    // PRESENT A USER FOR UI about not being able to make payments.
                    
                    break
                }
            }
        }
    }
    
    
    //MARK: Deliver Product
    
    func deliverProduct(product : String)
    {
        self.validateReceipt { status in
            
            if status
            {
                self.delegate.transactionCompletedForRequest(PRODUCT_ID: product)
            }
            else
            {
                print("Something bad happened")
            }
        }
    }
    
    //MARK: Receipt Validation
    
    func validateReceipt(completion : @escaping (_ status : Bool) -> ())  {
        
        let receiptUrl = Bundle.main.appStoreReceiptURL
        let receipt =  NSData(contentsOf: receiptUrl!)
        
        let receiptdata: NSString = receipt!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0)) as NSString
    
        let dict = ["receipt-data" : receiptdata]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: 0))
        
        let request = NSMutableURLRequest(url: NSURL(string: ReceiptURL.sandbox.rawValue)! as URL)
        
        let session = URLSession.shared
        request.httpMethod = "POST"
        
        request.httpBody = jsonData
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error  in
            
            if let dataR = data
            {
                self.handleData(responseDatas: dataR as NSData, completion: { status in
                    
                    completion(status)
                })
            }
        })
        
        task.resume()
    }
    
    
    func handleData(responseDatas : NSData, completion : (_ status : Bool) -> ())
    {
        if let json = try! JSONSerialization.jsonObject(with: responseDatas as Data, options: JSONSerialization.ReadingOptions.mutableLeaves) as? NSDictionary
        {
            if let value = json.value(forKeyPath: "status") as? Int
            {
                if value == 0
                {
                    completion(true)
                }
                else
                {
                    completion(false)
                }
            }
            else
            {
                completion(false)
            }
        }
    }
}
