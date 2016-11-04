//
//  RegisterViewController.swift
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

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    var ref: FIRDatabaseReference!
    
    let transitionManager = MenuTransitionManager()
    
    var base64String: NSString!
    
    var fullName: String?
    var currentPoints: Double?
    var totalPoints: Double?
    var profilePictureString: String?
    var rewardsReceived: Int?
    var timeSpentDriving: Double?
    var email: String?
    var distanceTraveled: Double?
    var userExists: Bool?
    var firebaseUserId: String?
    var kbHeight: CGFloat!
    var uidToSave: String?
    
//    let ref = Firebase(url: "https://passenger-app.firebaseio.com")
//    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users")
    
    let facebookLogin = FBSDKLoginManager()

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var connectFacebookButton: UIButton!
    @IBOutlet weak var emailTextFieldView: UIView!
    @IBOutlet weak var passwordTextFieldView: UIView!
    @IBOutlet weak var registerBackButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerBackground: UIImageView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingView: UIView!
    
    var imageList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.ref = FIRDatabase.database().reference()
        configureView()
        startAnimation()
        // Do any additional setup after loading the view.
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.transitionManager.sourceViewController = self
        nameTextField.delegate = self
        emailTextField.delegate = self
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
            self.view.frame = CGRectOffset(self.view.frame, 0, movement)
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
        } else if (segue.identifier == "finishedSigningUp") {
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            appDelegate.profilePictureString = self.profilePictureString
            appDelegate.usersName = self.fullName
            appDelegate.currentUserCurrentPoints = self.currentPoints!
            appDelegate.currentUserTotalPoints = self.totalPoints!
            appDelegate.rewardsReceived = self.rewardsReceived
            appDelegate.currentUserTimeSpentDriving = self.timeSpentDriving!
            appDelegate.currentUserCurrentDistance = self.distanceTraveled!
            
            
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
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
        ]
        navigationController?.navigationBar.barTintColor = UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0)
        
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        //create a new button
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        createAccountButton.layer.cornerRadius = 5
        connectFacebookButton.layer.cornerRadius = 5
        emailTextFieldView.layer.cornerRadius = 5
        passwordTextFieldView.layer.cornerRadius = 5
        nameView.layer.cornerRadius = 5

        navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.translucent = true
        
        for i in 0...9 {
            let imageName = "tmp-\(i).jpg"
            imageList.append(UIImage(named: imageName)!)
        }
    }
    
    func startAnimation() {
        registerBackground.animationImages = imageList
        registerBackground.startAnimating()
    }
    
    func registerUser() {
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
            activityIndicator.startAnimating()
            activityIndicator.hidden = false
            let password = passwordTextField.text!
            let email = emailTextField.text!
            let name = nameTextField.text!
            
            var isEmail: Bool = false
            
            if email.rangeOfString("@") != nil {
                isEmail = true
            }
            
            if (password == "" || email == "" || name == "") {
                let alert = UIAlertController(title: "REGISTRATION ERROR", message: "Make sure you fill out all of the fields.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.loadingView.hidden = true
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
            } else {
                if (email.characters.count < 5 && isEmail == false) {
                    let alert = UIAlertController(title: "EMAIL", message: "Please enter a valid email", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.loadingView.hidden = true
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                } else if (password.characters.count < 6) {
                    let alert = UIAlertController(title: "PASSWORD", message: "Please enter a password longer than 6 characters for security purposes.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.loadingView.hidden = true
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                } else {
                    
                    // Register & Authenticate user
                    
                    FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: {
                        (user: FIRUser?, error) in
                        
                        if error == nil {
                            
                            // Registration successful
                            
                            let userID = user?.uid

                            let uploadImage = UIImage(named: "default-profile.png")
                            let imageData: NSData = UIImagePNGRepresentation(uploadImage!)!
                            
                            let storage = FIRStorage.storage()
                            let storageRef = storage.referenceForURL("gs://firebase-passenger-app.appspot.com/images/\(userID!)")
                            let uploadTask = storageRef.putData(imageData, metadata: nil) { metadata, error in
                                
                                let currentUser = [
                                    "\(userID!)": [
                                        "name": name,
                                        "email": email.lowercaseString,
                                        "totalPoints": 0,
                                        "currentPoints": 0,
                                        "distanceTraveled": 0,
                                        "timeSpentDriving": 0,
                                        "rewardsReceived": 0,
                                        "phoneNumber": "",
                                        "profileImage": " ",
                                        "imageLocation": "gs://firebase-passenger-app.appspot.com/images/\(userID!)"
                                    ]
                                ]
                                
                                self.ref.child("users").updateChildValues(currentUser)
                                
                                self.fullName = name
                                self.currentPoints = 0
                                self.totalPoints = 0
                                self.profilePictureString = "\(self.base64String)"
                                self.rewardsReceived = 0
                                self.timeSpentDriving = 0
                                self.email = email.lowercaseString
                                self.distanceTraveled = 0
                                
                                self.activityIndicator.hidden = true
                                self.activityIndicator.stopAnimating()
                                
                                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                                appDelegate.profilePictureString = self.profilePictureString
                                appDelegate.currentUserCurrentPoints = self.currentPoints!
                                appDelegate.usersEmail = self.email?.lowercaseString
                                appDelegate.usersName = self.fullName
                                appDelegate.userId = userID!
                                appDelegate.currentUserTotalPoints = self.totalPoints!
                                appDelegate.currentUserTimeSpentDriving = self.timeSpentDriving!
                                appDelegate.currentUserCurrentDistance = self.distanceTraveled!
                                appDelegate.rewardsReceived = self.rewardsReceived!
                                appDelegate.imageData = imageData
                                
                                self.performSegueWithIdentifier("finishedSigningUp", sender: nil)
                                
                            }
                            
                        }else{
                            
                            // Registration failure
                            
                            self.loadingView.hidden = true
                            self.activityIndicator.hidden = true
                            self.activityIndicator.stopAnimating()
                            let alert = UIAlertController(title: "SIGN UP", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                    })

                }
            }

        }
    }


    @IBAction func createAccount(sender: AnyObject) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        registerUser()
    }
    
    
    @IBAction func createAccountWithFacebook(sender: AnyObject) {
//        let reachable = Reachability()
//        if !(reachable.isConnectedToNetwork()) {
//            let alert = UIAlertController(title: "INTERNET CONNECTION", message: "You are currently not connected to the internet. Make sure you are connected and try again.", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//            self.loadingView.hidden = true
//            self.activityIndicator.hidden = true
//            self.activityIndicator.stopAnimating()
//        } else {
//            loadingView.hidden = false
//            activityIndicator.startAnimating()
//            activityIndicator.hidden = false
//            facebookLogin.logInWithReadPermissions(["email"], handler: {
//                (facebookResult, facebookError) -> Void in
//                if facebookError != nil {
//                    print("Facebook login failed. Error \(facebookError)")
//                } else if facebookResult.isCancelled {
//                    print("Facebook login was cancelled.")
//                    
//                    self.loadingView.hidden = true
//                    self.activityIndicator.hidden = true
//                    self.activityIndicator.stopAnimating()
//                } else {
//                    let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
//                    self.ref.authWithOAuthProvider("facebook", token: accessToken,
//                        withCompletionBlock: { error, authData in
//                            if error != nil {
//                                print("Login failed. \(error)")
//                            } else {
//                                print("Logged in! \(authData)")
//                                self.uidToSave = authData.uid
//                                self.registerUserInformation()
//                                
//                            }
//                    })
//                }
//            })
//        }
    }
    
    func registerUserInformation() {
        
//        self.usersRef.queryOrderedByChild("email").queryEqualToValue("\(self.ref.authData.providerData["email"]!)")
//            .observeEventType(.Value, withBlock: { snapshot in
//
//                if snapshot.value is NSNull {
//                    // The user is not currently in the database
//                    
//                    print("This user is not in the database")
//                    
//                    // Register user in the database function
//                    
//                    let requestParameters = ["fields": "id, email, first_name, last_name"]
//                    
//                    let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
//                    
//                    userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
//                        
//                        if(error != nil)
//                        {
//                            print("\(error.localizedDescription)", terminator: "")
//                            return
//                        }
//                        
//                        if(result != nil)
//                        {
//                            
//                            let userId:String = result.objectForKey("id") as! String
//                            let userFirstName:String? = result.objectForKey("first_name") as? String
//                            let userLastName:String? = result.objectForKey("last_name") as? String
//                            let userEmail:String? = result.objectForKey("email") as? String
//                            
//                            let fullName:String? = userFirstName! + " " + userLastName!
//                                
//                                // Get Facebook profile picture
//                                let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
//                                
//                                let profilePictureUrl = NSURL(string: userProfile)
//                                
//                                let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
//                                let imageProfile: UIImage! = UIImage(data: profilePictureData!)!
//                                
//                                
//                                var data: NSData = NSData()
//                                
//                                if let image = imageProfile {
//                                    data = UIImageJPEGRepresentation(image,0.1)!
//                                }
//                                
//                                let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
//                                
//                                if(profilePictureData != nil && fullName != nil && userEmail != nil)
//                                {
//                                    self.base64String = profilePictureData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//                                    let currentUser = [
//                                        "\(self.uidToSave!)": [
//                                            "name": "\(fullName!)",
//                                            "email": "\(userEmail!)",
//                                            "totalPoints": 0,
//                                            "currentPoints": 0,
//                                            "distanceTraveled": 0,
//                                            "timeSpentDriving": 0,
//                                            "rewardsReceived": 0,
//                                            "phoneNumber": "",
//                                            "profileImage": base64String
//                                        ]
//                                    ]
//                                    
//                                    self.usersRef.updateChildValues(currentUser)
//                                } else {
//                                    
//                                    let uploadImage = UIImage(named: "default-profile.png")
//                                    let imageData: NSData = UIImagePNGRepresentation(uploadImage!)!
//                                    self.base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
//                                    
//                                    let currentUser = [
//                                        "\(self.uidToSave!)": [
//                                            "name": "\(fullName!)",
//                                            "email": "\(userEmail!)",
//                                            "totalPoints": 0,
//                                            "currentPoints": 0,
//                                            "distanceTraveled": 0,
//                                            "timeSpentDriving": 0,
//                                            "rewardsReceived": 0,
//                                            "phoneNumber": "",
//                                            "profileImage": self.base64String
//                                        ]
//                                    ]
//                                    
//                                    self.usersRef.updateChildValues(currentUser)
//                                
//                                }
//                            
//                            self.fullName = fullName!
//                            self.currentPoints = 0
//                            self.totalPoints = 0
//                            self.profilePictureString = base64String
//                            self.rewardsReceived = 0
//                            self.timeSpentDriving = 0
//                            self.email = userEmail!
//                            self.distanceTraveled = 0
//                            
//                            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                            appDelegate.userId = userId
//                            
//                            self.performSegueWithIdentifier("finishedSigningUp", sender: nil)
//                        }
//                        
//                    }
//                    
//                    
//                } else {
//                    
//                    // The user is in the datbase and simply logged in
//                    self.userExists = true
//                    if self.ref.authData.uid.rangeOfString("facebook:") != nil{
//                        let userId = self.ref.authData.uid.stringByReplacingOccurrencesOfString(
//                            "facebook:",
//                            withString: "",// or just nil
//                            range: nil)
//                        let currentUser = snapshot.value.objectForKey("\(userId)")
//                        self.fullName = currentUser!.objectForKey("name") as? String
//                        self.currentPoints = currentUser!.objectForKey("currentPoints") as? Double
//                        self.totalPoints = currentUser!.objectForKey("totalPoints") as? Double
//                        self.profilePictureString = currentUser!.objectForKey("profileImage") as? String
//                        self.rewardsReceived = currentUser!.objectForKey("rewardsReceived") as? Int
//                        self.timeSpentDriving = currentUser!.objectForKey("timeSpentDriving") as? Double
//                        self.email = currentUser!.objectForKey("email") as? String
//                        self.distanceTraveled = currentUser!.objectForKey("distanceTraveled") as? Double
//                        print("current points for the user \(self.currentPoints)")
//                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                        appDelegate.userId = userId
//                    } else {
//                        let userId = self.ref.authData.uid
//                        let currentUser = snapshot.value.objectForKey("\(userId)")
//                        self.fullName = currentUser!.objectForKey("name") as? String
//                        self.currentPoints = currentUser!.objectForKey("currentPoints") as? Double
//                        self.totalPoints = currentUser!.objectForKey("totalPoints") as? Double
//                        self.profilePictureString = currentUser!.objectForKey("profileImage") as? String
//                        self.rewardsReceived = currentUser!.objectForKey("rewardsReceived") as? Int
//                        self.timeSpentDriving = currentUser!.objectForKey("timeSpentDriving") as? Double
//                        self.email = currentUser!.objectForKey("email") as? String
//                        self.distanceTraveled = currentUser!.objectForKey("distanceTraveled") as? Double
//                        
//                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                        appDelegate.userId = userId
//                    }
//
//                    
//                    self.performSegueWithIdentifier("finishedSigningUp", sender: nil)
//                    
//                }
//                
//                
//                
//            })
    }

}
