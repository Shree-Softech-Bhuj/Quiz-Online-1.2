import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import GoogleSignIn

//import FBSDKLoginKit


class SignUpViewController: UIViewController {
       
    
    @IBOutlet weak var name: FloatingTF!
    
    @IBOutlet weak var email: FloatingTF!
    
    @IBOutlet weak var password: FloatingTF!
    
    @IBOutlet weak var referralCode: FloatingTF!
        
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
//        let emailTxt = ""
//        email.text = emailTxt
        
//        var isInitial = true
//        var Loader: UIAlertController = UIAlertController()
        
        //create referernce to the data user enter
        var nameTxt = ""
        var emailTxt =  ""
        var passwordTxt = ""
        var refCodeTxt = ""
        
        self.hideKeyboardWhenTappedAround()
//        if email.isHidden == false {
//            if isValidEmail(email) == false {
//                //return "1"
//                email.text = ""
//                email.becomeFirstResponder()
//            }
//        }
    }
    @IBAction func SignupUser(_ sender: Any) {
        //"refer_code"
        //create referernce to the data user enter
        let nameTxt = name.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailTxt =  email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTxt = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let refCodeTxt = referralCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
       //create a user
        Auth.auth().createUser(withEmail: emailTxt, password: passwordTxt) { (result, err) in
            if err != nil {
                let error_descr = err?.localizedDescription
                if error_descr != nil {
                    print(error_descr!)
                    //self.showError(error_descr!)
                }
                else{
                    print("Error Creating User")
                    //self.showError("Error Creating User")
                }
                    //self.showError("Error Creating User") // for general use
            }
            else {
                //store first name & last name as user created successfully
                let db =  Firestore.firestore()
                db.collection("users").addDocument(data: ["name": nameTxt,"refcode": refCodeTxt,"uid": result!.user.uid ]) { (error) in
                    if error != nil {
                       // self.showError("Error Saving User Data")
                        print("Error Saving User Data")
                    }else{
                         //send verification link to given email id -> emailTxt here
                        guard let user = Auth.auth().currentUser else {
                           return signin(auth: Auth.auth())
                    }
                           user.reload { (error) in
                                     user.sendEmailVerification { (error) in
                                         guard let error = error else {
                                                print("user email verification sent")
                                             return myAlert("user email verification sent")
                                         }
                                        let alert = UIAlertController(title: "", message: "Error", preferredStyle: UIAlertController.Style.alert)
                                            // add the actions (buttons)
                                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                            // show the alert
                                            self.present(alert, animated: true, completion: nil)
                                        //myAlert("\(error)")
                                        //print(error)
                                     }
                             }
                    } // else of db.collection
                } //db.collection
            } //else
        } //signup user
        
//        let subView = self.storyboard!.instantiateViewController(withIdentifier: "ViewController")
//        self.present(subView, animated: true, completion: nil)
    
    
       func signin (auth: Auth){
               Auth.auth().signIn(withEmail: emailTxt, password: passwordTxt) { (result, error) in
                guard error == nil else {
                    return print(error!)
                }
                guard let user = result?.user else{
                    fatalError("User Not Found, Something went wrong")
                }
                print("Signed in user: \(user.email ?? emailTxt)")
        }
       }
        func myAlert(_ msg: String) {
            let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        
            // show the alert
            self.present(alert, animated: true, completion: nil)
            //alert.view.tintColor = UIColor.red //alert Action font color changes to red
            
        }
    
    }
        
   
//    func isValidEmail(_ testStr : FloatingTF) -> Bool {
//            //print("validate emilId: \(testStr)")
//            let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
//            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
//            return emailTest.evaluate(with: testStr)
//        }
}
