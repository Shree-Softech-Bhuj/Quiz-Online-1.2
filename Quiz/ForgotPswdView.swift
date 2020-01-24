import UIKit
import Firebase
//import GoogleSignIn
import FirebaseAuth

class ForgotPswdView: UIViewController {
    
    @IBOutlet weak var email: FloatingTF!
    
    @IBOutlet weak var detailsView: UIView!
    
    var emailTxt = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        email.becomeFirstResponder()
       //hide current view if user tap twice ,other than email txt
        self.hideCurrViewWhenTappedAround()
    }
      
    func dismissView(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitBtn(_ sender: UIButton)
        {
        if email.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
                    email.placeholder? = "Please enter email id."
                    email.placeHolderColor = UIColor.red
                   // email.becomeFirstResponder()
             }
        else{
            //send new pswd link to given mail id
             Auth.auth().sendPasswordReset(withEmail: email.text ?? emailTxt, completion: { (error) in
                     //Make sure you execute the following code on the main queue
                     DispatchQueue.main.async {
                         //Use "if let" to access the error, if it is non-nil
                         if let error = error {
                             let resetFailedAlert = UIAlertController(title: "Reset Failed", message: error.localizedDescription, preferredStyle: .alert)
                             resetFailedAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            //do nothing or give chance to enter proper email
                            self.present(resetFailedAlert, animated: true, completion: nil)
                         } else {
                             let resetEmailSentAlert = UIAlertController(title: "To Reset Password, Email sent successfully", message: "Check your email", preferredStyle: .alert)
                            // resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                             resetEmailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                self.dismissView()
                            }))
                             self.present(resetEmailSentAlert, animated: true, completion: nil)
                         }
                     }
                 })
            }
     }
} 
