//
//  PointsHistoryTableViewCell.swift
//  Passenger
//
//  Created by Connor Myers on 11/19/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit

class PointsHistoryTableViewCell: UITableViewCell {

    // MARK: Properties 
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
