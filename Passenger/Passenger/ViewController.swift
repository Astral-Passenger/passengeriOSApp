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

class ViewController: UIViewController {

    @IBOutlet weak var homeProfileLayout: UIView!
    @IBOutlet weak var rewardsButtonView: UIView!
    @IBOutlet weak var pointsHistoryButtonView: UIView!
    @IBOutlet weak var rewardsHistoryButtonView: UIView!
    @IBOutlet weak var usernameTextView: UILabel!
    @IBOutlet weak var totalPointsTextView: UILabel!
    @IBOutlet weak var profilePictureView: UIImageView!
    
    var currentUser: PFUser?
    
    var seconds = 0.0
    var distance = 0.0
    
    var currentSpeed = 0.0
    
    var previousLocation: CLLocation?
    var currentLocation: CLLocation?
    
    override func viewDidLoad() {
        checkUser()
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
        let hexConverter = HexToUIColor()
        self.navigationController!.navigationBar.barTintColor = hexConverter.hexStringToUIColor("ffffff")
        // Change the font and size of nav bar text
        /*
            let navBarAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor.whiteColor(),
            ] */
        /*
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        navigationController?.view.backgroundColor = UIColor.clearColor()
        */
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        let currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            let fullName = currentUser!["full_name"] as! String
            usernameTextView.text = fullName
            let currentPoints = currentUser!["currentPoints"] as! Int
            totalPointsTextView.text = String(currentPoints)
            
            let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
            
            
            let navBarAttributesDictionary: [String: AnyObject]? = [
                NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
                NSFontAttributeName: font
            ]
            //navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
            
            navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                
                if let profileImage = currentUser!["profile_picture"] as? PFFile {
                    profileImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                        let image: UIImage! = UIImage(data: imageData!)!
                        self.profilePictureView?.image = image
                        self.profilePictureView.layer.masksToBounds = true
                        self.profilePictureView.layer.cornerRadius = 33.33333
                    })
                }
                
            }
        } else {
            // Show the signup or login screen
            performSegueWithIdentifier("signOutUser", sender: nil)
        }

    }
    
    func checkUser () {
        currentUser = PFUser.currentUser()
        if currentUser != nil {
            // Do stuff with the user
            
        } else {
            // Show the signup or login screen
            performSegueWithIdentifier("signOutUser", sender: nil)
        }
    }


}

