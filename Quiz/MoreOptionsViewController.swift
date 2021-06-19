import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds
import Firebase

class MoreOptionsViewController: UIViewController{ //,GADFullScreenContentDelegate { //,GADInterstitialDelegate -10feb- //, UIDocumentInteractionControllerDelegate
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emailAdrs: UILabel!
    
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var showUserStatistics: UIButton!
    @IBOutlet weak var showBookmarks: UIButton!
    @IBOutlet weak var showNotifications: UIButton!
    @IBOutlet weak var showAboutUs: UIButton!
    @IBOutlet weak var showInstructions: UIButton!
    @IBOutlet weak var showInviteFrnd: UIButton!
    @IBOutlet weak var showTermsOfService: UIButton!
    @IBOutlet weak var showPrivacyPolicy: UIButton!
    @IBOutlet weak var logOutbtn: UIButton!
    
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    
    var interstitialAd : GADInterstitialAd? //GADInterstitialAdBeta?
//GADInterstitial! -10feb-
    var controllerName:String = ""
    
    var dUser:User? = nil
   
   // let xyz = InterstitialAdViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            print("user details \(dUser!) ")
            emailAdrs.text = dUser?.email
            userName.text = "\(Apps.APP_NAME)"  //"\(Apps.HELLO) \(dUser!.name)"
            //userName.textChangeAnimationToRight()
            
            //imgProfile.SetShadow()
//            imgProfile.layer.cornerRadius =  imgProfile.frame.height / 2
            imgProfile.layer.masksToBounds = true//false
            imgProfile.clipsToBounds = true
            
            logOutbtn.alpha = 1
            
//            imgProfile.isUserInteractionEnabled = true
//            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
//            imgProfile.addGestureRecognizer(tapRecognizer)
            
//            DispatchQueue.main.async {
//                if(self.dUser!.image != ""){
//                    self.imgProfile.loadImageUsingCache(withUrl: self.dUser!.image)
//                }else{
//                    self.imgProfile.image = UIImage(named: "guest")
//                }
//            }
        }else{
            logOutbtn.alpha = 0
            emailAdrs.text = ""
            userName.text = "\(Apps.APP_NAME)"//"\(Apps.HELLO) \(Apps.USER)"
        }
        designImageView()
        imgProfile.image = UIImage(named: "homeIcon")

//    imgProfile.layer.borderWidth = 2
//    imgProfile.layer.borderColor = UIColor.white.cgColor
//    imgProfile.layer.masksToBounds = true
//    imgProfile.clipsToBounds = true
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 500)
        
        // calll button design button and pass button varaible those buttons nedd to be design
        self.DesignButton(btns: showUserStatistics,showBookmarks,showInstructions,showNotifications,showInviteFrnd,showAboutUs,showPrivacyPolicy,showTermsOfService,logOutbtn)
    }
    
