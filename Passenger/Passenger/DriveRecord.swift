//
//  DriveRecord.swift
//  Passenger
//
//  Created by Connor Myers on 11/19/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import Foundation

class DriveRecord {
    
    var milesDriven: Double?
    var timeRecorded: String?
    var pointsGenerated: String?
    
    init(milesDriven: Double, timeRecorded: String, pointsGenerated: String) {
        self.milesDriven = milesDriven
        self.timeRecorded = timeRecorded
        self.pointsGenerated = pointsGenerated
        
    }
    
}