import UIKit

class ReferAndEarnView: UIViewController {

    @IBOutlet weak var referBtn: UIButton!
    @IBOutlet weak var referCode: UILabel!
    
    @IBOutlet weak var referText: UILabel!
    
    var dUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        referText.text = "Refer a Friend, and you will get \(Apps.EARN_COIN) coins each time your referral code is used and your friend will get \(Apps.REFER_COIN) coins by using your referral code "
        
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print("user details \(dUser!) ")
        referCode.text = dUser?.ref_code
        referCode.layer.borderWidth = 1.0
        referCode.layer.borderColor = UIColor.rgb(57, 129, 156, 1.0).cgColor
        referBtn.layer.cornerRadius = 20
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        //copy refercode to clipboard
        UIPasteboard.general.string = referCode.text
        ShowAlertOnly(title: "", message: "Refer Code Copied to Clipboard")
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
