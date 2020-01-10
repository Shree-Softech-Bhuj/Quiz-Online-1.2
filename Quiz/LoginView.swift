

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth

//class LoginView: UIViewController,GIDSignInDelegate,GIDSignInUIDelegate{
class LoginView: UIViewController,GIDSignInDelegate{
    
    //    @IBOutlet var fbBtn: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    @IBOutlet weak var guestView: UIView!
    
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var optView: UIView!
    @IBOutlet weak var loginSignUpView: UIView!
    @IBOutlet weak var pswdButton: UIButton!
    @IBOutlet weak var emailTxt: FloatingTF!
    @IBOutlet weak var pswdTxt: FloatingTF!
    
    
    //var iconClick = true //pswd text
    
    var email = ""
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate=self
        //GIDSignIn.sharedInstance().uiDelegate=self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        
        
        self.hideKeyboardWhenTappedAround() //hide keyboard on tap anywhere in screen
        
        //slight curve in borders of views
        labelView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
        optView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
        loginSignUpView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
    }
    
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        //show signup View
        let subView = self.storyboard!.instantiateViewController(withIdentifier: "SignUpView")
        self.present(subView, animated: true, completion: nil)
    }
    
    @IBAction func loginBtn(_ sender: UIButton) {
        if emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""||pswdTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            //return "Please fill in all fields"
            //let error = "Please fill in all fields"
            print("check username and password first")
        }
        else{
            //create referernce to the data user enter
             let username = emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
             let password = pswdTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                    //signIn user & check whether it is verified or not ? if not verified then dnt allow to login by showing an alert
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        Auth.auth().signIn(withEmail: username, password: password){
                                  (result,error) in
                                  if error != nil {
                                      //unable to sign in
                                    //  self.showError(error!.localizedDescription)
                                   print(error!.localizedDescription)
                                  }
                                  else{
                                          UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
                                          let subView = self.storyboard!.instantiateViewController(withIdentifier: "ViewController")
                                          self.present(subView, animated: true, completion: nil)
                                  }
                              }
                    }else{
                        let alert = UIAlertController(title: "Check Your Mail", message: "Please Verify Email First & Go Ahead !", preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                    }                      
        }
    }
    
//    func showError(_ message : String){
//            errorLabel.text = message
//            errorLabel.alpha=1
//        }
  
    
    @IBAction func forgotPswd(_ sender: UIButton) {
//               let storyboard = UIStoryboard(name: "Main", bundle: nil)
//               let myAlert = storyboard.instantiateViewController(withIdentifier: "ForgotPswd") as! ForgotPswdView
//               myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//               myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//               self.present(myAlert, animated: true, completion: nil)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPswd")
        self.present(vc!, animated: false, completion: nil)
        }
    

    @IBAction func pswdBtn(_ sender: UIButton) {
//            guard let image = UIImage(named: "unlock") else {
//                       print("Image Not Found")
//                       return
//                   }
        //change img/icon accordingly and set text secure and unsecure as button tapped
        if pswdTxt.isSecureTextEntry == true {
                pswdButton.setImage(UIImage(named: "unlock"), for: UIControlState.normal)
                pswdTxt.isSecureTextEntry = false
            }else{
               // pswdButton.setImage(image, for: UIControlState.normal)
                pswdButton.setImage(UIImage(named: "lock"), for: UIControlState.normal)
                pswdTxt.isSecureTextEntry = true
            }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func googleSignIn(sender: AnyObject) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func guestBtn(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController")// ViewController
        self.present(vc!, animated: true, completion: nil)
        
    }
       
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if let error = error {
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,accessToken: authentication.accessToken)
         self.Loader = self.LoadLoader(loader: self.Loader)
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // error signin
                return
            }
            
            UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
            let sUser = User.init(UID: "\((user?.user.uid)!)",userID: "", name: "\((user?.user.displayName)!)", email: "\((user?.user.email)!)", phone: "\(user?.user.phoneNumber)", address: " ", userType: "gmail", image: "\((user?.user.photoURL)!)", status: "0")
            UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
            
            // send data to server after successfully loged in
           
            let apiURL = "name=\((user?.user.displayName)!)&email=\((user?.user.email)!)&profile=\((user?.user.photoURL)!)&type=gmail&fcm_id=null&ip_address=1.0.0&status=0"
            self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
        }
    }
    
    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logIn(permissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = AccessToken.current else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
                let sUser = User.init(UID: "\((user?.user.uid)!)",userID: "", name: "\((user?.user.displayName)!)", email: "\((user?.user.email)!)", phone: "\(user?.user.phoneNumber)", address: " ",userType: "fb", image: "\((user?.user.photoURL)!)", status: "0")
               
                UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
                
               
                // send data to server after successfully loged in
                self.Loader = self.LoadLoader(loader: self.Loader)
                let apiURL = "name=\((user?.user.displayName)!)&email=\((user?.user.email)!)&profile=\((user?.user.photoURL)!)&type=fb&fcm_id=null&ip_address=1.0.0&status=0"
                self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
            })
        }
    }
    
    @IBAction func PrivacyBtn(_ sender: Any) {
        let goHome = self.storyboard!.instantiateViewController(withIdentifier: "PrivacyView")
        self.present(goHome, animated: true, completion: nil)
    }
    
    @IBAction func TermsBtn(_ sender: Any) {
        let goHome = self.storyboard!.instantiateViewController(withIdentifier: "TermsView")
        self.present(goHome, animated: true, completion: nil)
    }
    
    //load category data here
    func ProcessLogin(jsonObj:NSDictionary){
        //print("LOG",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "status")!)" )
            })
            
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                var userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                userD.name = "\((data["name"])!)"
                userD.userID = "\((data["user_id"])!)"
                userD.phone = "\((data["mobile"])!)"
                userD.image = "\((data["profile"])!)"
                UserDefaults.standard.set(try? PropertyListEncoder().encode(userD), forKey: "user")
                
                let uScore:UserScore = UserScore.init(coins: 6, points: 00)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(uScore),forKey: "UserScore")
            
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                // Present the main view
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
            }
        });
        
    }

}

