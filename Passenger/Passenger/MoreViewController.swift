//
//  MoreViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/22/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Firebase
import Bolts

class MoreViewController: UIViewController {
    
    let ref = Firebase(url: "https://passenger-app.firebaseio.com")

    @IBOutlet weak var helpSupportButton: UIButton!
    @IBOutlet weak var profileSettingsButton: UIButton!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var currentUserNameLabel: UILabel!
    
    private var currentUser: PFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //currentUser = PFUser.currentUser()
        
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Handling the button click events to give them nice backgrounds when tapped on.
    
    @IBAction func profileSettingsUp(sender: AnyObject) {
        profileSettingsButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func profileSettingsDown(sender: AnyObject) {
        profileSettingsButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    @IBAction func logOutUser(sender: AnyObject) {
        ref.unauth()
    }

    @IBAction func helpButtonDown(sender: AnyObject) {
        helpSupportButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func helpButtonUp(sender: AnyObject) {
        helpSupportButton.backgroundColor = UIColor.whiteColor()
    }
    
    func configureView() {
        helpSupportButton.adjustsImageWhenHighlighted = true;
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            
//            if let profileImage = self.currentUser!["profile_picture"] as? PFFile {
//                profileImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
//                    let image: UIImage! = UIImage(data: imageData!)!
//                    self.profilePicture?.image = image
//                    self.profilePicture.layer.masksToBounds = true
//                    self.profilePicture.layer.cornerRadius = 20
//                })
//            }
//            
//        }
//        
//        let userFullName = self.currentUser!["full_name"] as! String
//        
//        self.currentUserNameLabel.text = userFullName
        
    }

}
