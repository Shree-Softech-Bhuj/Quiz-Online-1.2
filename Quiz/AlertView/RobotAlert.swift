

import UIKit

class RobotAlert: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    var imageUrl = ""
    var parentController:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        mainView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 20)
        bottomView.addTopBorderWithColor(color: .black, width: 1)
        
        if !imageUrl.isEmpty{
            userImage.loadImageUsingCache(withUrl: imageUrl)
        }
        
         NotificationCenter.default.addObserver(self,selector: #selector(self.DismissAlert),name: NSNotification.Name(rawValue: "DismissAlert"),object: nil)
    }
    
    @IBAction func PlayWithRobot(_ sender: Any) {
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let bpc: RobotPlayView = storyBoard.instantiateViewController(withIdentifier: "RobotPlayController") as! RobotPlayView
        
        self.present(bpc, animated: true, completion: nil)
    }
    
    @IBAction func TryAgainBtn(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("CompleteBattle"), object: nil)
        NotificationCenter.default.post(name: Notification.Name("CheckBattle"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func ExitBtn(_ sender: Any) {
        NotificationCenter.default.post(name: Notification.Name("CloseBattleViewController"), object: nil)
        parentController?.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func DismissAlert(){
        self.dismiss(animated: true, completion: nil)
    }
}
