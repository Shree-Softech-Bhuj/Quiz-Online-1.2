import UIKit
import FirebaseDatabase
import AVFoundation

class GroupBattleView: UIViewController {
    
//    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var createCollectionView: UICollectionView!
    /*  @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var playButtonView:UIView!
    @IBOutlet weak var roomName:UILabel!
    @IBOutlet weak var roomDetails:UITextView!
    @IBOutlet weak var indicatorView:UIView! */
    
    @IBOutlet weak var createView: UIView!
    @IBOutlet weak var joinView: UIView!
    
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var gameCode: UILabel!
    @IBOutlet weak var shareBtnTxt: UILabel!
    
    @IBOutlet weak var topView:UIView!
    
    var ref: DatabaseReference!
    var db: DatabaseReference!
    var availUser:[OnlineUser] = []
    var joinUser:[JoinedUser] = []
    
    var roomInfo:RoomDetails? 
    var selfUser = true
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var isRoomStarted = false
    
    var count:CGFloat = 0.0
    var timer: Timer!
    var seconds = 03
    let countdownTimeStart = Date()
    var countdownTimeRemaining = 0
    
    var isUserJoininig = false
    var gameRoomCode = ""//randomNumberForBattle()
    var usersCount = 0
    var catID = 0
    var sysConfig:SystemConfiguration!
    let currUser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Database.database().reference().child("MultiplayerRoom")
        
        if isUserJoininig == true{
            joinView.alpha = 1
            createView.alpha = 0
            gameCode.text = gameRoomCode
            self.ref = db.child(self.gameRoomCode)//(Apps.ROOM_NAME)
        }else{
            joinView.alpha = 0
            createView.alpha = 1
            gameRoomCode = randomNumberForBattle()
            gameCode.text = gameRoomCode
            self.ref = db//(Apps.ROOM_NAME)
            //create room api
            var apiURL = ""
            if Apps.GROUP_BATTLE_WITH_CATEGORY == "1" {
                apiURL = "user_id=\(currUser.userID)&room_id=\(gameRoomCode)&room_type=private&category=\(self.catID)&no_of_que=\(Apps.TOTAL_BATTLE_QS)"
            }else{
                apiURL = "user_id=\(currUser.userID)&room_id=\(gameRoomCode)&room_type=private&category=&no_of_que=\(Apps.TOTAL_BATTLE_QS)"
            }
            if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) != nil {//sysConfig.LANGUAGE_MODE == 1{
               let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
               apiURL += "&language_id=\(langID)"
           }
            
            self.getAPIData(apiName: "create_room", apiURL: apiURL,completion: {jsonObj in
                print("JSON response - create room-",jsonObj)
                let status = "\(jsonObj.value(forKey: "error")!)".bool ?? true
                if (status) {
                    self.ShowAlert(title: "Error", message: "\(jsonObj.value(forKey: "message")!)")
                    return
                }
            })
            
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
            timer.fire()
        }
       
