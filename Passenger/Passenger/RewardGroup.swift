//
//  RewardGroup.swift
//  Passenger
//
//  Created by Connor Myers on 11/24/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class RewardGroup {

    var rewardType: String?
    var companyName: String?
    var backgroundImage: UIImage?
    var crossStreets: String?
    var sixDigitIdentifier: Int?
    var rewards: NSArray?
    
    init(rewardType: String, companyName: String, backgroundImage: UIImage, crossStreets: String, sixDigitIdentifier: Int, rewards: NSArray) {
        self.rewardType = rewardType
        self.companyName = companyName
        self.backgroundImage = backgroundImage
        self.crossStreets = crossStreets
        self.sixDigitIdentifier = sixDigitIdentifier
        self.rewards = rewards
    }
    
    func getRewards() -> NSArray {
        return self.rewards!
    }
    
    func getCrossStreets() -> String {
        return self.crossStreets!
    }
    
    func setCrossStreets(crossStreets: String) {
        self.crossStreets = crossStreets
    }
    
    func getRewardType() -> String {
        return self.rewardType!
    }
    
    func setRewardType(rewardType: String) {
        self.rewardType = rewardType
    }
    
    func getCompanyName() -> String {
        return self.companyName!
    }
    
    func setCompanyName(companyName: String) {
        self.companyName = companyName
    }
    
    func getBackgroundImage() -> UIImage {
        return self.backgroundImage!
    }
    
    func setBackgroundImage(backgroundImage: UIImage) {
        self.backgroundImage = backgroundImage
    }
    
}