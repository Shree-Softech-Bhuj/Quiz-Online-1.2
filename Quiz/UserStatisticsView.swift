//
//  UserStatisticsView.swift
//  Quiz
//
//  Created by Bhavesh Kerai on 01/02/20.
//  Copyright © 2020 LPK Techno. All rights reserved.
//

import UIKit

class UserStatisticsView: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    var userDefault:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefault = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        
        userName.text = "Hello, \(userDefault!.name)"
        
        self.userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.layer.masksToBounds = true
        userImage.layer.borderWidth = 1.5
        userImage.layer.borderColor = UIColor.black.cgColor
        
        DispatchQueue.main.async {
            if(self.userDefault!.image != ""){
                self.userImage.loadImageUsingCache(withUrl: self.userDefault!.image)
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
