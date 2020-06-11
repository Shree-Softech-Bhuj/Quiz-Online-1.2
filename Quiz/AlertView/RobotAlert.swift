import UIKit

class RobotAlert: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var playWithRobot: UIButton!
    @IBOutlet weak var tryAgain: UIButton!
    
    var imageUrl = ""
    var parentController:UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if !imageUrl.isEmpty{
            userImage.loadImageUsingCache(withUrl: imageUrl)
        }
        
         NotificationCenter.default.addObserver(self,selector: #selector(self.DismissAlert),name: NSNotification.Name(rawValue: "DismissAlert"),object: nil)
        
        mainView.SetShadow()
        playWithRobot.layer.cornerRadius = 20
        tryAgain.layer.cornerRadius = 20
        
    }
    
    @IBAction func PlayWithRobot(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "RobotPlayController")
        self.navigationController?.pushViewController(viewCont, animated: true)
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
