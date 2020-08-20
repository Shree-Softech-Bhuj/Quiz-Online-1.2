import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import AuthenticationServices

class LoginView: UIViewController,GIDSignInDelegate{
    
    // @IBOutlet var fbBtn: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var fbButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    
    @IBOutlet weak var btnSignUp: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var optView: UIView!
    @IBOutlet weak var loginSignUpView: UIView!
    @IBOutlet weak var pswdButton: UIButton!
    @IBOutlet weak var emailTxt: FloatingTF!
    @IBOutlet weak var pswdTxt: FloatingTF!
    
    var email = ""
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().delegate=self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        self.hideKeyboardWhenTappedAround() //hide keyboard on tap anywhere in screen
        //rounded borders of buttons
       btnSignUp.layer.cornerRadius = btnSignUp.frame.height / 2//10
//        btnSignUp.layer.borderColor = UIColor.rgb(49,36,36, 1).cgColor
//        btnSignUp.layer.borderWidth = 2
        btnLogin.layer.cornerRadius = btnLogin.frame.height / 2//10

        
        //slight curve in borders of views
        labelView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
        optView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
        loginSignUpView.roundCorners(corners: [.topLeft, .bottomRight, .topRight, .bottomLeft], radius: 10)
        
    }
    
    @IBAction func signUpBtn(_ sender: UIButton) {
        //show signup View
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "SignUpView")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    @IBAction func appleSignin(_ sender: Any) {
        
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            
            
            let request = appleIDProvider.createRequest()
            
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            authorizationController.delegate = self
            
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
            self.ShowAlert(title: Apps.APPLE_LOGIN_TITLE, message: Apps.APPLE_LOGIN_MSG)
        }
        
        
    }
    
    @IBAction func forgotPswd(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "ForgotPswd")
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    
    
    @IBAction func pswdBtn(_ sender: UIButton) {
        //change img/icon accordingly and set text secure and unsecure as button tapped
        if pswdTxt.isSecureTextEntry == true {
            pswdButton.setImage(UIImage(named: "ios-eye-off"), for: UIControl.State.normal)
            pswdTxt.isSecureTextEntry = false
        }else{
            pswdButton.setImage(UIImage(named: "eye"), for: UIControl.State.normal)
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
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    func checkIfEmailVerified(){
        if Auth.auth().currentUser != nil {
            print(Auth.auth().currentUser!)
            Auth.auth().currentUser?.reload (completion: {(error) in
                if error == nil{
                    //signIn user & check whether it is verified or not ? if not verified then dnt allow to login by showing an alert
                    if Auth.auth().currentUser?.isEmailVerified == true {
                        self.signInVerification()
                    }else{
                        let alert = UIAlertController(title: Apps.RESET_MSG, message: Apps.VERIFY_MSG, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }else{
                    let alert = UIAlertController(title: Apps.ERROR, message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true)
                    print(error?.localizedDescription ?? "error")
                }
            })
        }else{
            signInVerification()
        }
    }
    func signInVerification(){
        //create referernce to the data user enter
        let username = self.emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = self.pswdTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: username, password: password) { (result,error) in
            if error != nil {
                let alert = UIAlertController(title: Apps.ERROR, message: error!.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true)
                print(error!.localizedDescription)
            }else{
                UserDefaults.standard.set(true, forKey: "isLogedin")
                //set DisplayName by splitting from given email address
                let displayname = result?.user.email!.components(separatedBy: "@")
                let nm = displayname![0]
                //print("\(nm)")
                var fcode = ""
                let rcode = nm //ref code is same as initial username
                Apps.REFER_CODE = rcode
                print("curr user -- \((result?.user.uid)!)")
                if (UserDefaults.standard.value(forKey: "fr_code") != nil){
                    fcode = UserDefaults.standard.string(forKey: "fr_code")!
                    print(fcode)
                }else{
                    fcode = " "
                }
                let sUser = User.init(UID: "\((result?.user.uid)!)",userID: "", name: "\(result?.user.displayName ?? "\(nm)")", email: "\((result?.user.email)!)",phone: "\(result?.user.phoneNumber ?? "")", address: " ", userType: "email", image: "", status: "0",ref_code: "\(rcode)") //,frnd_code: "\(fcode)"
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
                print("user data-- \(sUser)")
                
                // send data to server after successfully loged in
                let apiURL = "name=\(result?.user.displayName ?? "\(nm)")&email=\((result?.user.email)!)&profile=&type=email&fcm_id=\(Apps.FCM_ID)&ip_address=1.0.0&status=0&friends_code=\(fcode)&refer_code=\(rcode)&firebase_id=\(result?.user.uid)"
                self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
                
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = storyboard.instantiateViewController(withIdentifier: "ViewController")
                self.navigationController?.pushViewController(viewCont, animated: true)
                
            }
        }
    }
    @IBAction func loginBtn(_ sender: UIButton)
    {
        if emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || pswdTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            print("Please enter correct username and password")
            let alert = UIAlertController(title: "", message: Apps.CORRECT_DATA_MSG, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: Apps.OK, style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true)
        } else{
            checkIfEmailVerified()
        }
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
            
            let displayname = user?.user.email!.components(separatedBy: "@")
            let nm = displayname![0]
            //print("\(nm)")
            let rcode = nm //ref code is same as initial username
            Apps.REFER_CODE = rcode
            
            UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
            let sUser = User.init(UID: "\((user?.user.uid)!)",userID: "", name: "\((user?.user.displayName)!)", email: "\((user?.user.email)!)", phone: "\(String(describing: user?.user.phoneNumber))", address: " ", userType: "gmail", image: "\((user?.user.photoURL)!)", status: "0",ref_code: "\(rcode)")
            UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
            
            // send data to server after successfully loged in
            let apiURL = "name=\((user?.user.displayName)!)&email=\((user?.user.email)!)&profile=\((user?.user.photoURL)!)&type=gmail&fcm_id=\(Apps.FCM_ID)&refer_code=\(rcode)&ip_address=1.0.0&status=0&firebase_id=\(sUser.UID)"
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
                    let alertController = UIAlertController(title: Apps.ERROR, message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: Apps.OK, style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                
                let displayname = user?.user.email!.components(separatedBy: "@")
                   let nm = displayname![0]
                   var rcode = ""
                   //print("\(nm)")
                   if displayname![0] == "" {
                       rcode = user?.user.phoneNumber as! String
                   }else{
                    rcode = nm //ref code is same as initial username
                   }
                   
                   Apps.REFER_CODE = rcode
                
                UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
                let sUser = User.init(UID: "\((user?.user.uid)!)",userID: "", name: "\((user!.user.displayName)!)", email: "\((user?.user.email)!)", phone: "\(String(describing: user?.user.phoneNumber))", address: " ",userType: "fb", image: "\((user?.user.photoURL)!)", status: "0",ref_code: "\(rcode)") //,frnd_code: "",ref_code: ""
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
                
                // send data to server after successfully loged in
                self.Loader = self.LoadLoader(loader: self.Loader)
                let apiURL = "name=\((user?.user.displayName)!)&email=\((user?.user.email)!)&profile=\((user?.user.photoURL)!)&type=fb&fcm_id=\(Apps.FCM_ID)&refer_code=\(rcode)&ip_address=1.0.0&status=0&firebase_id=\(user?.user.uid)"
                self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
            })
        }
    }
    
    @IBAction func PrivacyBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "PrivacyView")
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    
    @IBAction func TermsBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "TermsView")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    //load category data here
    func ProcessLogin(jsonObj:NSDictionary){
        print("LOG",jsonObj)
        let msg = jsonObj.value(forKey: "message") as! String
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.OK, message:"\(msg)" )
                })
            }
            return
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                //print("Data -- \(data)")
                var userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                userD.name = "\((data["name"])!)"
                userD.userID = "\((data["user_id"])!)"
                userD.phone = "\((data["mobile"])!)"
                userD.image = "\((data["profile"])!)"
                //userD.frnd_code = "\((data["friends_code"]) ?? " ")"
                userD.ref_code = "\((data["refer_code"])!)"
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(userD), forKey: "user")
                
