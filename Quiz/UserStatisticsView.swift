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
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var attendQuesLabel: UILabel!
    @IBOutlet weak var correctQuesLabel: UILabel!
    @IBOutlet weak var inCorrectQuesLabel: UILabel!
    @IBOutlet weak var strongCatLabel: UILabel!
    @IBOutlet weak var weakCatLabel: UILabel!
    @IBOutlet weak var strongPerLabel: UILabel!
    @IBOutlet weak var weakPerLabel: UILabel!
    @IBOutlet weak var strongProgress: UIProgressView!
    @IBOutlet weak var weakProgress: UIProgressView!
    
    var userDefault:User? = nil
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userDefault = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        
        userName.text = "Hello, \(userDefault!.name)"
        
        let score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        coinsLabel.text = "\(score.coins)"
        scoreLabel.text = "\(score.points)"
        
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
        
        strongProgress.progress = 0.0
        weakProgress.progress = 0.0
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "user_id=\(userDefault!.userID)"
            self.getAPIData(apiName: "get_users_statistics", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
            
        }else{
            //get data for category
            
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                DispatchQueue.main.async {
                    let ques = Int("\(data["questions_answered"]!)")
                    let corr = Int("\(data["correct_answers"]!)")
                    
                    self.attendQuesLabel.text = "\(ques!)"
                    self.correctQuesLabel.text = "\(corr!)"
                    self.inCorrectQuesLabel.text = "\(ques! - corr!)"
                    
                    self.strongCatLabel.text = "\(data["strong_category"]!)"
                    self.weakCatLabel.text = "\(data["weak_category"]!)"
                    
                    let strongP = Float("\(data["ratio1"]!)")
                    let weakP = Float("\(data["ratio2"]!)")
                    self.strongPerLabel.text = "\(strongP!)%"
                    self.weakPerLabel.text = "\(weakP!)%"
                    
                    self.strongProgress.progress = strongP! / 100.0
                    self.weakProgress.progress = weakP! / 100.0
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
