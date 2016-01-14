//
//  ProfileViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/22/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Darwin

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileTopBackground: UIImageView!

    @IBOutlet weak var rewardsReceivedButton: UIButton!
    @IBOutlet weak var milesDrivenButton: UIButton!
    @IBOutlet weak var totalCurrentPointsLabel: UILabel!
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var rewardsReceivedLabel: UILabel!
    @IBOutlet weak var milesDrivenLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeSpentDrivingLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    
    var currentUser: PFUser?
    
    private var days: Int?
    private var hoursFloored: Int?
    private var hoursFull: Double?
    private var minutes: Int?
    
    private var timeSpendDrivingText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This is one of the changes.
    
    func configureView() {
        
        currentUser = PFUser.currentUser()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            if let profileImage = self.currentUser!["profile_picture"] as? PFFile {
                profileImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    let image: UIImage! = UIImage(data: imageData!)!
                    self.profilePicture?.image = image
                    self.profilePicture.layer.masksToBounds = true
                    self.profilePicture.layer.cornerRadius = 50
                })
            }
            
        }
        
        if let totalPoints = self.currentUser!["totalPoints"] as? Int,
        let currentTotalPoints = self.currentUser!["currentPoints"] as? Int
        {
            totalCurrentPointsLabel.text = String(currentTotalPoints)
            totalPointsLabel.text = String(totalPoints)
        } else {
            // Either one of the points was nil.
        }
        
        if let distanceTraveled = self.currentUser!["distanceTraveled"] as? Int {
            milesDrivenLabel.text = String(distanceTraveled)
        } else {
            // The distance traveled was nil
        }
        
        if let rewardsReceived = self.currentUser!["rewardsReceived"] as? Int {
            rewardsReceivedLabel.text = String(rewardsReceived)
        } else {
            // The rewards received was nil
        }
        
        if let fullName = self.currentUser!["full_name"] as? String
         {
            fullNameLabel.text = fullName
        } else {
            // The first or last name is nil
        }
        
        if let username = self.currentUser!.username {
            usernameLabel.text = username
        } else {
            // The username came back as nil
        }
        
        if let timeSpentDriving = self.currentUser!["timeSpendDriving"] as? Int {
            timeSpentDrivingLabel.text = calculateTimeSpentDriving(timeSpentDriving)
        } else {
            // Couldn't get the time spent driving
        }
        

        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        
    }

    @IBAction func editProfileUp(sender: AnyObject) {
        editProfileButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func editProfileDown(sender: AnyObject) {
        editProfileButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func rewardsReceivedDown(sender: AnyObject) {
        rewardsReceivedButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func rewardsReceivedUp(sender: AnyObject) {
        rewardsReceivedButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func milesDrivenDown(sender: AnyObject) {
        milesDrivenButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }

    @IBAction func milesDrivenUp(sender: AnyObject) {
        milesDrivenButton.backgroundColor = UIColor.whiteColor()
    }
    
    func calculateTimeSpentDriving(totalTime: Int) -> String {
        var finalString: String?
        self.hoursFull = (Double(totalTime)/3600.0)
        
        if(hoursFull! > 23.999) {
            self.days = Int(hoursFull!/24.0)
            self.hoursFull = hoursFull! - (Double(days!) * 24.0)
            print(hoursFull!)
            self.hoursFloored = Int(floor(hoursFull!))
            self.minutes = Int((hoursFull! - Double(hoursFloored!)) * 60)
            finalString = "\(days!) d. \(hoursFloored!) hr. \(minutes!) min."
        } else {
            self.hoursFloored = Int(floor(hoursFull!))
            self.minutes = Int((hoursFull! - Double(hoursFloored!)) * 60)
            finalString = "\(hoursFloored!) hr. \(minutes!) min."
        }
        
        return finalString!
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if (segue.identifier == "profileToEditProfile") {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let targetViewController = destinationViewController.topViewController as! ProfileSettingsViewController
            targetViewController.senderViewController = "Profile"
        } else if (segue.identifier == "profiileToRewardsHistory") {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let targetViewController = destinationViewController.topViewController as! RewardsHistoryCollectionViewController
            targetViewController.senderViewController = "Rewards"
        } else if (segue.identifier == "profileToPointsHistory") {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let targetViewController = destinationViewController.topViewController as! PointsHistoryTableViewController
            targetViewController.senderViewController = "Points"
        }
        
    }


}
