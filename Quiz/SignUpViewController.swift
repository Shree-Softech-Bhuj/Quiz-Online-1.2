import UIKit
import FirebaseAuth
import Firebase
import FirebaseCore
import GoogleSignIn
import Foundation
//import FBSDKLoginKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var name: FloatingTF!
    @IBOutlet weak var email: FloatingTF!
    @IBOutlet weak var password: FloatingTF!
    @IBOutlet weak var referralCode: FloatingTF!
    @IBOutlet weak var pswdButton: UIButton!
    
    var ref: DatabaseReference!
        
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()//.child("users") //as it already have users, so no need to add it
        
        self.hideKeyboardWhenTappedAround()
    }
    
    //load category data here
          func LoadData(jsonObj:NSDictionary){
            print("RS",jsonObj.value(forKey: "data")!)
              let status = jsonObj.value(forKey: "error") as! String
              if (status == "true") {
                  self.Loader.dismiss(animated: true, completion: {
                      self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "status")!)" )
                  })
              }else{
                  //get data for category
                if let data = jsonObj.value(forKey: "data") {
                    print("else part \(data)")
//                    guard let optE = data as? [String:Any] else{
//                        return //Apps.opt_E = false //"0"
//                    }                    
                  }
              }
    //        for key in jsonObj {
    //            let value = jsonObj[key]
    //            print("Value:\(value ?? "value") - for key:\(key)");
    //        }
              //close loader here
              DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                  DispatchQueue.main.async {
                      self.DismissLoader(loader: self.Loader)
                  }
              });
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
        //create referernce to the data user enter
        let nameTxt = name.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let emailTxt =  email.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let passwordTxt = password.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let refCodeTxt = referralCode.text!.trimmingCharacters(in: .whitespacesAndNewlines)
       
         //chk for name As its not optional
        if  self.name.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""
          {
               self.name.becomeFirstResponder()
               let alert = UIAlertController(title: "", message: "Please Enter Name", preferredStyle: UIAlertController.Style.alert)
                   alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                   self.present(alert, animated: true)
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
               //set frnd code
                UserDefaults.standard.set(refCodeTxt, forKey: "fr_code")
                
                //store data to realtime database of firebase as user created successfully
                let key = self.ref.childByAutoId().key
                let user = [
                    "uid": key,
                    "name" : nameTxt ,
                    "ref_code" : refCodeTxt
                ]                
                self.ref.child("users").child(key!).setValue(user){(error:Error?, ref:DatabaseReference) in
                  if let error = error {
                     let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                     self.present(alert, animated: true)
                     print("error - \(error.localizedDescription)")
                  } else {
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
                    }//else of reference error
                } //end of reference
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
