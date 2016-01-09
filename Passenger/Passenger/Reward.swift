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
    var rewardPrice: Int?
    var rewardDescription: String = ""
    var rewardType: String = ""
    var rewardName: String = ""
    
    init() {
        
    }
    
    init(companyName: String, pointCost: Int, rewardImage: UIImage, rewardPrice: Int, rewardDescription: String, rewardName: String) {
        self.companyName = companyName
        self.pointCost = pointCost
        self.rewardImage = rewardImage
        self.rewardPrice = rewardPrice
        self.rewardDescription = rewardDescription
        self.rewardName = rewardName
    }
    
    func getCompanyName() -> String {
        return self.companyName
    }
    
    func setCompanyName(companyName: String) {
        self.companyName = companyName
    }
    
    func getRewardPrice() -> Int {
        return self.rewardPrice!
    }
    
    func setRewardPrice(rewardPrice: Int) {
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
    
}