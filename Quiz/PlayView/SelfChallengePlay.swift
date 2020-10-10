import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds

class SelfChallengePlay: UIViewController, UIScrollViewDelegate, GADRewardBasedVideoAdDelegate {
    
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet var lblQuestion: UITextView!
    @IBOutlet var question: UITextView!
    
    @IBOutlet var btnA: UIButton!
    @IBOutlet var btnB: UIButton!
    @IBOutlet var btnC: UIButton!
    @IBOutlet var btnD: UIButton!
    @IBOutlet var btnE: UIButton!
        
    //@IBOutlet weak var bookmarkBtn: UIButton!
    
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet var mainQuestionView: UIView!
    @IBOutlet var speakBtn: UIButton!
    @IBOutlet var zoomBtn: UIButton!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var zoomScroll: UIScrollView!
    @IBOutlet var view1: UIView!
    
   // @IBOutlet var leftView: UIView!
    @IBOutlet var centerView: UIView!
    @IBOutlet var rightView: UIView!
    @IBOutlet var secondChildView: UIView!
    
    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var topView: TopView!
    
    var seconds = 0
    var score: Int = 0
    
    var timer: Timer!
    var player: AVAudioPlayer?
    
    // Is an ad being loaded.
    var adRequestInProgress = false
    
    // The reward-based video ad.
    var rewardBasedVideo: GADRewardBasedVideoAd?

    var falseCount = 0
    var trueCount = 0
    
    @IBOutlet weak var mainQuesCount: UILabel!
    
    @IBOutlet var verticalView: UIView!
    
    var jsonObj : NSDictionary = NSDictionary()
    var quesData: [QuestionWithE] = []
    var reviewQues:[ReQuestionWithE] = []
    var BookQuesList:[QuestionWithE] = []
    
    var currentQuestionPos = 0
   
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var level = 0
    var catID = 0
    var questionType = "sub"
    var zoomScale:CGFloat = 1
    
    var opt_ft = false
    var opt_sk = false
    var opt_au = false
    var opt_re = false
    
    var callLifeLine = ""
    let speechSynthesizer = AVSpeechSynthesizer()
    var quizPlayTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblQuestion.backgroundColor = .white
        if Apps.opt_E == true {
            btnE.isHidden = false
            buttons = [btnA,btnB,btnC,btnD,btnE]
        }else{
            btnE.isHidden = true
            buttons = [btnA,btnB,btnC,btnD]
        }
       // view1.SetShadow()
        //Google AdMob
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo!.delegate = self
         if Apps.opt_E == true {
            DesignOpetionButton(buttons: btnA,btnB,btnC,btnD,btnE)
         }else{
            DesignOpetionButton(buttons: btnA,btnB,btnC,btnD)
        }
       // centerView.layer.addBorder(edge: .left, color: .darkGray, thickness: 1)
        centerView.layer.addBorder(edge: .right, color: .darkGray, thickness: 1)
        
        btnA.setImage(SetOptionView(otpStr: "A").createImage(), for: .normal)
        btnB.setImage(SetOptionView(otpStr: "B").createImage(), for: .normal)
        btnC.setImage(SetOptionView(otpStr: "C").createImage(), for: .normal)
        btnD.setImage(SetOptionView(otpStr: "D").createImage(), for: .normal)
        btnE.setImage(SetOptionView(otpStr: "E").createImage(), for: .normal)
        
        self.topView.addBottomBorderWithColor(color: .gray, width: 1)
        //font
        resizeTextview()
      
