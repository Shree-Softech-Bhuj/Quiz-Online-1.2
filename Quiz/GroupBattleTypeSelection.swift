import UIKit
import Firebase
import FirebaseAuth

class GroupBattleTypeSelection: UIViewController {    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = Apps.GROUP_BTL
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
       //hide current view if user tap twice ,other than email txt
        self.hideCurrViewWhenTappedAround()
    }
         
    @IBAction func closeView(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func createRoom(_ sender: Any) {
        //show battle group View if category selection is not enabled / and if enabled - then open categoryView.
    }
    
    @IBAction func JoinRoom(_ sender: Any) {
        //enter room code and join / play group battle
    }
    
} 