//    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
//        presentViewController("UpdateProfileView")
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        RequestInterstitialAd()
    }
    
    func designImageView(){
        if #available(iOS 13.0, *) {
            imgProfile.translatesAutoresizingMaskIntoConstraints = false
            print( Apps.screenHeight)
            if Apps.screenHeight > 750 {
                imgProfile.heightAnchor.constraint(equalToConstant: 140).isActive = true
                imgProfile.widthAnchor.constraint(equalToConstant: 140).isActive = true
               // imgProfile.layer.cornerRadius = 60 // 70
            }else {
                imgProfile.heightAnchor.constraint(equalToConstant: 90).isActive = true
                imgProfile.widthAnchor.constraint(equalToConstant: 90).isActive = true
               // imgProfile.layer.cornerRadius = 45
            }
//        }else{
//            imgProfile.layer.cornerRadius =  imgProfile.frame.height / 2
        }
       // imgProfile.layer.borderWidth = 2
       // imgProfile.layer.borderColor = UIColor.white.cgColor
        imgProfile.layer.masksToBounds = true
        imgProfile.clipsToBounds = true
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.layer.cornerRadius = btn.frame.height / 3//2 //0 //
           // btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
            btn.SetShadow()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logOutButton(_ sender: Any){
        let alert = UIAlertController(title: Apps.LOGOUT_TITLE,message: Apps.LOGOUT_MSG,preferredStyle: .alert)        
        let imageView = UIImageView(frame: CGRect(x: 30, y: 100, width: 230, height: 100))
        imageView.image = UIImage(named: "Sad Puppy")

        alert.view.addSubview(imageView)
        
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            if self.dUser!.userType == "apple"{
               // if app is not loged in than navigate to loginview controller
               UserDefaults.standard.set(false, forKey: "isLogedin")
               UserDefaults.standard.removeObject(forKey: "user")
               
               let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
               let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginView")
               
               let navigationcontroller = UINavigationController(rootViewController: initialViewController)
               navigationcontroller.setNavigationBarHidden(true, animated: false)
               navigationcontroller.isNavigationBarHidden = true
               
               UIApplication.shared.keyWindow?.rootViewController = navigationcontroller
               return
           }
            
            if Auth.auth().currentUser != nil { 
                do {
                    try Auth.auth().signOut()
                    UserDefaults.standard.removeObject(forKey: "isLogedin")
                    //remove friend code
                    UserDefaults.standard.removeObject(forKey: "fr_code")
                    
                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginView")
                    
                    let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                    navigationcontroller.setNavigationBarHidden(true, animated: false)
                    navigationcontroller.isNavigationBarHidden = true
                    UIApplication.shared.keyWindow?.rootViewController = navigationcontroller
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }))
        
        let height = NSLayoutConstraint(item: alert.view!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250)
        let width = NSLayoutConstraint(item: alert.view! , attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 300)
        alert.view.addConstraint(height)
        alert.view.addConstraint(width)
        
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func userStatistics(_ sender: Any) {
        self.controllerName = "UserStatistics"
        /*if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }   -10feb-*/
        
        let myNewView=UIView(frame: CGRect(x: 10, y: 100, width: 300, height: 200))
//                // Change UIView background colour
//                myNewView.backgroundColor=UIColor.lightGray
//
//                // Add rounded corners to UIView
//                myNewView.layer.cornerRadius=25
//
//                // Add border to UIView
//                myNewView.layer.borderWidth=2
//
//                // Change UIView Border Color to Red
//                myNewView.layer.borderColor = UIColor.red.cgColor
                
                // Add UIView as a Subview
                self.view.addSubview(myNewView)
        
        if let ad = interstitialAd {
           ad.present(fromRootViewController: self)
         }else{
            presentViewController("UserStatistics")
           // presentViewController("SelfChallengeController")
        }
    }
    
    @IBAction func instructions(_ sender: Any) {
        presentViewController("instructions")
//        self.modalTransitionStyle = .flipHorizontal
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let viewCont = storyboard.instantiateViewController(withIdentifier: "instructions")
//        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    @IBAction func bookmarks(_ sender: Any) {
        self.controllerName = "BookmarkView"
        
        /*if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }   -10feb-*/
        if let ad = interstitialAd {
           ad.present(fromRootViewController: self)
         }else{
            presentViewController( "BookmarkView")
//            self.modalTransitionStyle = .flipHorizontal
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//            let viewCont = storyboard.instantiateViewController(withIdentifier: "BookmarkView")
//            self.navigationController?.pushViewController(viewCont, animated: true)
        }
    }
    
    @IBAction func notifications(_ sender: Any) {
        self.controllerName = "NotificationsView"
        
        /*if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }   -10feb-*/
        if let ad = interstitialAd {
           ad.present(fromRootViewController: self)
         }else{
//            self.modalTransitionStyle = .flipHorizontal
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//            let viewCont = storyboard.instantiateViewController(withIdentifier: "NotificationsView")
//            self.navigationController?.pushViewController(viewCont, animated: true)
            presentViewController("NotificationsView")
        }
    }
    
    @IBAction func inviteFriends(_ sender: Any) {
        presentViewController("ReferAndEarn")
    }
    @IBAction func termsOfService(_ sender: Any) {
        //weak var pvc = self.presentingViewController
        self.modalTransitionStyle = .flipHorizontal
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "TermsView")
        
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    @IBAction func privacyPolicy(_ sender: Any) {
//        weak var pvc = self.presentingViewController
        self.modalTransitionStyle = .flipHorizontal
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "PrivacyView")
        
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    
    @IBAction func aboutUs(_ sender: Any) {
//        weak var pvc = self.presentingViewController
        self.modalTransitionStyle = .flipHorizontal
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "AboutUsView")
        
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    //Google AdMob
    func RequestInterstitialAd() {
       /* self.interstitialAd = GADInterstitial(adUnitID: Apps.INTERSTITIAL_AD_UNIT_ID)
        self.interstitialAd.delegate = self
        let request = GADRequest() -10feb-*/
        let request = GADRequest() //GADInterstitialAdBeta
         GADInterstitialAd.load(withAdUnitID:Apps.INTERSTITIAL_AD_UNIT_ID,
                                    request: request,
                                    completionHandler: { (ad, error) in
                                     if let error = error {
                                       print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                       return
                                     }
                                     self.interstitialAd = ad
                                     self.interstitialAd!.fullScreenContentDelegate = self
         })
        // request.testDevices = [ kGADSimulatorID ];
        //request.testDevices = Apps.AD_TEST_DEVICE
        //GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        // self.interstitialAd.load(request) -10feb-
    }
    
    // Tells the delegate the interstitial had been animated off the screen.
    //func interstitialDidDismissScreen(_ ad: GADInterstitial) { -10feb-
   /*     func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd){
        if self.controllerName == "UserStatistics"{
            presentViewController("UserStatistics")
            xyz.RequestInterstitialAd()
            //RequestInterstitialAd()
        }else if self.controllerName == "BookmarkView"{
            presentViewController("BookmarkView")
            xyz.RequestInterstitialAd()
            //RequestInterstitialAd()
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//            let viewCont = storyboard.instantiateViewController(withIdentifier: "BookmarkView")
//            self.navigationController?.pushViewController(viewCont, animated: true)
                        
        }else if self.controllerName == "NotificationsView"{
            presentViewController("NotificationsView")
            xyz.RequestInterstitialAd()
            //RequestInterstitialAd()
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//            let viewCont = storyboard.instantiateViewController(withIdentifier: "NotificationsView")
//            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }*/
    
    func presentViewController (_ identifier : String) {
        //click sound
        self.PlaySound(player: &audioPlayer, file: "click")
        self.Vibrate() // make device vibrate
        if (identifier == "UserStatistics") || (identifier == "UpdateProfileView") || (identifier == "ReferAndEarn") {
            //print("it worked for login user")
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = storyboard.instantiateViewController(withIdentifier: identifier)
                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else {
            //print("it is working - not login required")
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: identifier)
            self.navigationController?.pushViewController(viewCont, animated: true)
        }
    }
}
extension MoreOptionsViewController : GADFullScreenContentDelegate{

    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd){
        print("extension called")
    if self.controllerName == "UserStatistics"{
        presentViewController("UserStatistics")
        RequestInterstitialAd()
    }else if self.controllerName == "BookmarkView"{
        presentViewController("BookmarkView")
        RequestInterstitialAd()
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//            let viewCont = storyboard.instantiateViewController(withIdentifier: "BookmarkView")
//            self.navigationController?.pushViewController(viewCont, animated: true)
                    
    }else if self.controllerName == "NotificationsView"{
        presentViewController("NotificationsView")
        RequestInterstitialAd()
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//            let viewCont = storyboard.instantiateViewController(withIdentifier: "NotificationsView")
//            self.navigationController?.pushViewController(viewCont, animated: true)
    }else{
        self.navigationController?.popViewController(animated: true)
    }
}
    override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
    }
    
}


