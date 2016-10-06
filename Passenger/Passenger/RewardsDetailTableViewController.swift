//
//  RewardsDetailTableViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/24/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Firebase

class RewardsDetailTableViewController: UITableViewController {
    
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    let cellIdentifier = "rewardsDetailedCell"
    
    let transitionManager = MenuTransitionManager()
    
    var currentTitle: String?
    var rewardType: String?
    
    var currentLongitude: Double?
    var currentLatitude: Double?
    
    var rewardsRef = Firebase(url:"https://passenger-app.firebaseio.com/rewards/")
    var rewards: NSArray?
    var companyImage: UIImage?
    
    private var companyName: String?
    
    var rewardsList = [RewardGroup]()
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.activityIndicatorView = activityIndicatorView

        
        var locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.Authorized){
            
            currentLocation = locManager.location!
            
        }
        
        currentLongitude = currentLocation.coordinate.longitude
        currentLatitude = currentLocation.coordinate.latitude
        configureView()
        
        if (-119.533779 > currentLongitude && currentLongitude > -120.001937 && 36.917322 > currentLatitude && currentLatitude > 36.660517) {
            activityIndicatorView.startAnimating()
            loadSampleProducts()
        } else {
            
            let alertController = UIAlertController(title: "Passenger", message: "We currently only offer rewards in Fresno, CA. We will soon be expanding to more cities around the United States so stay tuned. If you want to recommend your city send us an email through our website and we will get your city on board as soon as possible!", preferredStyle: .Alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(defaultAction)
            
            let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
            dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                // your function here
                self.presentViewController(alertController, animated: true, completion: self.completePopUp)
            })
            
        }
        
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        self.transitionManager.sourceViewController = self
    }
    
    func completePopUp() {
        performSegueWithIdentifier("presentMenu", sender: nil)
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
            dest.rewards = rewards!
            dest.companyImage = companyImage
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
        
        self.title = "Fresno, CA"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadSampleProducts() {
        
        let reachable = Reachability()
        if !(reachable.isConnectedToNetwork()) {
            var emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            emptyLabel.text = "No internet connection"
            emptyLabel.textAlignment = NSTextAlignment.Center
            let hexChanger = HexToUIColor()
            emptyLabel.textColor = hexChanger.hexStringToUIColor("#5c5c5c")
            self.tableView!.backgroundView = emptyLabel
        } else {
            rewardsRef.observeEventType(.Value, withBlock: { snapshot in
                for (var i = 0; i < snapshot.value.count; i++) {
                    let info = snapshot.value.objectAtIndex(i).objectForKey("companyImage") as! String
                    let decodedData = NSData(base64EncodedString: info, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                    let decodedImage = UIImage(data: decodedData!)
                    let data = snapshot.value.objectAtIndex(i).objectForKey("rewards")
                    let rewardGroup  = RewardGroup(
                        rewardType: "Discount",
                        companyName: snapshot.value.objectAtIndex(i).objectForKey("companyName") as! String,
                        backgroundImage: decodedImage!,
                        crossStreets: snapshot.value.objectAtIndex(i).objectForKey("crossStreets") as! String,
                        sixDigitIdentifier: snapshot.value.objectAtIndex(i).objectForKey("sixDigitIdentifier") as! Int,
                        rewards: snapshot.value.objectAtIndex(i).objectForKey("rewards") as! NSArray)
                    self.rewardsList.append(rewardGroup)
                    self.tableView.reloadData()
                }
                self.activityIndicatorView.hidden = true
                }, withCancelBlock: { error in
                    print(error.description)
            })
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
        rewards = rewardsList[indexPath.row].getRewards()
        companyImage = rewardsList[indexPath.row].getBackgroundImage()
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
