import Foundation
import UIKit
import GoogleMobileAds
import StoreKit

class ResultsViewController: UIViewController,GADFullScreenContentDelegate {//,GADInterstitialDelegate -10feb- //, UIDocumentInteractionControllerDelegate
    
    @IBOutlet var lblCoin: UILabel!
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
    
    @IBOutlet weak var resultImg: UIImageView!
    
    @IBOutlet weak var titleText: UILabel!
        
    @IBOutlet weak var backImg: UIImageView!
    
    var interstitialAd : GADInterstitialAd?
    //GADInterstitial! -10feb-
    
    var count:CGFloat = 0.0
    var progressRing: CircularProgressBar!
    var sysConfig:SystemConfiguration!
    var timer: Timer!
    
    var trueCount = 0
    var falseCount = 0
    var percentage:CGFloat = 0.0
    var earnedCoin = 0
    var earnedPoints = 0
    var ReviewQues:[ReQuestionWithE] = []
    
    var level = 0
    var catID = 0
    var questionType = "sub"
    var quesData: [QuestionWithE] = []
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
    var playType = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
        
        let xPosition = viewProgress.center.x - 20
        var yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 120//20
        
        var progRadius:CGFloat = 38
        var minScale:CGFloat = 0.6
        var fontSize:CGFloat = 20
        
        if deviceStoryBoard == "Ipad"{
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 150
        }
        
        if Apps.screenHeight < 750 {
            progRadius = 25
            minScale = 0.3
            fontSize = 12
            
           // xPosition = viewProgress.center.x - 20
            yPosition = viewProgress.center.y-viewProgress.frame.origin.y + 90
        }
        
        let position = CGPoint(x: xPosition, y: yPosition)
        
        // set circular progress bar here and pass required parameters
        progressRing = CircularProgressBar(radius: progRadius, position: position, innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6, progValue: 100)
        viewProgress.layer.addSublayer(progressRing)
        progressRing.progressLabel.numberOfLines = 1;
        progressRing.progressLabel.font = progressRing.progressLabel.font.withSize(fontSize)
        progressRing.progressLabel.minimumScaleFactor = minScale;
        progressRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        self.RegisterNotification(notificationName: "ResultView")
        self.CallNotification(notificationName: "PlayView")
        
        // Calculate the percentage of quesitons you got right
        percentage = CGFloat(trueCount) / CGFloat(Apps.TOTAL_PLAY_QS)
        percentage *= 100
        
