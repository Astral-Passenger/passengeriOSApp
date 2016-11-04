//
//  RewardsHistoryCollectionViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/30/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "rewardsHistoryCell"

class RewardsHistoryCollectionViewController: UICollectionViewController {
    
    var ref: FIRDatabaseReference!
    
    var counter = 0
    let sectionInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    
    var senderViewController: String?
    
    let transitionManager = MenuTransitionManager()
    
    var rewardsHistory: NSArray?
    
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
            if (senderViewController == "Rewards") {
                let menu = segue.destinationViewController as! HomeNavigationViewController
                let targetController = menu.topViewController as! HomeViewController
                targetController.profile = true
                menu.transitioningDelegate = self.transitionManager
                self.transitionManager.menuViewController = menu
            } else {
                let menu = segue.destinationViewController as! HomeNavigationViewController
                menu.transitioningDelegate = self.transitionManager
                self.transitionManager.menuViewController = menu
            }
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadRewards() {
        
        let reachable = Reachability()
        if !(reachable.isConnectedToNetwork()) {
            var emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            emptyLabel.text = "No internet connection"
            emptyLabel.textAlignment = NSTextAlignment.Center
            let hexChanger = HexToUIColor()
            emptyLabel.textColor = hexChanger.hexStringToUIColor("#5c5c5c")
            self.collectionView!.backgroundView = emptyLabel
        } else {
            let userID = FIRAuth.auth()?.currentUser?.uid
            print(self.redeemedRewards.count)
            self.ref = FIRDatabase.database().reference()
            ref.child("users").child(userID!).observeSingleEventOfType(.Value, withBlock: { (snapshot) in
                if let rewardsHistory = snapshot.value!.objectForKey("rewardsHistory") as? NSArray {

                    self.rewardsHistory = rewardsHistory

                    for(var i = self.rewardsHistory!.count - 1; i >= 0; i--) {
                        let imageString = self.rewardsHistory!.objectAtIndex(i).objectForKey("rewardImage") as! String
                        let decodedData = NSData(base64EncodedString: imageString, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                        let decodedImage = UIImage(data: decodedData!)
                        let reward = Reward()
                        reward.companyName = self.rewardsHistory!.objectAtIndex(i).objectForKey("companyName") as! String
                        reward.pointCost = self.rewardsHistory!.objectAtIndex(i).objectForKey("pointCost") as! Int
                        reward.rewardDescription = self.rewardsHistory!.objectAtIndex(i).objectForKey("rewardText") as! String
                        reward.rewardName = self.rewardsHistory!.objectAtIndex(i).objectForKey("rewardItem") as! String
                        reward.rewardImage = decodedImage
                        self.redeemedRewards.append(reward)
                        self.collectionView!.reloadData()

                    }
                } else {
                    // The user does not yet have any rewards that they have redeemed yet.
                    var emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                    emptyLabel.text = "You have not redeemed any rewards yet."
                    emptyLabel.textAlignment = NSTextAlignment.Center
                    let hexChanger = HexToUIColor()
                    emptyLabel.textColor = hexChanger.hexStringToUIColor("#5c5c5c")
                    self.collectionView!.backgroundView = emptyLabel
                }

            })
            collectionView?.reloadData()
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
        return CGSize(width: (collectionViewWidth/2) - 1.0, height: collectionViewWidth/2)
        
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
