//
//  SignInViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/13/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Parse
import FBSDKCoreKit
import ParseFacebookUtilsV4
import Firebase

class SignInViewController: UIViewController {
    
    let ref = Firebase(url: "https://passenger-app.firebaseio.com")
    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users")
    
    let transitionManager = MenuTransitionManager()
    let facebookLogin = FBSDKLoginManager()
    
    var fullName: String?
    var username: String?
    var currentPoints: Int?
    var totalPoints: Int?
    var profilePictureString: String?
    var rewardsReceived: Int?
    var timeSpentDriving: Double?
    var email: String?
    var distanceTraveled: Double?
    var userExists: Bool = false
    var firebaseUserId: String?
    
    var base64String: NSString!

    @IBOutlet weak var usernameTextViewField: UIView!
    @IBOutlet weak var passwordTextViewField: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInBackground: UIImageView!
    
    var imageList = [UIImage]()
    
    var rewards = [PFObject]()
    var rewardsHistory = [PFObject]()
    var helpData = [PFObject]()
    
    var localData = ParseLocalData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        startAnimation()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        self.transitionManager.sourceViewController = self
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if(segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            let menu = segue.destinationViewController as! FirstScreenViewController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        } else if(segue.identifier == "signInSegue") {
            let prefs = NSUserDefaults.standardUserDefaults()
            
            prefs.setValue(fullName!, forKey: "name")
            prefs.setValue(username!, forKey: "username")
            prefs.setValue(currentPoints!, forKey: "currentPoints")
            prefs.setValue(totalPoints!, forKey: "totalPoints")
            prefs.setValue(profilePictureString!, forKey: "profilePictureString")
            prefs.setValue(rewardsReceived!, forKey: "rewardsReceived")
            prefs.setValue(timeSpentDriving!, forKey: "timeSpentDriving")
            prefs.setValue(email!, forKey: "email")
            prefs.setValue(distanceTraveled!, forKey: "distanceTraveled")
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
    }
    
