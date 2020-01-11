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
     
    @IBOutlet weak var pswdButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //create referernce to the data user enter
//        var nameTxt = ""
//        var emailTxt =  ""
//        var passwordTxt = ""
//        var refCodeTxt = ""
        
        self.hideKeyboardWhenTappedAround()
    }
      @IBAction func pswdBtn(_ sender: UIButton) {
    //            guard let image = UIImage(named: "unlock") else {
    //                       print("Image Not Found")
    //                       return
    //                   }
        //change img/icon accordingly and set text secure and unsecure as button tapped
        if password.isSecureTextEntry == true {
                pswdButton.setImage(UIImage(named: "unlock"), for: UIControlState.normal)
                password.isSecureTextEntry = false
            }else{
               // pswdButton.setImage(image, for: UIControlState.normal)
                pswdButton.setImage(UIImage(named: "lock"), for: UIControlState.normal)
                password.isSecureTextEntry = true
            }
        }
    @IBAction func SignupUser(_ sender: Any) {
        //"refer_code"
        //create referernce to the data user enter
        let nameTxt = name.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailTxt =  email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTxt = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let refCodeTxt = referralCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
//        //validate fields
//        if  name.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
//            name.placeholder? = ("Please enter Name Here")
//            name.placeHolderColor = UIColor.red
//        }else{
//            name.placeholder? = ("Name")
//        }
//        if  email.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//            email.placeholder? = ("Please enter Email Here")
//            email.placeHolderColor = UIColor.red
//        }else{
//            email.placeholder? = ("Email")
//        }
//        if password.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
//           password.placeholder? = ("Please enter Password Here")
//           password.placeHolderColor = UIColor.red
//        }else{
//            password.placeholder? = ("Password")
//        }
         var providers = ""
         //chk for name As its not optional
        if  self.name.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
          {
               self.name.becomeFirstResponder()
               let alert = UIAlertController(title: "", message: "Please Enter Name", preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true)
                  
//         }else if providers = Auth.auth().fetchSignInMethods(forEmail: emailTxt, completion: <#T##SignInMethodQueryCallback?##SignInMethodQueryCallback?##([String]?, Error?) -> Void#>) {
//            //chk for user authentication as its email id is not used with fb or google already! if return true then dnt allow to save data / signup
        }else{
         //create a user
         Auth.auth().createUser(withEmail: emailTxt, password: passwordTxt) { (result, err) in
            if err != nil {
                let error_descr = err?.localizedDescription
                if error_descr != nil {
                    print(" error -- creating user \(error_descr!)")
                    let alert = UIAlertController(title: "", message: error_descr!, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                    //self.showError(error_descr!)
                }
                else{
                    print("Error Creating User")
                    let alert = UIAlertController(title: "", message: "Error Creating User", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                    //self.showError("Error Creating User")
                }
                    //self.showError("Error Creating User") // for general use
                print("Error Creating User")
                let alert = UIAlertController(title: "", message: "Error Creating User", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true)
            }
            else {
            //store first name & last name as user created successfully
              //Firestore.firestore().collection("users").document(email).setData(emailTxt)
                
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
                                        print("user verification email sent")
                                        let alert = UIAlertController(title: "", message: "User verification email sent", preferredStyle: UIAlertController.Style.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                                            self.dismissCurrView()
                                            let subView = self.storyboard!.instantiateViewController(withIdentifier: "ViewController")
                                            self.present(subView, animated: true, completion: nil)
                                          }))
                                        return self.present(alert, animated: true, completion: nil)
                                         // return myAlert("user email verification sent")
                                 }
                                let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                                self.present(alert, animated: true)
                                print("error - \(error.localizedDescription)")
                               // myAlert(error.localizedDescription)
                             }
                        }
                    } // else of db.collection
                 } //db.collection
              } //else inside else
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
//        func myAlert(_ msg: String) {
//            let alert = UIAlertController(title: "", message: msg, preferredStyle: UIAlertController.Style.alert)
//            // add the actions (buttons)
//            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//
//            // show the alert
//            self.present(alert, animated: true, completion: nil)
//            //alert.view.tintColor = UIColor.red //alert Action font color changes to red
//        }
    }
}
