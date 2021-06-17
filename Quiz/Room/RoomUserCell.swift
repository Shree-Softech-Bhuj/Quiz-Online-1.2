//
//  RoomUserCell.swift
//  Themiscode Q&A
//
//  Created by LPK's Mini on 23/11/20.
//  Copyright © 2020 LPK Techno. All rights reserved.
//

import UIKit

class RoomUserCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var userName:UILabel!
    
    var joinUser:JoinedUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userImage.layer.cornerRadius = 10
        userImage.layer.borderWidth = 2
        userImage.layer.masksToBounds = true
    }
    
    func ConfigCell(){
        if  let currUser = self.joinUser{
            
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            
            if user.UID == currUser.uID{
                userImage.layer.borderColor = Apps.COLOR_DARK_RED.cgColor
            }else{
                userImage.layer.borderColor = UIColor.white.cgColor
            }
            if !currUser.userImage.isEmpty{
                userImage.loadImageUsingCache(withUrl: currUser.userImage)
            }else{
                userImage.image = UIImage(named: "userAvtar")
            }
            userName.text = currUser.userName
            if currUser.isJoined{
                userName.textColor = Apps.COLOR_DARK_RED
            }else{
                userName.textColor = .lightGray
            }
        }else{
            userName.text = "???"
            userImage.image = UIImage(named: "userAvtar")
            userName.textColor = Apps.COLOR_DARK_RED
            
            userImage.layer.borderColor = UIColor.white.cgColor
        }
    }
}
