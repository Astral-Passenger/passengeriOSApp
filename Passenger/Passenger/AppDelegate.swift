//
//  AppDelegate.swift
//  Passenger
//
//  Created by Connor Myers on 11/2/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Bolts
import FBSDKCoreKit
import ParseFacebookUtilsV4
import CoreLocation
import CoreMotion
import HealthKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    let ref = Firebase(url: "https://passenger-app.firebaseio.com/")
    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users/")
    let activityManager = CMMotionActivityManager()
    var window: UIWindow?
    
    var currentUserPointsList: NSArray?
    var currentUserPointsListAppended = [NSDictionary]()
    
    var userId = ""

    var currentUser: PFUser?
    
    var pointsPerMinute = 0.0055
    var pointsPerMile = 0.5
    
    var totalCurrentPoints = 0.0
    var phoneScreenIsOff = true
    var isDrivingSpeedLimit = true
    var everyTenSeconds = 0
    var distanceTraveledInTen = 0.0
    
    var currentSpeedIsZero = 0
    
    var isSittingStillCount = 0
    var isDriving = true
    var updatesAlreadyStarted = false
    var stoppedDriving = true
    
    var seconds = 0.0
    var distance = 0.0
    var secondsToAddToUser = 0.0
    
    var currentSpeed = 0.0
    var averageSpeedOverTen = 0.0
    
    var boolean: Bool?
    
    var currentUserTotalPoints = 0.0
    var currentUserCurrentPoints = 0.0
    var currentUserCurrentDistance = 0.0
    var currentUserTimeSpentDriving = 0.0
    
    var previousLocation: CLLocation?
    var currentLocation: CLLocation?
    
    lazy var locationManager: CLLocationManager = {
        var _locationManager = CLLocationManager()
        _locationManager.delegate = self
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest
        _locationManager.requestAlwaysAuthorization()
        _locationManager.allowsBackgroundLocationUpdates = true
        _locationManager.activityType = .AutomotiveNavigation
        _locationManager.pausesLocationUpdatesAutomatically = false
        
        // Movement threshold for new events
        _locationManager.distanceFilter = 10.0
        return _locationManager
    }()
    
    lazy var locations = [CLLocation]()
    lazy var timer = NSTimer()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // [Optional] Power your app with Local Datastore. For more info, go to
        // https://parse.com/docs/ios_guide#localdatastore/iOS
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.locationManager.requestAlwaysAuthorization()
        
        // Initialize Parse.
        Parse.setApplicationId("kGhDAAyw5RwtYNrm70j8cYHlOPj60A9rnJ0UI0o1",
            clientKey: "JeIYcqqk1S8nNaJ1SChjSPemYlyxPbA8Z4p8CB8b")
        
        // [Optional] Track statistics around application opens.
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        if(NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce"))
        {
            // app already launched

            UITabBar.appearance().tintColor = UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0)
            UITabBar.appearance().barTintColor = UIColor.whiteColor()
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)

            if ref.authData != nil {
                // user authenticated
                let initialViewController = storyboard.instantiateViewControllerWithIdentifier("homeViewController")
                
                self.usersRef.queryOrderedByChild("email").queryEqualToValue("\(self.ref.authData.providerData["email"]!)")
                    .observeEventType(.ChildAdded, withBlock: { snapshot in

                        self.userId = snapshot.key
                        self.currentUserCurrentPoints = snapshot.value.objectForKey("currentPoints") as! Double!
                        self.currentUserTotalPoints = snapshot.value.objectForKey("totalPoints") as! Double!
                        self.currentUserTimeSpentDriving = snapshot.value.objectForKey("timeSpentDriving") as! Double!
                        self.currentUserCurrentDistance = snapshot.value.objectForKey("currentPoints") as! Double!
                        self.currentUserPointsList = snapshot.value.objectForKey("pointsHistory") as! NSArray!
                        
                    })
                
                self.window?.rootViewController = initialViewController
                
                // Need to comment the below until the database has been completely switched over to parse to get this data
                
            } else {
                // No user is signed in
                // Show the first screen
                let initialViewController = storyboard.instantiateViewControllerWithIdentifier("firstViewController")
                
                self.window?.rootViewController = initialViewController
                self.window?.makeKeyAndVisible()
            }
            
            seconds = 0.0
            distance = 0.0
            locations.removeAll(keepCapacity: false)
            timer = NSTimer.scheduledTimerWithTimeInterval(1,
                target: self,
                selector: "eachSecond:",
                userInfo: nil,
                repeats: true)
            startLocationUpdates()

        } else {
            
            // This is the first launch ever
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("firstLaunchViewController")
            
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
            seconds = 0.0
            distance = 0.0
            locations.removeAll(keepCapacity: false)
            timer = NSTimer.scheduledTimerWithTimeInterval(1,
                target: self,
                selector: "eachSecond:",
                userInfo: nil,
                repeats: true)
            startLocationUpdates()
        }

        return true
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    
    
    //Make sure it isn't already declared in the app delegate (possible redefinition of func error)
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {

    }

    func applicationWillEnterForeground(application: UIApplication) {

        if (currentUser != nil) {
            self.currentUser?.fetchInBackground()
        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        if (totalCurrentPoints > 0.75) {
            
            if (ref.authData != nil) {
            
                let date = NSDate()
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                let dateToRecordString = dateFormatter.stringFromDate(date)
                
                let currentPointRecord: NSDictionary = ["distanceTraveled": distance * 0.000189394, "pointsGenerated": totalCurrentPoints, "createdAt": dateToRecordString]
                
                if (self.currentUserPointsList != nil && self.currentUserPointsListAppended.count == 0) {
                    for (var i = 0; i < self.currentUserPointsList!.count; i++) {
                        self.currentUserPointsListAppended.append(self.currentUserPointsList![i] as! NSDictionary)
                    }
                }
                
                self.currentUserPointsListAppended.append(currentPointRecord)
                usersRef.childByAppendingPath("\(userId)/pointsHistory").setValue(currentPointRecord)
                
                currentUserCurrentPoints = currentUserCurrentPoints + totalCurrentPoints
                currentUserTotalPoints = currentUserTotalPoints + totalCurrentPoints
                currentUserCurrentDistance = currentUserCurrentDistance + ((distance * 3.28084) * 0.000189394)
                currentUserTimeSpentDriving = secondsToAddToUser + currentUserTimeSpentDriving
                
                usersRef.childByAppendingPath("\(userId)/currentPoints").setValue(currentUserCurrentPoints)
                usersRef.childByAppendingPath("\(userId)/totalPoints").setValue(currentUserTotalPoints)
                usersRef.childByAppendingPath("\(userId)/distanceTraveled").setValue(currentUserCurrentDistance)
                usersRef.childByAppendingPath("\(userId)/timeSpentDriving").setValue(currentUserTimeSpentDriving)
            }
        }
        
    }

    func eachSecond(timer: NSTimer) {
        
        let instanceOfCustomObject: Notifier = Notifier()
        instanceOfCustomObject.registerAppforDetectLockState()
        let isLocked = instanceOfCustomObject.isLocked()
        
        if (((everyTenSeconds % 10) == 0 && isLocked) && isDriving && seconds > 1.0) {
        
            self.addScreenOffPoints()
            phoneScreenIsOff = true
            distanceTraveledInTen = 0
            secondsToAddToUser += 10
            
        } else if (isLocked == false) {
            self.totalCurrentPoints = 0
            self.distance = 0
            self.seconds = 0
        }

        seconds += 1
        
        if (distanceTraveledInTen < 50) {
            currentSpeed = 0.0
            isSittingStillCount += 1
            if (isSittingStillCount > 120 && stoppedDriving) {
                if (totalCurrentPoints > 0.75 && ref.authData != nil) {
                    self.isSittingStillCount = 0
                    self.stoppedDriving = true
                    
                    let date = NSDate()
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let dateToRecordString = dateFormatter.stringFromDate(date)
                    
                    let currentPointRecord: NSDictionary = ["distanceTraveled": distance * 0.000189394, "pointsGenerated": totalCurrentPoints, "createdAt": dateToRecordString]
                    
                    if (self.currentUserPointsList != nil && self.currentUserPointsListAppended.count == 0) {
                        for (var i = 0; i < self.currentUserPointsList!.count; i++) {
                            self.currentUserPointsListAppended.append(self.currentUserPointsList![i] as! NSDictionary)
                        }
                    }
                    
                    self.currentUserPointsListAppended.append(currentPointRecord)
                    
                    usersRef.childByAppendingPath("\(userId)/pointsHistory").setValue(currentUserPointsListAppended)
                    
                    currentUserCurrentPoints = currentUserCurrentPoints + totalCurrentPoints
                    currentUserTotalPoints = currentUserTotalPoints + totalCurrentPoints
                    currentUserCurrentDistance = currentUserCurrentDistance + ((distance * 3.28084) * 0.000189394)
                    currentUserTimeSpentDriving = secondsToAddToUser + currentUserTimeSpentDriving
                    
                    usersRef.childByAppendingPath("\(userId)/currentPoints").setValue(currentUserCurrentPoints)
                    usersRef.childByAppendingPath("\(userId)/totalPoints").setValue(currentUserTotalPoints)
                    usersRef.childByAppendingPath("\(userId)/distanceTraveled").setValue(currentUserCurrentDistance)
                    usersRef.childByAppendingPath("\(userId)/timeSpentDriving").setValue(currentUserTimeSpentDriving)
                    
                    let prefs = NSUserDefaults.standardUserDefaults()
                    
                    prefs.setValue(self.currentUserCurrentPoints, forKey: "currentPoints")
                    prefs.setValue(currentUserTotalPoints, forKey: "totalPoints")
                    prefs.setValue(currentUserTimeSpentDriving, forKey: "timeSpentDriving")
                    prefs.setValue(currentUserCurrentDistance, forKey: "distanceTraveled")
                    
                    self.totalCurrentPoints = 0
                    self.distance = 0.0
                    self.seconds = 0.0
   
                } else {
                    totalCurrentPoints = 0.0
                }
                
            } else {
                // The user may be at a stop light or something.
                self.stoppedDriving = true
            }
            isDriving = false
        } else {
            isDriving = true
            self.stoppedDriving = false
            isSittingStillCount = 0
            print(totalCurrentPoints)
        }
        
        print("Current speed: \(currentSpeed)")
        print("Current Distance: \(distanceTraveledInTen)")
        //print("Is Driving: \(isDriving)")
        //print(isLocked)
        
        everyTenSeconds += 1
    }
    
    func startLocationUpdates() {
        //self.locationManager.startUpdatingLocation()
        // Here, the location manager will be lazily instantiated
        
        self.activityManager.startActivityUpdatesToQueue(NSOperationQueue.mainQueue()) { data in
            if let data = data {
                dispatch_async(dispatch_get_main_queue()) {
                    if(data.stationary == true && self.updatesAlreadyStarted && self.isSittingStillCount > 120){
                        print("Stationary: Location updating in the background has been stopped until the user drives again.")
                        self.updatesAlreadyStarted = false
                        self.locationManager.stopUpdatingLocation()
                    } else if (data.walking == true) {
                        print("Walking")
                    } else if (data.automotive == true && self.updatesAlreadyStarted == false && (self.isSittingStillCount > 120 || self.isSittingStillCount == 0)){
                        print("Driving: The location updating has been started and wont stop until the user is stationary again.")
                        self.updatesAlreadyStarted = true
                        self.locationManager.startUpdatingLocation()
                    }
                }
            }
        }
    }
    
    func addScreenOffPoints() {
        
        // Calculate the points for the phone being off
        
        totalCurrentPoints = totalCurrentPoints + (10 * 0.025)

    }
    
    
}
// MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations as [CLLocation] {
            if location.horizontalAccuracy < 20 {
                //update distance
                if self.locations.count > 0 {
                    distance += location.distanceFromLocation(self.locations.last!)
                    let currentDistance = location.distanceFromLocation(self.locations.last!)
                    print(currentDistance)
                        currentSpeed = (location.distanceFromLocation(self.locations.last!)) * 2.23694
                        distanceTraveledInTen = distanceTraveledInTen + currentDistance
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
}

