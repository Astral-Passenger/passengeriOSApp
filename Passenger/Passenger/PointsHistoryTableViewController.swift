//
//  PointsHistoryTableViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/19/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Firebase
import Bolts

class PointsHistoryTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    
    // MARK: Properties
    
    let transitionManager = MenuTransitionManager()
    
    let cellIdentifier = "PointsHistoryTableViewCell"

    var dailyRecords = [DayDriveRecorded]()
    
    var currentDriveDateIteration: NSDate?
    var pointsHistory: NSArray?
    var senderViewController: String?
    
    var dateFormatter = NSDateFormatter()
    var readableDateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        loadPreviousDrives()
        self.transitionManager.sourceViewController = self
    }
    
    func configureView() {
        
        dateFormatter.dateFormat = "HH:mm"
        readableDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        let font = UIFont.systemFontOfSize(16, weight: UIFontWeightLight)
        
        let navBarAttributesDictionary: [String: AnyObject]? = [
            NSForegroundColorAttributeName: UIColor(red:0.04, green:0.37, blue:0.76, alpha:1.0),
            NSFontAttributeName: font
        ]
        navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        navigationController?.navigationBar.titleTextAttributes = navBarAttributesDictionary
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        
        UIApplication.sharedApplication().statusBarStyle = .Default
        
        
    }
    
    func loadPreviousDrives() {
        
        let reachable = Reachability()
        if !(reachable.isConnectedToNetwork()) {
            var emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            emptyLabel.text = "No internet connection"
            emptyLabel.textAlignment = NSTextAlignment.Center
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            let hexChanger = HexToUIColor()
            emptyLabel.textColor = hexChanger.hexStringToUIColor("#5c5c5c")
            self.tableView.backgroundView = emptyLabel
        } else {
            let userID = FIRAuth.auth()?.currentUser?.uid
            self.ref = FIRDatabase.database().reference()
            ref.child("users").child(userID!).observeEventType(.Value, withBlock: { (snapshot) in
                if let pointsHistory = snapshot.value!.objectForKey("pointsHistory") as? NSArray {
                    
                    self.pointsHistory = pointsHistory
                    
                    var recordedDrives = [DriveRecord]()
                    var dateRecordedString: String?
                    var dateRecorded = NSDate()
                    var finalDatePlusOne = NSDate()
                    var pointsGenerated = Int()
                    var distanceTraveled = Double()
                    let finalDate = NSDate()
                    self.pointsHistory!.reverse()
                    
                    for (var i = self.pointsHistory!.count - 1; i >= 0; i--) {
                        
                        distanceTraveled = self.pointsHistory!.objectAtIndex(i).objectForKey("distanceTraveled") as! Double
                        pointsGenerated = self.pointsHistory!.objectAtIndex(i).objectForKey("pointsGenerated") as! Int
                        dateRecordedString = self.pointsHistory!.objectAtIndex(i).objectForKey("createdAt") as! String
                        let dateFormatter = NSDateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
                        dateRecorded = dateFormatter.dateFromString(dateRecordedString!)!
                        
                        let date = NSDate()
                        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                        let newDate = cal.startOfDayForDate(date)
                        let finalDate = newDate.dateByAddingTimeInterval(60*60*12)
                        finalDatePlusOne = newDate.dateByAddingTimeInterval(60*60*13)
                        let newStr = self.dateFormatter.stringFromDate(finalDate)
                        
                        if (i == self.pointsHistory!.count - 1) {
                            self.currentDriveDateIteration = dateRecorded
                            let currentDriveRecord = DriveRecord(milesDriven: Double(distanceTraveled), timeRecorded: self.getDateString(dateRecorded, dateTo: finalDate, dateSubtract: finalDatePlusOne), pointsGenerated: "+\(pointsGenerated)")
                            recordedDrives += [currentDriveRecord]
                        } else if (self.compareDate(dateRecorded, secondDate: self.currentDriveDateIteration!)) {
                            // The date is less than the previous date, therefore, create a new iteration in the array
                            let dateString = self.readableDateFormatter.stringFromDate(self.currentDriveDateIteration!)
                            let dayRecord = DayDriveRecorded(dateRecorded: dateString, recordedDrives: recordedDrives)
                            self.dailyRecords += [dayRecord]
                            recordedDrives = [DriveRecord]()
                            let currentDriveRecord = DriveRecord(milesDriven: Double(distanceTraveled), timeRecorded: self.getDateString(dateRecorded, dateTo: finalDate, dateSubtract: finalDatePlusOne), pointsGenerated: "+\(pointsGenerated)")
                            recordedDrives += [currentDriveRecord]
                            self.currentDriveDateIteration = dateRecorded
                        } else {
                            // The dates are the same, just add the curentDrivePoint to the array
                            let currentDriveRecord = DriveRecord(milesDriven: Double(distanceTraveled), timeRecorded: self.getDateString(dateRecorded, dateTo: finalDate, dateSubtract: finalDatePlusOne), pointsGenerated: "+\(pointsGenerated)")
                            recordedDrives += [currentDriveRecord]
                        }
                        self.tableView.reloadData()
                    }
                    
                    let dateString = self.readableDateFormatter.stringFromDate(self.currentDriveDateIteration!)
                    let dayRecord = DayDriveRecorded(dateRecorded: dateString, recordedDrives: recordedDrives)
                    self.dailyRecords += [dayRecord]
                    recordedDrives = [DriveRecord]()
                    let currentDriveRecord = DriveRecord(milesDriven: Double(distanceTraveled), timeRecorded: self.getDateString(dateRecorded, dateTo: finalDate, dateSubtract: finalDatePlusOne), pointsGenerated: String(pointsGenerated))
                    recordedDrives += [currentDriveRecord]
                    self.tableView.reloadData()
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
                } else {
                    // The user has not recorded any drives yet so show a different screen that lets the user know this.
                    
                    var emptyLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
                    emptyLabel.text = "You have not recorded any drives yet. "
                    emptyLabel.textAlignment = NSTextAlignment.Center
                    self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
                    let hexChanger = HexToUIColor()
                    emptyLabel.textColor = hexChanger.hexStringToUIColor("#5c5c5c")
                    self.tableView.backgroundView = emptyLabel
                }
                
            })

        }

    }
    
    func compareDate(firstDate: NSDate, secondDate: NSDate) -> Bool {
        
        let calendar = NSCalendar.currentCalendar()
        
        let firstDay = calendar.component(.Day, fromDate: firstDate)
        let secondDay = calendar.component(.Day, fromDate: secondDate)
        
        if (firstDay != secondDay) {
            
            return true
        } else {
            return false
        }

    }
    
    func getDateString(currentDate: NSDate, dateTo: NSDate, dateSubtract: NSDate) -> String {
        
        var strDate: String
        
        let calendar = NSCalendar.currentCalendar()
        
        let hours = calendar.component(.Hour, fromDate: currentDate)
        let minutes = calendar.component(.Minute, fromDate: currentDate)
        
        if(hours < 12) {
            if (hours == 0) {
                if (minutes < 10) {
                    strDate = "\(12):0\(minutes) AM"
                } else {
                    strDate = "\(12):\(minutes) AM"
                }
            } else if (minutes < 10) {
               strDate = "\(hours):0\(minutes) AM"
            } else {
                strDate = "\(hours):\(minutes) AM"
            }
            
        } else {
            if (hours == 12){
                if (minutes < 10) {
                    strDate = "\(hours):0\(minutes) PM"
                } else {
                    strDate = "\(hours):\(minutes) PM"
                }
            } else {
                if (minutes < 10) {
                    strDate = "\(hours-12):0\(minutes) PM"
                } else {
                    strDate = "\(hours-12):\(minutes) PM"
                }
            }
            
        }
        
        return strDate
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            if (senderViewController == "Points") {
                let menu = segue.destinationViewController as! HomeNavigationViewController
                let targetController = menu.topViewController as! HomeViewController
                targetController.profile = true
                menu.transitioningDelegate = self.transitionManager
                self.transitionManager.menuViewController = menu
            } else {
                let menu = segue.destinationViewController as! HomeNavigationViewController
                menu.transitioningDelegate = self.transitionManager
                self.transitionManager.menuViewController = menu
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dailyRecords.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dailyRecords[section].recordedDrives.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let recordedDrive = dailyRecords[indexPath.section].recordedDrives[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath)
        as! PointsHistoryTableViewCell
        
        cell.distanceLabel.text = String(format:"%.1f", recordedDrive.milesDriven!)
        cell.timeLabel.text = recordedDrive.timeRecorded
        cell.pointsLabel.text = recordedDrive.pointsGenerated

        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dailyRecords[section].dateRecorded
    }
    
    // MARK: - Table View Delegate Methods
    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel!.font = UIFont(name: "HelveticaNeue-Thin", size: 14.0)
        }
        
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

extension NSDate
{
    func isGreaterThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedDescending
        {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
    
    
    func isLessThanDate(dateToCompare : NSDate) -> Bool
    {
        //Declare Variables
        var isLess = false
        
        //Compare Values
        if self.compare(dateToCompare) == NSComparisonResult.OrderedAscending
        {
            isLess = true
        }
        
        //Return Result
        return isLess
    }
    
    
    func addDays(daysToAdd : Int) -> NSDate
    {
        let secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        let dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        let secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        let dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}
