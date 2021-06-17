//
//  AvailUserListCell.swift
//  Themiscode Q&A
//
//  Created by LPK's Mini on 23/11/20.
//  Copyright © 2020 LPK Techno. All rights reserved.
//

import UIKit

class AvailUserListCell: UITableViewCell {

    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var inviteButton:UIButton!
    @IBOutlet weak var userView:UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.userImage.layer.cornerRadius = self.userImage.frame.height / 2
        self.userImage.layer.borderWidth = 1
        self.userImage.layer.borderColor = Apps.COLOR_DARK_RED.cgColor
        
        self.inviteButton.layer.cornerRadius = 4
        self.userView.layer.addBorder(edge: .bottom, color: Apps.COLOR_DARK_RED, thickness: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
