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
    var distanceToLocation: Double?
    var merchantEmail: String?
    var merchantLatitude: Double?
    var currentMerchantIndex: Int?
    
    init(rewardType: String, companyName: String, backgroundImage: UIImage, crossStreets: String, sixDigitIdentifier: Int, rewards: NSArray, distanceToLocation: Double, merchantEmail: String, merchantLatitude: Double, currentMerchantIndex: Int) {
        self.rewardType = rewardType
        self.companyName = companyName
        self.backgroundImage = backgroundImage
        self.crossStreets = crossStreets
        self.sixDigitIdentifier = sixDigitIdentifier
        self.rewards = rewards
        self.distanceToLocation = distanceToLocation
        self.merchantEmail = merchantEmail
        self.merchantLatitude = merchantLatitude
        self.currentMerchantIndex = currentMerchantIndex
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
    
    func getDistance() -> Double {
        return self.distanceToLocation!
    }
    
    func getMerchantEmail() -> String {
        return self.merchantEmail!
    }
    
    func getLatitude() -> Double {
        return self.merchantLatitude!
    }
    
    func getMerchantIndex() -> Int {
        return self.currentMerchantIndex!
    }
    
}
