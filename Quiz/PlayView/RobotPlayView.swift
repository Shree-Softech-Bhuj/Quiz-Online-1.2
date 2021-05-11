import Foundation
import UIKit
import AVFoundation
import  FirebaseDatabase

protocol RobotPlayViewDelegate: class {
    func DismissSelf()
}

class RobotPlayView: UIViewController, UIScrollViewDelegate {
    
    let trueVerticleBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_true)
    let falseVerticleBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_false)
    
    @IBOutlet weak var userImg1: UIImageView!
    @IBOutlet weak var userImg2: UIImageView!
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var secondChildView: UIView!
    
    @IBOutlet weak var userName1: UILabel!
    @IBOutlet weak var userName2: UILabel!
    
    @IBOutlet weak var userCount1: UILabel!
    @IBOutlet weak var userCount2: UILabel!
    
    @IBOutlet weak var trueCount: UILabel!
    @IBOutlet weak var trueVerticleProgress: UIView!
    
    @IBOutlet weak var falseCount: UILabel!
    @IBOutlet weak var falseVerticleProgress: UIView!
    
    @IBOutlet weak var mainQuestionLbl: UITextView!
    @IBOutlet weak var questionImageView: UIImageView!
    
    @IBOutlet weak var zoomScroll: UIScrollView!
    @IBOutlet weak var zoomBtn: UIButton!
    @IBOutlet weak var imageQuestionLbl: UITextView!
    
    @IBOutlet weak var totalCount: UILabel!
    
    @IBOutlet weak var battleScoreView: UIView!
    
    @IBOutlet weak var btnA: UIButton!
    @IBOutlet weak var btnB: UIButton!
    @IBOutlet weak var btnC: UIButton!
    @IBOutlet weak var btnD: UIButton!
    @IBOutlet weak var btnE: UIButton!
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var questionView: UIView!
    
    var progressRing: CircularProgressBar!
    var timer: Timer!
    
    var count: CGFloat = 0.0
    var rightCount = 0
    var wrongCount = 0
  
    var zoomScale:CGFloat = 1
    var opponentRightCount = 0
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var quesData: [QuestionWithE] = []
    
    var currentQuestionPos = 0
    
    var user:User!
    var observeQues = 0
    
    var robotName = Apps.ROBOT
    var robotImage:UIImage!
    var sysConfig:SystemConfiguration!
    
     var correctAnswer = "a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageQuestionLbl.backgroundColor = .white
        btnE.isHidden = true
        buttons = [btnA,btnB,btnC,btnD]
        
        userImg1.layer.borderWidth = 2
        userImg1.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        userImg1.layer.cornerRadius = userImg1.bounds.width / 2
        userImg1.clipsToBounds = true
        userImg2.layer.borderWidth = 2
        userImg2.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        userImg2.layer.cornerRadius = userImg2.bounds.width / 2
        userImg2.clipsToBounds = true
                
        NotificationCenter.default.post(name: Notification.Name("DismissAlert"), object: nil)
        // set refrence for firebase database
        mainQuestionLbl.centerVertically()
        imageQuestionLbl.centerVertically()
        
        // add ring progress to timer view
        if deviceStoryBoard == "Ipad"{
                  progressRing = CircularProgressBar(radius: 20, position: CGPoint(x: timerView.center.x, y: timerView.center.y - 20), innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6)
              }else{
                   progressRing = CircularProgressBar(radius: 20, position: CGPoint(x: timerView.center.x, y: timerView.center.y + 3), innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6)
              }
        timerView.layer.addSublayer(progressRing)
        
        self.setVerticleProgress(view: trueVerticleProgress, progress: trueVerticleBar)// true verticle progress bar
        self.setVerticleProgress(view: falseVerticleProgress, progress: falseVerticleBar) // false verticle progress bar
       
        battleScoreView.SetShadow()
        self.questionView.DesignViewWithShadow()
        
       //set four option's view shadow
        self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
        
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        userName1.text = user.name
       // userName1.setLabel()
        userName2.text = robotName
        robotImage = UIImage(named: "robot")
        DispatchQueue.main.async {
            self.userImg1.loadImageUsingCache(withUrl: self.user.image)
            self.userImg2.image = self.robotImage
        }
        
       
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            var apiURL = ""//"user_id_1=\(user.UID)&user_id_2=0987654321&match_id=\(user.UID)"
            if sysConfig.LANGUAGE_MODE == 1{
                           let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                           apiURL = "&language_id=\(langID)" //+=
                       }
            self.getAPIData(apiName: "get_random_questions_for_computer", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        
        zoomScroll.minimumZoomScale = 1.0
        zoomScroll.maximumZoomScale = 6.0
        
        NotificationCenter.default.addObserver(self, selector: #selector(BattlePlayController.ReloadFont), name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.CompleteBattle),name: NSNotification.Name(rawValue: "CompleteRobotBattle"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.DismissSelf),name: NSNotification.Name(rawValue: "CloseRobotPlay"),object: nil) // close this view controller
        
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
    
    @objc func ReloadFont(noti: NSNotification){
        resizeTextview()
    }
    
    func resizeTextview(){
        
        var getFont = UserDefaults.standard.float(forKey: "fontSize")
        if (getFont == 0){
            getFont = 16
        }
        mainQuestionLbl.font = mainQuestionLbl.font?.withSize(CGFloat(getFont))
        imageQuestionLbl.font = imageQuestionLbl.font?.withSize(CGFloat(getFont))
        
        mainQuestionLbl.centerVertically()
        imageQuestionLbl.centerVertically()
        
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
        return questionImageView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    @IBAction func ZoomBtn(_ sender: Any) {
        if zoomScroll.zoomScale == zoomScroll.maximumZoomScale {
            zoomScale = 0
        }
        zoomScale += 1
        zoomScroll.zoomScale = zoomScale
    }
    
    @IBAction func SpeechBtn(_ sender: Any) {
        let speechSynthesizer = AVSpeechSynthesizer()
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "\(quesData[currentQuestionPos].question)")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: Apps.LANG)
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func LeaveBattle(_ sender: Any) {
        let alert = UIAlertController(title: Apps.EXIT_APP_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            if self.timer.isValid{
                self.timer.invalidate()
            }
            NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("CloseBattleViewController"), object: nil)
            self.navigationController?.popViewController(animated: true)
        }))
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    @IBAction func settingButton(_ sender: Any) {
          let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
          let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
          myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
          myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
          self.present(myAlert, animated: true, completion: nil)
      }
    @objc func CompleteBattle(){
        if timer.isValid{
            timer.invalidate()
        }
        self.dismiss(animated: true, completion: nil)
    }
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
       // print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
            
        }else{
            //get data for category
            //print(jsonObj.value(forKey: "data")!)
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                    
                        //check if admin have added questions with 5 options? if not, then hide option E btn by setting boolean variable to false even if option E mode is Enabled.
//                        if let e = val["optione"] as? String {
//                          if e == ""{
//                               Apps.opt_E = false
//                             DispatchQueue.main.async {
//                                self.btnE.isHidden = true
//                            }
//                               buttons = [btnA,btnB,btnC,btnD]
//                               //set four option's view shadow
//                               self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
//                          }else{
//                               Apps.opt_E = true
//                             DispatchQueue.main.async {
//                                self.btnE.isHidden = false
//                            }
//                                buttons = [btnA,btnB,btnC,btnD,btnE]
//                               //set five option's view shadow
//                               self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
//                          }
//                        }
                }
                Apps.TOTAL_PLAY_QS  =  data.count
                print(Apps.TOTAL_PLAY_QS)
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.quesData.shuffle()
                self.DismissLoader(loader: self.Loader)
                self.LoadQuestion()
            }
        });
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        
        buttons.forEach{$0.isUserInteractionEnabled = true}
        if self.timer != nil && self.timer.isValid{
            timer.invalidate()
        }
        
        progressRing.innerTrackShapeLayer.strokeColor = UIColor.defaultInnerColor.cgColor
        progressRing.progressLabel.textColor = Apps.BASIC_COLOR //chng font color to initial color
        
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
            progressRing.progressLabel.textColor = Apps.WRONG_ANS_COLOR //chng font color to red
        }
        if count >= Apps.QUIZ_PLAY_TIME {
            timer.invalidate()
            //score count
            wrongCount += 1
            falseCount.text = "\(wrongCount)"
            falseVerticleBar.setProgress(Float(wrongCount) / Float(Apps.TOTAL_PLAY_QS), animated: true)
            if Apps.TOTAL_PLAY_QS > self.currentQuestionPos{
                self.currentQuestionPos += 1
                self.LoadQuestion()
            }
        }
    }
    
    //load question here
    func LoadQuestion(){
        if(currentQuestionPos  < quesData.count && currentQuestionPos + 1 <= Apps.TOTAL_PLAY_QS ) {
            resetProgressCount()
//            if Apps.opt_E == true{
//                 MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)// enable button and restore to its default value
//            }else{
//                 MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)// enable button and restore to its default value
//            }
            if(quesData[currentQuestionPos].image == ""){
                // if question dose not contain images
                mainQuestionLbl.text = quesData[currentQuestionPos].question
                mainQuestionLbl.stringFormation(quesData[currentQuestionPos].question)
                //hide some components
                imageQuestionLbl.isHidden = true
                questionImageView.isHidden = true
                zoomBtn.isHidden = true
                
                mainQuestionLbl.isHidden = false
            }else{
                // if question has image
                imageQuestionLbl.text = quesData[currentQuestionPos].question
                imageQuestionLbl.stringFormation(quesData[currentQuestionPos].question)
                questionImageView.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)
                
                //show some components
                imageQuestionLbl.isHidden = false
                questionImageView.isHidden = false
                zoomBtn.isHidden = false
                
                mainQuestionLbl.isHidden = true
            }
            if(quesData[currentQuestionPos].opetionE) == ""{
               Apps.opt_E = false
               btnE.isHidden = true
               buttons = [btnA,btnB,btnC,btnD]
               MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
               self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
               
           }else {
               Apps.opt_E = true
               btnE.isHidden = false
               buttons = [btnA,btnB,btnC,btnD,btnE]
               MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
               self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
           }
                self.SetButtonOpetion(opestions: quesData[currentQuestionPos].opetionA,quesData[currentQuestionPos].opetionB,quesData[currentQuestionPos].opetionC,quesData[currentQuestionPos].opetionD,quesData[currentQuestionPos].opetionE,quesData[currentQuestionPos].correctAns)
            totalCount.roundCorners(corners: [ .bottomRight], radius: 5)
            totalCount.text = "\(currentQuestionPos + 1)"//"\(currentQuestionPos + 1)/\(Apps.TOTAL_PLAY_QS)"
        } else { 
            // If there are no more questions show the results
             ShowResultAlert()
        }
    }
    
    func ShowResultAlert(){
        
        if timer != nil && timer.isValid{
            timer.invalidate()
        }
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "ResultAlert") as! ResultAlert
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alert.parentController = self
        if rightCount < opponentRightCount{
            alert.winnerImg = "robot"
            alert.winnerName = robotName
        }else if opponentRightCount < rightCount{
            alert.winnerImg = user.image
            alert.winnerName = user.name
        }else{
            alert.winnerName = Apps.MATCH_DRAW
        }
        self.present(alert, animated: true, completion: nil)
    }
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //make timer invalidate
        timer.invalidate()
        
        //score count
        rightCount += 1
        trueCount.text = "\(rightCount)"
        trueVerticleBar.setProgress(Float(rightCount) / Float(Apps.TOTAL_PLAY_QS), animated: true)
        self.userCount1.text = "\(String(format: "%02d", rightCount))"
        
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
        self.PlayRobot()
    }
    
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        
        //make timer invalidate
        timer.invalidate()
        
        //score count
        wrongCount += 1
        falseCount.text = "\(wrongCount)"
        falseVerticleBar.setProgress(Float(wrongCount) / Float(Apps.TOTAL_PLAY_QS), animated: true)
        
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
        
        if Apps.ANS_MODE == "1"{
            //show correct answer
            for button in buttons{
            if button.titleLabel?.text == correctAnswer{
               button.tag = 1
            }
            for button in buttons {
              if button.tag == 1{
                  button.backgroundColor = Apps.RIGHT_ANS_COLOR
                  button.tintColor = UIColor.white
                  break
              }
            }
          }
        }
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "wrong")
        self.PlayRobot()
    }
    
    // set button opetion's
    var buttons:[UIButton] = []
    func SetButtonOpetion(opestions:String...){
        clickedButton.removeAll()
        var temp: [String]
        if opestions.contains("") {
            temp = ["a","b","c","d"]
        }else{
             temp = ["a","b","c","d","e"]
        }
//        if Apps.opt_E == true{
//            temp = ["a","b","c","d","e"]
//        }else{
//            temp = ["a","b","c","d"]
//        }
        let ans = temp
        var rightAns = ""
        if ans.contains("\(opestions.last!.lowercased())") {
            rightAns = opestions[ans.firstIndex(of: opestions.last!.lowercased())!]
        }else{            
            self.ShowAlert(title: Apps.INVALID_QUE, message: Apps.INVALID_QUE_MSG)
            rightAnswer(btn: btnA)
        }
       let singleQues = quesData[currentQuestionPos]
        if singleQues.quesType == "2"{
    
            MakeChoiceBtnDefault(btns: btnA,btnB)
            
            btnC.isHidden = true
            btnD.isHidden = true

            self.buttons = [btnA,btnB]
            //btnE.isHidden = true
             temp = ["a","b"]
//            self.buttons.forEach{
//                 $0.setImage(SetClickedOptionView(otpStr: "o").createImage(), for: .normal)
//            }
        }else{
            btnC.isHidden = false
            btnD.isHidden = false
            
//            btnA.setImage(UIImage(named: "btnA"), for: .normal)
//            btnB.setImage(UIImage(named: "btnB"), for: .normal)
//            btnC.setImage(UIImage(named: "btnc"), for: .normal)
//            btnD.setImage(UIImage(named: "btnD"), for: .normal)
//            btnE.setImage(UIImage(named: "btnE"), for: .normal)
            
            buttons.shuffle()
        }
        var index = 0
        for button in buttons{
            button.setTitle(opestions[index], for: .normal)
            if opestions[index] == rightAns{
                button.tag = 1
                let ans = button.currentTitle
                correctAnswer = ans!
                print(correctAnswer)
            }else{
                button.tag = 0
            }
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
        
        self.SetButtonHeight(buttons: btnA,btnB,btnC,btnD,btnE)
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
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
    
    @objc func DismissSelf(){
        self.navigationController?.popViewController(animated: true)
    }
    // set default to four/five choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.isEnabled = true
            btn.isHidden = false
            btn.backgroundColor = Apps.BASIC_COLOR//UIColor.white
            btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
            btn.subviews.forEach({
                if($0.tag == 11){
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    // add lable and show opponent answer what he has selected
    func ShowOpponentAns(btn: UIButton){
        let lblWidth:CGFloat = 90
        let lblHeight:CGFloat = 25
        
        let lbl = UILabel(frame: CGRect(x: btn.frame.size.width - (lblWidth + 5),y: (btn.frame.size.height - lblHeight)/2, width: lblWidth, height: lblHeight))
        lbl.textAlignment = .center
        lbl.text = "\(robotName)"
        lbl.tag = 11 // identified tag for remove it from its super view
        lbl.clipsToBounds = true
        lbl.font = .systemFont(ofSize: 12)
        //if robot selects same ans as user then bg is white and text is red or green and if robot ans is other than user then it shows text with color red or green
        if btn.tag == 1{ // true answer
            lbl.textColor = Apps.RIGHT_ANS_COLOR
        }else{ //wrong answer
             lbl.textColor = Apps.WRONG_ANS_COLOR
        }
       // if clickedButton.contains(btn){
            lbl.backgroundColor = UIColor.white
       // }
        
        btn.addSubview(lbl)
        
        self.timer.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increament for next question
            self.LoadQuestion()
        })
    }
    
    //play robot function
    func PlayRobot(){
        let opponentAns = buttons.randomElement()
        
        for button in buttons {
            if button.title(for: .normal) == opponentAns?.title(for: .normal){
                self.ShowOpponentAns(btn: button)
                if button.tag == 1{
                    self.opponentRightCount += 1
                }
                break
            }
        }
        self.userCount2.text = "\(String(format: "%02d", self.opponentRightCount))"
    }
}
