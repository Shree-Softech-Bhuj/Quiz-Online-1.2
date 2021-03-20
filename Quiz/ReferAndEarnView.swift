import UIKit

class ReferAndEarnView: UIViewController {

    @IBOutlet weak var referBtn: UIButton!
    @IBOutlet weak var referCode: UILabel!
    
    @IBOutlet weak var referText: UILabel!
    
    var dUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        referText.text = "\(Apps.REFER_MSG1) \(Apps.EARN_COIN) \(Apps.REFER_MSG2) \(Apps.REFER_COIN) \(Apps.REFER_MSG3)"
        
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print("user details \(dUser!) ")
        referCode.text = dUser?.ref_code
        referCode.layer.borderWidth = 1.0
        referCode.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        referBtn.layer.cornerRadius = referBtn.frame.height / 3 //referBtn.bounds.size.height/2 //20
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        //copy refercode to clipboard
        UIPasteboard.general.string = referCode.text
        ShowAlertOnly(title: "", message: Apps.REFER_CODE_COPY)
    }
    
    @IBAction func referNow(_ sender: Any) {
      
        let shareText = Apps.SHARE_APP_TXT
        guard let url = URL(string: Apps.SHARE_APP) else { return }
        let msgTxt = "\(Apps.SHARE_MSG) \" \(referCode.text!) \" "
        let shareContent: [Any] = [shareText, msgTxt,"\n", url]
        let activityController = UIActivityViewController(activityItems: shareContent,applicationActivities: nil)
        activityController.popoverPresentationController?.sourceView = sender as! UIView 
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
       }
}