        // set timer for progress ring and make it active
        timer = Timer.scheduledTimer(timeInterval: 0.06, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        // call button design button and pass button variable those buttons need to be design
        self.DesignButton(btns: nxtLvl,reviewAns, yourScore,rateUs,homeBtn)
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
       // view1.SetShadow()
        viewProgress.SetShadow()
        
        if (self.playType == "daily") || (self.playType == "RandomQuiz") || (self.playType == "True/False"){
            titleText.text = Apps.DAILY_QUIZ_TITLE
            nxtLvl.setTitle( Apps.DAILY_QUIZ_TITLE, for: .normal)
        }
      
        // Based on the percentage of questions you got right present the user with different message
        if(percentage >= 30 && percentage < 50) {
            earnedCoin = 1
            setResultLabel()
           // lblResults.text = self.playType == "main" ? Apps.COMPLETE_LEVEL : Apps.DAILY_QUIZ_MSG_SUCCESS
           // viewProgress.backgroundColor = UIColor.rgb(212, 247, 248, 1.0)
            resultImg.image = UIImage(named: "trophy")
        } else if(percentage >= 50 && percentage < 70) {
            earnedCoin = 2
            setResultLabel()
           // lblResults.text = self.playType == "main" ? Apps.COMPLETE_LEVEL : Apps.DAILY_QUIZ_MSG_SUCCESS
           // viewProgress.backgroundColor = UIColor.rgb(212, 247, 248, 1.0)
            resultImg.image = UIImage(named: "trophy")
        }else if(percentage >= 70 && percentage < 90) {
            earnedCoin = 3
            setResultLabel()
//            lblResults.text = self.playType == "main" ? Apps.COMPLETE_LEVEL : Apps.DAILY_QUIZ_MSG_SUCCESS
//            viewProgress.backgroundColor = UIColor.rgb(212, 247, 248, 1.0)
            resultImg.image = UIImage(named: "trophy")
        }else if(percentage >= 90) {
            earnedCoin = 4
            setResultLabel()
//            lblResults.text = self.playType == "main" ? Apps.COMPLETE_LEVEL : Apps.DAILY_QUIZ_MSG_SUCCESS
//            viewProgress.backgroundColor = UIColor.rgb(212, 247, 248, 1.0)
            resultImg.image = UIImage(named: "trophy")
        }else{
            earnedCoin = 0
            if (self.playType == "daily") {
                lblResults.text = Apps.DAILY_QUIZ_MSG_FAIL
            }else if (self.playType == "RandomQuiz") {
                lblResults.text = Apps.RANDOM_QUIZ_MSG_FAIL
            }else if (self.playType == "True/False"){
                lblResults.text = Apps.TF_QUIZ_MSG_FAIL
            }else{
                lblResults.text = Apps.NOT_COMPLETE_LEVEL
            }
//            lblResults.text = self.playType == "main" ? Apps.NOT_COMPLETE_LEVEL : Apps.DAILY_QUIZ_MSG_FAIL
//            viewProgress.backgroundColor = UIColor.rgb(255, 226, 244, 1.0)
            resultImg.image = UIImage(named: "defeat")
            //set backtop tint to Red
            backImg.tintColor = UIColor.red
            //chng backcolor of containing view to red-pink & titlebar txt to play again
            titleText.text = self.playType == "main" ? Apps.PLAY_AGAIN : Apps.DAILY_QUIZ_TITLE
            nxtLvl.setTitle(self.playType == "main" ? Apps.PLAY_AGAIN : Apps.DAILY_QUIZ_TITLE, for: .normal)
        }
        func setResultLabel(){
//            lblResults.text = self.playType == "main" ? Apps.COMPLETE_LEVEL : Apps.DAILY_QUIZ_MSG_SUCCESS
            if (self.playType == "daily") {
                lblResults.text = Apps.DAILY_QUIZ_MSG_SUCCESS
            }else if (self.playType == "RandomQuiz") {
                lblResults.text = Apps.RANDOM_QUIZ_MSG_SUCCESS
            }else if (self.playType == "True/False"){
                lblResults.text = Apps.TF_QUIZ_MSG_SUCCESS
            }else{
                lblResults.text = Apps.COMPLETE_LEVEL
            }
        }
        //apps has level lock unlock, remove this code if add no need level lock unlock
        if true { //if (percentage >= 30){
            if true { // if scoreLavel + 1 == self.level{
               // score.points = score.points + earnedPoints
                score.coins = score.coins + earnedCoin
                
                if UserDefaults.standard.bool(forKey: "isLogedin") {
                    let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                    
                    if(Reachability.isConnectedToNetwork()){
                        self.SetUserLevel()
                        var apiURL = "user_id=\(duser.userID)&score=\(earnedPoints)" //"user_id=\(duser.userID)&score=\(score.points)"
                        self.getAPIData(apiName: "set_monthly_leaderboard", apiURL: apiURL,completion: LoadData)
                        
                        apiURL = "user_id=\(duser.userID)&questions_answered=\(trueCount + falseCount)&correct_answers=\(trueCount)&category_id=\(catID)&ratio=\(percentage)&coins=\(score.coins)"
                        self.getAPIData(apiName: "set_users_statistics", apiURL: apiURL,completion: LoadData)
                    }else{
                        ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
                    }
                }
            }
        }
        
        lblCoin.text = "\(score.coins)"
        lblScore.text = "\(score.points)"
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(Apps.TOTAL_PLAY_QS - trueCount)"
                
        totalCoin.text = "\(earnedCoin)"
        totalScore.text = "\(earnedPoints)"
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        RequestInterstitialAd()
    }
    // make button custom design function
    func DesignButton(btns:UIButton...){
        for btn in btns {
            btn.SetShadow()
            btn.layer.cornerRadius = btn.frame.height / 3//0//btn.frame.height / 2
          //  btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title:Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            
        }else{
            // on success response do code here
        }
    }
    
    //Google AdMob
    func RequestInterstitialAd() {
        
       /* self.interstitialAd = GADInterstitial(adUnitID: Apps.INTERSTITIAL_AD_UNIT_ID)
        self.interstitialAd.delegate = self
        let request = GADRequest()
        // request.testDevices = [ kGADSimulatorID ];
        //request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        self.interstitialAd.load(request) -10feb-*/
        let request = GADRequest()
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
    }
    
