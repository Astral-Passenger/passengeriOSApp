//
//  RedeemViewController.swift
//  Passenger
//
//  Created by Connor Myers on 1/7/16.
//  Copyright © 2016 Astral. All rights reserved.
//

import UIKit
import Firebase
import Bolts
import Foundation

class RedeemViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    let transitionManager = MenuTransitionManager()

    var userId: String?
    
//    let ref = Firebase(url: "https://passenger-app.firebaseio.com/")
//    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users/")
//    let rewardsRef = Firebase(url: "https://passenger-app.firebaseio.com/rewards/")
    
    var rewardPointCost: Int?
    var rewardDescription: String?
    var rewardImage: UIImage?
    var rewardImageString: String?
    var companyName: String?
    var merchantEmail: String?
    var merchantLatitude: Double?
    var currentMerchantIndex: Int?
    var rewardName: String?
    var rewardRealPrice: Double?
    var rewardsList: NSArray?
    var companyImage: UIImage?
   // var couponCodes: NSArray?
    var couponCodesToReturn: [NSArray]?
    var didUseRewardBefore = false
    var couponCode: String?
    
    var couponCodeUsedBefore = 0
    
    var newRewardRedeemed: NSDictionary = [:]
    
    var isEditable = false
    
    private var currentTotalPoints: Int?

    @IBOutlet weak var rewardPointCostLabel: UILabel!
    @IBOutlet weak var redeemCompanyImage: UIImageView!
    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var rewardPrice: UILabel!
    @IBOutlet weak var rewardNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        
        // Do any additional setup after loading the view.
        self.transitionManager.sourceViewController = self
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func couponReceived() {
            
        var iteration = 0
        
        var currentBusinessMonthlyTransactions: NSArray?
        var currentMerchantMonthlyTransactions: NSArray?
        
        var currentBusinessMonthlyTransactionsAppended = [NSDictionary]()
        var currentMerchantMonthlyTransactionsAppended = [NSDictionary]()
        var currentUserRewardsList: NSArray?
        var currentUserRewardsListAppended = [NSDictionary]()
        self.ref.child("merchants").queryOrderedByChild("latitude").queryEqualToValue(self.merchantLatitude).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
            let key = snapshot.key 
            let value = snapshot.value! as! NSDictionary
            let currentCompany = value["\(self.currentMerchantIndex!)"]
            currentBusinessMonthlyTransactions = currentCompany!["monthlyTransactions"] as? NSArray
            if (currentBusinessMonthlyTransactions != nil) {
                for (var i = 0; i < currentBusinessMonthlyTransactions!.count; i++) {
                    currentBusinessMonthlyTransactionsAppended.append(currentBusinessMonthlyTransactions![i] as! NSDictionary)
                }
            } else {
                print("They are nil")
            }
            
            var date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateToRecordString = dateFormatter.stringFromDate(date)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            self.newRewardRedeemed = ["dateRecorded": "\(dateToRecordString)", "rewardDescription": "\(self.rewardDescription!)", "rewardItem": "\(self.rewardName!)", "userEmail": "\(appDelegate.usersEmail!)", "pointCost": (self.rewardPointCost!), "rewardPrice": self.rewardRealPrice!]
            currentBusinessMonthlyTransactionsAppended.append(self.newRewardRedeemed)
            print(currentBusinessMonthlyTransactionsAppended)
            
            self.ref.child("merchants/\(self.currentMerchantIndex!)/monthlyTransactions").setValue(currentBusinessMonthlyTransactionsAppended)

            self.ref.child("merchantLocationOwners").queryOrderedByChild("email").queryEqualToValue(self.merchantEmail!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                
                let value = snapshot.value! as! NSDictionary
                let currentCompany = value.allValues.first!
                let currentKey = value.allKeys.first!
                
                // Handling the storing of the transaction for the businesses
                
                currentMerchantMonthlyTransactions = currentCompany["monthlyTransactions"] as? NSArray
                if (currentMerchantMonthlyTransactions != nil) {
                    for (var i = 0; i < currentMerchantMonthlyTransactions!.count; i++) {
                        currentMerchantMonthlyTransactionsAppended.append(currentMerchantMonthlyTransactions![i] as! NSDictionary)
                    }
                } else {
                    print("They are nil")
                }
                
                var date = NSDate()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateToRecordString = dateFormatter.stringFromDate(date)
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                
                self.newRewardRedeemed = ["dateRecorded": "\(dateToRecordString)", "rewardDescription": "\(self.rewardDescription!)", "rewardItem": "\(self.rewardName!)", "userEmail": "\(appDelegate.usersEmail!)", "pointCost": (self.rewardPointCost!), "rewardPrice": self.rewardRealPrice!]
                currentMerchantMonthlyTransactionsAppended.append(self.newRewardRedeemed)
                print(currentMerchantMonthlyTransactionsAppended)
                self.ref.child("merchantLocationOwners/\(currentKey)/monthlyTransactions").setValue(currentMerchantMonthlyTransactionsAppended)
                
                
                // Handling the storing of the transaction for the user
                
                self.ref.child("users").child(appDelegate.userId).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                    let userID = appDelegate.userId
                    
                    let currentUser = snapshot.value!
                    
                    var currentPoints = currentUser["currentPoints"] as! Int
                    var rewardsReceived = currentUser["rewardsReceived"] as! Int
                    rewardsReceived = rewardsReceived + 1
                    currentPoints = currentPoints - self.rewardPointCost!
                    currentUserRewardsList = currentUser["rewardsHistory"] as? NSArray
                    if (currentUserRewardsList != nil) {
                        for (var i = 0; i < currentUserRewardsList!.count; i++) {
                            currentUserRewardsListAppended.append(currentUserRewardsList![i] as! NSDictionary)
                        }
                    }
                    
                    let currentReward: NSDictionary = ["companyName": self.companyName!, "pointCost": self.rewardPointCost!, "rewardImage": self.rewardImageString!, "rewardItem": self.rewardName!, "rewardText": self.rewardDescription!]
                    
                    currentUserRewardsListAppended.append(currentReward)
                    
                    self.ref.child("users/\(userID)/currentPoints").setValue(currentPoints)
                    self.ref.child("users/\(userID)/rewardsHistory").setValue(currentUserRewardsListAppended)
                    self.ref.child("users/\(userID)/rewardsReceived").setValue(rewardsReceived)
                    
                    self.performSegueWithIdentifier("redeemToRewardsHistory", sender: nil)
                    
                })
            })
        })

    }
    
    func configureView() {

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.ref.child("users").queryOrderedByChild("email").queryEqualToValue(appDelegate.usersEmail).observeEventType(.ChildAdded, withBlock: { (snapshot) in
            self.currentTotalPoints = snapshot.value!.objectForKey("currentPoints") as! Int
            self.userId = snapshot.key
        })
        
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        

        rewardNameLabel.text = rewardName!
        rewardPrice.text = rewardDescription!
        rewardPointCostLabel.text = String(rewardPointCost!)
        rewardImageView.image = rewardImage!
        redeemCompanyImage.image = companyImage!
        self.rewardImageView.layer.masksToBounds = true
        rewardImageView.layer.cornerRadius = 33.3333333
        
    }
    
    
    @IBAction func redeemButtonTapped(sender: AnyObject) {
        
        // Check to see if the user even has enough points saved to redeem it before they actually go to the pop up
        if(rewardPointCost < currentTotalPoints) {
            //backgroundPopUpView.hidden = false
            let alert = UIAlertController(title: "SHOW TO TELLER", message: "Show your phone to the teller at \(self.companyName!) and have them click redeem before you have purchased the \(self.rewardName!)", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "REDEEM", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.couponReceived()}))
            alert.addAction(UIAlertAction(title: "CANCEL", style: UIAlertActionStyle.Cancel, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            // The user didn't have enough points show an alert
            let alertController = UIAlertController(title: "Passenger", message: "You do not have enough points built up to redeem this reward", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // set transition delegate for our menu view controller
    
        if(segue.identifier == "presentMenu") {
                let menu = segue.destinationViewController as! UINavigationController
                menu.transitioningDelegate = self.transitionManager
                self.transitionManager.menuViewController = menu
                let dest = menu.topViewController as! DiscountCollectionViewController
                dest.companyName = self.companyName
                dest.rewards = self.rewardsList
            dest.companyImage = self.companyImage
            dest.couponCodes = self.couponCodesToReturn!
            dest.merchantLatitude = self.merchantLatitude!
            dest.merchantEmail = self.merchantEmail!
            dest.currentMerchantIndex = self.currentMerchantIndex!
        }
    
    
    }
    
    @IBAction func cancelRedeemButton(sender: AnyObject) {
        self.performSegueWithIdentifier("cancelRedeemToHome", sender: nil)
    }


}