//        self.tableView.layer.cornerRadius = 10
     /*   self.playButton.layer.cornerRadius = 10
        self.roomName.layer.addBorder(edge: .bottom, color: Apps.BASIC_COLOR, thickness: 1)
        
        self.roomName.text =  roomInfo!.roomName
        self.roomDetails.text = "\(Apps.BULLET) \(roomInfo!.catName)  \(Apps.BULLET) \(roomInfo!.noOfQues) \(Apps.QSTN). \(Apps.BULLET) \(roomInfo!.playTime) \(Apps.MINUTES). \(Apps.BULLET) \(roomInfo!.noOfPlayer) \(Apps.PLYR)." */
        
                
      //  if selfUser{
          //  let currUser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            print(currUser.name)
            if isUserJoininig == false{
                let refAdd = ref.child(gameRoomCode)
                var setDetails:[String:String] = [:]
                setDetails["authId"] = currUser.UID
                setDetails["isRoomActive"] = "true"
                setDetails["isStarted"] = "false"
                refAdd.setValue(setDetails, withCompletionBlock: {(error,snapshot) in
                  // self.collectionView.reloadData()
                   self.createCollectionView.reloadData()
                })
                
                let refRoomUser = db.child(gameRoomCode).child("roomUser")
                var roomUserDetails:[String:String] = [:]
                roomUserDetails["userID"] = currUser.userID
                roomUserDetails["name"] = currUser.name
                roomUserDetails["image"] = currUser.image
                refRoomUser.setValue(roomUserDetails, withCompletionBlock: {(error,snapshot) in
                    self.collectionView.reloadData()
                    self.createCollectionView.reloadData()
                })
            }
            var userDetails:[String:String] = [:]
            userDetails["UID"] = currUser.UID
            userDetails["userID"] = currUser.userID
            userDetails["name"] = currUser.name
            userDetails["image"] = currUser.image
            userDetails["isJoined"] = "true"
            //.child(self.roomInfo!.roomFID)
            let refR = db.child(gameRoomCode).child("joinUser").child(currUser.UID)
            refR.setValue(userDetails, withCompletionBlock: {(error,snapshot) in
               self.collectionView.reloadData()
               self.createCollectionView.reloadData()
            })
                        
            //self.tableView.isHidden = false
           /* self.playButton.isHidden = false
            self.indicatorView.isHidden = true */
            self.GetAvailUser()
           // self.GetInvitedUser()
            self.ObserveUser()
     //   }else{
           // self.tableView.isHidden = true
          /*  self.playButton.isHidden = true
            self.indicatorView.isHidden = false */
            //self.GetInvitedUser()
            self.ObserveRoomActive()
       // }        
    }
        
    @IBAction func shareButton(_ sender: Any) {
        let str  = Apps.APP_NAME
        var shareUrl = ""
        let gameCode = self.gameCode.text ?? "00000"
        shareUrl = "\(Apps.MSG_GAMEROOM_SHARE) \(gameCode)"
       
        let textToShare = str + "\n" + shareUrl
       
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
        vc.popoverPresentationController?.sourceView = (sender as! UIView)
        present(vc, animated: true)
    }
    
    @IBAction func PlayBtn(_ sender: Any) {

        if self.usersCount <= 1 {
            ShowAlert(title: Apps.GAMEROOM_WAIT_ALERT, message: "")
        }else{
            //        if self.joinUser.count <= 1 || self.joinUser.filter({ $0.isJoined }).count <= 1{
            //            self.ShowAlert(title: "\(Apps.USER_NOT_JOIN)", message: "")
            //            return
            //        }
            let refR = db.child(self.gameRoomCode)//.child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID)
            refR.child("isStarted").setValue("true")
            
            self.PlaySound(player: &self.audioPlayer, file: "click") // play sound
            self.Vibrate() // make device vibrate
            
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "RoomBattlePlayView") as! RoomBattlePlayView
            
            viewCont.roomCode = gameRoomCode
            viewCont.roomType = "private"
            //viewCont.roomInfo = self.roomInfo
            self.isRoomStarted = true
            timer.invalidate()
            self.navigationController?.pushViewController(viewCont, animated: true)
        }
    }
    
    @objc func incrementCount(){

        let timeRemaining = Apps.GROUP_BTL_WAIT_TIME - (0 + Int(floor(Date().timeIntervalSince(countdownTimeStart))))
        //print(timeRemaining)
        let countDownLabelText = getSecondsAsString(seconds:abs(timeRemaining))
            timerLabel.text = countDownLabelText
        
        //countdownTimeRemaining = Apps.GROUP_BTL_WAIT_TIME - 1
        //print(countdownTimeRemaining)
        if timerLabel.text == "00:00" {
            timer.invalidate()
            
            //show alert
            let alert = UIAlertController(title: "\(Apps.OOPS) \(Apps.NO_USER_JOINED)", message: Apps.NO_USER_JOINED_MSG, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: Apps.EXIT, style: UIAlertAction.Style.cancel, handler: backButton(_:)))
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
        }
    }
    func getSecondsAsString(seconds:Int)->String{
      //let hours   = Int(seconds) / 3600
      let minutes = Int(seconds) / 60 % 60
      let seconds = Int(seconds) % 60
      return String(format:"%02i:%02i", minutes, seconds)
    }
    @IBAction func backButton(_ sender: Any) {
        
        if self.selfUser{
            var msg = ""
            if isUserJoininig == true { //user have joined room.
                msg = Apps.LEAVE_MSG
            }else{ //user have created room.
                msg = Apps.GAMEROOM_CLOSE_MSG
            }
            let alert = UIAlertController(title: msg, message: "", preferredStyle: .alert)
            let acceptAction = UIAlertAction(title: Apps.LEAVE, style: .default, handler: {_ in
                
                // make room deactive and leave viewcontroller
                //DispatchQueue.main.async {
                    let ref = self.db.child(self.gameRoomCode).child("joinUser").child(self.currUser.UID)
                    //set isLeave to true
                    ref.child("isLeave").setValue("true")
                
                    let refR = self.db.child(self.gameRoomCode)
                    if self.isUserJoininig == false { //user have created room.
                        refR.child("isRoomActive").setValue("false")
                    }else{ //joined User
                        ref.removeValue() //removes current user
                    }                   
                
                    self.ref.removeAllObservers()
                    refR.removeAllObservers()
                    ref.removeAllObservers()
                    self.navigationController?.popViewController(animated: true)
                //}
            })
            let rejectAction = UIAlertAction(title: Apps.STAY_BACK, style: .cancel, handler: {_ in
              // do nothing here
            })
            
            alert.addAction(acceptAction)
            alert.addAction(rejectAction)
            
            self.present(alert, animated: true, completion: nil)
            return
        } /*else{ //public room
            let alert = UIAlertController(title: "\(Apps.GAMEROOM_EXIT_MSG)", message: "", preferredStyle: .alert)
            
            let acceptAction = UIAlertAction(title: Apps.YES, style: .default, handler: {_ in
                // make room deactive and leave viewcontroller
                DispatchQueue.main.async {
                    let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                    
                    let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
                    refR.child(user.UID).removeValue()
                    
                    self.ref.removeAllObservers()
                    refR.removeAllObservers()
                    
                    let refOnline = Database.database().reference().child(Apps.ROOM_NAME).child(user.UID)
                    refOnline.child("status").setValue("free")
                    refOnline.removeAllObservers()
                    
                    self.navigationController?.popViewController(animated: true)
                }
            })
            let rejectAction = UIAlertAction(title: Apps.NO, style: .cancel, handler: {_ in
              // do nothing here
            })
            
            alert.addAction(acceptAction)
            alert.addAction(rejectAction)
            
            self.present(alert, animated: true, completion: nil)
            return
        } */
    }
        
    func ObserveRoomActive(){
        let refR = db.child(self.gameRoomCode)//.child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID)
        refR.observe(.value, with: { (snapshot) in
            if self.isRoomStarted{
                refR.removeAllObservers()
                return
            }
             print("SNAP",snapshot.value,snapshot.key)
            if let data = snapshot.value as? [String:Any]{
                if let isStarted = "\(data["isStarted"] ?? "false")".bool , let isRoomActive = "\(data["isRoomActive"] ?? "false")".bool {
                    if !isRoomActive{
                        self.ShowRoomLeaveAlert()
                        refR.removeAllObservers()
                        return
                    }
                    if isStarted{
                        // room active here
                        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                        let viewCont = storyboard.instantiateViewController(withIdentifier: "RoomBattlePlayView") as! RoomBattlePlayView
                        
                        viewCont.roomType = "private"
                        viewCont.roomInfo = self.roomInfo
                        self.isRoomStarted = true
                        viewCont.roomCode = self.gameRoomCode
                        self.navigationController?.pushViewController(viewCont, animated: true)
                    }
                }
            }
        })
    }
    
    func ObserveUser(){
        self.joinUser.removeAll()
        let refR = db.child(self.gameRoomCode).child("joinUser")//Database.database().reference().child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
        refR.observe(.value, with: {(snapshot) in
          //  print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
              //  print("DATA",data)
                self.joinUser.removeAll()
                for val in data{
                    if let user = val.value as? [String:Any]{
                        self.joinUser.append(JoinedUser.init(uID: "\(user["UID"]!)", userID: "\(user["userID"]!)", userName: "\(user["name"]!)", userImage: "\(user["image"]!)", isJoined: "\(user["isJoined"]!)".bool ?? false,rightAns: "\(user["rightAns"] ?? "0")",wrongAns: "\(user["wrongAns"] ?? "0")",isLeave:  "\(user["isLeave"] ?? "false")".bool ?? false))
                    }
                }
                self.collectionView.reloadData()
                self.createCollectionView.reloadData()
                self.usersCount = self.joinUser.count
                print("count of JoinUsers - \(self.joinUser.count)")
            }
        })
    }
    
    
    func ShowRoomLeaveAlert(){
        DispatchQueue.main.async {
            self.ShowAlert(title: "\(Apps.GAMEROOM_EXIT_MSG)", message: "")
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func GetAvailUser(){
        let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        ref.observe(.value, with: { (snapshot) in
            if let data = snapshot.value as? [String:Any]{
                self.availUser.removeAll()
                for val in data{
                    if let userVal = val.value as? [String:Any]{
                        if "\(userVal["userID"] ?? "0")" == user.userID{
                            //same user do not display this
                            continue
                        }
                        self.availUser.append(OnlineUser.init(uID: val.key, userID: "\(userVal["userID"] ?? "No ID")", userName: "\(userVal["name"] ?? "No Name")", userImage: "\(userVal["image"] ?? "")",status: "\(userVal["status"] ?? "free")"))
                    }
                }
              //  self.tableView.reloadData()
            }
        })
    }
}

//collectionview set
extension GroupBattleView:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("number of cells - \(usersCount)")
        if collectionView == self.createCollectionView{
            return usersCount
        }else{
            return usersCount //6 //self.joinUser.count //
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.createCollectionView{
            let cellCreate = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomUserCell", for: indexPath) as! RoomUserCell
            
            let index = indexPath.row
            print("joinuser value - \(self.joinUser) -- \(self.joinUser.count) -- \(usersCount)-- \(indexPath.row)")
            
            if index < self.joinUser.count{
                cellCreate.joinUser = self.joinUser[index]
            }
            cellCreate.ConfigCell()
            
            return cellCreate
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomUserCell", for: indexPath) as! RoomUserCell
            
            let index = indexPath.row
            print("In Create - joinuser value - \(self.joinUser) -- \(self.joinUser.count) -- \(usersCount)-- \(indexPath.row)")
            
            if index < self.joinUser.count{
                cell.joinUser = self.joinUser[index]
            }
    //        else{
    //            cell.joinUser = nil
    //        }
            cell.ConfigCell()
            
            return cell
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomUserCell", for: indexPath) as! RoomUserCell
//
//        cell.ConfigCell()
//    }
}

//table view
extension GroupBattleView:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AvailUserListCell", for: indexPath) as! AvailUserListCell
        
        let index = indexPath.row
        let currUser = self.availUser[index]
        
        cell.userName.text = currUser.userName
        if !currUser.userImage.isEmpty{
            cell.userImage.loadImageUsingCache(withUrl: currUser.userImage)
        }else{
            cell.userImage.image = UIImage(systemName: "person.fill")//(named: "userAvtar")
        }
        
        if currUser.status == "busy"{
            cell.inviteButton.setTitle("\(Apps.BUSY)", for: .normal)
        }else{
            cell.inviteButton.setTitle("\(Apps.INVITE)", for: .normal)
        }
        cell.inviteButton.tag = index
        cell.inviteButton.addTarget(self, action: #selector(InviteButtonAction), for: .touchUpInside)
        
        return cell
    }
    
    @objc func InviteButtonAction(button:UIButton){
//        if self.joinUser.count >= Int(self.roomInfo!.noOfPlayer)!{
//            self.ShowAlert(title: "\(Apps.MAX_USER_REACHED)", message: "")
//            return
//        }
        let currUser = self.availUser[button.tag]
        // print("CURR",currUser)
        if self.joinUser.contains(where: {$0.uID == currUser.uID}){
            print("Invitation already sent")
            return
        }
        var userDetails:[String:String] = [:]
        userDetails["UID"] = currUser.uID
        userDetails["userID"] = currUser.userID
        userDetails["name"] = currUser.userName
        userDetails["image"] = currUser.userImage
        userDetails["isJoined"] = "false"
        let refR = db.child(self.gameRoomCode).child("joinUser").child(currUser.uID)//.child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser").child(currUser.uID)
        refR.setValue(userDetails, withCompletionBlock: {(error,snapshot) in
            self.collectionView.reloadData()
            self.createCollectionView.reloadData()
            self.ObserveUserJoining()
           // self.SendInvite(inviteUserID: currUser.userID)
        })
    }
    
    func SendInvite(inviteUserID:String){
        if(Reachability.isConnectedToNetwork()){
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            
            let apiURL = "user_id=\(user.userID)&room_id=\(self.roomInfo!.ID)&invited_id=\(inviteUserID)&room_key=\(self.roomInfo!.roomFID)"
            self.getAPIData(apiName: "invite_friend", apiURL: apiURL,completion: {jsonObj in
                // print("JSON",jsonObj)
                let status = "\(jsonObj.value(forKey: "error")!)".bool ?? true
                if (status) {
                    self.ShowAlert(title: Apps.ERROR, message: "\(jsonObj.value(forKey: "message")!)")
                    return
                }else{
                    print("Invitation sent successfull")
                }
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    func ObserveUserJoining(){
        print("Observe -- \(self.gameRoomCode)")
        let refR = db.child(self.gameRoomCode).child("joinUser")//.child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
        refR.observe(.childChanged, with: {(snapshot) in
               print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
                if  let index = self.joinUser.firstIndex(where: {$0.uID == "\(data["UID"]!)"}){
                    self.joinUser[index].isJoined = "\(data["isJoined"]!)".bool ?? false
                    self.collectionView.reloadData()
                    self.createCollectionView.reloadData()
                }
            }
        })
    }
    
    func GetInvitedUser(){
       //get invited user list
        self.joinUser.removeAll()
        let refR = db.child(self.gameRoomCode).child("joinUser")//.child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
        refR.observe(.value, with: {(snapshot) in
            //  print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
                //print("DATA",data)
                self.joinUser.removeAll()
                for val in data{
                    if let user = val.value as? [String:Any]{
                        if let uid = user["UID"] as? String{
                            self.joinUser.append(JoinedUser.init(uID: uid, userID: "\(user["userID"]!)", userName: "\(user["name"]!)", userImage: "\(user["image"]!)", isJoined: "\(user["isJoined"]!)".bool ?? false,rightAns: "\(user["rightAns"] ?? "0")",wrongAns: "\(user["wrongAns"] ?? "0")"))
                        }else{
                            continue
                        }
                    }
                }
                self.collectionView.reloadData()
                self.createCollectionView.reloadData()
                self.ObserveUserJoining()
            }
        })
        print("count of joined user - \(self.joinUser.count) ")
    }
}
