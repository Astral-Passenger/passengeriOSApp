//
//  RewardsHistoryCollectionViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/30/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit

private let reuseIdentifier = "rewardsHistoryCell"

class RewardsHistoryCollectionViewController: UICollectionViewController {
    
    var counter = 0
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    let transitionManager = MenuTransitionManager()
    
    private var statusBarBackground: UIView!
    
    var redeemedRewards = [Reward]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        loadRewards()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        
        self.collectionView!.dataSource = self
        
        self.transitionManager.sourceViewController = self
        
        // add to window rather than view controller
       
        UIApplication.sharedApplication().statusBarStyle = .Default

        // Do any additional setup after loading the view.
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
    
    func loadRewards() {
        let rewardsQuery = PFQuery(className:"RewardsHistory")
        if let user = PFUser.currentUser() {
            rewardsQuery.whereKey("userId", equalTo: user)
            rewardsQuery.orderByDescending("createdAt")
            rewardsQuery.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    print("Successfully retrieved \(objects!.count) rewards.")
                    if let objects = objects {
                        for object in objects {
                            let rewardImageFiles = object["rewardImage"] as! PFFile
                            var imageData = NSData()
                            do {
                                imageData = try rewardImageFiles.getData()
                            } catch {
                                print("There was a problem getting the data")
                            }
                            let reward = Reward()
                            reward.companyName = (object["companyName"] as? String)!
                            reward.pointCost = (object["pointCost"] as? Int)!
    
                            reward.rewardDescription = (object["rewardText"] as? String)!
                            reward.rewardName = object["rewardItem"] as! String
                            let rewardImage = UIImage(data: imageData)!
                            reward.rewardImage = rewardImage
                            self.redeemedRewards.append(reward)
                            self.collectionView!.reloadData()
                        }
                        self.collectionView!.reloadData()
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
            
        }
        
        
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
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return redeemedRewards.count
    }
    
    func collectionView(collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAtIndexPath indexPath: NSIndexPath!) -> CGSize {
        
        let collectionViewWidth = self.collectionView!.bounds.size.width
        return CGSize(width: collectionViewWidth/2, height: collectionViewWidth/2)
        
    }
    
    func collectionView(collectionView: UICollectionView!,layout collectionViewLayout: UICollectionViewLayout!,insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return sectionInsets
        
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> RewardsHistoryCollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! RewardsHistoryCollectionViewCell
        if (counter % 2 == 0) {
            cell.backgroundColor = UIColor.redColor()
        } else {
            cell.backgroundColor = UIColor.blueColor()
        }
        
        // Set cell width to 100%
        let reward = redeemedRewards[indexPath.row]
        print(reward.rewardDescription)
        
        cell.rewardDescriptionLabel.text = reward.rewardDescription
        cell.rewardPointCost.text = String(reward.pointCost)
        cell.rewardImage.image = reward.rewardImage
        cell.rewardNameLabel.text = reward.rewardName
        
        counter++
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
