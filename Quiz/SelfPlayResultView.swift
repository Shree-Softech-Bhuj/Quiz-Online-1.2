//
//  SelfPlayResultView.swift
//  Quiz
//
//  Created by Macmini on 02/06/20.
//  Copyright © 2020 LPK Techno. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class SelfPlayResultView: UIViewController,GADInterstitialDelegate, UIDocumentInteractionControllerDelegate {
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var lblScore: UILabel!
    @IBOutlet var lblResults: UILabel!
    @IBOutlet var lblTrue: UILabel!
    @IBOutlet var lblFalse: UILabel!
    @IBOutlet var totalScore: UILabel!
    @IBOutlet var totalCoin: UILabel!
    @IBOutlet var nxtLvl: UIButton!
    @IBOutlet var reviewAns: UIButton!
    @IBOutlet var yourScore: UIButton!
    @IBOutlet var rateUs: UIButton!
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var viewProgress: UIView!
    @IBOutlet var view1: UIView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var titleText: UILabel!
    
    var interstitialAd : GADInterstitial!
    
    var count:CGFloat = 0.0
    var progressRing: CircularProgressBar!
    var timer: Timer!
    
    var trueCount = 0
    var falseCount = 0
    var percentage:CGFloat = 0.0
    
    var ReviewQues:[ReQuestionWithE] = []
    var quesCount = 0
    var quesData: [QuestionWithE] = []
    
    var completedTime = 0
    var totalTime = 0
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
        
        let xPosition = viewProgress.center.x - 20
        let yPosition = viewProgress.center.y-viewProgress.frame.origin.y - 15
        let position = CGPoint(x: xPosition, y: yPosition)
        
        // set circular progress bar here and pass required parameters
        progressRing = CircularProgressBar(radius: 35, position: position, innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 5,progValue: CGFloat(self.totalTime * 60))
        viewProgress.layer.addSublayer(progressRing)
        progressRing.progressLabel.numberOfLines = 1;
        progressRing.progressLabel.font = progressRing.progressLabel.font.withSize(20)
        progressRing.progressLabel.minimumScaleFactor = 0.5;
        progressRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        // Calculate the percentage of quesitons you got right
        self.timerLabel.text = "Challenge time: \(self.secondsToHoursMinutesSeconds(seconds: self.totalTime))"
        
        for rev in self.ReviewQues{
            let rightStr = self.GetRightAnsString(correctAns: rev.correctAns, quetions: rev)
            if rightStr == rev.userSelect{
                self.trueCount += 1
            }
        }
        percentage = CGFloat(trueCount) / CGFloat(self.quesCount)
        percentage *= 100
        // set timer for progress ring and make it active
        timer = Timer.scheduledTimer(timeInterval: 0.06, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        // call button design button and pass button variable those buttons need to be design
        self.DesignButton(btns: nxtLvl,reviewAns, yourScore,rateUs,homeBtn)
        
        viewProgress.SetShadow()
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(self.quesCount - trueCount)"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        RequestInterstitialAd()
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.SetShadow()
            btn.layer.cornerRadius = 0//btn.frame.height / 2
          //  btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
            
        }else{
            // on success response do code here
        }
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
        if self.controllerName == "review"{
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.navigationController?.pushViewController(viewCont, animated: true)
            
            RequestInterstitialAd()
        }else if self.controllerName == "home"{
            self.navigationController?.popToRootViewController(animated: true)
            
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        count = 0
        timer.fire()
    }
    
    @objc func incrementCount() {
        let comTime = self.totalTime - self.completedTime
        count += 2
        progressRing.progressManual = CGFloat(count)
        progressRing.progressLabel.text = self.secondsToHoursMinutesSeconds(seconds: Int(count))
        if count >= CGFloat(comTime) {
            timer.invalidate()
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let viewCont = storyboard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
//
//        self.navigationController?.popToViewController(viewCont, animated: true)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func nxtButton(_ sender: UIButton) {

    }
    
    @IBAction func reviewButton(_ sender: UIButton) {
        self.controllerName = "review"
        if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }else{
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.navigationController?.pushViewController(viewCont, animated: true)
        }
    }
    
    @IBAction func homeButton(_ sender: UIButton) {
        self.controllerName = "home"
        if interstitialAd.isReady{
            interstitialAd.present(fromRootViewController: self)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func scoreButton(_ sender: UIButton) {
        let str  = Apps.APP_NAME
        let shareUrl = "I have completed self challenge with right answer \(self.trueCount)"
        let textToShare = str + "\n" + shareUrl
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
        present(vc, animated: true)
    }
    
    func OptionStr(rightAns:String, userAns:String,opt:String,choice:String) ->String {
        if(rightAns == userAns && userAns == choice){
            return "<font color='green'>\(opt). \(choice) </font><br>"
        }else if(userAns == choice){
            return "<font color='red'>\(opt). \(choice) </font><br>"
        }else if(rightAns == choice){
            return "<font color='green'>\(opt). \(choice) </font><br>"
        }else{
            return "\(opt). \(choice)<br>"
        }
    }
    
    func GetRightAnsString(correctAns:String, quetions:ReQuestionWithE)->String{
        if correctAns == "a"{
            return quetions.opetionA
        }else if correctAns == "b"{
            return quetions.opetionB
        }else if correctAns == "c"{
            return quetions.opetionC
        }else if correctAns == "d"{
            return quetions.opetionD
        }else if correctAns == "e"{
            return quetions.opetionE
        }else{
            return ""
        }
    }
    
    @IBAction func rateButton(_ sender: UIButton) {
        let url = URL(string: "itms-apps://itunes.apple.com/app/" + "\(Apps.APP_ID)")
        UIApplication.shared.open(url!)
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }
}
