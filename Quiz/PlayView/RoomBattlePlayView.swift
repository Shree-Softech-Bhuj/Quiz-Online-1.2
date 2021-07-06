import Foundation
import UIKit
import AVFoundation
import  FirebaseDatabase
import CallKit

class RoomBattlePlayView: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var timerLabel:UILabel!
    @IBOutlet var questionView: UIView!
    @IBOutlet weak var mainQuestionLbl: UITextView!
    @IBOutlet weak var questionImageView: UIImageView!

    @IBOutlet weak var imageQuestionLbl: UITextView!
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var secondChildView: UIView!
    
    @IBOutlet weak var questionView1: UIView!
    
    @IBOutlet weak var battleScoreView: UIView!
    
    @IBOutlet weak var btnA: ResizableButton!
    @IBOutlet weak var btnB: ResizableButton!
    @IBOutlet weak var btnC: ResizableButton!
    @IBOutlet weak var btnD: ResizableButton!
    @IBOutlet weak var btnE: ResizableButton!
    
    @IBOutlet weak var leaveButton:UIButton!
    
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var collectionView:UICollectionView!
    
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
    
    var joinedUsers:[JoinedUser] = []
    var user:User!
    var ref: DatabaseReference!
    var observeQues = 0
    var sysConfig:SystemConfiguration!
    var hasLeave = false
    var callObserver: CXCallObserver!
    var roomInfo:RoomDetails?
    var seconds = 0
    
    var roomType = "private"
    var roomCode = "00000"
    var isCompleted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.leaveButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4)
        
        if Apps.opt_E == true {
            btnE.isHidden = false
            buttons = [btnA,btnB,btnC,btnD,btnE]
        }else{
            btnE.isHidden = true
            buttons = [btnA,btnB,btnC,btnD]
        }
    
         if Apps.opt_E == true {
            DesignOpetionButton(buttons: btnA,btnB,btnC,btnD,btnE)
         }else{
            DesignOpetionButton(buttons: btnA,btnB,btnC,btnD)
        }
        
        questionView1.layer.cornerRadius = 15
        callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil) // nil queue means main thread
        
        NotificationCenter.default.post(name: Notification.Name("PlayMusic"), object: nil)
        //show 4 options by default & set 5th later by checking for opt E mode
        btnE.isHidden = true
        hasLeave = false
        buttons = [btnA,btnB,btnC,btnD]
        
        // set refrence for firebase database
        self.ref = Database.database().reference().child("MultiplayerRoom") //AvailUserForBattle
        mainQuestionLbl.centerVertically()
        imageQuestionLbl.centerVertically()
        
        self.seconds = Int(Apps.GROUP_BTL_WAIT_TIME) //Int(self.roomInfo!.playTime)! * 60
        
       // battleScoreView.SetShadow()
       // self.questionView.DesignViewWithShadow()
        
        //set four option's view shadow by default & set 5th later by checking for opt E mode
      //  self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
        
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        
        sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)

            var apiURL = "room_id=\(self.roomCode)" //self.roomInfo!.ID