        //get bookmark list
        if (UserDefaults.standard.value(forKey: "booklist") != nil){
            BookQuesList = try! PropertyListDecoder().decode([QuestionWithE].self, from:((UserDefaults.standard.value(forKey: "booklist") as? Data)!))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ReloadFont), name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ResumeTimer), name: NSNotification.Name(rawValue: "ResumeTimer"), object: nil)

        zoomScroll.minimumZoomScale = 1.0
        zoomScroll.maximumZoomScale = 6.0
        
        setGradientBackground()
    
        self.mainQuestionView.DesignViewWithShadow()
        
        quesData.shuffle()
        rewardBasedVideo?.load(GADRequest(),withAdUnitID: Apps.REWARD_AD_UNIT_ID)
        
        RequestForRewardAds()
        
        seconds = self.quizPlayTime * 60
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        for ques in self.quesData{
            self.reviewQues.append(ReQuestionWithE.init(id: ques.id, question: ques.question, opetionA: ques.opetionA, opetionB: ques.opetionB, opetionC: ques.opetionC, opetionD: ques.opetionD, opetionE:ques.opetionE, correctAns: ques.correctAns, image: ques.image, level: ques.level, note: ques.note, quesType: ques.quesType, userSelect: ""))
        }
        self.loadQuestion()
    }
    
    
    var btnY = 0
    func SetButtonHeight(buttons:UIButton...){
        
        var minHeight = 50
        if UIDevice.current.userInterfaceIdiom == .pad{
            minHeight = 90
        }else{
            minHeight = 50
        }
        self.scroll.setContentOffset(.zero, animated: true)
        
        let perButtonChar = 35
        btnY = Int(self.secondChildView.frame.height + self.secondChildView.frame.origin.y)
        
        for button in buttons{
            let btnWidth = button.frame.width
            //let fonSize = 18
            let charCount = button.title(for: .normal)?.count
            
            let btnX = button.frame.origin.x
            
            let charLine = Int(charCount! / perButtonChar) + 1
            
            let btnHeight = charLine * 20 < minHeight ? minHeight : charLine * 20
            
            let newFram = CGRect(x: Int(btnX), y: btnY, width: Int(btnWidth), height: btnHeight)
            btnY += btnHeight + 8
            
            button.frame = newFram
            
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 0
        }
        let with = self.scroll.frame.width
        self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY))
    }
    
    func SetOptionView(otpStr:String) -> UIView{
        let color = Apps.BASIC_COLOR
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = .black
        
        let imgView = UIView(frame: CGRect(x: 3, y: 3, width: 35, height: 35))
        imgView.layer.cornerRadius = 4
        imgView.layer.borderColor = color.cgColor
        imgView.layer.borderWidth = 1
       
        imgView.addSubview(lbl)
        return imgView
    }
    
    func RequestForRewardAds(){
        let request = GADRequest()
        //request.testDevices = [ kGADSimulatorID ];
       // request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        rewardBasedVideo?.load(request,withAdUnitID: Apps.REWARD_AD_UNIT_ID)
    }
    
    @objc func ReloadFont(noti: NSNotification){
        resizeTextview()
    }
    
    func watchAd() {
        if rewardBasedVideo?.isReady == true {
            rewardBasedVideo?.present(fromRootViewController: self)
        }
    }
    
    // MARK: GADRewardBasedVideoAdDelegate implementation
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load: \(error.localizedDescription)")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
        rewardBasedVideo?.load(GADRequest(),withAdUnitID: Apps.REWARD_AD_UNIT_ID)
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
        
         var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        score.coins = score.coins + Int(Apps.REWARD_COIN)!//4
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
      
    }
    
    func resizeTextview(){
        
        var getFont = UserDefaults.standard.float(forKey: "fontSize")
        if (getFont == 0){
            getFont = 18
        }
        lblQuestion.font = lblQuestion.font?.withSize(CGFloat(getFont))
        question.font = question.font?.withSize(CGFloat(getFont))
        
        lblQuestion.centerVertically()
        question.centerVertically()
        
        btnA.titleLabel?.font = btnA.titleLabel?.font?.withSize(CGFloat(getFont))
        btnB.titleLabel?.font = btnB.titleLabel?.font?.withSize(CGFloat(getFont))
        btnC.titleLabel?.font = btnC.titleLabel?.font?.withSize(CGFloat(getFont))
        btnD.titleLabel?.font = btnD.titleLabel?.font?.withSize(CGFloat(getFont))
        btnE.titleLabel?.font = btnE.titleLabel?.font?.withSize(CGFloat(getFont))
        
        btnA.resizeButton()
        btnB.resizeButton()
        btnC.resizeButton()
        btnD.resizeButton()
        btnE.resizeButton()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImage
    }

    // resume timer when setting alert closed
    @objc func ResumeTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        buttons.forEach{$0.isUserInteractionEnabled = true}
        
        zoomScale = 1
        zoomScroll.zoomScale = 1
        
    }
    
    @objc func incrementCount() {
        self.timerLabel.text = self.secondsToHoursMinutesSeconds(seconds: seconds) //String(format: "%02d", seconds)
        seconds -= 1
        if seconds < 0 {
            self.ShowResultScreen()
        }
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert.isPlayView = true
        self.present(myAlert, animated: true, completion: {
             self.timer.invalidate()
        })
    }
    
    @IBAction func backButton(_ sender: Any) {
        let alert = UIAlertController(title: Apps.LEAVE_MSG ,message: Apps.BACK_MSG,preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            if self.timer.isValid{
                self.timer.invalidate()
            }
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func speakButton(_ sender: Any) {
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "\(quesData[currentQuestionPos].question)")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: Apps.LANG)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func zoomBtn(_ sender: Any) {
        if zoomScroll.zoomScale == zoomScroll.maximumZoomScale {
                   zoomScale = 0
               }
        zoomScale += 1
        zoomScroll.zoomScale = zoomScale
    }
    
    override func viewDidAppear(_ animated: Bool) {
       // clearColor()
    }
    
//    @IBAction func BookMark(_ sender: Any) {
//
//        if(self.bookmarkBtn.tag == 0){
//            let reQues = quesData[currentQuestionPos]
//            self.BookQuesList.append(QuestionWithE.init(id: reQues.id, question: reQues.question, opetionA: reQues.opetionA, opetionB: reQues.opetionB, opetionC: reQues.opetionC, opetionD: reQues.opetionD, opetionE: reQues.opetionE, correctAns: reQues.correctAns, image: reQues.image, level: reQues.level, note: reQues.note, quesType: reQues.quesType))
//            bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
//            bookmarkBtn.tag = 1
//            self.SetBookmark(quesID: reQues.id, status: "1", completion: {})
//        }else{
//            let reQues = quesData[currentQuestionPos]
//            BookQuesList.removeAll(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})
//            bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
//            bookmarkBtn.tag = 0
//            self.SetBookmark(quesID: reQues.id, status: "0", completion: {})
//        }
//
//        UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
//
//    }
    
    func clearColor(views:UIView...){
        
        let singleQues = quesData[currentQuestionPos]
        if singleQues.quesType == "2"{
            btnA.setImage(SetOptionView(otpStr: "o").createImage(), for: .normal)
            btnB.setImage(SetOptionView(otpStr: "o").createImage(), for: .normal)
        }else{
            btnA.setImage(SetOptionView(otpStr: "A").createImage(), for: .normal)
            btnB.setImage(SetOptionView(otpStr: "B").createImage(), for: .normal)
            btnC.setImage(SetOptionView(otpStr: "C").createImage(), for: .normal)
            btnD.setImage(SetOptionView(otpStr: "D").createImage(), for: .normal)
            btnE.setImage(SetOptionView(otpStr: "E").createImage(), for: .normal)
        }
       
      
        for view in views{
            view.isHidden = false
            view.backgroundColor = UIColor.white
            view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    
    @IBAction func SubmitForResult(_ sender: Any) {
        let alert = UIAlertController(title: Apps.SUBMIT_TEST,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            self.ShowResultScreen()
        }))
        
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func PrevBtn(_ sender: Any) {
        self.currentQuestionPos -= 1
        if self.currentQuestionPos >= 0{
            self.loadQuestion()
        }else{
            self.currentQuestionPos = 0
        }
    }
   
    @IBAction func ShowAttemp(_ sender: Any){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "SelfAttempAlertView") as! SelfAttempAlertView
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert.bottomAlertData  = self.bottomAlertData
        myAlert.noOfQues = self.quesData.count
        self.present(myAlert, animated: true, completion: nil)
    }
  
    
    @IBAction func NextBtn(_ sender: Any) {
           
        self.currentQuestionPos += 1
        if self.currentQuestionPos < self.quesData.count{
            self.loadQuestion()
        }else{
            self.currentQuestionPos = self.quesData.count - 1
        }
    }
    // set question vcalue and its answer here
    @objc func loadQuestion() {
        // Show next question
        
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
        resetProgressCount() // reset timer
//        if Apps.opt_E == true {
//            clearColor(views: btnA,btnB,btnC,btnD,btnE)
//            // enabled opetions button
//            MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
//        }else{
//            clearColor(views: btnA,btnB,btnC,btnD)
//            // enabled opetions button
//            MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
//        }
            
        if(currentQuestionPos  < quesData.count ) {
            if(quesData[currentQuestionPos].image == ""){
                // if question dose not contain images
                question.text = quesData[currentQuestionPos].question
                question.centerVertically()
                //hide some components
                lblQuestion.isHidden = true
                questionImage.isHidden = true
               // zoomBtn.isHidden = true
                
                question.isHidden = false
            }else{
                // if question has image
                lblQuestion.text = quesData[currentQuestionPos].question
                lblQuestion.centerVertically()
                questionImage.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)
                //show some components
                lblQuestion.isHidden = false
                questionImage.isHidden = false
             //   zoomBtn.isHidden = false
                question.isHidden = true
            }
         if(quesData[currentQuestionPos].opetionE == "")
         {
             Apps.opt_E = false
         }else{
             Apps.opt_E = true
         }
         if Apps.opt_E == true {
             clearColor(views: btnA,btnB,btnC,btnD,btnE)
             btnE.isHidden = false
             buttons = [btnA,btnB,btnC,btnD,btnE]
             DesignOpetionButton(buttons: btnA,btnB,btnC,btnD,btnE)
             self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
             // enabled opetions button
             MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
         }else{
             clearColor(views: btnA,btnB,btnC,btnD)
             btnE.isHidden = true
             buttons = [btnA,btnB,btnC,btnD]
             DesignOpetionButton(buttons: btnA,btnB,btnC,btnD)
             self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
             // enabled opetions button
             MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
         }            
           self.SetButtonOpetion(opestions: quesData[currentQuestionPos].opetionA,quesData[currentQuestionPos].opetionB,quesData[currentQuestionPos].opetionC,quesData[currentQuestionPos].opetionD,quesData[currentQuestionPos].opetionE,quesData[currentQuestionPos].correctAns)
            
            mainQuesCount.roundCorners(corners: [ .bottomRight], radius: 5)
            mainQuesCount.text = "\(currentQuestionPos + 1)" //"\(currentQuestionPos + 1)/10"
           
            
//            //check current question is in bookmark list or not
//            if(BookQuesList.contains(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})){
//                self.bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
//                self.bookmarkBtn.tag = 1
//            }else{
//                self.bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
//                self.bookmarkBtn.tag = 0
//            }
        } else {
            //self.ShowResultScreen()
        }
    }
    
    func ShowResultScreen(){
        timer.invalidate()
        if self.quesData.count != self.reviewQues.count{
            for ques in self.quesData{
                if self.reviewQues.contains(where: {$0.id == ques.id}){
                }else{
                    self.reviewQues.append(ReQuestionWithE.init(id: ques.id, question: ques.question, opetionA: ques.opetionA, opetionB: ques.opetionB, opetionC: ques.opetionC, opetionD: ques.opetionD, opetionE:ques.opetionE, correctAns: ques.correctAns, image: ques.image, level: ques.level, note: ques.note, quesType: ques.quesType, userSelect: ""))
                }
            }
        }
        // If there are no more questions show the results
        let storyBoard:UIStoryboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let resultView = storyBoard.instantiateViewController(withIdentifier: "SelfPlayResultView") as! SelfPlayResultView
        
        resultView.totalTime = self.quizPlayTime * 60
        resultView.completedTime = self.seconds
        resultView.quesCount = self.quesData.count
        resultView.ReviewQues = self.reviewQues
       
        self.navigationController?.pushViewController(resultView, animated: true)
    }
    // set button opetion's
    var buttons:[UIButton] = []
    func SetButtonOpetion(opestions:String...){
        clickedButton.removeAll()
        var temp : [String]
        if opestions.contains("") {
             print("true - \(opestions)")
             temp = ["a","b","c","d"]
             self.buttons = [btnA,btnB,btnC,btnD]
         }else{
               print("false - \(opestions)")
               temp = ["a","b","c","d","e"]
               self.buttons = [btnA,btnB,btnC,btnD,btnE]
         }
//        if Apps.opt_E == true {
//             temp = ["a","b","c","d","e"]
//        }else{
//             temp = ["a","b","c","d"]
//        }
       let ans = temp
        if ans.contains("\(opestions.last!.lowercased())") { //last is answer here
        }else{
            self.ShowAlert(title: Apps.INVALID_QUE, message: Apps.INVALID_QUE_MSG)
        }
      let singleQues = quesData[currentQuestionPos]
       if singleQues.quesType == "2"{
           
           clearColor(views: btnA,btnB)
           MakeChoiceBtnDefault(btns: btnA,btnB)
           
           btnC.isHidden = true
           btnD.isHidden = true

           self.buttons = [btnA,btnB]
           //btnE.isHidden = true
            temp = ["a","b"]
           self.buttons.forEach{
                $0.setImage(SetOptionView(otpStr: "o").createImage(), for: .normal)
           }
       }else{
           btnC.isHidden = false
           btnD.isHidden = false
       }
        var index = 0
        var userSelectedAns = ""
        if  let tm = self.reviewQues.first(where: {$0.id == self.quesData[self.currentQuestionPos].id}){
            userSelectedAns = tm.userSelect
        }
        
        for button in buttons{
            if userSelectedAns != "" && userSelectedAns == opestions[index]{
                if singleQues.quesType == "2"{
                    button.setImage(SetClickedOptionView(otpStr: "o").createImage(), for: .normal)
                }else{
                    button.setImage(SetClickedOptionView(otpStr: temp[index]).createImage(), for: .normal)
                }
                
            }
            button.setTitle(opestions[index], for: .normal)
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
        self.SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE)
    }
    
    // opetion buttons click action
    var bottomAlertData:[Int] = []
    @objc func ClickButton(button:UIButton){
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound "selfClick"
        self.Vibrate() // make device vibrate
        
        let singleQues = quesData[currentQuestionPos]
        
        buttons.forEach{
            $0.isUserInteractionEnabled = false
            if singleQues.quesType == "2"{
                $0.setImage(SetOptionView(otpStr: "o").createImage(), for: .normal)
            }else{
                $0.setImage(SetOptionView(otpStr: ($0.accessibilityLabel?.uppercased())!).createImage(), for: .normal)
            }
            
        }
        if singleQues.quesType == "2"{
            button.setImage(self.SetClickedOptionView(otpStr: "o").createImage(), for: .normal)
        }else{
            button.setImage(self.SetClickedOptionView(otpStr: (button.accessibilityLabel?.uppercased())!).createImage(), for: .normal)
        }
      
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            if button.tag == 1{
               // rightAnswer(btn: button)
            }else{
               // wrongAnswer(btn: button)
            }
            AddToReview(opt: button.title(for: .normal)!)
            if !self.bottomAlertData.contains(self.currentQuestionPos + 1){
                self.bottomAlertData.append(self.currentQuestionPos + 1)
            }
        }
        
        buttons.forEach{
            $0.isUserInteractionEnabled = true
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
    
    // set default to four choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.isEnabled = true
            btn.resizeButton()
            btn.subviews.forEach({
                if($0.tag == 11){
                    $0.removeFromSuperview()
                }
                //find if there is any circular progress on opetion button and remove it
                for calayer in (btn.layer.sublayers)!{
                    if calayer.name == "circle" {
                        calayer.removeFromSuperlayer()
                    }
                }
            })
        }
    }
    
    // Set the background as a blue gradient
    func setGradientBackground() {
        let colorTop =  UIColor(red: 243/255, green: 243/255, blue: 247/255, alpha: 1.0).cgColor
        let colorBottom = UIColor.white.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = self.view.bounds
        
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // add question to review array for later review it
    func AddToReview(opt:String){
        if  var tm = self.reviewQues.first(where: {$0.id == self.quesData[self.currentQuestionPos].id}){
            let index = self.reviewQues.firstIndex(where: {$0.id == tm.id})
            tm.userSelect = opt
            self.reviewQues[index!] = tm
            return
        }
        let ques = quesData[currentQuestionPos]
        reviewQues.append(ReQuestionWithE.init(id: ques.id, question: ques.question, opetionA: ques.opetionA, opetionB: ques.opetionB, opetionC: ques.opetionC, opetionD: ques.opetionD, opetionE:ques.opetionE, correctAns: ques.correctAns, image: ques.image, level: ques.level, note: ques.note, quesType: ques.quesType, userSelect: opt))
    }
}

