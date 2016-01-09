//
//  RankingTableViewCell.swift
//  Passenger
//
//  Created by Connor Myers on 11/29/15.
//  Copyright © 2015 Astral. All rights reserved.
//

import UIKit

class RankingTableViewCell: UITableViewCell {

    @IBOutlet weak var totalPoints: UILabel!
    @IBOutlet weak var userFullName: UILabel!
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var currentRanking: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
