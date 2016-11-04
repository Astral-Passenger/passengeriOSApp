//
//  RewardsViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/10/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RewardsViewController: UIViewController {
    
    let transitionManager = MenuTransitionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureView()
        
        self.transitionManager.sourceViewController = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "idRewardDetailGiftcards") {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.topViewController as! RewardsDetailTableViewController
            dest.currentTitle = "GIFTCARDS"
            dest.rewardType = "Giftcard"
        } else if(segue.identifier == "idRewardsDetailProducts") {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.topViewController as! RewardsDetailTableViewController
            dest.currentTitle = "DISCOUNTS"
            dest.rewardType = "Discounts"
        } else if(segue.identifier == "idRewardsDetailSweepstakes") {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.topViewController as! RewardsDetailTableViewController
            dest.currentTitle = "SWEEPSTAKES"
            dest.rewardType = "Sweepstakes"
        } else if(segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            let menu = segue.destinationViewController as! HomeNavigationViewController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        } else if (segue.identifier == "dismissMenu") {
            let menu = segue.destinationViewController as! HomeNavigationViewController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        }
        
    }
    
    func configureView() {
        // Change the font and size of nav bar text
        
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

