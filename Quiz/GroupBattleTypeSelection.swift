import UIKit
import Firebase
import FirebaseAuth

class GroupBattleTypeSelection: UIViewController {    
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = Apps.GROUP_BTL
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
         
    @IBAction func closeView(_ sender: Any) {
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createRoom(_ sender: Any) {
        //show battle group View if category selection is not enabled / and if enabled - then open categoryView.
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if Apps.GROUP_BATTLE_WITH_CATEGORY == "1"{
                print("battle with category")
                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let viewCont = storyboard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
                    //pass value to identify to jump to battle and not play quiz view.
                    viewCont.isGroupCategoryBattle = true
                    self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
                print("battle without category")
               // self.dismiss(animated: false, completion:{
                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let viewCont = storyboard.instantiateViewController(withIdentifier: "GroupBattleView") as! GroupBattleView //"PrivateRoomView"
                    viewCont.isUserJoininig = false
                    self.navigationController?.pushViewController(viewCont, animated: true)
               // })
            }
        }else{
//            self.dismiss(animated: false, completion:{
            self.navigationController?.popToRootViewController(animated: true)
//            })
        }
    }
    
    @IBAction func JoinRoom(_ sender: Any) {
        //enter room code and join / play group battle
       /* let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "EnterInGroupBattleAlert") as! EnterInGroupBattleAlert
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//        hideContentController(content: myAlert)
//        displayContentController(content:myAlert)
        self.present(myAlert, animated: true, completion: nil)*/
        
       // self.dismiss(animated: false, completion:{
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "EnterInGroupBattleAlert") as! EnterInGroupBattleAlert
            self.navigationController?.pushViewController(viewCont, animated: true)
       // })
    }
} 
