import Foundation
import UIKit
import AVFoundation
import GoogleMobileAds

class PlayQuizView: UIViewController, UIScrollViewDelegate, GADRewardBasedVideoAdDelegate {
    
    let progressBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_true)
    let progressFalseBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_false)
    
    @IBOutlet weak var titleBar: UILabel!
    @IBOutlet var lblQuestion: UITextView!
    @IBOutlet var question: UITextView!
    
    @IBOutlet var btnA: UIButton!
    @IBOutlet var btnB: UIButton!
    @IBOutlet var btnC: UIButton!
    @IBOutlet var btnD: UIButton!
    @IBOutlet var btnE: UIButton!
        
    @IBOutlet weak var bookmarkBtn: UIButton!
    
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet var mainQuestionView: UIView!
    @IBOutlet var speakBtn: UIButton!
    @IBOutlet var zoomBtn: UIButton!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var zoomScroll: UIScrollView!
    
    @IBOutlet var scoreLbl: UILabel!
    @IBOutlet var trueLbl: UILabel!
    @IBOutlet var falseLbl: UILabel!
    
    @IBOutlet var view1: UIView!
    @IBOutlet weak var progFalseView: UIView!
    
    var count: CGFloat = 0.0
    var score: Int = 0
    
    var progressRing: CircularProgressBar!
    var timer: Timer!
    var player: AVAudioPlayer?
    
    // Is an ad being loaded.
    var adRequestInProgress = false
    
    // The reward-based video ad.
    var rewardBasedVideo: GADRewardBasedVideoAd?

    var falseCount = 0
    var trueCount = 0
    
    @IBOutlet weak var mainQuesCount: UILabel!
    @IBOutlet weak var mainScoreCount: UILabel!
    @IBOutlet weak var mainCoinCount: UILabel!
    
    @IBOutlet weak var proview: UIView!
    @IBOutlet var verticalView: UIView!
    
    var jsonObj : NSDictionary = NSDictionary()
    
