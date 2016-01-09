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

class SignInViewController: UIViewController {
    
    let transitionManager = MenuTransitionManager()

    @IBOutlet weak var usernameTextViewField: UIView!
    @IBOutlet weak var passwordTextViewField: UIView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signInFacebookButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInBackground: UIImageView!
    
    var imageList = [UIImage]()
    
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
        PFUser.logInWithUsernameInBackground(usernameTextField.text!, password: passwordTextField.text!) {
            (user: PFUser?, error: NSError?) -> Void in
            if user != nil {
                // do stuff with a successful login
                self.performSegueWithIdentifier("signInSegue", sender: nil)
            } else {
                // the login failed. Check error to see what happened
                let alert = UIAlertController(title: "SIGN IN FAILED", message: "Please make sure that you entered in the correct login infotmation", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }

    @IBAction func loginUserWithFacebook(sender: AnyObject) {
        let permissions = []
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions as? [String]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!", terminator: "")
                    self.performSegueWithIdentifier("signInSegue", sender: nil)
                } else {
                    print("User logged in through Facebook!", terminator: "")
                    self.performSegueWithIdentifier("signInSegue", sender: nil)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.", terminator: "")
            }
        }
    }

}