//                let uScore:UserScore = UserScore.init(coins: 0, points: 00)
//                UserDefaults.standard.set(try? PropertyListEncoder().encode(uScore),forKey: "UserScore")
            }
                
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                // Present the main view
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
                
                let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                navigationcontroller.setNavigationBarHidden(true, animated: false)
                navigationcontroller.isNavigationBarHidden = true
                
                UIApplication.shared.keyWindow?.rootViewController = navigationcontroller
            }
        });
    }
}

@available(iOS 13, *)
extension LoginView:ASAuthorizationControllerDelegate{
    func setupSOAppleSignIn() {
        
        let btnAuthorization = ASAuthorizationAppleIDButton()
        
        btnAuthorization.frame = CGRect(x: 0, y: 0, width: 200, height: 40)
        
        btnAuthorization.center = self.view.center
        
        btnAuthorization.addTarget(self, action: #selector(actionHandleAppleSignin), for: .touchUpInside)
        
        self.view.addSubview(btnAuthorization)
        
    }
    @objc func actionHandleAppleSignin() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        let request = appleIDProvider.createRequest()
        
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = self
        
        authorizationController.presentationContextProvider = self
        
        authorizationController.performRequests()
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
        print(error.localizedDescription)
        
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            // Create an account as per your requirement
            
            let appleId = appleIDCredential.user
            
            let appleUserFirstName = appleIDCredential.fullName!.givenName
            
            let appleUserLastName = appleIDCredential.fullName!.familyName
            
            let appleUserEmail =  appleIDCredential.email
            print(appleUserEmail)
            
            UserDefaults.standard.set(true, forKey: "isLogedin") //Bool
            
            let uid = appleId.replacingOccurrences(of: ".", with: "", options: NSString.CompareOptions.literal, range: nil)
            let sUser = User.init(UID: "\(uid)",userID: "", name: "\(appleUserFirstName) \(appleUserLastName)", email: "\(appleUserEmail ?? "\(uid)@privaterelay.appleid.com")", phone: "0", address: " ",userType: "apple", image: "", status: "0", ref_code: "\(uid)")
            
            UserDefaults.standard.set(try? PropertyListEncoder().encode(sUser), forKey: "user")
            
            
            // send data to server after successfully loged in
            self.Loader = self.LoadLoader(loader: self.Loader)
            let apiURL = "name=\(appleUserFirstName ?? "none") \(appleUserLastName)&email=\(appleUserEmail ?? "\(uid)@privaterelay.appleid.com")&profile=&type=apple&fcm_id=null&ip_address=1.0.0&status=0&firebase_id=null&refer_code=\(uid)"
            self.getAPIData(apiName: "user_signup", apiURL: apiURL,completion: self.ProcessLogin)
            //Write your code
            
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            
            let appleUsername = passwordCredential.user
            
            let applePassword = passwordCredential.password
            
        }
        
    }
}

@available(iOS 13, *)
extension LoginView: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        
        return self.view.window!
        
    }
    
}
