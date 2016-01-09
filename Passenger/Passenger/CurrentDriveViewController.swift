//
//  CurrentDriveViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/10/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import Foundation
import UIKit
import Parse
import CoreLocation
import HealthKit

class CurrentDriveViewController: UIViewController {
    
    let transitionManager = MenuTransitionManager()
    
    @IBOutlet weak var currentDriveDistanceLabel: UILabel!
    @IBOutlet weak var currentDriveFinishButton: UIBarButtonItem!
    @IBOutlet weak var currentVelocityLabel: UILabel!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.transitionManager.sourceViewController = self
        
        configureView()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            let menu = segue.destinationViewController as! HomeNavigationViewController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView() {
        
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        let font2 = UIFont.systemFontOfSize(14, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary2: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font2
        ]
        
        currentDriveFinishButton.setTitleTextAttributes(navBarAttributesDictionary2, forState: UIControlState.Normal)
        
    }
    
}
