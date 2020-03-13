import UIKit

class ReferAndEarnView: UIViewController {

    @IBOutlet weak var referBtn: UIButton!
    @IBOutlet weak var referCode: UILabel!
    
    var dUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print("user details \(dUser!) ")
        referCode.text = dUser?.ref_code
        referCode.layer.borderWidth = 1.0
        referCode.layer.borderColor = UIColor.rgb(57, 129, 156, 1.0).cgColor//UIColor.systemBlue.cgColor
       // referCode.backgroundColor = UIColor(patternImage: UIImage(named: "dashed-frame")!)
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
        self.present(activityController, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: Any) {
           self.dismiss(animated: true, completion: nil)
       }
}