//            if sysConfig.LANGUAGE_MODE == 1{
//                let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
//                apiURL += "&language_id=\(langID)"
//            }
            self.getAPIData(apiName: "get_question_by_room_id", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        NotificationCenter.default.addObserver(self,selector: #selector(self.CompleteBattle),name: NSNotification.Name(rawValue: "CompleteBattle"),object: nil)
        
    }
    
   /* func animationView(){
        self.questionView1.slideInFromLeft()
        self.questionView1.isHidden = false
        
        //qstn animation
        self.imageQuestionLbl.slideInFromRight(duration: 1.0, completionDelegate: nil)
        self.imageQuestionLbl.isHidden = false
        
        self.mainQuestionLbl.slideInFromRight(duration: 1.0, completionDelegate: nil)
        self.mainQuestionLbl.isHidden = false
        
        //optn animation
        self.btnA.slideInFromRight(duration: 1.2, completionDelegate: nil)
        self.btnB.slideInFromRight(duration: 1.5, completionDelegate: nil)
        self.btnC.slideInFromRight(duration: 1.8, completionDelegate: nil)
        self.btnD.slideInFromRight(duration: 2.0, completionDelegate: nil)
        self.btnE.slideInFromRight(duration: 2.3, completionDelegate: nil)
        self.btnA.isHidden = false
        self.btnB.isHidden = false
        self.btnC.isHidden = false
        self.btnD.isHidden = false
        self.btnE.isHidden = false
    }*/
    
    func DesignViews(battleHeight:CGFloat){
        
        let battleFrame = CGRect(x: self.battleScoreView.frame.origin.x, y: self.battleScoreView.frame.origin.y, width: self.battleScoreView.frame.width, height: battleHeight)
        self.battleScoreView.frame = battleFrame
        
        let secondFrame = CGRect(x: self.secondChildView.frame.origin.x, y: self.battleScoreView.frame.height + self.battleScoreView.frame.origin.y + 20, width: self.secondChildView.frame.width, height: self.secondChildView.frame.height)
        self.secondChildView.frame = secondFrame
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImageView
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        myAlert.parentName = "play"
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func LeaveBattle(_ sender: Any) {
        let alert = UIAlertController(title: Apps.EXIT_APP_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            //  if let validTimer = self.timer?.isValid {
            self.LeaveBattleProc()
           
        }))
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    func LeaveBattleProc(){
        self.hasLeave = true
        let users = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let refR = ref.child(roomCode).child("joinUser").child(users.UID) //Database.database().reference().child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser").child(users.UID)
        refR.child("isLeave").setValue("true")
       
        let roomVal = ref.child(roomCode)
        roomVal.observeSingleEvent(of: .value, with: { (snapshot) in
             if let data = snapshot.value as? [String:Any]{
               // print(data)
                let authID = data["authId"] as! String
               // print(authID)
                if authID == self.user.UID {
                    //let roomL = authId//self.ref.child(self.roomCode)//Database.database().reference().child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID)
                    roomVal.child("isRoomActive").setValue("false")//roomL.child("isRoomActive").setValue("false")
                }
             }
        })
        
        //if authId ==  user.UID{ //  if self.roomInfo!.roomFID ==  user.UID{
            // let roomL = ref.child(roomCode)//Database.database().reference().child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID)
           // roomL.child("isRoomActive").setValue("false")
        //}
        
        if  let index = self.joinedUsers.firstIndex(where: {$0.uID == "\(user.UID)"}){
            self.joinedUsers[index].isLeave = true
           
            self.collectionView.reloadData()
        }
        
        if (self.timer?.isValid) != nil {
            self.timer!.invalidate()
        }
        self.ref.removeAllObservers()
     
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "room_id=\(self.roomCode)" //self.roomInfo!.ID
            self.getAPIData(apiName: "destroy_room_by_room_id", apiURL: apiURL,completion: {_ in })
        }
        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func CompleteBattle(){
        if self.isCompleted{
            return
        }
        if timer != nil && timer!.isValid{
            timer!.invalidate()
        }
        if ref != nil{
            self.ref.removeAllObservers()
//            self.ref.removeValue()
            self.ref = nil
        }
        
        if(Reachability.isConnectedToNetwork()){
            let apiURL = "room_id=\(self.roomCode)"//self.roomInfo!.ID
            self.getAPIData(apiName: "destroy_room_by_room_id", apiURL: apiURL,completion: {_ in })
        }
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "BattleRoomResult") as! BattleRoomResult
        viewCont.joinedUsers = self.joinedUsers
        viewCont.roomType = self.roomType
        viewCont.roomInfo = self.roomInfo
        viewCont.roomCode = self.roomCode
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = "\(jsonObj.value(forKey: "error")!)".bool!
        
        if (status) {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
            
        }else{
            //get data for category
            // print(jsonObj.value(forKey: "data") as Any)
            self.quesData.removeAll()
          
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)")) //, quesStatus: "\(val["que_status"]!)".bool ?? false
                    
                  /*  if let e = val["optione"] as? String {
                        if e == ""{
                            Apps.opt_E = false
                            buttons = [btnA,btnB,btnC,btnD]
                         //   self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
                        }else{
                            Apps.opt_E = true
                            buttons = [btnA,btnB,btnC,btnD,btnE]
                           // self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
                        }
                    }*/
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
               // self.animationView()
                self.DismissLoader(loader: self.Loader)
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.incrementCount), userInfo: nil, repeats: true)
                self.timer!.fire()
                self.LoadQuestion()
                self.ObserveUser(self.roomCode)
                //print("QSN",self.quesData.count)
            }
        });
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        buttons.forEach{$0.isUserInteractionEnabled = true} 
    }
    
    @objc func incrementCount() {
        
        count += 0.1
        self.timerLabel.text = self.secondsToHoursMinutesSeconds(seconds: Int(CGFloat(CGFloat(self.seconds) - count)))
        
        if count >= CGFloat(self.seconds - 10){
           //change color on based remian secon
        }
        if count >= CGFloat(self.seconds) {
            timer!.invalidate()
            self.SetRightWrongtoFIR()
            self.ShowResultAlert()
        }
    }
    
    //load question here
    func LoadQuestion(){
        
        if(currentQuestionPos  < quesData.count) {
            
           // animationView()
            
            resetProgressCount()
           // ObserveQuestion()
            if Apps.opt_E == true{
                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)// enable button and restore to its default value
            }else{
                MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)// enable button and restore to its default value
            }
            
            if(quesData[currentQuestionPos].image == ""){
                // if question dose not contain images
//                if quesData[currentQuestionPos].quesStatus{
//                    mainQuestionLbl.attributedText = quesData[currentQuestionPos].question.htmlData()
//                }else{
                    mainQuestionLbl.text = quesData[currentQuestionPos].question
//                }
                
                //hide some components
                imageQuestionLbl.isHidden = true
                questionImageView.isHidden = true
                
                mainQuestionLbl.isHidden = false
                
                mainQuestionLbl.centerVertically()
                
            }else{
                // if question has image
//                if quesData[currentQuestionPos].quesStatus{
//                    imageQuestionLbl.attributedText = quesData[currentQuestionPos].question.htmlData()
//                }else{
                    imageQuestionLbl.text = quesData[currentQuestionPos].question
//                }
                questionImageView.loadImageUsingCache(withUrl: quesData[currentQuestionPos].image)
                
                questionImageView.isHidden = false
                imageQuestionLbl.isHidden = false
                
                mainQuestionLbl.isHidden = true
            }
            if(quesData[currentQuestionPos].opetionE == "")
               {
                   Apps.opt_E = false
               }else{
                   Apps.opt_E = true
               }
               if Apps.opt_E == true {
                   btnE.isHidden = false
                   buttons = [btnA,btnB,btnC,btnD,btnE]
                   DesignOpetionButton(buttons: btnA,btnB,btnC,btnD,btnE)
                   self.SetViewWithShadow(views: btnA,btnB, btnC, btnD, btnE)
                   // enabled opetions button
                   MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD,btnE)
               }else{
                   btnE.isHidden = true
                   buttons = [btnA,btnB,btnC,btnD]
                   DesignOpetionButton(buttons: btnA,btnB,btnC,btnD)
                   self.SetViewWithShadow(views: btnA,btnB, btnC, btnD)
                   // enabled opetions button
                   MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)
               }
            self.SetButtonOpetion(opestions: quesData[currentQuestionPos].opetionA,quesData[currentQuestionPos].opetionB,quesData[currentQuestionPos].opetionC,quesData[currentQuestionPos].opetionD,quesData[currentQuestionPos].opetionE,quesData[currentQuestionPos].correctAns)
            
          //  self.emojiImageView.removeFromSuperview()
            
          //  totalCount.roundCorners(corners: [ .bottomRight], radius: 5)
            //  totalCount.text = "\(currentQuestionPos + 1)/10"
           // totalCount.text = "\(currentQuestionPos + 1)"
            // totalCount.text = "\(currentQuestionPos + 1)/\(Apps.TOTAL_PLAY_QS)"
            
        } else {
            // If there are no more questions show the results
            if oppAnswer{
                ShowResultAlert()
            }
           // self.emojiImageView.removeFromSuperview()
            self.scroll.setContentOffset(.zero, animated: true)
            
            self.secondChildView.isHidden = true
            
            self.btnA.isHidden = true
            self.btnB.isHidden = true
            self.btnC.isHidden = true
            self.btnD.isHidden = true
            self.btnE.isHidden = true
            
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: self.scroll.frame.width, height: self.scroll.frame.height))
            noDataLabel.text          = Apps.BTL_WAIT_MSG
            noDataLabel.textColor     = Apps.BASIC_COLOR
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            noDataLabel.lineBreakMode = .byWordWrapping
            
            self.scroll.addSubview(noDataLabel)
        }
    }
    
    var btnY = 0
    func SetButtonHeight(buttons:UIButton...){
        
        self.scroll.setContentOffset(.zero, animated: true)
        self.scroll.contentSize = CGSize(width: self.scroll.frame.width, height: self.view.frame.height)
        
        if self.quesData[self.currentQuestionPos].quesType == "2"{
            return
        }
        
        btnY = Int(self.secondChildView.frame.height + self.secondChildView.frame.origin.y + 20)
        
        for button in buttons{
            let btnWidth = self.btnD.frame.width
            
            let btnX = button.frame.origin.x
            
            let size = button.intrinsicContentSize
            let newHeight = size.height > 50 ? size.height : 50
            let newFram = CGRect(x: Int(btnX), y: btnY, width: Int(btnWidth), height: Int(newHeight))
            btnY += Int(newHeight) + 10
            button.frame = newFram
            
            button.titleLabel?.lineBreakMode = .byWordWrapping
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.layoutIfNeeded()
            button.layoutIfNeeded()
            button.backgroundColor = .clear
        }
        
        buttons.forEach{ $0.layer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.4).cgColor }
        
        let with = self.scroll.frame.width
        self.scroll.contentSize = CGSize(width: Int(with), height: Int(btnY + 10))
        //self.childView.backgroundColor = .lightGray
    
    }
    
    func ShowResultAlert(){
        
        NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        if timer != nil && timer!.isValid{
            timer!.invalidate()
        }
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "BattleRoomResult") as! BattleRoomResult
        viewCont.joinedUsers = self.joinedUsers
        viewCont.roomType = self.roomType
        viewCont.roomInfo = self.roomInfo
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //score count
        rightCount += 1
        self.ref.child(user.UID).child("rightAns").setValue("\(rightCount)")
        
       // rightWrongEmoji(imgName: "excellent")
        
        btn.backgroundColor = Apps.RIGHT_ANS_COLOR
        btn.tintColor = UIColor.white
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "right")

        self.SetRightWrongtoFIR()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            DispatchQueue.main.async {
                self.currentQuestionPos += 1 //increament for next question
                self.LoadQuestion()
            }
        });
    }
    
   /* var emojiImageView = UIImageView()
    func rightWrongEmoji(imgName: String){

        if deviceStoryBoard == "Main"{
            emojiImageView = UIImageView(frame: self.secondChildView.bounds)
            emojiImageView.layer.backgroundColor = UIColor.clear.cgColor // UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0).cgColor
        }else{
            emojiImageView = UIImageView(frame: self.secondChildView.bounds)
            emojiImageView.layer.backgroundColor = UIColor.clear.cgColor //UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0).cgColor
        }
        emojiImageView.frame = CGRect(x: emojiImageView.frame.origin.x, y: emojiImageView.frame.origin.y + 150, width: emojiImageView.frame.width, height: emojiImageView.frame.height)
        emojiImageView.center.x = self.secondChildView.center.x
        
        emojiImageView.bringSubview(toFront: self.secondChildView)
        emojiImageView.image = UIImage(named: imgName)
        emojiImageView.contentMode = .scaleAspectFit
        self.view.addSubview(emojiImageView)
    }*/
    
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        
        for rbtn in self.buttons{
            if rbtn.tag == 1{
                rbtn.backgroundColor = Apps.RIGHT_ANS_COLOR
                rbtn.tintColor = UIColor.white
            }
        }
        
      //  rightWrongEmoji(imgName: "oppss")
        
        //score count
        wrongCount += 1
        
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
        
        // sound
        self.PlaySound(player: &audioPlayer, file: "wrong")
        
        self.SetRightWrongtoFIR()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            DispatchQueue.main.async {
                self.currentQuestionPos += 1 //increament for next question
                self.LoadQuestion()
            }
        });
    }
    
    //observe data in firebase and show updated data to user
    func SetRightWrongtoFIR(){
        
        let users = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let refR = ref.child(roomCode).child("joinUser").child(users.UID)//Database.database().reference().child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser").child(users.UID)
        
        refR.child("rightAns").setValue("\(self.rightCount)")
        refR.child("wrongAns").setValue("\(self.wrongCount)")
        
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
        
        let singleQues = quesData[currentQuestionPos]
        if singleQues.quesType == "2"{
            
            let trueFrame = CGRect(x: 10, y: self.view.frame.maxY - 300, width: (self.view.frame.width / 2) - 16, height: 120)
            let falseFrame = CGRect(x: trueFrame.width + 20, y: self.view.frame.maxY - 300, width: (self.view.frame.width / 2) - 16, height: 120)
            
            self.btnA.frame = trueFrame
            self.btnB.frame = falseFrame
            
            self.btnA.contentHorizontalAlignment = .center
            self.btnB.contentHorizontalAlignment = .center
            
            self.buttons = [btnA,btnB]
    
            btnC.isHidden = true
            btnD.isHidden = true
            btnE.isHidden = true
         
            temp = ["a","b"]
            
        }else{
            
            self.btnA.contentHorizontalAlignment = .left
            self.btnB.contentHorizontalAlignment = .left
            
            if Apps.opt_E == true {
            self.buttons = [btnA,btnB,btnC,btnD,btnE]
                btnE.isHidden = false
            }else{
                self.buttons = [btnA,btnB,btnC,btnD]
            }
            btnC.isHidden = false
            btnD.isHidden = false
            
            btnA.setImage(UIImage(named: "btnA"), for: .normal)
            btnB.setImage(UIImage(named: "btnB"), for: .normal)
            btnC.setImage(UIImage(named: "btnc"), for: .normal)
            btnD.setImage(UIImage(named: "btnD"), for: .normal)
            btnE.setImage(UIImage(named: "btnE"), for: .normal)
            
            buttons.shuffle()
        }
        
        let ans = temp
        var rightAns = ""
        if ans.contains("\(opestions.last!.lowercased())") {
            rightAns = opestions[ans.firstIndex(of: opestions.last!.lowercased())!]
        }else{
            // self.ShowAlert(title: "Invalid Question", message: "This Question has wrong value.")
            rightAnswer(btn: btnA)
        }
        buttons.shuffle()
        var index = 0
        for button in buttons{
            button.titleLabel?.lineBreakMode = .byCharWrapping
            button.setTitle(opestions[index].trimmingCharacters(in: .whitespaces), for: .normal)
            if opestions[index] == rightAns{
                button.tag = 1
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
        }else{
            clickedButton.removeAll()
            buttons.forEach{$0.isUserInteractionEnabled = true}
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
            btn.frame = self.btnA.frame //btnE.frame
            btn.backgroundColor = .clear
            btn.layer.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2).cgColor
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
        
        self.timer!.invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            if self.timer!.isValid{
                self.timer?.invalidate()
            }
            self.currentQuestionPos += 1 //increament for next question
            self.LoadQuestion()
        })
    }
}

class ResizableButton: UIButton {
    override var intrinsicContentSize: CGSize {
       let labelSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
       let desiredButtonSize = CGSize(width: labelSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: labelSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom + 25)

       return desiredButtonSize
    }
}

