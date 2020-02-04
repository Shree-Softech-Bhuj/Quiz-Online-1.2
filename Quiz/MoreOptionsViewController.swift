import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds

class MoreOptionsViewController: UIViewController,GADInterstitialDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emailAdrs: UILabel!
    
    @IBOutlet var scrollView: UIScrollView!
    
    @IBOutlet weak var showUserStatistics: UIButton!
    @IBOutlet weak var showBookmarks: UIButton!
    @IBOutlet weak var showNotifications: UIButton!
    @IBOutlet weak var showAboutUs: UIButton!
    @IBOutlet weak var showInstructions: UIButton!
    @IBOutlet weak var showInviteFrnd: UIButton!
       
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    
    var interstitialAd : GADInterstitial!
    var controllerName:String = ""
    
    var dUser:User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgProfile.layer.borderWidth = 2
        imgProfile.layer.borderColor = UIColor.black.cgColor
        imgProfile.layer.cornerRadius = 40

        imgProfile.layer.masksToBounds = false
        imgProfile.clipsToBounds = true
        
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print("user details \(dUser!) ")
        emailAdrs.text = dUser?.email
        userName.text = userName.text! + dUser!.name
        			
        DispatchQueue.main.async {
            if(self.dUser!.image != ""){
                self.imgProfile.loadImageUsingCache(withUrl: self.dUser!.image)
            }
        }
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
    
        // calll button design button and pass button varaible those buttons nedd to be design
        self.DesignButton(btns: showUserStatistics,showBookmarks,showInstructions,showNotifications,showInviteFrnd,showAboutUs)
        }
       
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        RequestInterstitialAd()
    }

    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.layer.cornerRadius = btn.frame.height / 2
            btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
            btn.applyGradient(colors: [UIColor.rgb(243, 243, 247, 1.0).cgColor, UIColor.white.cgColor])
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
        presentViewController("instructions")
    }
    
    @IBAction func bookmarks(_ sender: Any) {
        presentViewController( "BookmarkView")
    }
    
    @IBAction func notifications(_ sender: Any) {
        presentViewController("NotificationsView")
    }
    
    @IBAction func inviteFriends(_ sender: Any) {
       presentViewController("ReferAndEarn")
        }
    
    @IBAction func aboutUs(_ sender: Any) {
      //  presentViewController("AboutUs")
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
                let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let review:ReView = storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
                self.present(review, animated: true, completion: nil)
                RequestInterstitialAd()
            }else if self.controllerName == "xyz"{
                             
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
