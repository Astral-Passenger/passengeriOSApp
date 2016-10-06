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
    
    let transitionManager = MenuTransitionManager()

    var userId: String?
    
    let ref = Firebase(url: "https://passenger-app.firebaseio.com/")
    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users/")
    let rewardsRef = Firebase(url: "https://passenger-app.firebaseio.com/rewards/")
    
    var rewardPointCost: Int?
    var rewardDescription: String?
    var rewardImage: UIImage?
    var rewardImageString: String?
    var companyName: String?
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
        
        print(rewardRealPrice)
        
        // Do any additional setup after loading the view.
        self.transitionManager.sourceViewController = self
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func couponReceived() {
        UIPasteboard.generalPasteboard().string = "Hello World"
            
        var iteration = 0
        
        var currentBusinessMonthlyTransactions: NSArray?
        
        var currentBusinessMonthlyTransactionsAppended = [NSDictionary]()
        var currentUserRewardsList: NSArray?
        var currentUserRewardsListAppended = [NSDictionary]()
        
        rewardsRef.queryOrderedByChild("companyName").queryEqualToValue(companyName)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                
                // Handling the storing of the transaction for the businesses
                
                iteration = Int(snapshot.key!)!
                currentBusinessMonthlyTransactions = snapshot.value.objectForKey("monthlyTransactions") as? NSArray
                if (currentBusinessMonthlyTransactions != nil) {
                    for (var i = 0; i < currentBusinessMonthlyTransactions!.count; i++) {
                        currentBusinessMonthlyTransactionsAppended.append(currentBusinessMonthlyTransactions![i] as! NSDictionary)
                    }
                }
                
                var date = NSDate()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateToRecordString = dateFormatter.stringFromDate(date)
                
                self.newRewardRedeemed = ["dateRecorded": "\(dateToRecordString)", "rewardDescription": "\(self.rewardDescription!)", "rewardItem": "\(self.rewardName!)", "userEmail": "\(self.ref.authData.providerData["email"]!)", "pointCost": (self.rewardPointCost!), "rewardPrice": self.rewardRealPrice!]
                currentBusinessMonthlyTransactionsAppended.append(self.newRewardRedeemed)
                
                let currentBusinessRef = Firebase(url: "https://passenger-app.firebaseio.com/rewards/\(iteration)/monthlyTransactions")
                
                currentBusinessRef.setValue(currentBusinessMonthlyTransactionsAppended)
                
                // Handling the storing of the transaction for the user
                
                self.usersRef.queryOrderedByChild("email").queryEqualToValue("\(self.ref.authData.providerData["email"]!)")
                    .observeEventType(.ChildAdded, withBlock: { snapshot in
                        let id = snapshot.key
                        
                        var currentPoints = snapshot.value.objectForKey("currentPoints") as! Int
                        var rewardsReceived = snapshot.value.objectForKey("rewardsReceived") as! Int
                        rewardsReceived = rewardsReceived + 1
                        currentPoints = currentPoints - self.rewardPointCost!
                        currentUserRewardsList = snapshot.value.objectForKey("rewardsHistory") as? NSArray
                        if (currentUserRewardsList != nil) {
                            for (var i = 0; i < currentUserRewardsList!.count; i++) {
                                currentUserRewardsListAppended.append(currentUserRewardsList![i] as! NSDictionary)
                            }
                        }
                        
                        let currentReward: NSDictionary = ["companyName": "", "pointCost": self.rewardPointCost!, "rewardImage": self.rewardImageString!, "rewardItem": self.rewardName!, "rewardText": self.rewardDescription!]
                        
                        currentUserRewardsListAppended.append(currentReward)
                        
                        let currentUserPointsRef = Firebase(url: "https://passenger-app.firebaseio.com/users/\(id)/currentPoints/")
                        let currentUserRewardsRef = Firebase(url: "https://passenger-app.firebaseio.com/users/\(id)/rewardsHistory/")
                        let currentUserRewardsReceivedRef = Firebase(url: "https://passenger-app.firebaseio.com/users/\(id)/rewardsReceived/")

                        currentUserPointsRef.setValue(currentPoints)
                        currentUserRewardsReceivedRef.setValue(rewardsReceived)
                        currentUserRewardsRef.setValue(currentUserRewardsListAppended)
                        
                        let tracker = GAI.sharedInstance().defaultTracker
                        let builder: NSObject = GAIDictionaryBuilder.createEventWithCategory(
                            "Reward",
                            action: "Redeemed",
                            label: "Reward redeemed for: \(self.companyName!) and the item is: \(self.rewardName!)",
                            value: nil).build()
                        tracker.send(builder as! [NSObject : AnyObject])
                        
                        self.performSegueWithIdentifier("redeemToRewardsHistory", sender: nil)
                    })
                
            })
        

    }
    
    func configureView() {
        // Change the font and size of nav bar text

        // Change the font and size of nav bar text
        
        usersRef.queryOrderedByChild("email").queryEqualToValue("\(ref.authData.providerData["email"]!)")
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                self.currentTotalPoints = snapshot.value.objectForKey("currentPoints") as! Int
                self.userId = snapshot.key

                // Check if this reward has been used before
                
                if ((snapshot.value.objectForKey("couponHistory")) != nil) {
                    
                    // The user has gotten at least one reward from some partner of ours before
                    
                    for i in snapshot.value.objectForKey("couponHistory") as! NSArray {
                        
                        let currentCompany = i.objectForKey("companyName") as! String
                        
                        if (self.companyName == currentCompany) {
                            self.didUseRewardBefore = true
                            self.couponCodeUsedBefore = i.objectForKey("previousCouponNumber") as! Int
                        }

                    }
                    
                    if (self.didUseRewardBefore) {
                        
                        // User has used this company before
                        
                       // self.couponCode = self.couponCodes?.objectAtIndex(self.couponCodeUsedBefore + 1) as? String

                    } else {
                        
                        // First time using this company
                        
                    // self.couponCode = self.couponCodes?.objectAtIndex(self.couponCodeUsedBefore) as? String

                    }
                    
                } else {
                    
                    // The user has never before redeemed a reward.
                    
                   // self.couponCode = self.couponCodes?.objectAtIndex(self.couponCodeUsedBefore) as? String

                }
                
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
        }
    
    
    }
    
    @IBAction func cancelRedeemButton(sender: AnyObject) {
        self.performSegueWithIdentifier("cancelRedeemToHome", sender: nil)
    }


}
