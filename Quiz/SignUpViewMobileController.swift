import UIKit
import FirebaseAuth

class SignUpViewMobileController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var name: FloatingTF!
    @IBOutlet weak var countryCode: FloatingTF!
    @IBOutlet weak var phoneNumber: FloatingTF!
    @IBOutlet weak var referralCode: FloatingTF!
    @IBOutlet weak var btnSignUp: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
        
        btnSignUp.setBorder()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: textField.center.y-40), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool { //to move cursor to next textfield
              if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
                  nextField.becomeFirstResponder()
              }else {
                 textField.resignFirstResponder()
             }
        
                if textField.tag == 1 { // incase of country code
                  if (self.countryCode.text!.contains("+") == false){
                      self.countryCode.text = "+\(self.countryCode.text!)"
                  }
                }
              return false
           }
       
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SignupUser(_ sender: Any) {
       // print("length of num: \(self.phoneNumber.text?.count)")
        //chk for all text fields
        if  (self.phoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "") || (self.phoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines).count < 10)
        {
            self.phoneNumber.becomeFirstResponder()
            let alert = UIAlertController(title: "", message: Apps.MSG_NUM, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        }else  if  (self.countryCode.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "") || (self.countryCode.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "+") || (self.countryCode.text!.contains("+") == false)
        {
            self.countryCode.becomeFirstResponder()
            let alert = UIAlertController(title: "", message: Apps.MSG_CC, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        }else if  self.name.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
        {
            self.name.becomeFirstResponder()
            let alert = UIAlertController(title: "", message: Apps.MSG_NM, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        }else{
            let phnNum = "\(countryCode.text!.trimmingCharacters(in: .whitespacesAndNewlines))"+"\((phoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines)))"
            //send code to entered phone number
            PhoneAuthProvider.provider().verifyPhoneNumber(phnNum, uiDelegate: nil) { (verificationID, error) in
              if let error = error {
                print(error)
                self.ShowAlert(title: Apps.ERROR, message: error.localizedDescription)
                return
              }
                // Change language code to language entered in Apps.lang
                Auth.auth().languageCode = "\(Apps.LANG)"
                UserDefaults.standard.set(verificationID!, forKey: "authVerificationID")
                print("set verif. ID \(verificationID!)")
                
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = storyboard.instantiateViewController(withIdentifier: "OTPController") as! OTPController
                self.navigationController?.pushViewController(viewCont, animated: true)
                viewCont.name = self.name.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                viewCont.phnNum = "\(self.countryCode.text!.trimmingCharacters(in: .whitespacesAndNewlines))"+"\((self.phoneNumber.text!.trimmingCharacters(in: .whitespacesAndNewlines)))"
                viewCont.frndCode = self.referralCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
    }
}
