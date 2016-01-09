//
//  RewardGroup.swift
//  Passenger
//
//  Created by Connor Myers on 11/24/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import Foundation
import UIKit

class RewardGroup {

    var rewardType: String?
    var companyName: String?
    var backgroundImage: UIImage?
    
    init(rewardType: String, companyName: String, backgroundImage: UIImage) {
        self.rewardType = rewardType
        self.companyName = companyName
        self.backgroundImage = backgroundImage
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