//    var quesData: [Question] = []
//    var reviewQues:[ReQuestion] = []
//    var BookQuesList:[Question] = []
       var quesData: [QuestionWithE] = []
       var reviewQues:[ReQuestionWithE] = []
       var BookQuesList:[QuestionWithE] = []
    
    var currentQuestionPos = 0
    var color1 = UIColor(red: 243/255, green: 243/255, blue: 247/255, alpha: 1.0)
   
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Apps.opt_E == true {
            btnE.isHidden = false
            buttons = [btnA,btnB,btnC,btnD,btnE]
        }else{
            btnE.isHidden = true
            buttons = [btnA,btnB,btnC,btnD]
            //resetOpetionsPositions(btnB,btnC,btnD)
        }
        
        //Google AdMob
        rewardBasedVideo = GADRewardBasedVideoAd.sharedInstance()
        rewardBasedVideo!.delegate = self
         if Apps.opt_E == true {
            DesignOpetionButton(buttons: btnA,btnB,btnC,btnD,btnE)
         }else{
            DesignOpetionButton(buttons: btnA,btnB,btnC,btnD)
        }
        
        //font
        resizeTextview()
      
        //get bookmark list
        if (UserDefaults.standard.value(forKey: "booklist") != nil){
        //do{
            BookQuesList = try! PropertyListDecoder().decode([QuestionWithE].self, from:((UserDefaults.standard.value(forKey: "booklist") as? Data)!))
                print(BookQuesList)       // }
//             catch {
//                print(error.localizedDescription)
//            }
        }
        
        self.RegisterNotification(notificationName: "PlayView")
        self.CallNotification(notificationName: "ResultView")
        
        NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ReloadFont), name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
         NotificationCenter.default.addObserver(self, selector: #selector(PlayQuizView.ResumeTimer), name: NSNotification.Name(rawValue: "ResumeTimer"), object: nil)
        
        setVerticleProgress(view: proview, progress: progressBar)// true progres bar
        setVerticleProgress(view: progFalseView, progress: progressFalseBar)// false progress bar
        
        let mScore = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        mainScoreCount.text = "\(mScore.points)"
        mainCoinCount.text = "\(mScore.coins)"
        
       // self.scroll.contentSize = CGSize(width: 320, height: 800)

        zoomScroll.minimumZoomScale = 1.0
        zoomScroll.maximumZoomScale = 6.0
        
        setGradientBackground()
        
        if Apps.opt_E == true {
            //set five option's view shadow
            self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
        }else{
            //set four option's view shadow
            self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
        }
                
        self.mainQuestionView.DesignViewWithShadow()
        
        let xPosition = view1.center.x - 10
        let yPosition = view1.center.y + 3 //- 5
        let position = CGPoint(x: xPosition, y: yPosition)
        progressRing = CircularProgressBar(radius: (view1.frame.size.height - 10) / 2, position: position, innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6)
        view1.layer.addSublayer(progressRing)
        
        quesData.shuffle()
        rewardBasedVideo?.load(GADRequest(),withAdUnitID: Apps.REWARD_AD_UNIT_ID)
        
        RequestForRewardAds() // by M
        
        self.titleBar.text = "\(Apps.LEVEL): \(level)"
        self.loadQuestion()
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
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
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
        score.coins = score.coins + 4
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        mainCoinCount.text = "\(score.coins)"
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
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
       buttons.forEach{$0.isUserInteractionEnabled = true}
        if self.timer != nil && self.timer.isValid{
            self.timer.invalidate()
        }
        progressRing.innerTrackShapeLayer.strokeColor = UIColor.defaultInnerColor.cgColor
        zoomScale = 1
        zoomScroll.zoomScale = 1
        count = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
    }
    
    @objc func incrementCount() {
        count += 0.1
        progressRing.progress = CGFloat(Apps.QUIZ_PLAY_TIME - count)
        if count >= 20{
              progressRing.innerTrackShapeLayer.strokeColor = Apps.WRONG_ANS_COLOR.cgColor
        }
        if count >= Apps.QUIZ_PLAY_TIME { // set timer here
            timer.invalidate()
            currentQuestionPos += 1
            loadQuestion()
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
        let alert = UIAlertController(title: Apps.EXIT_APP_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            self.timer.invalidate()
            self.speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
            self.dismiss(animated: true, completion: nil)
        }))
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func speakButton(_ sender: Any) {
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "\(quesData[currentQuestionPos].question)")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func zoomBtn(_ sender: Any) {
        zoomScale += 1
        zoomScroll.zoomScale = zoomScale
    }
    
    //50 50 option select
    @IBAction func fiftyButton(_ sender: Any) {
        if(!opt_ft){
             var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_FT_COIN){
                // user does not have enough coins
                self.ShowAlertForNotEnoughtCoins(requiredCoins: Apps.OPT_FT_COIN, lifelineName: "fifty")
            }else{
                // if user have coins
                var index = 0
                for button in buttons{
                          if button.tag == 0 && index < 2{ //To remove 3 options from 5, use 3 instead of 2 here
                          button.isHidden = true
                          index += 1
                      }
                }
                opt_ft = true
                //deduct coin for use lifeline and store it
              score.coins = score.coins - Apps.OPT_FT_COIN
                 UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                 mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //skip option select
    @IBAction func SkipBtn(_ sender: Any) {
        if(!opt_sk){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_SK_COIN){
                // user dose not have enought coins
                self.ShowAlertForNotEnoughtCoins(requiredCoins: Apps.OPT_SK_COIN, lifelineName: "skip")
            }else{
                // if user have coins
                timer.invalidate()
                currentQuestionPos += 1
                loadQuestion()
                
                opt_sk = true
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_SK_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                 mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //Audios poll option select
    @IBAction func AudionsBtn(_ sender: Any) {
        if(!opt_au){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_SK_COIN){
                // user dose not have enought coins
                self.ShowAlertForNotEnoughtCoins(requiredCoins: Apps.OPT_AU_COIN, lifelineName: "audions")
            }else{
                // if user have coins
                var r1:Int,r2:Int,r3:Int,r4:Int,r5:Int
                
                r1 = Int.random(in: 1 ... 96)
                r2 = Int.random(in: 1 ... 97 - r1)
                r3 = Int.random(in: 1 ... 98 - r1 - r2)
                r5 = Int.random(in: 1 ... 98 - r1 - r2 - r3)
                r4 = 100 - r1 - r2 - r3 - r5
                
                var randoms = [r1,r2,r3,r5,r4]
                randoms.sort(){$0 > $1}
                
                var index = 0
                for button in buttons{
                    if button.tag == 1{
                        drawCircle(btn: button, proVal: randoms[0])
                    }else{
                        index += 1
                        drawCircle(btn: button, proVal: randoms[index])
                    }
                }
                opt_au = true
        
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_AU_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    //reset timer option select
    @IBAction func ResetBtn(_ sender: Any) {
        if(!opt_re){
            var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
            
            if(score.coins < Apps.OPT_RES_COIN){
                // user dose not have enought coins
                self.ShowAlertForNotEnoughtCoins(requiredCoins: Apps.OPT_RES_COIN, lifelineName: "reset")
            }else{
                // if user have coins
                timer.invalidate()
                resetProgressCount()
                opt_re = true
                //deduct coin for use lifeline and store it
                score.coins = score.coins - Apps.OPT_RES_COIN
                UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
                mainCoinCount.text = "\(score.coins)"
            }
        }else{
            self.ShowAlert(title: Apps.LIFELINE_ALREDY_USED_TITLE, message: Apps.LIFELINE_ALREDY_USED)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        clearColor()
    }
    
    @IBAction func BookMark(_ sender: Any) {
        
        if(self.bookmarkBtn.tag == 0){
            let reQues = quesData[currentQuestionPos]
            self.BookQuesList.append(QuestionWithE.init(id: reQues.id, question: reQues.question, opetionA: reQues.opetionA, opetionB: reQues.opetionB, opetionC: reQues.opetionC, opetionD: reQues.opetionD, opetionE: reQues.opetionE, correctAns: reQues.correctAns, image: reQues.image, level: reQues.level, note: reQues.note))
            bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
            bookmarkBtn.tag = 1
        }else{
            BookQuesList.removeAll(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})
            bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
            bookmarkBtn.tag = 0
        }
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
        
    }
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //make timer invalidate
        timer.invalidate() //by me
        
        //score count
        trueCount += 1
        trueLbl.text = "\(trueCount)"
        progressBar.setProgress(Float(trueCount) / Float(10), animated: true)
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        score.points = score.points + Apps.QUIZ_R_Q_POINTS
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        btn.backgroundColor = Apps.RIGHT_ANS_COLOR
        btn.tintColor = UIColor.white
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.3
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: btn.center.x, y: btn.center.y - 5))
        animation.toValue = NSValue(cgPoint: CGPoint(x: btn.center.x, y: btn.center.y + 5))
        btn.layer.add(animation, forKey: "position")
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "right")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increament for next question
            self.loadQuestion()
        })
    }
    
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        //make timer invalidate
        timer.invalidate() //by me
        
        //score count
        falseCount += 1
        falseLbl.text = "\(falseCount)"
        progressFalseBar.setProgress(Float(falseCount) / Float(10), animated: true)
        
        var score = try! PropertyListDecoder().decode(UserScore.self, from: (UserDefaults.standard.value(forKey:"UserScore") as? Data)!)
        score.points = score.points - Apps.QUIZ_W_Q_POINTS
        UserDefaults.standard.set(try? PropertyListEncoder().encode(score),forKey: "UserScore")
        
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "wrong")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increament for next question
            self.loadQuestion()
        })
    }
    
    func clearColor(views:UIView...){
        for view in views{
            view.isHidden = false
            view.backgroundColor = UIColor.white
            view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    // set question vcalue and its answer here
    @objc func loadQuestion() {
        // Show next question
        
        speechSynthesizer.stopSpeaking(at: AVSpeechBoundary(rawValue: 0)!)
        resetProgressCount() // reset timer
        if Apps.opt_E == true {
            clearColor(views: btnA,btnB,btnC,btnD,btnE)
            // enabled opetions button
            MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
        }else{
            clearColor(views: btnA,btnB,btnC,btnD)
            // enabled opetions button
            MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
        }
                
        if(currentQuestionPos  < quesData.count && currentQuestionPos + 1 <= Apps.TOTAL_PLAY_QS ) {
            if(quesData[currentQuestionPos].image == ""){
                // if question dose not contain images
                question.text = quesData[currentQuestionPos].question
                question.centerVertically()
                //hide some components
                lblQuestion.isHidden = true
                questionImage.isHidden = true
                zoomBtn.isHidden = true
                
                question.isHidden = false
            }else{
                // if question has image
                lblQuestion.text = quesData[currentQuestionPos].question
                lblQuestion.centerVertically()
                questionImage.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)
                //show some components
                lblQuestion.isHidden = false
                questionImage.isHidden = false
                zoomBtn.isHidden = false
                question.isHidden = true
            }
            if Apps.opt_E == true {
                   self.SetButtonOpetion(opestions: quesData[currentQuestionPos].opetionA,quesData[currentQuestionPos].opetionB,quesData[currentQuestionPos].opetionC,quesData[currentQuestionPos].opetionD,quesData[currentQuestionPos].opetionE,quesData[currentQuestionPos].correctAns)
            }else{
                   self.SetButtonOpetion(opestions: quesData[currentQuestionPos].opetionA,quesData[currentQuestionPos].opetionB,quesData[currentQuestionPos].opetionC,quesData[currentQuestionPos].opetionD,quesData[currentQuestionPos].correctAns)
            }
         
            
            mainQuesCount.text = "\(currentQuestionPos + 1)/10"
            mainScoreCount.text = "\((trueCount * Apps.QUIZ_R_Q_POINTS) - (falseCount * Apps.QUIZ_W_Q_POINTS))"
            
            //check current question is in bookmark list or not
            if(BookQuesList.contains(where: {$0.id == quesData[currentQuestionPos].id && $0.correctAns == quesData[currentQuestionPos].correctAns})){
                self.bookmarkBtn.setBackgroundImage(UIImage(named: "book-on"), for: .normal)
                self.bookmarkBtn.tag = 1
            }else{
                self.bookmarkBtn.setBackgroundImage(UIImage(named: "book-off"), for: .normal)
                self.bookmarkBtn.tag = 0
            }
        } else {
            timer.invalidate()
            // If there are no more questions show the results
            let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let resultView:ResultsViewController = storyBoard.instantiateViewController(withIdentifier: "ResultsViewController") as! ResultsViewController
            resultView.trueCount = trueCount
            resultView.earnedPoints = (trueCount * Apps.QUIZ_R_Q_POINTS) - (falseCount * Apps.QUIZ_W_Q_POINTS)
            resultView.ReviewQues = reviewQues
            resultView.level = self.level
            resultView.catID = self.catID
            resultView.questionType = self.questionType
            self.present(resultView, animated: true, completion: nil)
        }
    }
    
    // set button opetion's
    var buttons:[UIButton] = []
    func SetButtonOpetion(opestions:String...){
        clickedButton.removeAll()
        var temp : [String]
        if Apps.opt_E == true {
             temp = ["a","b","c","d","e"]
        }else{
             temp = ["a","b","c","d"]
        }
       let ans = temp
        var rightAns = ""
        if ans.contains("\(opestions.last!.lowercased())") { //last is answer here
            rightAns = opestions[ans.index(of: opestions.last!.lowercased())!]
        }else{
            self.ShowAlert(title: "Invalid Question", message: "This Question has wrong value.")
            rightAnswer(btn: btnA)
        }
        buttons.shuffle()
        var index = 0
        for button in buttons{
            button.setTitle(opestions[index], for: .normal)
            if opestions[index] == rightAns{
                button.tag = 1
            }else{
                button.tag = 0
            }
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
    }
    
    // opetion buttons click action
    @objc func ClickButton(button:UIButton){
        buttons.forEach{$0.isUserInteractionEnabled = false}
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            if button.tag == 1{
                rightAnswer(btn: button)
            }else{
                wrongAnswer(btn: button)
            }
            AddToReview(opt: button.title(for: .normal)!)
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
        let ques = quesData[currentQuestionPos]
        reviewQues.append(ReQuestionWithE.init(id: ques.id, question: ques.question, opetionA: ques.opetionA, opetionB: ques.opetionB, opetionC: ques.opetionC, opetionD: ques.opetionD, opetionE:ques.opetionE, correctAns: ques.correctAns, image: ques.image, level: ques.level, note: ques.note, userSelect: opt))
    }
    
    // draw circle for audions poll lifeline
    func drawCircle(btn: UIButton, proVal: Int){
        let progRing = CircularProgressBar(radius: 20, position: CGPoint(x: btn.frame.size.width - 25, y: (btn.frame.size.height )/2), innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 5,progValue: 100)
        progRing.name = "circle"
        
        progRing.progressLabel.numberOfLines = 1;
        progRing.progressLabel.minimumScaleFactor = 0.7;
        progRing.progressLabel.adjustsFontSizeToFitWidth = true;
        
        btn.layer.addSublayer(progRing)
        var count:CGFloat = 0
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            count += 1
            progRing.progressManual = count
            if count >= CGFloat(proVal){
               timer.invalidate()
            }
        }
    }
    
    //show alert for not enought coins
    func ShowAlertForNotEnoughtCoins(requiredCoins:Int, lifelineName:String){
        self.timer.invalidate()
        let alert = UIAlertController(title: Apps.MSG_ENOUGH_COIN, message: "\(Apps.NEED_COIN_MSG1) \(requiredCoins) \(Apps.NEED_COIN_MSG2) \n \(Apps.NEED_COIN_MSG3)", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: Apps.SKIP_COINS, style: UIAlertAction.Style.cancel, handler: {action in
            self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.incrementCount), userInfo: nil, repeats: true)
            self.timer.fire()
        }))
        alert.addAction(UIAlertAction(title: Apps.WATCH_VIDEO, style: .default, handler: { action in
            self.watchAd()
            self.callLifeLine = lifelineName
        }))
        self.present(alert, animated: true)
    }
}
