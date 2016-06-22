//
//  RedeemViewController.swift
//  Passenger
//
//  Created by Connor Myers on 1/7/16.
//  Copyright © 2016 Astral. All rights reserved.
//

import UIKit
import Parse
import Firebase
import Bolts
import Foundation

class RedeemViewController: UIViewController {
    
    let transitionManager = MenuTransitionManager()

    let ref = Firebase(url: "https://passenger-app.firebaseio.com/")
    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users/")
    let rewardsRef = Firebase(url: "https://passenger-app.firebaseio.com/rewards/")
    
    var rewardPointCost: Int?
    var rewardDescription: String?
    var rewardImage: UIImage?
    var rewardImageString: String?
    var companyName: String?
    var rewardName: String?
    var rewardsList: NSArray?
    
    var newRewardRedeemed: NSDictionary = [:]
    
    var redeemedRewards = [PFObject]()
    
    var isEditable = false
    
    var company: PFObject?
    
    var localData = ParseLocalData()
    
    var digitTextField: UITextField?
    
    private var sixDigitString = ""
    private var currentTotalPoints: Int?

    @IBOutlet weak var rewardImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var rewardNameLabel: UILabel!
    @IBOutlet weak var rewardPriceLabel: UILabel!
    @IBOutlet weak var rewardPointCostLabel: UILabel!
    @IBOutlet weak var backgroundPopUpView: UIView!
    @IBOutlet weak var sixDigitLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var popUpWhiteBackground: UIView!
    @IBOutlet weak var popUpDoneButton: UIButton!
    @IBOutlet weak var buttonOne: UIButton!
    @IBOutlet weak var buttonTwo: UIButton!
    @IBOutlet weak var buttonThree: UIButton!
    @IBOutlet weak var buttonFour: UIButton!
    @IBOutlet weak var buttonFive: UIButton!
    @IBOutlet weak var buttonSix: UIButton!
    @IBOutlet weak var buttonSeven: UIButton!
    @IBOutlet weak var buttonEight: UIButton!
    @IBOutlet weak var buttonNine: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        var altMessage = UIAlertController(title: "Warning", message: "This is Alert Message", preferredStyle: UIAlertControllerStyle.Alert)
//        altMessage.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.Default, handler: nil))
//        self.presentViewController(altMessage, animated: true, completion: nil)
//        var alert = UIAlertController(title: "Title", message: "Your msg", preferredStyle: UIAlertControllerStyle.Alert)
//        
//        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel,
//            handler:{(alert: UIAlertAction!) in self.identifierReceived()}))
//        

//        
//        self.presentViewController(alert, animated: true, completion: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "closePopUp")
        view.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
        self.transitionManager.sourceViewController = self
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func identifierReceived() {
        print(digitTextField!.text!)
        sixDigitString = digitTextField!.text!
        if (sixDigitString.characters.count < 6) {
            let alertController = UIAlertController(title: "Passenger", message: "Please enter a 6 digit number to verify your business", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            activityIndicator.startAnimating()
            activityIndicator.hidden = false
            
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
                    
                    self.newRewardRedeemed = ["dateRecorded": "\(dateToRecordString)", "rewardDescription": "\(self.rewardDescription!)", "rewardItem": "\(self.rewardName!)", "userEmail": "\(self.ref.authData.providerData["email"]!)"]
                    currentBusinessMonthlyTransactionsAppended.append(self.newRewardRedeemed)
                    
                    let currentBusinessRef = Firebase(url: "https://passenger-app.firebaseio.com/rewards/\(iteration)/monthlyTransactions")
                    
                    currentBusinessRef.setValue(currentBusinessMonthlyTransactionsAppended)
                    
                    // Handling the storing of the transaction for the user
                    
                    self.usersRef.queryOrderedByChild("email").queryEqualToValue("\(self.ref.authData.providerData["email"]!)")
                        .observeEventType(.ChildAdded, withBlock: { snapshot in
                            let id = snapshot.key
                            print(id)
                            
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
                            
                            self.performSegueWithIdentifier("redeemToRewardsHistory", sender: nil)
                        })
                    
                })
        }

    }
    
    func configureView() {
        // Change the font and size of nav bar text
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        /*
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showRewardsViewController")
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeGestureRecognizer) */
        // Change the font and size of nav bar text
        
        usersRef.queryOrderedByChild("email").queryEqualToValue("\(ref.authData.providerData["email"]!)")
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                let fullName = snapshot.value.objectForKey("name") as! String!
                let currentPoints = snapshot.value.objectForKey("currentPoints") as! Int
                self.currentTotalPoints = snapshot.value.objectForKey("currentPoints") as! Int
            })
        
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        companyNameLabel.text = companyName!
        rewardNameLabel.text = rewardName!
        rewardPriceLabel.text = rewardDescription!
        rewardPointCostLabel.text = String(rewardPointCost!)
        rewardImageView.image = rewardImage!
        
        rewardImageView.layer.cornerRadius = 25
        popUpWhiteBackground.layer.cornerRadius = 10
        popUpDoneButton.layer.cornerRadius = 6
        
    }
    
    
    @IBAction func redeemButtonTapped(sender: AnyObject) {
        
        // Check to see if the user even has enough points saved to redeem it before they actually go to the pop up
        if(rewardPointCost < currentTotalPoints) {
            //backgroundPopUpView.hidden = false
            let alert = UIAlertController(title: "SHOW TO TELLER", message: "Show your phone to the teller so that they can enter in their 6 digit code to give you the reward.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.identifierReceived()}))
            alert.addTextFieldWithConfigurationHandler({(textField) in
                textField.placeholder = "Password"
                textField.secureTextEntry = true  // setting the secured text for using password
                textField.keyboardType = UIKeyboardType.NumberPad
                self.digitTextField = textField
            })
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
        }
    
    
    }
    
    func closePopUp() {
        backgroundPopUpView.hidden = true
    }
    
    @IBAction func oneUp(sender: AnyObject) {
        buttonOne.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func oneDown(sender: AnyObject) {
        buttonOne.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "1"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func twoUp(sender: AnyObject) {
        buttonTwo.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func twoDown(sender: AnyObject) {
        buttonTwo.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "2"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func threeUp(sender: AnyObject) {
        buttonThree.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func threeDown(sender: AnyObject) {
        buttonThree.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "3"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func fourUp(sender: AnyObject) {
        buttonFour.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func fourDown(sender: AnyObject) {
        buttonFour.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "4"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func fiveUp(sender: AnyObject) {
        buttonFive.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func fiveDown(sender: AnyObject) {
        buttonFive.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "5"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func sixUp(sender: AnyObject) {
        buttonSix.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func sixDown(sender: AnyObject) {
        buttonSix.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "6"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func sevenUp(sender: AnyObject) {
        buttonSeven.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func sevenDown(sender: AnyObject) {
        buttonSeven.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "7"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func eightUp(sender: AnyObject) {
        buttonEight.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func eightDown(sender: AnyObject) {
        buttonEight.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "8"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func nineUp(sender: AnyObject) {
        buttonNine.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func nineDown(sender: AnyObject) {
        buttonNine.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
        if(sixDigitString.characters.count < 6) {
            sixDigitString = sixDigitString + "9"
            sixDigitLabel.text = sixDigitString
            isEditable = true
        } else if(sixDigitString.characters.count > 6) {
            sixDigitString = "9"
            sixDigitLabel.text = sixDigitString
        }
    }
    
    @IBAction func exitPopUp(sender: AnyObject) {
        backgroundPopUpView.hidden = true
    }
    
    @IBAction func doneButtonClicked(sender: AnyObject) {
        //  Verfiy that the 6 digit code corresponds to an actual company on our list
        
    }
    

    @IBAction func backspaceButtonTapped(sender: AnyObject) {
        
        if (isEditable) {
            sixDigitString = String(sixDigitString.characters.dropLast())
        }
        
        if (sixDigitString.characters.count < 1) {
            sixDigitString = "Enter 6 digit code"
            isEditable = false
        } else {
            
        }
        sixDigitLabel.text = sixDigitString
    }
    
    


}
