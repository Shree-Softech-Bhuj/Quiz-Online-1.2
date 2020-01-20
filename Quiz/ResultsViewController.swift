import Foundation
import UIKit
import GoogleMobileAds

class ResultsViewController: UIViewController,GADInterstitialDelegate, UIDocumentInteractionControllerDelegate {
    
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
    @IBOutlet var generatePdf: UIButton!
    @IBOutlet var rateUs: UIButton!
    @IBOutlet var homeBtn: UIButton!
    @IBOutlet var viewProgress: UIView!
    @IBOutlet var scrollView: UIScrollView!
    
    var interstitialAd : GADInterstitial!

    var count:CGFloat = 0.0
    var progressRing: CircularProgressBar!
    var timer: Timer!
    
    var trueCount = 0
    var percentage:CGFloat = 0.0
    var earnedCoin = 0
    var earnedPoints = 0
   // var ReviewQues:[ReQuestion] = []
    var ReviewQues:[ReQuestionWithE] = []
    
    var level = 0
    var catID = 0
    var questionType = "sub"
//    var quesData: [Question] = []
    var quesData: [QuestionWithE] = []
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var controllerName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 400)
        
        let xPosition = viewProgress.center.x
        let yPosition = viewProgress.center.y-viewProgress.frame.origin.y
        let position = CGPoint(x: xPosition, y: yPosition)
        
        // set circular progress bar here and pass required parameters
        progressRing = CircularProgressBar(radius: 28, position: position, innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6, progValue: 100)
        viewProgress.layer.addSublayer(progressRing)
        progressRing.progressLabel.numberOfLines = 1;
        progressRing.progressLabel.minimumScaleFactor = 0.7;
        progressRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        self.RegisterNotification(notificationName: "ResultView")
        self.CallNotification(notificationName: "PlayView")
        
        // Calculate the percentage of quesitons you got right
        percentage = CGFloat(trueCount) / CGFloat(Apps.TOTAL_PLAY_QS)
        percentage *= 100
        
        // set timer for progress ring and make it active
        timer = Timer.scheduledTimer(timeInterval: 0.06, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()

        // calll button design button and pass button varaible those buttons nedd to be design
        self.DesignButton(btns: nxtLvl,reviewAns, yourScore,generatePdf,rateUs,homeBtn)
        
         var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        
        // Based on the percentage of questions you got right present the user with different message
        if(percentage >= 30 && percentage < 50) {
            earnedCoin = 1
            lblResults.text = Apps.COMPLETE_LEVEL
        } else if(percentage >= 50 && percentage < 70) {
            earnedCoin = 2
            lblResults.text = Apps.COMPLETE_LEVEL
        }else if(percentage >= 70 && percentage < 90) {
            earnedCoin = 3
            lblResults.text = Apps.COMPLETE_LEVEL
        }else if(percentage >= 90) {
            earnedCoin = 4
            lblResults.text = Apps.COMPLETE_LEVEL
        }else{
            earnedCoin = 0
            lblResults.text = Apps.NOT_COMPLETE_LEVEL
            nxtLvl.setTitle(Apps.PLAY_AGAIN, for: .normal)
        }
       
        //apps has level lock unlock, remove this code if add no need level lock unlock
        if (percentage >= 30){
            var lvl = 0
            if UserDefaults.standard.value(forKey:"\(questionType)\(catID)") != nil {
                lvl = Int(truncating: UserDefaults.standard.value(forKey:"\(questionType)\(catID)") as! NSNumber)
            }
            if self.level > lvl {
                UserDefaults.standard.set(self.level, forKey: "\(questionType)\(catID)")
            }
        }
        
        lblCoin.text = "\(score.coins)"
        lblScore.text = "\(score.points)"
        
        lblTrue.text = "\(trueCount)"
        lblFalse.text = "\(Apps.TOTAL_PLAY_QS - trueCount)"
        
        score.coins = score.coins + earnedCoin
    
        totalCoin.text = "\(earnedCoin)"
        totalScore.text = "\(earnedPoints)"
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            //get data from server
            if(Reachability.isConnectedToNetwork()){
                let apiURL = "user_id=\(duser.userID)&score=\(earnedPoints)"
                self.getAPIData(apiName: "set_monthly_leaderboard", apiURL: apiURL,completion: LoadData)
            }else{
                ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
            }
        }
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
        request.testDevices = Apps.AD_TEST_DEVICE
        self.interstitialAd.load(request)
    }

    // Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        if self.controllerName == "review"{
            let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let review:ReView = storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            review.ReviewQues = ReviewQues
            self.present(review, animated: true, completion: nil)
            RequestInterstitialAd()
        }else if self.controllerName == "home"{
           
            self.dismiss(animated: true, completion: {
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            })
        
        }else{
             self.dismiss(animated: true, completion: nil)
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func nxtButton(_ sender: UIButton) {
        
        let playLavel = percentage < 30 ? self.level : self.level + 1
        self.quesData.removeAll()
        
        let apiURL = questionType == "main" ? "level=\(playLavel)&category=\(catID)" : "level=\(playLavel)&subcategory=\(catID)"
    
        self.getAPIData(apiName: "get_questions_by_level", apiURL: apiURL,completion: {jsonObj in
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
                self.ShowAlert(title: "Opps!", message: "Error while fetchning data")
            }else{
                //get data for category
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: "\(val["answer"]!)", image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)"))
                    }
                    //check this level has enought (10) question to play? or not
                    if self.quesData.count >= 10{
                        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let playView:PlayQuizView = storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                        playView.catID = self.catID
                        playView.level = playLavel
                        playView.questionType = self.questionType
                        playView.quesData = self.quesData
                        DispatchQueue.main.async {
                            self.present(playView, animated: true, completion:nil)
                        }
                    }else{
                        self.ShowAlert(title: Apps.NOT_ENOUGH_QUESTION_TITLE, message: Apps.NO_ENOUGH_QUESTION_MSG)
                    }
                }
            }
        })
    }
    
    @IBAction func reviewButton(_ sender: UIButton) {
        self.controllerName = "review"
        if interstitialAd.isReady{
            self.interstitialAd.present(fromRootViewController: self)
        }else{
            let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let review:ReView = storyBoard.instantiateViewController(withIdentifier: "ReView") as! ReView
            review.ReviewQues = ReviewQues
            self.present(review, animated: true, completion: nil)
        }
    }
    
    @IBAction func homeButton(_ sender: UIButton) {
        self.controllerName = "home"
        if interstitialAd.isReady{
            interstitialAd.present(fromRootViewController: self)
        }else{
            self.dismiss(animated: true, completion: {
                UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false, completion: nil)
            })
        }
    }
    
    @IBAction func scoreButton(_ sender: UIButton) {
        let str  = Apps.APP_NAME
        let shareUrl = "I have completed level \(self.level) with score \(self.earnedPoints)"
        let textToShare = str + "\n" + shareUrl
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
        present(vc, animated: true)
    }
    
    @IBAction func pdfButton(_ sender: UIButton) {
        var htmlStr = "<br><center><b><font size='16'>Quiz Review Question</font> </b></center><br>"
        var srno = 1
        for ques in ReviewQues {
            
            let correctAns = GetRightAnsString(correctAns: ques.correctAns, quetions: ques)
            htmlStr += "\(srno)). \(ques.question) <br>"
            htmlStr += self.OptionStr(rightAns: correctAns, userAns: ques.userSelect, opt: "a", choice: ques.opetionA)
            htmlStr += self.OptionStr(rightAns: correctAns, userAns: ques.userSelect, opt: "b", choice: ques.opetionB)
            htmlStr += self.OptionStr(rightAns: correctAns, userAns: ques.userSelect, opt: "c", choice: ques.opetionC)
            htmlStr += self.OptionStr(rightAns: correctAns, userAns: ques.userSelect, opt: "d", choice: ques.opetionD)
            
            htmlStr += "<br>"
            if(srno == 7){
                 htmlStr += "<br><br><br><br><br><br>"
            }
            srno += 1
        }
        self.createPDF(htmlStr: htmlStr)
        
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
        }        else{
            return ""
        }
    }
    @IBAction func rateButton(_ sender: UIButton) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "\(Apps.APP_ID)") {
            UIApplication.shared.openURL(url)
        }
    }
    
    func createPDF(htmlStr:String) {
        let html = htmlStr
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        pdfData.write(toFile: "\(documentsPath)/file.pdf", atomically: true)
        
        let url = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent("file").appendingPathExtension("pdf")
        
        let dc = UIDocumentInteractionController(url: url)
        dc.delegate = self
        dc.presentPreview(animated: true)
    }
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }
}
