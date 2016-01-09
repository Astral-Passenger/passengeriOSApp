//
//  HelpFinalViewController.swift
//  Passenger
//
//  Created by Connor Myers on 12/19/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit

class HelpFinalViewController: UIViewController {
    
    var returnQuestions: [String]?
    var returnAnswers: [String]?
    var question: String?
    var answer: String?
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "finalToHelpExpanded" {
            let destinationController = segue.destinationViewController as! UINavigationController
            let helpExpandedViewController = destinationController.viewControllers.first as! HelpExpandedTableViewController
            helpExpandedViewController.questions = returnQuestions
            helpExpandedViewController.answers = returnAnswers
        }
        
    }
    
    func configureView() {

        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        questionLabel.text = question
        answerLabel.text = answer
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
