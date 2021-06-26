import UIKit
import FirebaseDatabase
import AVFoundation

class PrivateRoomView: UIViewController {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var playButtonView:UIView!
    @IBOutlet weak var roomName:UILabel!
    @IBOutlet weak var roomDetails:UITextView!
    @IBOutlet weak var indicatorView:UIView!
    
    @IBOutlet weak var topView:UIView!
    
    var ref: DatabaseReference!
    var availUser:[OnlineUser] = []
    var joinUser:[JoinedUser] = []
    
    var roomInfo:RoomDetails? 
    var selfUser = true
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var isRoomStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.layer.cornerRadius = 10
        self.playButton.layer.cornerRadius = 10
        self.roomName.layer.addBorder(edge: .bottom, color: Apps.BASIC_COLOR, thickness: 1)
        
        self.roomName.text =  roomInfo!.roomName
        self.roomDetails.text = "\(Apps.BULLET) \(roomInfo!.catName)  \(Apps.BULLET) \(roomInfo!.noOfQues) \(Apps.QSTN). \(Apps.BULLET) \(roomInfo!.playTime) \(Apps.MINUTES). \(Apps.BULLET) \(roomInfo!.noOfPlayer) \(Apps.PLYR)."
        self.ref = Database.database().reference().child(Apps.ROOM_NAME)
        
        if selfUser{
            let currUser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            
            var userDetails:[String:String] = [:]
            userDetails["UID"] = currUser.UID
            userDetails["userID"] = currUser.userID
            userDetails["name"] = currUser.name
            userDetails["image"] = currUser.image
            userDetails["isJoined"] = "true"
            let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser").child(currUser.UID)
            refR.setValue(userDetails, withCompletionBlock: {(error,snapshot) in
                self.collectionView.reloadData()
            })
            
            self.tableView.isHidden = false
            self.playButton.isHidden = false
            self.indicatorView.isHidden = true
            self.GetAvailUser()
            self.GetInvitedUser()
        }else{
            self.tableView.isHidden = true
            self.playButton.isHidden = true
            self.indicatorView.isHidden = false
            self.GetInvitedUser()
            self.ObserveRoomActive()
        }        
    }
    
    @IBAction func backButton(_ sender: Any) {
        if self.selfUser{
            let alert = UIAlertController(title: "\(Apps.GAMEROOM_DESTROY_MSG)", message: "", preferredStyle: .alert)
            
            let acceptAction = UIAlertAction(title: Apps.YES, style: .default, handler: {_ in
                // make room deactive and leave viewcontroller
                DispatchQueue.main.async {
                    let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID)
                    refR.child("isRoomActive").setValue("false")
                    self.ref.removeAllObservers()
                    refR.removeAllObservers()
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
        }else{
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
        }
    }
    
    @IBAction func PlayBattle(_ sender: Any) {
        
        if self.joinUser.count <= 1 || self.joinUser.filter({ $0.isJoined }).count <= 1{
            self.ShowAlert(title: "\(Apps.USER_NOT_JOIN)", message: "")
            return
        }
        let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID)
        refR.child("isStarted").setValue("true")
        
        self.PlaySound(player: &self.audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "RoomBattlePlayView") as! RoomBattlePlayView
        
        viewCont.roomType = "private"
        viewCont.roomInfo = self.roomInfo
        self.isRoomStarted = true
        
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    
    func ObserveRoomActive(){
        let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID)
        refR.observe(.value, with: { (snapshot) in
            if self.isRoomStarted{
                refR.removeAllObservers()
                return
            }
            // print("SNAP",snapshot.value,snapshot.key)
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
                        
                        self.navigationController?.pushViewController(viewCont, animated: true)
                    }
                }
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
                self.tableView.reloadData()
            }
        })
    }
}

//collectionview set
extension PrivateRoomView:UICollectionViewDelegate,UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomUserCell", for: indexPath) as! RoomUserCell
        
        let index = indexPath.row
   
        if index < self.joinUser.count{
            cell.joinUser = self.joinUser[index]
        }else{
            cell.joinUser = nil
        }
        cell.ConfigCell()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RoomUserCell", for: indexPath) as! RoomUserCell
        
        cell.ConfigCell()
    }
}


//table view
extension PrivateRoomView:UITableViewDelegate,UITableViewDataSource{
    
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
        if self.joinUser.count >= Int(self.roomInfo!.noOfPlayer)!{
            self.ShowAlert(title: "\(Apps.MAX_USER_REACHED)", message: "")
            return
        }
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
        let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser").child(currUser.uID)
        refR.setValue(userDetails, withCompletionBlock: {(error,snapshot) in
            self.collectionView.reloadData()
            self.ObserveUserJoining()
            self.SendInvite(inviteUserID: currUser.userID)
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
        print("Observe")
        let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
        refR.observe(.childChanged, with: {(snapshot) in
            //   print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
                if  let index = self.joinUser.firstIndex(where: {$0.uID == "\(data["UID"]!)"}){
                    self.joinUser[index].isJoined = "\(data["isJoined"]!)".bool ?? false
                    self.collectionView.reloadData()
                }
            }
        })
    }
    
    func GetInvitedUser(){
       //get invited user list
        self.joinUser.removeAll()
        let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
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
                self.ObserveUserJoining()
            }
        })
    }
}
