//
//  SignInViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/13/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth
import FirebaseStorage

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    var ref: FIRDatabaseReference!
    
    let transitionManager = MenuTransitionManager()
    let facebookLogin = FBSDKLoginManager()
    
    var fullName: String?
    var username: String?
    var currentPoints: Double?
    var totalPoints: Double?
    var profilePictureString: String?
    var rewardsReceived: Int?
    var timeSpentDriving: Double?
    var email: String?
    var distanceTraveled: Double?
    var rewardsList: NSArray?
    var currentUserPointsList: NSArray?
    var userExists: Bool = false
    var firebaseUserId: String?
    var kbHeight: CGFloat!
    var imageLocation: String?
    var imageData: NSData?
    
    var base64String: NSString!
    var uidToSave: String?

    @IBOutlet weak var usernameTextViewField: UIView!
    @IBOutlet weak var passwordTextViewField: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInBackground: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    var imageList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        startAnimation()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.transitionManager.sourceViewController = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    override func viewWillAppear(animated:Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = 0
                self.animateTextField(true)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.animateTextField(false)
    }
    
    func animateTextField(up: Bool) {
        var movement = (up ? -kbHeight : kbHeight)
        
        UIView.animateWithDuration(0.3, animations: {
            //self.view.frame = CGRectOffset(self.view.frame, 0, movement)
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            let menu = segue.destinationViewController as! FirstScreenViewController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        } else if(segue.identifier == "signInSegue") {
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.profilePictureString = self.profilePictureString
            appDelegate.usersName = self.fullName
            appDelegate.currentUserCurrentPoints = self.currentPoints!
            appDelegate.currentUserTotalPoints = self.totalPoints!
            appDelegate.rewardsReceived = self.rewardsReceived
            appDelegate.currentUserTimeSpentDriving = self.timeSpentDriving!
            appDelegate.currentUserCurrentDistance = self.distanceTraveled!
            appDelegate.imageData = self.imageData!
            appDelegate.imageLocation = self.imageLocation!
            if (self.currentUserPointsList != nil) {
                appDelegate.currentUserPointsList = self.currentUserPointsList!
            }

        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
        self.loadingView.hidden = true
        self.activityIndicator.hidden = true
        self.activityIndicator.stopAnimating()
    }
    
    func configureView() {
        activityIndicator.hidden = true
        // Change the font and size of nav bar text
        
        // Change the font and size of nav bar text
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
        ]
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        //create a new button
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        usernameTextViewField.layer.cornerRadius = 5
        passwordTextViewField.layer.cornerRadius = 5
        signInButton.layer.cornerRadius = 5
        signInFacebookButton.layer.cornerRadius = 5
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        
        for i in 0...9 {
            let imageName = "tmp-\(i).jpg"
            imageList.append(UIImage(named: imageName)!)
        }
    }
    
    func startAnimation() {
        signInBackground.animationImages = imageList
        signInBackground.startAnimating()
    }
    
    @IBAction func signInUser(sender: AnyObject) {
        
        let reachable = Reachability()
        if !(reachable.isConnectedToNetwork()) {
            let alert = UIAlertController(title: "INTERNET CONNECTION", message: "You are currently not connected to the internet. Make sure you are connected and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.loadingView.hidden = true
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        } else {
            loadingView.hidden = false
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            self.ref = FIRDatabase.database().reference()
            FIRAuth.auth()?.signInWithEmail(usernameTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    // an error occured while attempting login
                    let alert = UIAlertController(title: "SIGN IN FAILED", message: "Please make sure that you entered in the correct login infotmation", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.loadingView.hidden = true
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                    
                } else {
                    // user is logged in, check authData for data and send it to the view controller

                    var uid = user?.uid
                    
                    self.ref.child("users").child(uid!).observeEventType(.Value, withBlock: { (snapshot) in
                        
                        self.userExists = true
                        self.firebaseUserId = snapshot.key

                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.userId = self.firebaseUserId!
                        self.fullName = snapshot.value!.objectForKey("name") as! String!
                        self.username = snapshot.value!.objectForKey("username") as! String!
                        self.currentPoints = snapshot.value!.objectForKey("currentPoints") as! Double!
                        self.totalPoints = snapshot.value!.objectForKey("totalPoints") as! Double!
                        self.profilePictureString = snapshot.value!.objectForKey("profileImage") as! String!
                        self.rewardsReceived = snapshot.value!.objectForKey("rewardsReceived") as! Int!
                        self.timeSpentDriving = snapshot.value!.objectForKey("timeSpentDriving") as! Double!
                        self.email = snapshot.value!.objectForKey("email") as! String!
                        self.distanceTraveled = snapshot.value!.objectForKey("distanceTraveled") as! Double!
                        self.currentUserPointsList = snapshot.value!.objectForKey("pointsHistory") as! NSArray!
                        self.imageLocation = snapshot.value!.objectForKey("imageLocation") as? String
                        
                        self.registerUserInformation()
                        if (self.imageLocation == nil) {
                            let decodedData = NSData(base64EncodedString: self.profilePictureString!, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
                            let storage = FIRStorage.storage()
                            let storageRef = storage.referenceForURL("gs://firebase-passenger-app.appspot.com/images/\(uid!)")
                            storageRef.putData(decodedData!, metadata: nil) { metadata, error in
                                self.ref.child("users/\(uid!)/imageLocation").setValue("gs://firebase-passenger-app.appspot.com/images/\(uid!)")
                                self.ref.child("users/\(uid!)/profileImage").setValue(" ")
                                self.imageLocation = "gs://firebase-passenger-app.appspot.com/images/\(uid!)"
                                self.imageData = decodedData!
                                self.performSegueWithIdentifier("signInSegue", sender: nil)
                                self.loadingView.hidden = true
                                self.activityIndicator.hidden = true
                                self.activityIndicator.stopAnimating()
                                
                            }
                        } else {
                            print(self.imageLocation)
                            let storage = FIRStorage.storage()
                            let storageRef = storage.referenceForURL("\(self.imageLocation!)")
                            
                            storageRef.dataWithMaxSize(1 * 3000 * 3000) { (data, error) -> Void in
                                if (error != nil) {
                                    // Uh-oh, an error occurred!
                                    print(error)
                                } else {
                                    // Data for "images/island.jpg" is returned
                                    // ... let islandImage: UIImage! = UIImage(data: data!)
                                    self.imageData = data
                                    self.performSegueWithIdentifier("signInSegue", sender: nil)
                                    self.loadingView.hidden = true
                                    self.activityIndicator.hidden = true
                                    self.activityIndicator.stopAnimating()                                }
                            }
                            
                        }
                        
                    })
                }

            }
            
        }
        
    }

    
    func registerUserInformation() {
       }


}
