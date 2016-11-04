//
//  AppDelegate.swift
//  Passenger
//
//  Created by Connor Myers on 11/2/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
import Bolts
import FBSDKCoreKit
import CoreLocation
import CoreMotion
import HealthKit

import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseInstanceID

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var ref: FIRDatabaseReference!
    
    let activityManager = CMMotionActivityManager()
    var window: UIWindow?
    
    // UsersInformation
    
    var usersName: String?
    var rewardsReceived: Int?
    var currentUserTotalPoints = 0.0
    var currentUserCurrentPoints = 0.0
    var currentUserCurrentDistance = 0.0
    var currentUserTimeSpentDriving = 0.0
    var profilePictureString: String?
    var usersEmail: String?
    var imageLocation: String?
    var imageData: NSData?
    var currentUserPointsList: NSArray?
    var currentUserPointsListAppended = [NSDictionary]()
    
    var userId = ""
    var email = ""
    
    var pointsPerMinute = 0.0055
    var pointsPerMile = 0.5
    
    var totalCurrentPoints = 0.0
    var phoneScreenIsOff = true
    var isDrivingSpeedLimit = true
    var everyTenSeconds = 0
    var distanceTraveledInTen = 0.0
    var checkingPhoneAndSpeed = true
    
    var currentSpeedIsZero = 0
    
    var isSittingStillCount = 0
    var isDriving = true
    var updatesAlreadyStarted = false
    var stoppedDriving = true
    var didUsePhoneAtStopLight = false
    
    var seconds = 0.0
    var distance = 0.0
    var secondsToAddToUser = 0.0
    
    var currentSpeed = 0.0
    var averageSpeedOverTen = 0.0
    
    var boolean: Bool?
    
    var previousLocation: CLLocation?
    var currentLocation: CLLocation?
    
    var reachable = Reachability()
    
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
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.Alert, .Badge, .Sound]
            let current = UNUserNotificationCenter.currentNotificationCenter()
            current.requestAuthorizationWithOptions(
                authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.currentNotificationCenter().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        FIRApp.configure()
        self.ref = FIRDatabase.database().reference()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        self.locationManager.requestAlwaysAuthorization()
        
        if(NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce"))
        {
            // app already launched

            UITabBar.appearance().tintColor = UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0)
            UITabBar.appearance().barTintColor = UIColor.whiteColor()
            
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            if let user = FIRAuth.auth()?.currentUser {
                
                // User is logged in
                
                let launchViewController = storyboard.instantiateViewControllerWithIdentifier("launchViewController")
                self.window?.rootViewController = launchViewController
                
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
        
        if (updatesAlreadyStarted == false) {
            updatesAlreadyStarted = true
            startLocationUpdates()
        }
       
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
            
        } else if (((everyTenSeconds % 10) == 0 && isLocked == false) && !isDriving && seconds > 1.0) {
            
            distanceTraveledInTen = 0
            //secondsToAddToUser += 10
            
        } else if(((everyTenSeconds % 10) == 0 && isLocked) && !isDriving && seconds > 1.0) {
            
            distanceTraveledInTen = 0
            //secondsToAddToUser += 10
            
        } else if(((everyTenSeconds % 10) == 0 && isLocked == false) && isDriving && seconds > 1.0) {
            
            distanceTraveledInTen = 0
            //secondsToAddToUser += 10
            
        }
    
        
        if ( isLocked == false && currentSpeed > 10) {
            
            
            if (checkingPhoneAndSpeed) {
                checkingPhoneAndSpeed = false
                let triggerTime = (Int64(NSEC_PER_SEC) * 5)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                    
                    if (self.currentSpeed < 10) {
                        // dont delete points
                    } else if (self.currentSpeed >= 10) {
                        // delete the points
                        self.totalCurrentPoints = 0
                        self.distance = 0
                        self.seconds = 0
                    }
                    self.checkingPhoneAndSpeed = true
                })
            }
            

            
        }

        seconds += 1
    
        if (distanceTraveledInTen < 50) {
            currentSpeed = 0.0
            isSittingStillCount += 1
            if (isSittingStillCount > 120 && stoppedDriving) {
                if (totalCurrentPoints > 0.9 && /* ref.authData != nil && */ self.userId != "" && self.reachable.isConnectedToNetwork()) {
                    self.isSittingStillCount = 0
                    self.stoppedDriving = true
                    
                    let date = NSDate()
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                    let dateToRecordString = dateFormatter.stringFromDate(date)
                    
                    let currentPointRecord: NSDictionary = ["distanceTraveled": ((distance * 3.28084) * 0.000189394), "pointsGenerated": totalCurrentPoints, "createdAt": dateToRecordString]
                    
                    if (self.currentUserPointsList != nil && self.currentUserPointsListAppended.count == 0) {
                        for (var i = 0; i < self.currentUserPointsList!.count; i++) {
                            self.currentUserPointsListAppended.append(self.currentUserPointsList![i] as! NSDictionary)
                        }
                    }
                    
                    self.currentUserPointsListAppended.append(currentPointRecord)
                    
                    if (self.currentUserPointsListAppended.count == 200) {
                        self.currentUserPointsListAppended.removeAtIndex(0)
                    }
                    
                    self.ref.child("users/\(userId)/pointsHistory").setValue(currentUserPointsListAppended)
                    
                    currentUserCurrentPoints = currentUserCurrentPoints + totalCurrentPoints
                    currentUserTotalPoints = currentUserTotalPoints + totalCurrentPoints
                    currentUserCurrentDistance = currentUserCurrentDistance + ((distance * 3.28084) * 0.000189394)
                    currentUserTimeSpentDriving = secondsToAddToUser + currentUserTimeSpentDriving
                    secondsToAddToUser = 0
                    

                    self.ref.child("users/\(userId)/currentPoints").setValue(currentUserCurrentPoints)
                    self.ref.child("users/\(userId)/totalPoints").setValue(currentUserTotalPoints)
                    self.ref.child("users/\(userId)/distanceTraveled").setValue(currentUserCurrentDistance)
                    self.ref.child("users/\(userId)/timeSpentDriving").setValue(currentUserTimeSpentDriving)
                    
                    self.totalCurrentPoints = 0
                    self.distance = 0.0
                    self.seconds = 0.0
   
                } else {
                    totalCurrentPoints = 0.0
                    self.distance = 0.0
                    self.seconds = 0.0
                }
                if (isSittingStillCount == 300) {
                    self.locationManager.stopUpdatingLocation()
                    updatesAlreadyStarted = false
                    self.isSittingStillCount = 0
                }
            } else if (isSittingStillCount > 9 && isLocked == false) {
                
                self.stoppedDriving = true
                self.didUsePhoneAtStopLight = true
                //print("The user used their phone while sitting at a stop light or right when they got out of the car")
                
            } else {
                // The user may be at a stop light or something.
                self.stoppedDriving = true
                
            }

            isDriving = false
        } else if (didUsePhoneAtStopLight) {
            self.totalCurrentPoints = 0
            isDriving = true
            self.stoppedDriving = false
            isSittingStillCount = 0
            //print(totalCurrentPoints)
            didUsePhoneAtStopLight = false
        } else {
            isDriving = true
            self.stoppedDriving = false
            isSittingStillCount = 0
            //print(totalCurrentPoints)
        }
        
