//
//  PointsHistoryTableViewController.swift
//  Passenger
//
//  Created by Connor Myers on 11/19/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit
import Parse
import Bolts

class PointsHistoryTableViewController: UITableViewController {
    
    // MARK: Properties
    
    let transitionManager = MenuTransitionManager()
    
    let cellIdentifier = "PointsHistoryTableViewCell"

    var dailyRecords = [DayDriveRecorded]()
    
    var currentDriveDateIteration: NSDate?
    
    var currentUser: PFUser?
    
    var dateFormatter = NSDateFormatter()
    var readableDateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentUser = PFUser.currentUser()
        configureView()
        //loadSampleDrives()
        loadPreviousDrives()
        
        self.transitionManager.sourceViewController = self
    }
    
    func configureView() {
        
        dateFormatter.dateFormat = "HH:mm"
        readableDateFormatter.dateStyle = NSDateFormatterStyle.LongStyle
        
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
        
        let query = PFQuery(className:"PointsHistory")
        query.orderByAscending("createdAt")
        query.whereKey("userID", equalTo: currentUser!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) rewards.")
                // Do something with the found objects gameScore["playerName"] as String
                var i = 0
                if let objects = objects {
                    var recordedDrives = [DriveRecord]()
                    var dateRecorded = NSDate()
                    var finalDatePlusOne = NSDate()
                    var pointsGenerated = Int()
                    var distanceTraveled = Double()
                    var finalDate = NSDate()
                    for object in objects {
                        
                        distanceTraveled = object["distanceTraveled"] as! Double
                        pointsGenerated = object["pointsGenerated"] as! Int
                        dateRecorded = object.createdAt!
                        
                        
                        
                        let date = NSDate()
                        let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                        let newDate = cal.startOfDayForDate(date)
                        let finalDate = newDate.dateByAddingTimeInterval(60*60*12)
                        finalDatePlusOne = newDate.dateByAddingTimeInterval(60*60*13)
                        let newStr = self.dateFormatter.stringFromDate(finalDate)
                        
                        if (i == 0) {
                            self.currentDriveDateIteration = dateRecorded
                            let currentDriveRecord = DriveRecord(milesDriven: Double(distanceTraveled), timeRecorded: self.getDateString(dateRecorded, dateTo: finalDate, dateSubtract: finalDatePlusOne), pointsGenerated: "+\(pointsGenerated)")
                            recordedDrives += [currentDriveRecord]
                        } else if (dateRecorded.isLessThanDate(self.currentDriveDateIteration!)) {
                            // The date is less than the previous date, therefore, create a new iteration in the array
                            self.currentDriveDateIteration = dateRecorded
                            let dateString = self.readableDateFormatter.stringFromDate(self.currentDriveDateIteration!)
                            let dayRecord = DayDriveRecorded(dateRecorded: dateString, recordedDrives: recordedDrives)
                            self.dailyRecords += [dayRecord]
                            recordedDrives = [DriveRecord]()
                            let currentDriveRecord = DriveRecord(milesDriven: Double(distanceTraveled), timeRecorded: self.getDateString(dateRecorded, dateTo: finalDate, dateSubtract: finalDatePlusOne), pointsGenerated: "+\(pointsGenerated)")
                            recordedDrives += [currentDriveRecord]
                        } else {
                            // The dates are the same, just add the curentDrivePoint to the array
                            let currentDriveRecord = DriveRecord(milesDriven: Double(distanceTraveled), timeRecorded: self.getDateString(dateRecorded, dateTo: finalDate, dateSubtract: finalDatePlusOne), pointsGenerated: "+\(pointsGenerated)")
                            recordedDrives += [currentDriveRecord]
                        }
                        self.tableView.reloadData()
                        i = i + 1
                    }
                    self.currentDriveDateIteration = dateRecorded
                    let dateString = self.readableDateFormatter.stringFromDate(self.currentDriveDateIteration!)
                    let dayRecord = DayDriveRecorded(dateRecorded: dateString, recordedDrives: recordedDrives)
                    self.dailyRecords += [dayRecord]
                    recordedDrives = [DriveRecord]()
                    let currentDriveRecord = DriveRecord(milesDriven: Double(distanceTraveled), timeRecorded: self.getDateString(dateRecorded, dateTo: finalDate, dateSubtract: finalDatePlusOne), pointsGenerated: String(pointsGenerated))
                    recordedDrives += [currentDriveRecord]
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        self.tableView.reloadData()
    }
    
    func getDateString(var currentDate: NSDate, dateTo: NSDate, dateSubtract: NSDate) -> String {
        
        var strDate: String
        
        if(currentDate.isLessThanDate(dateTo)) {
            strDate = dateFormatter.stringFromDate(currentDate)
            strDate = "\(strDate) AM"
        } else {
            if (currentDate.isLessThanDate(dateSubtract)){
                strDate = dateFormatter.stringFromDate(currentDate)
                strDate = "\(strDate) PM"
            } else {
                currentDate = currentDate.dateByAddingTimeInterval(-60*60*12)
                strDate = dateFormatter.stringFromDate(currentDate)
                strDate = "\(strDate) PM"
            }
            
        }
        
        return strDate
    }
    
    /*
    func loadSampleDrives() {
        let driveRecord1 = DriveRecord(milesDriven: 12.2, timeRecorded: "10:09 AM", pointsGenerated: "+412")
        let driveRecord2 = DriveRecord(milesDriven: 32.1,timeRecorded: "9:56 PM",pointsGenerated: "+1212")
        let driveRecord3 = DriveRecord(milesDriven: 3.5,timeRecorded: "11:52 PM",pointsGenerated: "+112")
        
        recordedDrives += [driveRecord1, driveRecord2, driveRecord3]
        
        let driveRecord4 = DriveRecord(milesDriven: 112.2, timeRecorded: "12:09 PM", pointsGenerated: "+2512")
        let driveRecord5 = DriveRecord(milesDriven: 2.1,timeRecorded: "9:56 PM",pointsGenerated: "+12")
        
        recordedDrives2 += [driveRecord4, driveRecord5]
        
        let driveRecord6 = DriveRecord(milesDriven: 10.0, timeRecorded: "6:09 AM", pointsGenerated: "+312")
        let driveRecord7 = DriveRecord(milesDriven: 24.1,timeRecorded: "9:56 AM",pointsGenerated: "+893")
        let driveRecord8 = DriveRecord(milesDriven: 13.5,timeRecorded: "7:52 PM",pointsGenerated: "+667")
        let driveRecord9 = DriveRecord(milesDriven: 6.5,timeRecorded: "10:47 PM",pointsGenerated: "+207")
        
        recordedDrives3 += [driveRecord6, driveRecord7, driveRecord8, driveRecord9]
        
        let dayRecord1 = DayDriveRecorded(dateRecorded: "Oct 3, 2015", recordedDrives: recordedDrives)
        let dayRecord2 = DayDriveRecorded(dateRecorded: "Oct 1, 2015", recordedDrives: recordedDrives2)
        let dayRecord3 = DayDriveRecorded(dateRecorded: "Sep 29, 2015", recordedDrives: recordedDrives3)
        
        dailyRecords += [dayRecord1,dayRecord2,dayRecord3]
        
    }*/
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "presentMenu") {
            // set transition delegate for our menu view controller
            let menu = segue.destinationViewController as! HomeNavigationViewController
            menu.transitioningDelegate = self.transitionManager
            self.transitionManager.menuViewController = menu
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
        var secondsInDays : NSTimeInterval = Double(daysToAdd) * 60 * 60 * 24
        var dateWithDaysAdded : NSDate = self.dateByAddingTimeInterval(secondsInDays)
        
        //Return Result
        return dateWithDaysAdded
    }
    
    
    func addHours(hoursToAdd : Int) -> NSDate
    {
        var secondsInHours : NSTimeInterval = Double(hoursToAdd) * 60 * 60
        var dateWithHoursAdded : NSDate = self.dateByAddingTimeInterval(secondsInHours)
        
        //Return Result
        return dateWithHoursAdded
    }
}
