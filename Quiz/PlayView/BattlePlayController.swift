import Foundation
import UIKit
import AVFoundation
import  FirebaseDatabase

class BattlePlayController: UIViewController, UIScrollViewDelegate {
    
    let trueVerticleBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_true)
    let falseVerticleBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_false)
    
    @IBOutlet weak var userImg1: UIImageView!
    @IBOutlet weak var userImg2: UIImageView!
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
    var myAnswer = false
    var oppAnswer = false
    var oppSelectedAns = ""
    var zoomScale:CGFloat = 1
    var opponentRightCount = 0
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
//    var quesData: [Question] = []
    var quesData: [QuestionWithE] = []
    var currentQuestionPos = 0
    
    var battleUser:BattleUser!
    var user:User!
    var ref: DatabaseReference!
    var observeQues = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        if Apps.opt_E == true {
            btnE.isHidden = false
            buttons = [btnA,btnB,btnC,btnD,btnE]
        }else{
            btnE.isHidden = true 
            buttons = [btnA,btnB,btnC,btnD]
        }
         
        // set refrence for firebase database
        self.ref = Database.database().reference().child("AvailUserForBattle")
        mainQuestionLbl.centerVertically()
        imageQuestionLbl.centerVertically()
        
        // add ring progress to timer view
        progressRing = CircularProgressBar(radius: 20, position: CGPoint(x: timerView.center.x, y: timerView.center.y - 20), innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6)
        timerView.layer.addSublayer(progressRing)
        
        setVerticleProgress(view: trueVerticleProgress, progress: trueVerticleBar)// true verticle progress bar
        setVerticleProgress(view: falseVerticleProgress, progress: falseVerticleBar) // false verticle progress bar
        
        self.questionView.DesignViewWithShadow()
        if Apps.opt_E == true {
            //set five option's view shadow
            self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
        }else{
            //set four option's view shadow
            self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
        }
        
        
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        userName1.text = user.name
        userName2.text = battleUser.name
        DispatchQueue.main.async {
            self.userImg1.loadImageUsingCache(withUrl: self.user.image)
            self.userImg2.loadImageUsingCache(withUrl: self.battleUser.image)
        }
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "user_id_1=\(user.UID)&user_id_2=\(battleUser.UID)&match_id=\(battleUser.matchingID)"
            self.getAPIData(apiName: "get_random_questions", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        
        zoomScroll.minimumZoomScale = 1
        zoomScroll.maximumZoomScale = 6
        NotificationCenter.default.addObserver(self,selector: #selector(self.CompleteBattle),name: NSNotification.Name(rawValue: "CompleteBattle"),object: nil)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    @IBAction func ZoomBtn(_ sender: Any) {
        zoomScale += 1
        zoomScroll.zoomScale = zoomScale
    }
    
    @IBAction func SpeechBtn(_ sender: Any) {
        let speechSynthesizer = AVSpeechSynthesizer()
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "\(quesData[currentQuestionPos].question)")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func LeaveBattle(_ sender: Any) {
        let alert = UIAlertController(title: Apps.EXIT_APP_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            if self.timer.isValid{
                self.timer.invalidate()
            }
            self.ref.removeAllObservers()
            self.ref.removeValue()
            self.ref = nil
            if(Reachability.isConnectedToNetwork()){
                let apiURL = "user_id_1=\(self.user.UID)&user_id_2=\(self.battleUser.UID)&match_id=\(self.battleUser.matchingID)&destroy_match=1"
                self.getAPIData(apiName: "get_random_questions", apiURL: apiURL,completion: {_ in })
            }
            
            NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("CloseBattleViewController"), object: nil)
            self.dismiss(animated: true, completion: nil)
        }))
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
       
    }
    
    @objc func CompleteBattle(){
        if timer != nil && timer.isValid{
           timer.invalidate()
        }
        self.ref.removeAllObservers()
        self.ref.removeValue()
        self.ref = nil
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "user_id_1=\(user.UID)&user_id_2=\(battleUser.UID)&match_id=\(battleUser.matchingID)&destroy_match=1"
            self.getAPIData(apiName: "get_random_questions", apiURL: apiURL,completion: {_ in })
        }
        NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
         //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
            })
            
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)"))
                }
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
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        buttons.forEach{$0.isUserInteractionEnabled = true}
        if self.timer != nil && self.timer.isValid{
            timer.invalidate()
        }
        progressRing.innerTrackShapeLayer.strokeColor = UIColor.defaultInnerColor.cgColor
        zoomScale = 1
        zoomScroll.zoomScale = 1
        
        self.myAnswer = false
        self.oppAnswer = false
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
        if count >= Apps.QUIZ_PLAY_TIME {
            timer.invalidate()
            self.AddQuestionToFIR(question: quesData[self.currentQuestionPos], userAns: "")
            //score count
            wrongCount += 1
            falseCount.text = "\(wrongCount)"
            falseVerticleBar.setProgress(Float(wrongCount) / Float(10), animated: true)
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
           
            MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)// enable button and restore to its default value
            if(quesData[currentQuestionPos].image == ""){
                // if question dose not contain images
                mainQuestionLbl.text = quesData[currentQuestionPos].question
                
                //hide some components
                imageQuestionLbl.isHidden = true
                questionImageView.isHidden = true
                zoomBtn.isHidden = true
                
                mainQuestionLbl.isHidden = false
            }else{
                // if question has image
                imageQuestionLbl.text = quesData[currentQuestionPos].question
                questionImageView.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)
               
                questionImageView.isHidden = false
                zoomBtn.isHidden = false
                imageQuestionLbl.isHidden = false
                
                mainQuestionLbl.isHidden = true
            }
            if Apps.opt_E == true {
                 self.SetButtonOpetion(opestions: quesData[currentQuestionPos].opetionA,quesData[currentQuestionPos].opetionB,quesData[currentQuestionPos].opetionC,quesData[currentQuestionPos].opetionD,quesData[currentQuestionPos].opetionE,quesData[currentQuestionPos].correctAns)
            }else{
                 self.SetButtonOpetion(opestions: quesData[currentQuestionPos].opetionA,quesData[currentQuestionPos].opetionB,quesData[currentQuestionPos].opetionC,quesData[currentQuestionPos].opetionD,quesData[currentQuestionPos].correctAns)
            }
          
            totalCount.text = "\(currentQuestionPos + 1)/10"
           
        } else {
             // If there are no more questions show the results
            if oppAnswer{
                ShowResultAlert()
            }
        }
        
    }
    
    func ShowResultAlert(){
        if timer != nil && timer.isValid{
            timer.invalidate()
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
        self.present(alert, animated: true, completion: nil)
    }
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //make timer invalidate
        timer.invalidate()
        
        //score count
        rightCount += 1
        trueCount.text = "\(rightCount)"
        trueVerticleBar.setProgress(Float(rightCount) / Float(10), animated: true)
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
        timer.invalidate()
        
        //score count
        wrongCount += 1
        falseCount.text = "\(wrongCount)"
        falseVerticleBar.setProgress(Float(wrongCount) / Float(10), animated: true)
        
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
        
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
//    func AddQuestionToFIR(question:Question, userAns:String){
    func AddQuestionToFIR(question:QuestionWithE, userAns:String){
    if question != nil{
        var data = question.toDictionaryE
            
            data["userSelect"] = userAns
        self.ref.child(user.UID).child("Questions").child("\(self.currentQuestionPos)").setValue(data)
        }
    }
    
    //observe data in firebase and show updated data to user
    func ObserveData(){
        self.ref.child(battleUser.UID).observe(.value, with: {(snapshot) in
            if snapshot.hasChild("rightAns"){
                self.userCount2.text = "\(String(format: "%02d",Int(snapshot.childSnapshot(forPath: "rightAns").value as! String)!))"
                self.opponentRightCount = Int(snapshot.childSnapshot(forPath: "rightAns").value as! String)!
            }
        })
    }
    
    func ObserveQuestion(){
        self.ref.child(battleUser.UID).child("Questions").child("\(self.currentQuestionPos)").observe(.value, with: {(snapshot) in
            let data = snapshot.value as? [String:Any]
            if data != nil{
                self.oppSelectedAns = data!["userSelect"]! as! String
                if self.myAnswer{
                    for button in self.buttons{
                        if button.title(for: .normal) == self.oppSelectedAns{
                             self.ShowOpponentAns(btn: button, str: "\(self.battleUser.name)")
                        }
                    }
                }else{
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
        if ans.contains("\(opestions.last!.lowercased())") {
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
    // set default to four choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.isEnabled = true
            btn.isHidden = false
            btn.backgroundColor = UIColor.white
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
        lbl.layer.cornerRadius = lblHeight / 2
        lbl.backgroundColor = UIColor.rgb(211, 205, 139, 1)
        lbl.font = .systemFont(ofSize: 12)
        btn.addSubview(lbl)
        
        self.timer.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increament for next question
            self.LoadQuestion()
        })
    }
}