//        print("Current speed: \(currentSpeed)")
//        print("Sitting still count: \(isSittingStillCount)")
//        print("Distance in 10: \(distanceTraveledInTen)")
        
        everyTenSeconds += 1
    }
    
    func startLocationUpdates() {
        // Here, the location manager will be lazily instantiated
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()) {
            case .NotDetermined, .Restricted, .Denied:
                presentLocationAlertAlways()
            case .AuthorizedWhenInUse:
                presentLocationAlertAlways()
            case .AuthorizedAlways: break
                // Nothing
            }
        } else {
            presentLocationAlertOn()
        }
        self.locationManager.startUpdatingLocation()
    }
    
    func presentLocationAlertOn() {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "Location", message: "Your location services are not on. Go to Settings/Privacy/Location Services to turn them on.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                (alert: UIAlertAction!) in
                    // self.sendUserToHome()
            }))
                
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func presentLocationAlertAlways() {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "Location", message: "Make sure the location service settings for Passenger Mobile are 'Always On'. Go to Settings/Privacy/ Location Services/Passenger to change the setting.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                (alert: UIAlertAction!) in
                    // self.sendUserToHome()
            }))
            self.window?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    func sendUserToHome() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let launchViewController = storyboard.instantiateViewControllerWithIdentifier("launchViewController")
        self.window?.rootViewController = launchViewController
    }
    
    func addScreenOffPoints() {
        
        // Calculate the points for the phone being off
        
        totalCurrentPoints = totalCurrentPoints + (10 * 0.0194)

    }
    

}
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    
    func userNotificationCenter(center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        
    }
    
}
extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("%@", remoteMessage.appData)
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
                        currentSpeed = (location.distanceFromLocation(self.locations.last!)) * 2.23694
                        distanceTraveledInTen = distanceTraveledInTen + currentDistance
                }
                
                //save location
                self.locations.append(location)
            }
        }
    }
}
