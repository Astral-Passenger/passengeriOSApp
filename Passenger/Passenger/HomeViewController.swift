//
//  HomeViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/20/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit

class HomeViewController: UITabBarController, UITabBarControllerDelegate {
    
    var helpSupport: Bool = false
    
    private var statusBarBackground: UIView!
    
    var colorGenerator = HexToUIColor()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        if (helpSupport) {
            self.navigationItem.titleView = nil
            self.navigationItem.title = "MORE"
        } else {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            imageView.contentMode = .ScaleAspectFit
            let image = UIImage(named: "logo.png")
            imageView.image = image
            self.navigationItem.titleView = imageView
        }

        configureView()

    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        if viewController is ViewController {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 28, height: 28))
            imageView.contentMode = .ScaleAspectFit
            let image = UIImage(named: "logo.png")
            imageView.image = image
            self.navigationItem.titleView = imageView
            self.navigationController?.navigationBarHidden = false
            if (statusBarBackground != nil) {
                self.statusBarBackground.removeFromSuperview()
                statusBarBackground = nil
            }
            UIApplication.sharedApplication().statusBarStyle = .Default
        } else if viewController is ProfileViewController {
            self.navigationController?.navigationBarHidden = true
            // create view to go behind statusbar
            self.statusBarBackground = UIView()
            self.statusBarBackground.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20)
            self.statusBarBackground.backgroundColor = UIColor.clearColor()
            
            // add to window rather than view controller
            UIApplication.sharedApplication().keyWindow!.addSubview(self.statusBarBackground)
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        } else if viewController is MoreViewController {
            self.navigationItem.titleView = nil
            self.navigationItem.title = "MORE"
            self.navigationController?.navigationBarHidden = false

            if (statusBarBackground != nil) {
                self.statusBarBackground.removeFromSuperview()
                statusBarBackground = nil
            }
            UIApplication.sharedApplication().statusBarStyle = .Default
        } else if viewController is UINavigationController {
            self.navigationItem.titleView = nil
            self.navigationItem.title = "RANKING"
            self.navigationController?.navigationBarHidden = false

            if (statusBarBackground != nil) {
                self.statusBarBackground.removeFromSuperview()
                statusBarBackground = nil
            }
            UIApplication.sharedApplication().statusBarStyle = .Default
            
        }
        
    }
    
    //MARK: - Life Cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkIfWorking()
    }
    
    func configureView() {
        /*
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "navigation_logo")
        imageView.image = image
        navigationItem.titleView = imageView*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkIfWorking() {
        if (helpSupport) {
            self.selectedIndex = 3
             helpSupport = false
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
    }


}
