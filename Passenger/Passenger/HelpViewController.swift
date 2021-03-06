//
//  HelpViewController.swift
//  Passenger
//
//  Created by Connor Myers on 12/16/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    
    let transitionManager = MenuTransitionManager()

    @IBOutlet weak var accountButton: UIButton!
    @IBOutlet weak var howButton: UIButton!
    @IBOutlet weak var whereButton: UIButton!
    @IBOutlet weak var rewardsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureView()
        self.transitionManager.sourceViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            let menu = segue.destinationViewController as! HomeNavigationViewController
            let targetController = menu.topViewController as! HomeViewController
            targetController.helpSupport = true
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        } else if (segue.identifier == "helpToExpandedAccount") {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let targetController = destinationViewController.topViewController as! HelpExpandedTableViewController
            targetController.helpTitle = "ACCOUNT"
            targetController.questionType = "Account"
        } else if (segue.identifier == "helpToExpandedHow") {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let targetController = destinationViewController.topViewController as! HelpExpandedTableViewController
            targetController.helpTitle = "HOW TO USE PASSENGER"
            targetController.questionType = "How"
        } else if (segue.identifier == "helpToExpandedWhere") {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let targetController = destinationViewController.topViewController as! HelpExpandedTableViewController
            targetController.helpTitle = "WHERE TO USE PASSENGER"
            targetController.questionType = "Where"
        } else if (segue.identifier == "helpToExpandedRewards") {
            let destinationViewController = segue.destinationViewController as! UINavigationController
            let targetController = destinationViewController.topViewController as! HelpExpandedTableViewController
            targetController.helpTitle = "REWARDS"
            targetController.questionType = "Rewards"
        }
    }
    
    @IBAction func accountDown(sender: AnyObject) {
        accountButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func accountUp(sender: AnyObject) {
        accountButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func howDown(sender: AnyObject) {
        howButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func howUp(sender: AnyObject) {
        howButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func whereDown(sender: AnyObject) {
        whereButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func whereUp(sender: AnyObject) {
        whereButton.backgroundColor = UIColor.whiteColor()
    }
    
    @IBAction func rewardsDown(sender: AnyObject) {
        rewardsButton.backgroundColor = UIColor(red:0.89, green:0.89, blue:0.89, alpha:1.0)
    }
    
    @IBAction func rewardsUp(sender: AnyObject) {
        rewardsButton.backgroundColor = UIColor.whiteColor()
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
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
