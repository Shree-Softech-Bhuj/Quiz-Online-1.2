

import UIKit

class ResultAlert: UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    var winnerName = ""
    var winnerImg = ""
    var parentController:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userName.text = winnerName
        if winnerName == "Robot"{
            userImage.image = UIImage(named: "robot")
        }else{
            if !winnerImg.isEmpty {
                DispatchQueue.main.async {
                    self.userImage.loadImageUsingCache(withUrl: self.winnerImg)
                }
            }
        }
        
    }
    
    @IBAction func RebattleBtn(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name("CloseRobotPlay"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("CompleteBattle"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("CheckBattle"), object: nil)
         parentController?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
}
    
    @IBAction func BattleExitBtn(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("CompleteBattle"), object: nil)// call this function to clear data to firebase
        NotificationCenter.default.post(name: Notification.Name("CloseRobotPlay"), object: nil)// this will close if user play with robot to close robotplayviewcontroller
        NotificationCenter.default.post(name: Notification.Name("CloseBattleViewController"), object: nil)
        parentController?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
