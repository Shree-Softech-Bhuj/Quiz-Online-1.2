import UIKit
import GoogleMobileAds

class InterstitialAdViewController: UIViewController { //,GADFullScreenContentDelegate {
    
    var interstitialAd : GADInterstitialAd?
    var controllerName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        RequestInterstitialAd()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        //    presentViewController("UserStatistics")
        }
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
}

extension InterstitialAdViewController : GADFullScreenContentDelegate{
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd){
    if self.controllerName == "UserStatistics"{
        //presentViewController("UserStatistics")
        
        RequestInterstitialAd()
    }else if self.controllerName == "BookmarkView"{
       // presentViewController("BookmarkView")
        RequestInterstitialAd()
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//            let viewCont = storyboard.instantiateViewController(withIdentifier: "BookmarkView")
//            self.navigationController?.pushViewController(viewCont, animated: true)
                    
    }else if self.controllerName == "NotificationsView"{
       // presentViewController("NotificationsView")
        RequestInterstitialAd()
//            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//            let viewCont = storyboard.instantiateViewController(withIdentifier: "NotificationsView")
//            self.navigationController?.pushViewController(viewCont, animated: true)
    }else{
        self.navigationController?.popViewController(animated: true)
    }
}
}