    func configureView() {
        
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
        
        ref.authUser(usernameTextField.text!, password: passwordTextField.text!) {
            error, authData in
            if error != nil {
                // an error occured while attempting login
                
                let alert = UIAlertController(title: "SIGN IN FAILED", message: "Please make sure that you entered in the correct login infotmation", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
            } else {
                // user is logged in, check authData for data and send it to the view controller
                
                self.usersRef.queryOrderedByChild("email").queryEqualToValue("\(self.ref.authData.providerData["email"]!)")
                    .observeEventType(.ChildAdded, withBlock: { snapshot in
                        self.userExists = true
                        self.firebaseUserId = snapshot.key
                        
                        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                        appDelegate.userId = self.firebaseUserId!
                        self.fullName = snapshot.value["name"] as! String!
                        self.username = snapshot.value["username"] as! String!
                        self.currentPoints = snapshot.value["currentPoints"] as! Int!
                        self.totalPoints = snapshot.value["totalPoints"] as! Int!
                        self.profilePictureString = snapshot.value["profileImage"] as! String!
                        self.rewardsReceived = snapshot.value["rewardsReceived"] as! Int!
                        self.timeSpentDriving = snapshot.value["timeSpentDriving"] as! Double!
                        self.email = snapshot.value["email"] as! String!
                        self.distanceTraveled = snapshot.value["currentPoints"] as! Double!
                        self.registerUserInformation()

                        self.performSegueWithIdentifier("signInSegue", sender: nil)
                    })
                
                //self.localData.loadDataDescending("RewardsHistory", descendingBy: "createdAt")
                //self.localData.loadData("Rewards")
                //self.localData.loadData("HelpQuestions")
            }
        }
        
    }

    @IBAction func loginUserWithFacebook(sender: AnyObject) {
        
        facebookLogin.logInWithReadPermissions(["email"], handler: {
            (facebookResult, facebookError) -> Void in
            if facebookError != nil {
                print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled {
                print("Facebook login was cancelled.")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                self.ref.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            
                            self.registerUserInformation()
                            
//                            self.usersRef.queryOrderedByChild("email").queryEqualToValue("\(self.ref.authData.providerData["email"]!)")
//                                .observeEventType(.Value, withBlock: { snapshot in
//                                    self.userExists = true
//                                    self.fullName = snapshot.value["name"] as! String!
//                                    self.username = snapshot.value["username"] as! String
//                                    self.currentPoints = snapshot.value["currentPoints"] as! Int
//                                    self.totalPoints = snapshot.value["totalPoints"] as! Int
//                                    self.profilePictureString = snapshot.value["profileImage"] as! String
//                                    self.rewardsReceived = snapshot.value["rewardsReceived"] as! Int
//                                    self.timeSpentDriving = snapshot.value["timeSpentDriving"] as! Double
//                                    self.email = snapshot.value["email"] as! String
//                                    self.distanceTraveled = snapshot.value["currentPoints"] as! Double
//                                    if (!(self.userExists)) {
//                                        
//                                    }
//                                    
//                                    self.performSegueWithIdentifier("signInSegue", sender: nil)
//                                
//                                })
                        }
                })
            }
        })
    }
    
    func registerUserInformation() {
        let requestParameters = ["fields": "id, email, first_name, last_name"]
        
        let userDetails = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        
        userDetails.startWithCompletionHandler { (connection, result, error:NSError!) -> Void in
            
            if(error != nil)
            {
                print("\(error.localizedDescription)", terminator: "")
                return
            }
            
            if(result != nil)
            {

                let userId:String = result["id"] as! String
                let userFirstName:String? = result["first_name"] as? String
                let userLastName:String? = result["last_name"] as? String
                let userEmail:String? = result["email"] as? String
                
                print("\(userEmail)", terminator: "")
            
                //let myUser:PFUser = PFUser.currentUser()!
                
                let fullName:String? = userFirstName! + " " + userLastName!
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    // Get Facebook profile picture
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    
                    let profilePictureUrl = NSURL(string: userProfile)
                    
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    let imageProfile: UIImage! = UIImage(data: profilePictureData!)!
                    
                    
                    var data: NSData = NSData()
                    
                    if let image = imageProfile {
                        data = UIImageJPEGRepresentation(image,0.1)!
                    }
                    
                    let base64String = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.Encoding64CharacterLineLength)
                    
                    if(profilePictureData != nil && fullName != nil && userEmail != nil)
                    {
                        self.base64String = profilePictureData!.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                        let currentUser = [
                            "\(userId)": [
                                "username": "",
                                "name": "\(fullName!)",
                                "email": "\(userEmail!)",
                                "totalPoints": 0,
                                "currentPoints": 0,
                                "distanceTraveled": 0,
                                "timeSpentDriving": 0,
                                "rewardsReceived": 0,
                                "phoneNumber": "",
                                "profileImage": base64String
                            ]
                        ]
                        
                        self.usersRef.updateChildValues(currentUser)
                    } else {
                        
                        let uploadImage = UIImage(named: "default-profile.png")
                        let imageData: NSData = UIImagePNGRepresentation(uploadImage!)!
                        self.base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                        
                        let currentUser = [
                            "\(userId)": [
                                "username": "",
                                "name": "\(fullName!)",
                                "email": "\(userEmail!)",
                                "totalPoints": 0,
                                "currentPoints": 0,
                                "distanceTraveled": 0,
                                "timeSpentDriving": 0,
                                "rewardsReceived": 0,
                                "phoneNumber": "",
                                "profileImage": self.base64String
                            ]
                        ]
                        
                        self.usersRef.updateChildValues(currentUser)
                        
                    }
                    
                    self.fullName = fullName!
                    self.username = ""
                    self.currentPoints = 0
                    self.totalPoints = 0
                    self.profilePictureString = base64String
                    self.rewardsReceived = 0
                    self.timeSpentDriving = 0
                    self.email = userEmail!
                    self.distanceTraveled = 0

                }
                
            }
            
        }
    }


}
