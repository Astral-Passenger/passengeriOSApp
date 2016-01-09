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

class RegisterViewController: UIViewController {
    
    let transitionManager = MenuTransitionManager()

    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var connectFacebookButton: UIButton!
    @IBOutlet weak var emailTextFieldView: UIView!
    @IBOutlet weak var passwordTextFieldView: UIView!
    @IBOutlet weak var registerBackButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerBackground: UIImageView!
    
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
        let user = PFUser()
        user.username = "Username"
        user.password = passwordTextField.text
        user.email = emailTextField.text
        
        user.signUpInBackgroundWithBlock {
            (succeed: Bool, error: NSError?) -> Void in
            if let error = error {
                let errorString = error.userInfo["error"] as? NSString
                print(errorString)
                // show the error somewhere and have the user try again
            } else {
                // Hooray, let them use the application
            self.performSegueWithIdentifier("registerSegue", sender: nil)
            }
        }
        
    }


    @IBAction func createAccount(sender: AnyObject) {
        registerUser()
    }
    
    
    @IBAction func createAccountWithFacebook(sender: AnyObject) {
        let permissions = []
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions as? [String]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!", terminator: "")
                    self.registerUserInformation()
                    self.performSegueWithIdentifier("signInSegue", sender: nil)
                } else {
                    print("User logged in through Facebook!", terminator: "")
                    self.registerUserInformation()
                    self.performSegueWithIdentifier("signInSegue", sender: nil)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.", terminator: "")
            }
        }
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
                
                let myUser:PFUser = PFUser.currentUser()!
                
                // Save first name
                if(userFirstName != nil)
                {
                    myUser.setObject(userFirstName!, forKey: "first_name")
                    
                }
                
                //Save last name
                if(userLastName != nil)
                {
                    myUser.setObject(userLastName!, forKey: "last_name")
                }
                
                // Save email address
                if(userEmail != nil)
                {
                    myUser.setObject(userEmail!, forKey: "email")
                }
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                    
                    // Get Facebook profile picture
                    let userProfile = "https://graph.facebook.com/" + userId + "/picture?type=large"
                    
                    let profilePictureUrl = NSURL(string: userProfile)
                    
                    let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
                    
                    if(profilePictureData != nil)
                    {
                        let profileFileObject = PFFile(data:profilePictureData!)
                        myUser.setObject(profileFileObject!, forKey: "profile_picture")
                    }
                    
                    
                    myUser.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                        
                        if(success)
                        {
                            print("User details are now updated", terminator: "")
                        }
                        
                    })
                    
                }
                
            }
            
        }
    }

}