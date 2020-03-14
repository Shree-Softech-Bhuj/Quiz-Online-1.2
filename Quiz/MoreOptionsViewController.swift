import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds

class MoreOptionsViewController: UIViewController,GADInterstitialDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emailAdrs: UILabel!
        
    @IBOutlet weak var imgView: UIView!
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
       
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
        
    var interstitialAd : GADInterstitial!
    var controllerName:String = ""
    
    var dUser:User? = nil
    
    let screenBounds = UIScreen.main.bounds
    var screen_height = CGFloat(0) //screen height of current device
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       // let screen_width = screenBounds.width
         screen_height = screenBounds.height
        
         if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                   print("user details \(dUser!) ")
                   emailAdrs.text = dUser?.email
                   userName.text = "Hello, " + dUser!.name
                   
                   imgProfile.isUserInteractionEnabled = true
                   let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
                   imgProfile.addGestureRecognizer(tapRecognizer)
                   
                   DispatchQueue.main.async {
                       if(self.dUser!.image != ""){
                          self.imgProfile.loadImageUsingCache(withUrl: self.dUser!.image)
                       }
                   }
         }else{
            emailAdrs.text = ""
            userName.text = "Hello, User"
            imgProfile.image = UIImage(named: "backtop")
        }
        designImageView()
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
    
        // calll button design button and pass button varaible those buttons nedd to be design
        self.DesignButton(btns: showUserStatistics,showBookmarks,showInstructions,showNotifications,showInviteFrnd,showAboutUs,showPrivacyPolicy,showTermsOfService)
    }
      
    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
         presentViewController("UpdateProfileView")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        RequestInterstitialAd()
    }
    
    func designImageView(){       
        imgProfile.translatesAutoresizingMaskIntoConstraints = false
        if screen_height > 700 {
            imgProfile.heightAnchor.constraint(equalToConstant: 140).isActive = true
            imgProfile.widthAnchor.constraint(equalToConstant: 140).isActive = true
            imgProfile.layer.cornerRadius = 70
        }else {
            imgProfile.heightAnchor.constraint(equalToConstant: 90).isActive = true
            imgProfile.widthAnchor.constraint(equalToConstant: 90).isActive = true
            imgProfile.layer.cornerRadius = 45
        }
        imgProfile.layer.borderWidth = 2
        imgProfile.layer.borderColor = UIColor.white.cgColor
       // imgProfile.layer.cornerRadius = imgProfile.frame.height / 2  //70
        imgProfile.layer.masksToBounds = false
        imgProfile.clipsToBounds = true
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.layer.cornerRadius = 0 //btn.frame.height / 2
            btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
           // btn.applyGradient(colors: [UIColor.rgb(243, 243, 247, 1.0).cgColor, UIColor.white.cgColor])
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
            
    @IBAction func userStatistics(_ sender: Any) {
        self.controllerName = "userStatistics"
                        
         if interstitialAd.isReady{
              self.interstitialAd.present(fromRootViewController: self)
        }else{
             presentViewController("UserStatistics")
        }
    }
        
    @IBAction func instructions(_ sender: Any) {
        //presentViewController("instructions")
        weak var pvc = self.presentingViewController
        self.modalTransitionStyle = .flipHorizontal
        self.dismiss(animated: true, completion: {
                let vc = self.storyboard!.instantiateViewController(withIdentifier: "instructions")
                //vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                pvc?.present(vc, animated: true, completion: nil)
          })
    }
    
    @IBAction func bookmarks(_ sender: Any) {
        self.controllerName = "bookmarks"
                        
         if interstitialAd.isReady{
              self.interstitialAd.present(fromRootViewController: self)
        }else{
            //presentViewController( "BookmarkView")
            weak var pvc = self.presentingViewController
            self.modalTransitionStyle = .flipHorizontal
            self.dismiss(animated: true, completion: {
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "BookmarkView")
                    //vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    pvc?.present(vc, animated: true, completion: nil)
              })
        }
    }
    
    @IBAction func notifications(_ sender: Any) {
        self.controllerName = "notifications"
                        
         if interstitialAd.isReady{
              self.interstitialAd.present(fromRootViewController: self)
        }else{
            weak var pvc = self.presentingViewController
            self.modalTransitionStyle = .flipHorizontal
            self.dismiss(animated: true, completion: {
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: "NotificationsView")
                    //vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    pvc?.present(vc, animated: true, completion: nil)
              })
        }
    }
    
    @IBAction func inviteFriends(_ sender: Any) {
       presentViewController("ReferAndEarn")
        }
    @IBAction func termsOfService(_ sender: Any) {
    presentViewController("TermsView")
     }
    @IBAction func privacyPolicy(_ sender: Any) {
    presentViewController("PrivacyView")
     }
    
    @IBAction func aboutUs(_ sender: Any) {
        //presentViewController("AboutUsView")
          weak var pvc = self.presentingViewController
          self.modalTransitionStyle = .flipHorizontal
          self.dismiss(animated: true, completion: {
                  let vc = self.storyboard!.instantiateViewController(withIdentifier: "AboutUsView")
                  //vc.modalPresentationStyle = .fullScreen
                  vc.modalTransitionStyle = .crossDissolve
                  pvc?.present(vc, animated: true, completion: nil)
            })
        }
    
     //Google AdMob
        func RequestInterstitialAd() {
            
            self.interstitialAd = GADInterstitial(adUnitID: Apps.INTERSTITIAL_AD_UNIT_ID)
            self.interstitialAd.delegate = self
            let request = GADRequest()
           // request.testDevices = [ kGADSimulatorID ];
            //request.testDevices = Apps.AD_TEST_DEVICE
            GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
            self.interstitialAd.load(request)
        }

        // Tells the delegate the interstitial had been animated off the screen.
        func interstitialDidDismissScreen(_ ad: GADInterstitial) {
            if self.controllerName == "userStatistics"{
                presentViewController("UserStatistics")
                RequestInterstitialAd()
            }else if self.controllerName == "bookmarks"{
                 let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                 let review:BookmarkView = storyBoard.instantiateViewController(withIdentifier: "BookmarkView") as! BookmarkView
                 self.present(review, animated: true, completion: nil)
                RequestInterstitialAd()
            }else if self.controllerName == "notifications"{
                 let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                 let review:NotificationsView = storyBoard.instantiateViewController(withIdentifier: "NotificationsView") as! NotificationsView
                 self.present(review, animated: true, completion: nil)
                RequestInterstitialAd()
            }else{
                 self.dismiss(animated: true, completion: nil)
            }
        }
    
    func presentViewController (_ identifier : String) {
        //click sound
        self.PlaySound(player: &audioPlayer, file: "click")
        self.Vibrate() // make device vibrate
        
         if UserDefaults.standard.bool(forKey: "isLogedin"){
            weak var pvc = self.presentingViewController
            self.modalTransitionStyle = .flipHorizontal
            self.dismiss(animated: true, completion: {
                    let vc = self.storyboard!.instantiateViewController(withIdentifier: identifier)
                    //vc.modalPresentationStyle = .fullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    pvc?.present(vc, animated: true, completion: nil)
                })
        }else{
                   let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
                   self.present(vc, animated: true, completion: nil)
               }
    }
}
