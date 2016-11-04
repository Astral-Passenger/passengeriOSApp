//
//  RewardsDetailTableViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/24/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import CoreLocation

class RewardsDetailTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    
    weak var activityIndicatorView: UIActivityIndicatorView!
    
    let cellIdentifier = "rewardsDetailedCell"
    
    let transitionManager = MenuTransitionManager()
    
    var currentTitle: String?
    var rewardType: String?
    
    var currentLongitude: Double?
    var currentLatitude: Double?

    var rewards: NSArray?
    var companyImage: UIImage?
    
    private var companyName: String?
    private var merchantEmail: String?
    private var merchantLatitude: Double?
    private var currentMerchantIndex: Int?
    
    var rewardsList = [RewardGroup]()
    
    override func viewDidAppear(animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ""
        definesPresentationContext = true
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        tableView.backgroundView = activityIndicatorView
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.activityIndicatorView = activityIndicatorView

        
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        var currentLocation = CLLocation()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways){
            
            currentLocation = locManager.location!
        
        }
        
        currentLongitude = currentLocation.coordinate.longitude
        currentLatitude = currentLocation.coordinate.latitude

        configureView()
        
        loadSampleProducts()
        
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
            dest.merchantEmail = merchantEmail!
            dest.rewards = rewards!
            dest.companyImage = companyImage
            dest.merchantLatitude = self.merchantLatitude
            dest.currentMerchantIndex = self.currentMerchantIndex
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
        
        let gpsConvert = GpsCoordinateConverter()
        gpsConvert.gpsToCityState(self.currentLatitude!, longitude: self.currentLongitude!) {
            (result: String) in
            self.title = result
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var processGroup = dispatch_group_create()
    
    func loadMerchantData(snapshotAtIndex: AnyObject, currentIndex: Int) {
        let imageLocation = snapshotAtIndex.objectForKey("imageLocation") as! String
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("\(imageLocation)")
        dispatch_group_enter(self.processGroup)
        storageRef.dataWithMaxSize(1 * 3000 * 3000) { (data, error) -> Void in
            if (error != nil) {
                // Uh-oh, an error occurred!
                print(error)
                
            } else {
                let decodedData = data
                let decodedImage = UIImage(data: decodedData!)
                let rewardGroup  = RewardGroup(
                    rewardType: "Discount",
                    companyName: snapshotAtIndex.objectForKey("companyName") as! String,
                    backgroundImage: decodedImage!,
                    crossStreets: snapshotAtIndex.objectForKey("crossStreets") as! String,
                    sixDigitIdentifier: snapshotAtIndex.objectForKey("sixDigitIdentifier") as! Int,
                    rewards: snapshotAtIndex.objectForKey("rewards") as! NSArray,
                    distanceToLocation: self.checkDistance(snapshotAtIndex.objectForKey("latitude") as! Double, longitude: snapshotAtIndex.objectForKey("longitude") as! Double),
                    merchantEmail: snapshotAtIndex.objectForKey("email") as! String,
                    merchantLatitude: snapshotAtIndex.objectForKey("latitude") as! Double,
                    currentMerchantIndex: currentIndex
                )
                
                self.rewardsList.append(rewardGroup)
                self.sortData()
            }
            dispatch_group_leave(self.processGroup)
        }
    }
    
    func loadSampleProducts() {
        self.activityIndicatorView.startAnimating()
        let reachable = Reachability()
        if !(reachable.isConnectedToNetwork()) {
            var emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            emptyLabel.text = "No internet connection"
            emptyLabel.textAlignment = NSTextAlignment.Center
            let hexChanger = HexToUIColor()
            emptyLabel.textColor = hexChanger.hexStringToUIColor("#5c5c5c")
            self.tableView!.backgroundView = emptyLabel
        } else {
            self.ref = FIRDatabase.database().reference()
            ref.child("merchants").observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                for (var i = 0; i < snapshot.value!.count; i++) {
                    if (self.checkDistance(snapshot.value!.objectAtIndex(i).objectForKey("latitude") as! Double, longitude: snapshot.value!.objectAtIndex(i).objectForKey("longitude") as! Double) <= 25) {
                        
                        self.loadMerchantData(snapshot.value!.objectAtIndex(i), currentIndex: i)
                    } else {
                    }
                }
                dispatch_group_notify(self.processGroup, dispatch_get_main_queue()) {
                    if (self.rewardsList.count == 0 ) {
                        var emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                        emptyLabel.text = "Currently no rewards in your area."
                        emptyLabel.textAlignment = NSTextAlignment.Center
                        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                        let hexChanger = HexToUIColor()
                        emptyLabel.textColor = hexChanger.hexStringToUIColor("#5c5c5c")
                        self.tableView.backgroundView = emptyLabel
                    } else {
                        self.tableView.reloadData()
                        self.activityIndicatorView.hidden = true
                    }
                }
            })
            
        }

    }
    
    func sortData() {
        var smallestIndex = 0
        for (var i = 0; i < self.rewardsList.count; i++) {
            smallestIndex = i
            for (var j = i; j < self.rewardsList.count; j++) {
                if (self.rewardsList[j].getDistance() < self.rewardsList[smallestIndex].getDistance()) {
                    smallestIndex = j
                }
            }
            let tempReward = self.rewardsList[i]
            self.rewardsList[i] = self.rewardsList[smallestIndex]
            self.rewardsList[smallestIndex] = tempReward
        }

    }
    
    func checkDistance(latitude: Double, longitude: Double) -> Double {
        let checkCoordinate = CLLocation(latitude: latitude, longitude: longitude)
        let currentCoordinate = CLLocation(latitude: self.currentLatitude!, longitude: self.currentLongitude!)
        
        let distanceInMiles = (checkCoordinate.distanceFromLocation(currentCoordinate))/1609
        return distanceInMiles
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
        let divisor = pow(10.0, Double(1))
        let distance = round(currentCompany.getDistance() * divisor) / divisor
        cell.distanceLabel.text = "\(distance)"
        
        cell.rewardCompanyBackgroundImage.layer.masksToBounds = true
        cell.rewardCompanyBackgroundImage.layer.cornerRadius = 2

        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        companyName = rewardsList[indexPath.row].getCompanyName()
        rewards = rewardsList[indexPath.row].getRewards()
        companyImage = rewardsList[indexPath.row].getBackgroundImage()
        merchantEmail = rewardsList[indexPath.row].getMerchantEmail()
        merchantLatitude = rewardsList[indexPath.row].getLatitude()
        currentMerchantIndex = rewardsList[indexPath.row].getMerchantIndex()
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
