//
//  Reward.swift
//  Passenger
//
//  Created by Connor Myers on 11/24/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import Foundation
import UIKit

class Reward {
    
    var companyName: String = ""
    var pointCost: Int = 0
    var rewardImage: UIImage?
    var rewardPrice: Double?
    var rewardDescription: String = ""
    var rewardType: String = ""
    var rewardName: String = ""
    var rewardImageString: String = ""
    var imageLocation: String = ""
    
    init() {
        
    }
    
    init(companyName: String, pointCost: Int, rewardImage: UIImage, rewardPrice: Double, rewardDescription: String, rewardName: String, rewardImageString: String, imageLocation: String) {
        self.companyName = companyName
        self.pointCost = pointCost
        self.rewardImage = rewardImage
        self.rewardPrice = rewardPrice
        self.rewardDescription = rewardDescription
        self.rewardName = rewardName
        self.rewardImageString = rewardImageString
        self.imageLocation = imageLocation
    }
    
    func getCompanyName() -> String {
        return self.companyName
    }
    
    func setCompanyName(companyName: String) {
        self.companyName = companyName
    }
    
    func getRewardPrice() -> Double {
        return self.rewardPrice!
    }
    
    func setRewardPrice(rewardPrice: Double) {
        self.rewardPrice = rewardPrice
    }
    
    func getPointCost() -> Int {
        return self.pointCost
    }
    
    func setPointCost(pointCost: Int) {
        self.pointCost = pointCost
    }
    
    func getRewardImage() -> UIImage {
        return self.rewardImage!
    }
    
    func setRewardImage(rewardImage: UIImage) {
        self.rewardImage = rewardImage
    }
    
    func getDescription() -> String {
        return self.rewardDescription
    }
    
    func setDescription(rewardDescription: String) {
        self.rewardDescription = rewardDescription
    }
    
    func getRewardName() -> String {
        return self.rewardName
    }
    
    func setRewardName(rewardName: String) {
        self.rewardName = rewardName
    }
    
    func getRewardImageString() -> String {
        return self.rewardImageString
    }
    
    func getRewardImageLocation() -> String {
        return self.imageLocation
    }
    
}
