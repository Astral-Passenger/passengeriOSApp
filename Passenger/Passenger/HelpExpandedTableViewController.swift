//
//  HelpExpandedTableViewController.swift
//  Passenger
//
//  Created by Connor Myers on 12/19/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Firebase

class HelpExpandedTableViewController: UITableViewController {
    
    let ref = Firebase(url: "https://passenger-app.firebaseio.com")
    let helpQuestionsRef = Firebase(url: "https://passenger-app.firebaseio.com/help/")
    
    let transitionManager = MenuTransitionManager()
    
    var helpTitle: String?
    var questions = [String]()
    var answers = [String]()
    
    var questionType: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = helpTitle

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        loadQuestions()
        self.transitionManager.sourceViewController = self
        configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return questions.count
    }
    
    func loadQuestions() {
        
        helpQuestionsRef.queryOrderedByChild("questionType").queryEqualToValue(questionType)
            .observeEventType(.ChildAdded, withBlock: { snapshot in
                self.questions.append(snapshot.value["question"] as! String)
                self.answers.append(snapshot.value["answer"] as! String)
                self.tableView.reloadData()
            })
        self.tableView.reloadData()

    }

    
    func configureView() {
        self.tableView.tableFooterView = UIView()
        self.tableView.contentInset = UIEdgeInsetsMake(24, 0, 0, 0);
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        self.tableView.estimatedRowHeight = 50.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("helpExpandedCell", forIndexPath: indexPath)
            as! HelpExpandedTableViewCell

        cell.cellQuestionLabel!.text = questions[indexPath.row]
        
        return cell

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        
        if segue.identifier == "helpExpandedToFinal" {
            let cell = sender as! UITableViewCell
            let destinationController = segue.destinationViewController as! UINavigationController
            let helpFinalViewController = destinationController.viewControllers.first as! HelpFinalViewController
            let row = self.tableView.indexPathForCell(cell)?.row
            helpFinalViewController.question = questions[row!]
            helpFinalViewController.answer = answers[row!]
            helpFinalViewController.questionType = self.questionType
            helpFinalViewController.helpTitle = self.helpTitle
        } else if (segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            let menu = segue.destinationViewController as! UINavigationController
            let targetController = menu.topViewController as! HelpViewController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
        }
        
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
