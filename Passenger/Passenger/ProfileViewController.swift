//
//  ProfileViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/22/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Darwin
import Firebase

class ProfileViewController: UIViewController {
    
    let ref = Firebase(url: "https://passenger-app.firebaseio.com")
    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users/")

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
    
    private var days: Int?
    private var hoursFloored: Int?
    private var hoursFull: Double?
    private var minutes: Int?
    
    var fullName: String?
    var totalPoints: Int?
    var currentPoints: Int?
    var distanceTraveled: Double?
    var rewardsReceived: Int?
    var timeSpentDriving: Double?
    var profilePictureString: String?
    
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
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        self.fullNameLabel.text = appDelegate.usersName
        self.totalPointsLabel.text = String(Int(appDelegate.currentUserTotalPoints))
        self.totalCurrentPointsLabel.text = String(Int(appDelegate.currentUserCurrentPoints))
        self.milesDrivenLabel.text = String(Int(appDelegate.currentUserCurrentDistance))
        self.rewardsReceivedLabel.text = String(appDelegate.rewardsReceived!)
        self.timeSpentDrivingLabel.text = self.calculateTimeSpentDriving(appDelegate.currentUserTimeSpentDriving)
        self.profilePictureString = appDelegate.profilePictureString
        
        let decodedData = NSData(base64EncodedString: profilePictureString!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedImage = UIImage(data: decodedData!)
        
        self.profilePicture?.image = decodedImage
        self.profilePicture.layer.masksToBounds = true
        self.profilePicture.layer.cornerRadius = 50


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
    
    func calculateTimeSpentDriving(totalTime: Double) -> String {
        var finalString: String?
        self.hoursFull = (Double(totalTime)/3600.0)
        
        print(self.hoursFull)
        
        if(hoursFull! > 23.999) {
            self.days = Int(hoursFull!/24.0)
            self.hoursFull = hoursFull! - (Double(days!) * 24.0)
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
