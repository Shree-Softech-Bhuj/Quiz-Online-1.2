//
//  RoomListCell.swift
//  Themiscode Q&A
//
//  Created by LPK's Mini on 25/11/20.
//  Copyright © 2020 LPK Techno. All rights reserved.
//

import UIKit

class RoomListCell: UITableViewCell {

    @IBOutlet weak var roomCatNate:UILabel!
    @IBOutlet weak var roomDetails:UILabel!
    @IBOutlet weak var roomView:LPKGradient!
    @IBOutlet weak var joinButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.roomView.layer.cornerRadius = 10
        self.joinButton.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
