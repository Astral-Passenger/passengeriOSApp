//
//  ProfileSettingsViewController.swift
//  Passenger
//
//  Created by Connor Myers on 12/16/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Parse
import Bolts
import FBSDKCoreKit
import ParseFacebookUtilsV4

class ProfileSettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let transitionManager = MenuTransitionManager()
    
    let imagePicker = UIImagePickerController()
    
    private var currentUser: PFUser?
    private var fullName: String = ""
    private var email: String = ""
    private var phoneNumber: String = ""
    private var updatedImage: UIImage?
    
    var senderViewController: String?
    
    var didEditImage: Bool = false
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var connectToFacebookButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var cameraImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = PFUser.currentUser()
        // Do any additional setup after loading the view.
        configureView()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        let profileImageTap = UITapGestureRecognizer(target:self, action: "imageTapped")
        profileImage.userInteractionEnabled = true
        profileImage.addGestureRecognizer(profileImageTap)
        
        self.transitionManager.sourceViewController = self
        
        imagePicker.delegate = self
    }
    
    @IBAction func connectToFacebookTap(sender: AnyObject) {
        if !PFFacebookUtils.isLinkedWithUser(currentUser!) {
            PFFacebookUtils.linkUserInBackground(currentUser!, withReadPermissions: nil, block: {
                (succeeded: Bool?, error: NSError?) -> Void in
                if (succeeded != nil) {
                    print("Woohoo, the user is linked with Facebook!")
                }
            })
        }

    }
    
    func imageTapped() {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .PhotoLibrary
            
            presentViewController(imagePicker, animated: true, completion: nil)

    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            if (senderViewController == "Profile") {
                let menu = segue.destinationViewController as! HomeNavigationViewController
                let targetController = menu.topViewController as! HomeViewController
                targetController.profile = true
                menu.transitioningDelegate = self.transitionManager
                self.transitionManager.menuViewController = menu
            } else {
                let menu = segue.destinationViewController as! HomeNavigationViewController
                let targetController = menu.topViewController as! HomeViewController
                targetController.helpSupport = true
                menu.transitioningDelegate = self.transitionManager
                self.transitionManager.menuViewController = menu
            }
            
        } else if (segue.identifier == "editProfileToForgotLoggedIn") {
            let menu = segue.destinationViewController as! UINavigationController
            let targetController = menu.topViewController as! ForgotPasswordLoggedInViewController
            targetController.profileSettingsSender = self.senderViewController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        }
    }
    
    func configureView() {
        activityIndicator.hidden = true
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        let fullName = currentUser!["full_name"] as! String
        let username = currentUser!.username
        
        let email = currentUser!.email
        
        nameTextField.text = fullName
        emailTextField.text = email
        usernameTextField.text = username
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            
            if let profileImage = self.currentUser!["profile_picture"] as? PFFile {
                profileImage.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
                    let image: UIImage! = UIImage(data: imageData!)!
                    self.profileImage?.image = image
                    self.profileImage.layer.masksToBounds = true
                    self.profileImage.layer.cornerRadius = 62.5
                    self.cameraImageView.hidden = false
                })
            } else {
                self.cameraImageView.hidden = true
            }
            
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        didEditImage = true
        let contextSize: CGSize = image.size
        
        let posX: CGFloat
        let posY: CGFloat
        let width: CGFloat
        let height: CGFloat
        
        // Check to see which length is the longest and create the offset based on that length, then set the width and height for our rect
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            width = contextSize.height
            height = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            width = contextSize.width
            height = contextSize.width
        }
        
        let rect: CGRect = CGRectMake(posX, posY, width, height)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(image.CGImage, rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let imageFinal: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)

        
        profileImage.contentMode = .ScaleAspectFit
        profileImage.image = imageFinal
        updatedImage = imageFinal
        print("Image Selected")
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func connectToFacebookButtonTap(sender: AnyObject) {

    }
    
    @IBAction func saveButtonTap(sender: AnyObject) {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        let fullName = nameTextField.text
        let email = emailTextField.text
        
        let username = usernameTextField.text
        
        //var parsedPhoneNumber: String = ""
        
        //let letters = phoneNumber!.characters.map { String($0) }

        
        //var iterator = 0

//        // Parse the phone number to make sure it fits the same format
//        if (phoneNumber?.characters.count < 11 && phoneNumber?.characters.count > 9) {
//            for (var i = 0; i < 12; i++) {
//                if (i == 0) {
//                    parsedPhoneNumber = parsedPhoneNumber + "+"
//                } else if (i == 1) {
//                    parsedPhoneNumber = parsedPhoneNumber + "1"
//                } else if (i == 2) {
//                    parsedPhoneNumber = parsedPhoneNumber + " "
//                } else if (i < 6) {
//                    let char = letters[iterator]
//                    parsedPhoneNumber = parsedPhoneNumber + String(UTF8String: char)!
//                    iterator++
//                } else if (i == 6) {
//                    parsedPhoneNumber = parsedPhoneNumber + "-"
//                } else {
//                    let char = letters[iterator]
//                    parsedPhoneNumber = parsedPhoneNumber + String(UTF8String: char)!
//                    iterator++
//                }
//            }
//
//        } else if (phoneNumber?.characters.count > 1){
//            let alert = UIAlertController(title: "EDIT PROFILE", message: "Please enter a phone number with an area code.", preferredStyle: UIAlertControllerStyle.Alert)
//            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
//            self.presentViewController(alert, animated: true, completion: nil)
//        }
        let query = PFQuery(className:"_User")
        print(username)
        query.whereKey("username", equalTo: username!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                if (objects!.count > 0) {
                    // There was already a user
                    let alert = UIAlertController(title: "USERNAME", message: "The username \(username!) has already been taken choose another one.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.activityIndicator.hidden = true
                    self.activityIndicator.stopAnimating()
                } else {
                    
                    
                    self.currentUser!["full_name"] = fullName
                    self.currentUser!.email = email
                    self.currentUser!.username = username
                    
                    if (self.didEditImage) {
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                            
                            let imageData = UIImageJPEGRepresentation(self.updatedImage!,0.05)
                            
                            if(imageData != nil)
                            {
                                let profileFileObject = PFFile(data:imageData!)
                                self.currentUser?.setObject(profileFileObject!, forKey: "profile_picture")
                            }
                            
                            
                            self.currentUser?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                                
                                if(success)
                                {
                                    self.activityIndicator.hidden = true
                                    self.activityIndicator.stopAnimating()
                                }
                                
                            })
                            
                        }
                    } else {
                        self.currentUser?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                            
                            if(success)
                            {
                                self.activityIndicator.hidden = true
                                self.activityIndicator.stopAnimating()
                            }
                            
                        })
                    }
                    
                    
                    self.nameTextField.text = fullName
                    self.emailTextField.text = email
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }

        }
    }

}
