//
//  PointsDetailedTableViewCell.swift
//  Passenger
//
//  Created by Connor Myers on 11/24/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit

class PointsDetailedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var rewardCompanyBackgroundImage: UIImageView!
    @IBOutlet weak var rewardCompanyName: UILabel!
    @IBOutlet weak var crossStreetsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureView()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureView() {
        
    }

}
