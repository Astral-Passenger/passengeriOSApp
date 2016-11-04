//
//  ViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/2/15.
//  Copyright © 2015 Astral. All rights reserved.
//
import Foundation
import UIKit
import CoreLocation
import HealthKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var homeProfileLayout: UIView!
    @IBOutlet weak var rewardsButtonView: UIView!
    @IBOutlet weak var pointsHistoryButtonView: UIView!
    @IBOutlet weak var rewardsHistoryButtonView: UIView!
    @IBOutlet weak var usernameTextView: UILabel!
    @IBOutlet weak var totalPointsTextView: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    
    @IBOutlet weak var rewardImageButton: UIButton!
    @IBOutlet weak var pointsHistoryImageButton: UIButton!
    // User information
    @IBOutlet weak var rewardsContainerView: UIView!
    @IBOutlet weak var rewardsHistoryImageButton: UIButton!
    @IBOutlet weak var driveStartedPopup: UIView!
    @IBOutlet weak var driveStartedContinueButton: UIButton!
    @IBOutlet weak var driveStartedLayoverView: UIView!
    
    var name = ""
    
    var seconds = 0.0
    var distance = 0.0
    
    var appDelegate = AppDelegate()
    
    var currentSpeed = 0.0
    
    var previousLocation: CLLocation?
    var currentLocation: CLLocation?
    
    var fullname: String = ""
    var currentPoints  = 0
    var totalPoints = 0
    var profilePictureString: String = ""
    var profilePictureLocation: String = ""
    var rewardsReceived: Int = 0
    var timeSpentDriving: Double = 0.0
    var email: String = ""
    var distanceTraveled: Double = 0.0
    var imageData: NSData?
    
    override func viewDidAppear(animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let reachable = Reachability()
        if !(reachable.isConnectedToNetwork()) {
            let alert = UIAlertController(title: "INTERNET CONNECTION", message: "You are currently not connected to the internet. Passenger requires that you have an internet connection in order to record your driving and give you points. Please make sure you have a connection to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }

        configureView()

        if let user = FIRAuth.auth()?.currentUser {
            // User is signed in.
            var uid = user.uid;
            uid = (uid as NSString).stringByReplacingOccurrencesOfString("facebook:", withString: "")
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.userId = uid
        } else {
            
        }

      //  performSegueWithIdentifier("presentLastDriveStats", sender: nil)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "homeToRewards") {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.topViewController as! RewardsDetailTableViewController
            dest.currentTitle = "CHOOSE COMPANY"
            dest.rewardType = "Discounts"
        } else if (segue.identifier == "presentLastDriveStats") {
            let dest = segue.destinationViewController as! PreviousDriveStatsViewController
            dest.usersName = self.fullname
            dest.userImageString = self.profilePictureString
        }
        
    }
    
    func configureView() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.usernameTextView.text = appDelegate.usersName
        self.fullname = appDelegate.usersName!
        self.totalPointsTextView.text = String(Int(appDelegate.currentUserCurrentPoints))
        self.profilePictureString = appDelegate.profilePictureString!
        self.profilePictureLocation = appDelegate.imageLocation!
        
       // let decodedData = NSData(base64EncodedString: profilePictureString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
       // let decodedImage = UIImage(data: decodedData!)
        let decodedImage = UIImage(data: appDelegate.imageData!)
        self.profilePictureView?.image = decodedImage
        self.profilePictureView.layer.masksToBounds = true
        self.profilePictureView.layer.cornerRadius = 37.5
        
        self.rewardImageButton.clipsToBounds = true
        self.pointsHistoryImageButton.clipsToBounds = true
        self.rewardsHistoryImageButton.clipsToBounds = true
        self.driveStartedPopup.clipsToBounds = true
        self.driveStartedContinueButton.clipsToBounds = true
        self.rewardImageButton.layer.cornerRadius = 3
        self.pointsHistoryImageButton.layer.cornerRadius = 3
        self.rewardsHistoryImageButton.layer.cornerRadius = 3
        self.driveStartedPopup.layer.cornerRadius = 10
        self.driveStartedContinueButton.layer.cornerRadius = 3
        
        let strDate = "2015-10-06T15:42:34Z" // "2015-10-06T15:42:34Z"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let currentDate = NSDate()
        let currentDateString:String = dateFormatter.stringFromDate(currentDate)
        
        
    }

    @IBAction func driveStartedContinueButtonClicked(sender: AnyObject) {
        self.driveStartedLayoverView.hidden = true
    }
}

