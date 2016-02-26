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
    
    var currentUser: PFUser?
    
    var seconds = 0.0
    var distance = 0.0
    
    var currentSpeed = 0.0
    
    var previousLocation: CLLocation?
    var currentLocation: CLLocation?
    
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
        let hexConverter = HexToUIColor()
        self.navigationController!.navigationBar.barTintColor = hexConverter.hexStringToUIColor("ffffff")
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        usersRef.queryOrderedByChild("email").queryEqualToValue("\(ref.authData.providerData["email"]!)")
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                let fullName = snapshot.value["name"] as! String!
                let currentPoints = snapshot.value["totalPoints"] as! Int
                self.usernameTextView.text = fullName
                self.totalPointsTextView.text = String(currentPoints)
                print("This is the key of the snapshot \(snapshot.value["profileImage"])")
                let info = snapshot.value["profileImage"] as! String!
                print(info)
        })
        
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        //navigationController?.navigationBar.backgroundColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary

//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//                
//                if let profileImage = currentUser!["profile_picture"] as? PFFile {
//                    profileImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
//                        let image: UIImage! = UIImage(data: imageData!)!
//                        self.profilePictureView?.image = image
//                        self.profilePictureView.layer.masksToBounds = true
//                        self.profilePictureView.layer.cornerRadius = 33.33333
//                    })
//                }
//                
//            }
//        }

    }


}

