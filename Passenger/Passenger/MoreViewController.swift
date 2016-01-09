//
//  MoreViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/22/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit

class MoreViewController: UIViewController {

    @IBOutlet weak var helpSupportButton: UIButton!
    @IBOutlet weak var profileSettingsButton: UIButton!
    @IBOutlet weak var legalButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        PFUser.logOut()
    }
    
    @IBAction func settingButtonDown(sender: AnyObject) {
        settingsButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func settingsButtonUp(sender: AnyObject) {
        settingsButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func legalButtonDown(sender: AnyObject) {
        legalButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func legalButtonUp(sender: AnyObject) {
        legalButton.backgroundColor = UIColor.whiteColor()
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
        
        
    }

}
