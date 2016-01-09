//
//  DayDriveRecorded.swift
//  Passenger
//
//  Created by Connor Myers on 11/19/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import Foundation

class DayDriveRecorded {
    
    var recordedDrives = [DriveRecord]()
    var dateRecorded: String?
    
    init(dateRecorded: String, recordedDrives: [DriveRecord]) {
        self.dateRecorded = dateRecorded
        self.recordedDrives = recordedDrives
    }
    
    func setDateRecorded(dateRecorded: String) {
        self.dateRecorded = dateRecorded
    }
    
    func addDrive(drive: DriveRecord) {
        recordedDrives += [drive]
    }
    
    func getRecordedDrivesCount() -> Int {
        return recordedDrives.count
    }
    
}