//
//  RewardsDetailTableViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/24/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Parse

class RewardsDetailTableViewController: UITableViewController {
    
    let cellIdentifier = "rewardsDetailedCell"
    
    let transitionManager = MenuTransitionManager()
    
    var currentTitle: String?
    var rewardType: String?
    
    var company: PFObject?
    
    private var companyName: String?
    
    var rewardsList = [RewardGroup]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSampleProducts()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        configureView()
        
        self.transitionManager.sourceViewController = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // set transition delegate for our menu view controller
        if(segue.identifier == "presentMenu") {
            let menu = segue.destinationViewController as! UINavigationController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        } else {
            let nav = segue.destinationViewController as! UINavigationController
            let dest = nav.topViewController as! DiscountCollectionViewController
            dest.companyName = companyName
            dest.company = company
        }

    }
    
    func configureView() {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        // Change the font and size of nav bar text
        
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        self.title = currentTitle
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSampleProducts() {
        
        let query = PFQuery(className:"Rewards")
        query.fromLocalDatastore()
        query.whereKey("rewardType", equalTo: rewardType!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) rewards.")
                // Do something with the found objects gameScore["playerName"] as String
                var i = 0
                if let objects = objects {
                    for object in objects {
                        var imageData = NSData()
                        let rewardImageFiles = object["companyImage"] as! PFFile
                        
                        do {
                            imageData = try rewardImageFiles.getData()
                        } catch {
                            print("There was a problem getting the data")
                        }
                        
                        let companyImage = UIImage(data: imageData)!
                        let rewardGroup = RewardGroup(rewardType: object["rewardType"] as! String, companyName: object["companyName"] as! String, backgroundImage: companyImage, crossStreets: object["crossStreets"] as! String, company: object)
                        self.rewardsList.append(rewardGroup)
                        self.tableView.reloadData()
                        
                        i = i + 1
                    }
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        self.tableView.reloadData()
    }
    
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rewardsList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let currentCompany = rewardsList[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
            as! PointsDetailedTableViewCell
        
        cell.rewardCompanyName.text = currentCompany.getCompanyName()
        cell.rewardCompanyBackgroundImage.image = currentCompany.getBackgroundImage()
        cell.crossStreetsLabel.text = currentCompany.getCrossStreets()
        
        cell.rewardCompanyBackgroundImage.layer.masksToBounds = true
        cell.rewardCompanyBackgroundImage.layer.cornerRadius = 2

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        companyName = rewardsList[indexPath.row].getCompanyName()
        company = rewardsList[indexPath.row].getCompany()
        performSegueWithIdentifier("rewardsToDiscounts", sender: nil)
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


}
