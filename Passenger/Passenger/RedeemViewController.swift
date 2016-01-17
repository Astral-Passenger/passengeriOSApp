//
//  RedeemViewController.swift
//  Passenger
//
//  Created by Connor Myers on 1/7/16.
//  Copyright © 2016 Astral. All rights reserved.
//

import UIKit
import Parse
import Bolts
import Foundation

class RedeemViewController: UIViewController {
    
    let transitionManager = MenuTransitionManager()
    
    var rewardPointCost: Int?
    var rewardDescription: String?
    var rewardImage: UIImage?
    var companyName: String?
    var rewardName: String?
    
    var redeemedRewards = [PFObject]()
    
    var currentUser: PFUser?
    
    var isEditable = false
    
    var localData = ParseLocalData()
    
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
        
        currentUser = PFUser.currentUser()

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
    
    func configureView() {
        // Change the font and size of nav bar text
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
        /*
        let swipeGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "showRewardsViewController")
        swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        self.view.addGestureRecognizer(swipeGestureRecognizer) */
        // Change the font and size of nav bar text
        
        self.currentTotalPoints = currentUser!["currentPoints"] as! Int
        
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
            backgroundPopUpView.hidden = false
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
        
        if (sixDigitString.characters.count < 6) {
            let alertController = UIAlertController(title: "Passenger", message: "Please enter a 6 digit number to verify your business", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            activityIndicator.startAnimating()
            activityIndicator.hidden = false
            let query = PFQuery(className:"Rewards")
            query.whereKey("companyName", equalTo: self.companyName!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    let company = objects![0]
                    let companyIdentifier = company["sixDigitIdentifier"] as! String
                    if (companyIdentifier == self.sixDigitString) {
                        
                        // Log the transaction for the business in parse so that we know if this business created a transaction so we can bill them in the future.
                        let businessTransaction = PFObject(className:"BusinessTranscation")
                        businessTransaction["company"] = company
                        businessTransaction["rewardItem"] = self.rewardName
                        businessTransaction["rewardDescription"] = self.rewardDescription
                        businessTransaction.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // The object has been saved.
                                print("The transaction was saved in the database")
                            } else {
                                // There was a problem, check error.description
                                print("There was an error saving the object")
                            }
                        }
                        
                        
                        
                        // If they are verified, then subtract the points from the user and log the entry in the rewards table for this user
                        let imageData = UIImageJPEGRepresentation(self.rewardImage!,0.05)

                        let rewardFileObject = PFFile(data:imageData!)
                        
                        let rewardTransaction = PFObject(className: "RewardsHistory")
                        rewardTransaction["userId"] = self.currentUser!
                        rewardTransaction["pointCost"] = self.rewardPointCost!
                        rewardTransaction["companyName"] = self.companyName!
                        rewardTransaction["rewardItem"] = self.rewardName!
                        rewardTransaction["rewardText"] = self.rewardDescription!
                        rewardTransaction.setObject(rewardFileObject!, forKey: "rewardImage")
                        rewardTransaction.saveInBackgroundWithBlock {
                            (success: Bool, error: NSError?) -> Void in
                            if (success) {
                                // The object has been saved.
                                print("The transaction was saved in the database")
                                self.currentUser!["currentPoints"] = self.currentUser!["currentPoints"] as! Int - self.rewardPointCost!
                                self.currentUser!["rewardsReceived"] = self.currentUser!["rewardsReceived"] as! Int + 1
                                self.currentUser?.saveInBackgroundWithBlock{
                                    (success: Bool, error: NSError?) -> Void in
                                    if (success) {
                                        // The object has been saved.
                                        print("The user was saved")
                                        self.performSegueWithIdentifier("redeemToRewardsHistory", sender: nil)
                                        self.localData.loadDataDescending("RewardsHistory", descendingBy: "createdAt")
                                        
                                    } else {
                                        // There was a problem, check error.description
                                    }
                                }
                            } else {
                                // There was a problem, check error.description
                                print("There was an error saving the object")
                            }
                        }
                        
                        
                    } else {
                        let alertController = UIAlertController(title: "Wrong ID Number", message: "Please enter the six digit number for your company", preferredStyle: .Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)

                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }

            }
            
            

        }
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
