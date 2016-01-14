//
//  RankingViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/22/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit

class RankingViewController: UITableViewController {

    let sectionStrings: [String] = ["", "..."]
    var rankedUsers = [RankingUser]()
    var currentRanking = 1
    var currentUser: PFUser?
    var currentUserRanking: Int?
    var currentIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = PFUser.currentUser()
        configureView()
        
        let parentViewController = self.parentViewController
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "tmp-9.jpg")
        imageView.image = image
        parentViewController!.navigationItem.titleView = imageView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadUsers() {
        let query = PFQuery(className:"_User")
        query.orderByDescending("totalPoints")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        let newRankedUser = RankingUser()
                        newRankedUser.fullName = object["full_name"] as? String
                        newRankedUser.totalPoints = object["totalPoints"] as? Int
                        newRankedUser.ranking = String(self.currentRanking)
                        self.rankedUsers.append(newRankedUser)
                        if let email = object["email"] as? String {
                            if (email == self.currentUser?.email) {
                                self.currentUserRanking = self.currentRanking - 1
                                let indexPath: NSIndexPath = NSIndexPath(forRow: self.currentUserRanking!, inSection: 0)
                                self.currentIndexPath = indexPath
                                newRankedUser.isCurrentUser = true
                            } else {
                                newRankedUser.isCurrentUser = false
                            }
                        }
                        self.currentRanking++
                    }
                    self.tableView.reloadData()
                    self.tableView.scrollToRowAtIndexPath(self.currentIndexPath!, atScrollPosition: .Top, animated: true)
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
    }
    
    func configureView() {
        loadUsers()
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankedUsers.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("rankingsCell", forIndexPath: indexPath)
            as! RankingTableViewCell
        
        cell.totalPoints.text = "\(rankedUsers[indexPath.row].totalPoints!)"
        cell.userFullName.text = rankedUsers[indexPath.row].fullName!
        cell.currentRanking.text = rankedUsers[indexPath.row].ranking! + "."
        
        if (rankedUsers[indexPath.row].isCurrentUser!) {
            cell.backgroundColor = UIColor(red:0.04, green:0.37, blue:0.76, alpha:0.3)
        } else {
            cell.backgroundColor = UIColor.whiteColor()
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionStrings[section]
    }
    
    // MARK: - Table View Delegate Methods
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 14.0)
        }
        
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
