//
//  ViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/2/15.
//  Copyright © 2015 Astral. All rights reserved.
//
import Foundation
import UIKit
import Parse
import CoreLocation
import HealthKit
import Firebase

class ViewController: UIViewController {
    
    let ref = Firebase(url: "https://passenger-app.firebaseio.com")
    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users/")

    @IBOutlet weak var homeProfileLayout: UIView!
    @IBOutlet weak var rewardsButtonView: UIView!
    @IBOutlet weak var pointsHistoryButtonView: UIView!
    @IBOutlet weak var rewardsHistoryButtonView: UIView!
    @IBOutlet weak var usernameTextView: UILabel!
    @IBOutlet weak var totalPointsTextView: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    
    // User information
    
    var name = ""
    
    var seconds = 0.0
    var distance = 0.0
    
    var currentSpeed = 0.0
    
    var previousLocation: CLLocation?
    var currentLocation: CLLocation?
    
    var fullname: String = ""
    var currentPoints  = 0
    var totalPoints = 0
    var profilePictureString: String = ""
    var rewardsReceived: Int = 0
    var timeSpentDriving: Double = 0.0
    var email: String = ""
    var distanceTraveled: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        configureView()
        let gpsConvert = GpsCoordinateConverter()
        gpsConvert.gpsToAddress(36.8080762, longitude: -119.7274735) {
            (result: String) in
            print(result)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "homeToRewards") {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.topViewController as! RewardsDetailTableViewController
            dest.currentTitle = "DISCOUNTS"
            dest.rewardType = "Discounts"
        }
        
    }
    
    func configureView() {
        
        let prefs = NSUserDefaults.standardUserDefaults()
        
        self.fullname = prefs.stringForKey("name")!
        self.currentPoints = prefs.integerForKey("currentPoints")
        self.profilePictureString = prefs.stringForKey("profilePictureString")!
        
        self.usernameTextView.text = self.fullname
        self.totalPointsTextView.text = String(self.currentPoints)
        
        let decodedData = NSData(base64EncodedString: profilePictureString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        let decodedImage = UIImage(data: decodedData!)
        
        self.profilePictureView?.image = decodedImage
        self.profilePictureView.layer.masksToBounds = true
        self.profilePictureView.layer.cornerRadius = 33.33333
        
        let strDate = "2015-10-06T15:42:34Z" // "2015-10-06T15:42:34Z"
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let currentDate = NSDate()
        let currentDateString:String = dateFormatter.stringFromDate(currentDate)
        print("Here is the current date \(currentDateString)")
        
        let hexConverter = HexToUIColor()
        self.navigationController!.navigationBar.barTintColor = hexConverter.hexStringToUIColor("ffffff")
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
    }

}

