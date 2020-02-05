//
//  BattleStatisticsCell.swift
//  Quiz
//
//  Created by Bhavesh Kerai on 05/02/20.
//  Copyright © 2020 LPK Techno. All rights reserved.
//

import UIKit

class BattleStatisticsCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var opponentImage: UIImageView!
    @IBOutlet weak var opponentName: UILabel!
    @IBOutlet weak var matchStatusLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
