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
    var crossStreets: String?
    var company: PFObject?
    
    init(rewardType: String, companyName: String, backgroundImage: UIImage, crossStreets: String, company: PFObject) {
        self.rewardType = rewardType
        self.companyName = companyName
        self.backgroundImage = backgroundImage
        self.crossStreets = crossStreets
        self.company = company
    }
    
    func getCompany() -> PFObject {
        return self.company!
    }
    
    func setCompany(company: PFObject) {
        self.company = company
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