    // Tells the delegate the interstitial had been animated off the screen.
    //func interstitialDidDismissScreen(_ ad: GADInterstitial) { -10feb-
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd){
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
        count += 2
        progressRing.progressManual = CGFloat(count)
        if count >= CGFloat(percentage) {
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
        
        let playLavel = percentage < 30 ? self.level : self.level + 1
        self.quesData.removeAll()
        
        var apiURL = questionType == "main" ? "level=\(playLavel)&category=\(catID)" : "level=\(playLavel)&subcategory=\(catID)"
        if sysConfig.LANGUAGE_MODE == 1{
            apiURL += "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
        }
     
        self.getAPIData(apiName: "get_questions_by_level", apiURL: apiURL,completion: {jsonObj in
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
                self.ShowAlert(title: Apps.OOPS, message: Apps.ERROR_MSG )
            }else{
                //get data for category
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: "\(val["answer"]!)", image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType:  "\(val["question_type"]!)"))
                    }
                    Apps.TOTAL_PLAY_QS = data.count
                    //check this level has enough (10) question to play? or not
                    if self.quesData.count >= Apps.TOTAL_PLAY_QS {
                        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                        let viewCont = storyboard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                        
                        viewCont.catID = self.catID
                        viewCont.level = playLavel
                        print("\(self.questionType) - \(self.playType)")
                        viewCont.playType = self.playType
                        viewCont.questionType = self.questionType
                        viewCont.quesData = self.quesData
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }
                    }//else{
//                        self.ShowAlert(title: Apps.NOT_ENOUGH_QUESTION_TITLE, message: Apps.NO_ENOUGH_QUESTION_MSG)
//                    }
                }
            }
        })
    }
    
    @IBAction func reviewButton(_ sender: UIButton) {
        self.controllerName = "review"
        /*if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }   -10feb-*/
        if let ad = interstitialAd {
           ad.present(fromRootViewController: self)
         }else{
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "ReView") as! ReView
            viewCont.ReviewQues = ReviewQues
            self.navigationController?.pushViewController(viewCont, animated: true)
        }
    }
    
    @IBAction func homeButton(_ sender: UIButton) {
        self.controllerName = "home"
        /*if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }   -10feb-*/
        if let ad = interstitialAd {
           ad.present(fromRootViewController: self)
         }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func scoreButton(_ sender: UIButton) {
        let str  = Apps.APP_NAME
        var shareUrl = ""
        
        if self.playType == "main"{
            shareUrl = "\(Apps.SHARE1) \(self.level) \(Apps.SHARE2) \(self.earnedPoints)"
        } else if self.playType == "True/False"{
            shareUrl = "\(Apps.TF_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        } else if self.playType == "RandomQuiz" {
            shareUrl = "\(Apps.RANDOM_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        }else{
            shareUrl = "\(Apps.DAILY_QUIZ_SHARE_MSG) \(self.earnedPoints)"
        }
       
        let textToShare = str + "\n" + shareUrl
        //take screenshot
        UIGraphicsBeginImageContext(viewProgress.frame.size)
        viewProgress.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let vc = UIActivityViewController(activityItems: [textToShare, image! ], applicationActivities: [])
       // vc.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionCentre;
        vc.popoverPresentationController?.sourceView = sender
        //vc.popoverPresentationController?.sourceView = self.view
//        if let popOver = vc.popoverPresentationController {
//            popOver.sourceView = self.view
//        }
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
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }else if let url = URL(string: Apps.SHARE_APP) {
             UIApplication.shared.open(url)
            //UIApplication.shared.openconvertToUIApplicationOpenExternalURLOptionsKeyDictionary(()url)
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }
}

extension ResultsViewController{
    
    func SetUserLevel(){
        if(Reachability.isConnectedToNetwork()){
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            let apiURL = self.questionType == "main" ? "user_id=\(user.userID)&category=\(self.catID)&subcategory=0&level=\(self.level)" : "user_id=\(user.userID)&category=\(mainCatID)&subcategory=\(self.catID)&level=\(self.level)"
            self.getAPIData(apiName: "set_level_data", apiURL: apiURL,completion: { jsonObj in
               // print("JSON",jsonObj)
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
