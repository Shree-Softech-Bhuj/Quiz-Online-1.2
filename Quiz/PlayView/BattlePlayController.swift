import Foundation
import UIKit
import AVFoundation
import FirebaseDatabase
import CallKit

class BattlePlayController: UIViewController, UIScrollViewDelegate {
    
    let trueVerticleBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_true)
    let falseVerticleBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_false)
    
    @IBOutlet weak var userImg1: UIImageView!
    @IBOutlet weak var userImg2: UIImageView!
    @IBOutlet weak var userName1: UILabel!
    @IBOutlet weak var userName2: UILabel!
    @IBOutlet weak var userCount1: UILabel!
    @IBOutlet weak var userCount2: UILabel!
    @IBOutlet var scroll: UIScrollView!
    
    @IBOutlet weak var trueCount: UILabel!
    @IBOutlet weak var trueVerticleProgress: UIView!
    @IBOutlet weak var falseCount: UILabel!
    @IBOutlet weak var falseVerticleProgress: UIView!
    
    @IBOutlet weak var mainQuestionLbl: UITextView!
    @IBOutlet weak var questionImageView: UIImageView!
    @IBOutlet var secondChildView: UIView!
    
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
    var timer: Timer?
    
    var count: CGFloat = 0.0
    var rightCount = 0
    var wrongCount = 0
    var myAnswer = false
    var oppAnswer = false
    var oppSelectedAns = ""
    var zoomScale:CGFloat = 1
    var opponentRightCount = 0
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var quesData: [QuestionWithE] = []
    var currentQuestionPos = 0
    
    var battleUser:BattleUser!
    var user:User!
    var ref: DatabaseReference!
    var observeQues = 0
    var sysConfig:SystemConfiguration!
    
    var correctAnswer = "a"
    var hasLeave = false
    var updatedOnce = false
    var callObserver: CXCallObserver!
    
    var isCategoryBattle = false
    var catID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil) // nil queue means main thread
        
        imageQuestionLbl.backgroundColor = .white
        hasLeave = false
        userImg1.layer.borderWidth = 2
        userImg1.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        userImg1.layer.cornerRadius = userImg1.bounds.width / 2
        userImg1.clipsToBounds = true
        
        userImg2.layer.borderWidth = 2
        userImg2.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        userImg2.layer.cornerRadius = userImg2.bounds.width / 2
        userImg2.clipsToBounds = true
        
        //show 4 options by default & set 5th later by checking for opt E mode
        btnE.isHidden = true
        buttons = [btnA,btnB,btnC,btnD]
        
        // set refrence for firebase database
        self.ref = Database.database().reference().child("AvailUserForBattle")
        mainQuestionLbl.centerVertically()
        imageQuestionLbl.centerVertically()
        
        resizeTextview()
        
        // add ring progress to timer view
        if deviceStoryBoard == "Ipad"{
            progressRing = CircularProgressBar(radius:18, position: CGPoint(x: timerView.center.x, y: timerView.center.y - 15), innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6) //y: timerView.center.y - 20
        }else{
            progressRing = CircularProgressBar(radius: 18, position: CGPoint(x: timerView.center.x, y: timerView.center.y + 3), innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6)
            
        }
        timerView.layer.addSublayer(progressRing)
        
        setVerticleProgress(view: trueVerticleProgress, progress: trueVerticleBar)// true verticle progress bar
        setVerticleProgress(view: falseVerticleProgress, progress: falseVerticleBar) // false verticle progress bar
        
        battleScoreView.SetShadow()
        self.questionView.DesignViewWithShadow()
        
        //set four option's view shadow by default & set 5th later by checking for opt E mode
        self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
        
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        userName1.text = user.name
        //  userName1.setLabel()
        userName2.text = battleUser.name
        // userName2.setLabel()
        DispatchQueue.main.async {
            self.userImg1.loadImageUsingCache(withUrl: self.user.image)
            self.userImg2.loadImageUsingCache(withUrl: self.battleUser.image)
        }
        
        sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            var apiURL = "match_id=\(battleUser.matchingID)" //user_id1=\(user.UID)&user_id2=\(battleUser.UID)&
            //var apiURL = "user_id_1=\(user.UID)&user_id_2=\(battleUser.UID)&match_id=\(battleUser.matchingID)&destroy_match=0"
            if isCategoryBattle == true{
                apiURL += "&category="
            }
            if sysConfig.LANGUAGE_MODE == 1{
                let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                apiURL += "&language_id=\(langID)"
            }
            print("viewDidLoad-  \(apiURL)")
            self.getAPIData(apiName: "get_random_questions", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        
        zoomScroll.minimumZoomScale = 1
        zoomScroll.maximumZoomScale = 6
        NotificationCenter.default.addObserver(self, selector: #selector(BattlePlayController.ReloadFont), name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.CompleteBattle),name: NSNotification.Name(rawValue: "CompleteBattle"),object: nil)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImageView
    }
    
    
    @IBAction func ZoomBtn(_ sender: Any) {
        if zoomScroll.zoomScale == zoomScroll.maximumZoomScale {
            zoomScale = 0
        }
        zoomScale += 1
        zoomScroll.zoomScale = zoomScale
    }
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
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
           self.LeaveBattleProc()
        }))
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func CompleteBattle(){
          if timer != nil && timer!.isValid{
              timer!.invalidate()
          }
          if ref != nil{
              self.ref.removeAllObservers()
              self.ref.removeValue()
              self.ref = nil
          }
          
          if(Reachability.isConnectedToNetwork()){
              let apiURL = "user_id1=\(user.UID)&user_id2=\(battleUser.UID)&match_id=\(battleUser.matchingID)&destroy_match=1"
              self.getAPIData(apiName: "get_random_questions", apiURL: apiURL,completion: {_ in })
          }
          
          if(Reachability.isConnectedToNetwork()){
              var winnerID = ""
              if rightCount > opponentRightCount{
                  winnerID = user.userID
              }else{
                  winnerID = battleUser.userID
              }
               // setStatistics()
            
//              if !self.hasLeave{
//                  let apiURL = "user_id1=\(user.userID)&user_id2=\(battleUser.userID)&winner_id=\(winnerID)&is_drawn=\(rightCount == opponentRightCount ? 1 : 0)"
//                  self.getAPIData(apiName: "set_battle_statistics", apiURL: apiURL,completion: {_ in })
//              }
          }
          NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
          self.navigationController?.popViewController(animated: true)
      }
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
//        let msg = jsonObj.value(forKey: "message") as! String 
        
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
            
        }else{
            //get data for category
            self.quesData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                    
                    //                    if let e = val["optione"] as? String {
                    //                        if e == ""{
                    //                            Apps.opt_E = false
                    //                            DispatchQueue.main.async {
                    //                                self.btnE.isHidden = true
                    //                            }
                    //                            buttons = [btnA,btnB,btnC,btnD]
                    //                            self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
                    //                        }else{
                    //                            Apps.opt_E = true
                    //                            DispatchQueue.main.async {
                    //                                self.btnE.isHidden = false
                    //                            }
                    //                            buttons = [btnA,btnB,btnC,btnD,btnE]
                    //                            self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
                    //                        }
                    //                    }
                }
                Apps.TOTAL_PLAY_QS = data.count
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.LoadQuestion()
                self.ObserveData()
            }
        });
    }
    
    
    func setStatistics(){
        if(Reachability.isConnectedToNetwork()){
            var winnerID = ""
            if rightCount > opponentRightCount{
                winnerID = user.userID
                
                if hasLeave == false && updatedOnce == false {
                    let apiURL = "user_id1=\(user.userID)&user_id2=\(battleUser.userID)&winner_id=\(winnerID)&is_drawn=\(rightCount == opponentRightCount ? 1 : 0)"
                    print("set stats.. \(apiURL)")
                    self.getAPIData(apiName: "set_battle_statistics", apiURL: apiURL,completion: {_ in })
                    updatedOnce = true
                }
                
            }else if rightCount < opponentRightCount{
                winnerID = battleUser.userID
                
                if hasLeave == false && updatedOnce == false {
                    let apiURL = "user_id1=\(user.userID)&user_id2=\(battleUser.userID)&winner_id=\(winnerID)&is_drawn=\(rightCount == opponentRightCount ? 1 : 0)"
                    print("set stats.. \(apiURL)")
                    self.getAPIData(apiName: "set_battle_statistics", apiURL: apiURL,completion: {_ in })
                    updatedOnce = true
                }
                
            }else{
                winnerID = ""
                if hasLeave == false && updatedOnce == false {
                    let apiURL = "user_id1=\(user.userID)&user_id2=\(battleUser.userID)&winner_id=&is_drawn=1"
                    print("set stats.. \(apiURL)")
                    self.getAPIData(apiName: "set_battle_statistics", apiURL: apiURL,completion: {_ in })
                    updatedOnce = true
                }
            }
        }
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        buttons.forEach{$0.isUserInteractionEnabled = true}
        if self.timer != nil && self.timer!.isValid{
            timer!.invalidate()
        }
        progressRing.innerTrackShapeLayer.strokeColor = UIColor.defaultInnerColor.cgColor
        progressRing.progressLabel.textColor = Apps.BASIC_COLOR
        zoomScale = 1
        zoomScroll.zoomScale = 1
        
        self.myAnswer = false
        self.oppAnswer = false
        count = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer!.fire()
    }
    @objc func incrementCount() {
        
        count += 0.1
        progressRing.progress = CGFloat(Apps.QUIZ_PLAY_TIME - count)
        if count >= 20{
            progressRing.innerTrackShapeLayer.strokeColor = Apps.WRONG_ANS_COLOR.cgColor
            progressRing.progressLabel.textColor = Apps.WRONG_ANS_COLOR
        }
        if count >= Apps.QUIZ_PLAY_TIME {
            timer!.invalidate()
            self.AddQuestionToFIR(question: quesData[self.currentQuestionPos], userAns: "")
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
            ObserveQuestion()
            //            if Apps.opt_E == true{
            //                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)// enable button and restore to its default value
            //            }else{
            //                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)// enable button and restore to its default value
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
                
                questionImageView.isHidden = false
                zoomBtn.isHidden = false
                imageQuestionLbl.isHidden = false
                
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
            //  totalCount.text = "\(currentQuestionPos + 1)/10"
            totalCount.text = "\(currentQuestionPos + 1)"
            // totalCount.text = "\(currentQuestionPos + 1)/\(Apps.TOTAL_PLAY_QS)"
            
        } else {
            // If there are no more questions show the results
            if oppAnswer{
                setStatistics()
                ShowResultAlert()
            }
        }
    }
    
    func ShowResultAlert(){
        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        if timer != nil && timer!.isValid{
            timer!.invalidate()
        }
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "ResultAlert") as! ResultAlert
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alert.parentController = self
        if rightCount < opponentRightCount{
            alert.winnerImg = battleUser.image
            alert.winnerName = battleUser.name
        }else if opponentRightCount < rightCount{
            alert.winnerImg = user.image
            alert.winnerName = user.name
        }else{
            alert.winnerName = Apps.MATCH_DRAW
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //make timer invalidate
        timer!.invalidate()
        
        //score count
        rightCount += 1
        trueCount.text = "\(rightCount)"
        trueVerticleBar.setProgress(Float(rightCount) / Float(Apps.TOTAL_PLAY_QS), animated: true)
        self.ref.child(user.UID).child("rightAns").setValue("\(rightCount)")
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
        if self.oppAnswer{
            for button in self.buttons{
                if button.title(for: .normal) == self.oppSelectedAns{
                    self.ShowOpponentAns(btn: button, str: "\(self.battleUser.name)")
                }
            }
        }else{
            self.myAnswer = true
        }
    }
    
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        
        //make timer invalidate
        timer!.invalidate()
        
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
        if self.oppAnswer{
            for button in self.buttons{
                if button.title(for: .normal) == self.oppSelectedAns{
                    self.ShowOpponentAns(btn: button, str: "\(self.battleUser.name)")
                }
            }
        }else{
            self.myAnswer = true
        }
    }
    
    // add question data to firebase
    func AddQuestionToFIR(question:QuestionWithE, userAns:String){
        if question != nil{
            var data = question.toDictionaryE            
            data["userSelect"] = userAns
            if self.ref != nil{
                self.ref.child(user.UID).child("Questions").child("\(self.currentQuestionPos)").setValue(data)
            }
        }
    }
    
    //observe data in firebase and show updated data to user
    func ObserveData(){
        if self.ref != nil{
            self.ref.child(battleUser.UID).observe(.value, with: {(snapshot) in
                if snapshot.hasChild("rightAns"){
                    self.userCount2.text = "\(String(format: "%02d",Int(snapshot.childSnapshot(forPath: "rightAns").value as! String)!))"
                    self.opponentRightCount = Int(snapshot.childSnapshot(forPath: "rightAns").value as! String)!
                }
                if snapshot.hasChild("leftBattle"){
                    if  let boolCheck = snapshot.childSnapshot(forPath: "leftBattle").value as? Bool{
                        if boolCheck{
                            self.hasLeave = true
                            self.ShowResultAlert()
                        }
                    }
                }
            })
        }
    }
    
    func ObserveQuestion(){
        if(self.ref != nil){
            self.ref.child(battleUser.UID).child("Questions").child("\(self.currentQuestionPos)").observe(.value, with: {(snapshot) in
                let data = snapshot.value as? [String:Any]
                if data != nil{
                    print("COMES 1")
                    self.oppSelectedAns = data!["userSelect"]! as! String
                    self.oppSelectedAns = self.oppSelectedAns.trimmingCharacters(in: .whitespacesAndNewlines)
                    if self.myAnswer{
                        print("COMES 2")
                        if self.oppSelectedAns.isEmpty || self.oppSelectedAns == ""{
                            self.timer!.invalidate()
                            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                                // load next question after 1 second
                                if self.timer!.isValid{
                                    self.timer?.invalidate()
                                }
                                self.currentQuestionPos += 1 //increment for next question
                                self.LoadQuestion()
                            })
                        }
                        for button in self.buttons{
                            let str = button.title(for: .normal)!.trimmingCharacters(in: .whitespacesAndNewlines)
                            print("COMES 3",str,"ANS",self.oppSelectedAns)
                            if str == self.oppSelectedAns{
                                print("COMES 4")
                                self.ShowOpponentAns(btn: button, str: "\(self.battleUser.name)")
                            }
                        }
                    }else{
                        print("COMES 5")
                        self.oppAnswer = true
                    }
                    if self.currentQuestionPos + 1 >= Apps.TOTAL_PLAY_QS{
                        if self.myAnswer{
                            self.ShowResultAlert()
                        }
                    }
                }
                
            })
        }
    }
    
    // set button opetion's
    var buttons:[UIButton] = []
    func SetButtonOpetion(opestions:String...){
        clickedButton.removeAll()
        var temp : [String]
        if opestions.contains("") {
            temp = ["a","b","c","d"]
        }else{
            temp = ["a","b","c","d","e"]
        }
        //        if Apps.opt_E == true {
        //            temp = ["a","b","c","d","e"]
        //        }else{
        //            temp = ["a","b","c","d"]
        //        }
        let ans = temp
        var rightAns = ""
        if ans.contains("\(opestions.last!.lowercased())") {
            rightAns = opestions[ans.firstIndex(of: opestions.last!.lowercased())!]
        }else{
            rightAnswer(btn: btnA)
        }
        let singleQues = quesData[currentQuestionPos]
        print("QUES",singleQues)
        if singleQues.quesType == "2"{
            
            MakeChoiceBtnDefault(btns: btnA,btnB)
            
            btnC.isHidden = true
            btnD.isHidden = true
            
            self.buttons = [btnA,btnB]
            //btnE.isHidden = true
            temp = ["a","b"]
//            self.buttons.forEach{
//                $0.setImage(SetClickedOptionView(otpStr: "o").createImage(), for: .normal)
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
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            buttons.forEach{$0.isUserInteractionEnabled = false}
            if button.tag == 1{
                rightAnswer(btn: button)
            }else{
                wrongAnswer(btn: button)
            }
            self.AddQuestionToFIR(question: self.quesData[currentQuestionPos],userAns: button.title(for: .normal)!)
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
    // set default to four/five choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.isEnabled = true
            btn.isHidden = false
            btn.backgroundColor = UIColor.white //Apps.BASIC_COLOR//
            btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
            btn.subviews.forEach({
                if($0.tag == 11){
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    // add lable and show opponent answer what he has selected
    func ShowOpponentAns(btn: UIButton, str: String){
        let lblWidth:CGFloat = 90
        let lblHeight:CGFloat = 25
        
        let lbl = UILabel(frame: CGRect(x: btn.frame.size.width - (lblWidth + 5) ,y: (btn.frame.size.height - lblHeight)/2, width: lblWidth, height: lblHeight))
        lbl.textAlignment = .center
        lbl.text = "\(str)"
        lbl.tag = 11 // identified tag for remove it from its super view
        lbl.clipsToBounds = true
        //        lbl.layer.cornerRadius = lblHeight / 2
        //        lbl.backgroundColor = UIColor.rgb(211, 205, 139, 1)
        lbl.font = .systemFont(ofSize: 12)
        if btn.tag == 1{ // true answer
            lbl.textColor = Apps.RIGHT_ANS_COLOR
        }else{ //wrong answer
            lbl.textColor = Apps.WRONG_ANS_COLOR
        }
        // if clickedButton.contains(btn){
        lbl.backgroundColor = UIColor.white
        // }
        btn.addSubview(lbl)
        
        self.timer!.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increament for next question
            self.LoadQuestion()
        })
    }
}

extension BattlePlayController: CXCallObserverDelegate {
    func LeaveBattleProc(){
        self.hasLeave = true
        self.ref.child(self.user.UID).child("leftBattle").setValue(true) //to be used for opponent user
        
        if (self.timer?.isValid) != nil {
            self.timer!.invalidate()
        }
        self.ref.removeAllObservers()
        //self.ref.removeValue()
        // self.ref = nil
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "user_id1=\(self.user.UID)&user_id2=\(self.battleUser.UID)&match_id=\(self.battleUser.matchingID)&destroy_match=1"
            self.getAPIData(apiName: "get_random_questions", apiURL: apiURL,completion: {_ in })
        }
        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        //NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
        //NotificationCenter.default.post(name: Notification.Name("CloseBattleViewController"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        if call.hasEnded == true {
            print("Disconnected")
        }
        
        if call.isOutgoing == true && call.hasConnected == false {
            print("Dialing")
        }
        
        if call.isOutgoing == false && call.hasConnected == false && call.hasEnded == false {
            print("Incoming")
        }
        
        if call.hasConnected == true && call.hasEnded == false {
            print("Connected")
            self.LeaveBattleProc()
        }
    }
}
