//
//  RegisterViewController.swift
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

class RegisterViewController: UIViewController {
    
    let transitionManager = MenuTransitionManager()
    
    var base64String: NSString!
    
    var fullName: String?
    var username: String?
    var currentPoints: Int?
    var totalPoints: Int?
    var profilePictureString: String?
    var rewardsReceived: Int?
    var timeSpentDriving: Double?
    var email: String?
    var distanceTraveled: Double?
    var userExists: Bool?
    var firebaseUserId: String?
    
    let ref = Firebase(url: "https://passenger-app.firebaseio.com")
    let usersRef = Firebase(url: "https://passenger-app.firebaseio.com/users")
    
    let facebookLogin = FBSDKLoginManager()

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var connectFacebookButton: UIButton!
    @IBOutlet weak var emailTextFieldView: UIView!
    @IBOutlet weak var passwordTextFieldView: UIView!
    @IBOutlet weak var registerBackButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerBackground: UIImageView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var imageList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        startAnimation()
        // Do any additional setup after loading the view.
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
        } else if (segue.identifier == "finishedSigningUp") {
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
        usernameView.layer.cornerRadius = 5

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
        
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        let email = emailTextField.text!
        let name = nameTextField.text!
        
        var isEmail: Bool = false
        
        if email.rangeOfString("@") != nil {
            isEmail = true
        }
        
        if (username.characters.count < 4) {
            let alert = UIAlertController(title: "USERNAME", message: "Enter a username that is longer than 4 characters.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        } else if (email.characters.count < 5 && isEmail == false) {
            let alert = UIAlertController(title: "EMAIL", message: "Please enter a valid email", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        } else if (password.characters.count < 6) {
            let alert = UIAlertController(title: "PASSWORD", message: "Please enter a password longer than 6 characters for security purposes.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            self.activityIndicator.hidden = true
            self.activityIndicator.stopAnimating()
        } else {
            // Register & Authenticate user
            self.ref.createUser(email, password: password) { (error: NSError!) in
                if error == nil {
                    self.ref.authUser(email, password: password,
                        withCompletionBlock: {
                            (error, auth) -> Void in
                            self.activityIndicator.hidden = true
                            self.activityIndicator.stopAnimating()
                            
                            let uploadImage = UIImage(named: "default-profile.png")
                            let imageData: NSData = UIImagePNGRepresentation(uploadImage!)!
                            self.base64String = imageData.base64EncodedStringWithOptions(.Encoding64CharacterLineLength)
                            
                            
                            let currentUser = [
                                "\(auth.uid)": [
                                    "username": username,
                                    "name": name,
                                    "email": email,
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
                            
                            self.fullName = name
                            self.username = ""
                            self.currentPoints = 0
                            self.totalPoints = 0
                            self.profilePictureString = "\(self.base64String)"
                            self.rewardsReceived = 0
                            self.timeSpentDriving = 0
                            self.email = email
                            self.distanceTraveled = 0
                            
                            self.performSegueWithIdentifier("finishedSigningUp", sender: nil)
                    })
                } else {
                    let alert = UIAlertController(title: "SIGN UP", message: "\(error!.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
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
                        
                        }
                })
            }
        })
    }
    
    func createNewUserInDatabase() {
        
    }
    
    func registerUserInformation() {
        
        self.usersRef.queryOrderedByChild("email").queryEqualToValue("\(self.ref.authData.providerData["email"]!)")
            .observeEventType(.Value, withBlock: { snapshot in
                print("This is called")
                if snapshot.value is NSNull {
                    // The user is not currently in the database
                    
                    // Register user in the database function
                    
                } else {
                    
                    // The user is in the datbase and simply logged in 
                    
                    // Assign all variables from the data that we pull from the user
                    
                    self.userExists = true
                    self.fullName = snapshot.value["name"] as! String
                    self.username = snapshot.value["username"] as! String
                    self.currentPoints = snapshot.value["currentPoints"] as! Int
                    self.totalPoints = snapshot.value["totalPoints"] as! Int
                    self.profilePictureString = snapshot.value["profileImage"] as! String
                    self.rewardsReceived = snapshot.value["rewardsReceived"] as! Int
                    self.timeSpentDriving = snapshot.value["timeSpentDriving"] as! Double
                    self.email = snapshot.value["email"] as! String
                    self.distanceTraveled = snapshot.value["currentPoints"] as! Double
                    self.performSegueWithIdentifier("finishedSigningUp", sender: nil)
                    
                }
                
                
                
            })
        
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
                    
                    self.performSegueWithIdentifier("finishedSigningUp", sender: nil)

                }
                
            }
            
        }
    }

}
