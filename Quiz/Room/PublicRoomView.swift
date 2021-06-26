import UIKit
import FirebaseDatabase
import AVFoundation

class PublicRoomView: UIViewController {

    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var playButton:UIButton!
    @IBOutlet weak var playButtonView:UIView!
    @IBOutlet weak var roomName:UILabel!
    @IBOutlet weak var roomDetails:UITextView!
    @IBOutlet weak var indicatorView:UIView!
    
    @IBOutlet weak var topView:UIView!
    
    var ref: DatabaseReference!
    var joinUser:[JoinedUser] = []
    var roomInfo:RoomDetails?
    
    var selfUser = true
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var isRoomStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.topView.addBottomBorderWithColor(color: .lightGray, width: 1.2)
        
        self.playButton.layer.cornerRadius = 10
        self.roomName.layer.addBorder(edge: .bottom, color: Apps.BASIC_COLOR, thickness: 1) 
        
        self.roomName.text = roomInfo!.roomName
        self.roomDetails.text = "\(Apps.BULLET) \(roomInfo!.catName)   \(Apps.BULLET) \(roomInfo!.noOfQues) \(Apps.QSTN).  \(Apps.BULLET) \(roomInfo!.playTime) \(Apps.MINUTES)."
        self.ref = Database.database().reference().child(Apps.ROOM_NAME)
        
        if selfUser{
            let currUser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            
            var userDetails:[String:String] = [:]
            userDetails["UID"] = currUser.UID
            userDetails["userID"] = currUser.userID
            userDetails["name"] = currUser.name
            userDetails["image"] = currUser.image
            userDetails["isJoined"] = "true"
            let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser").child(currUser.UID)
            refR.setValue(userDetails, withCompletionBlock: {(error,snapshot) in
                self.collectionView.reloadData()
            })
            
            self.playButton.isHidden = false
            self.indicatorView.isHidden = true
            self.GetInvitedUser()
        }else{
            self.playButton.isHidden = true
            self.indicatorView.isHidden = false
            self.GetInvitedUser()
            self.ObserveRoomActive()
        }
        
    }
    
    @IBAction func backButton(_ sender: Any) {
        if self.selfUser{
            let alert = UIAlertController(title: Apps.GAMEROOM_DESTROY_MSG , message: "", preferredStyle: .alert)
            
            let acceptAction = UIAlertAction(title: Apps.YES, style: .default, handler: {_ in
                // make room deactive and leave viewcontroller
                DispatchQueue.main.async {
                    let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID)
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
            let alert = UIAlertController(title: Apps.GAMEROOM_EXIT_MSG, message: "", preferredStyle: .alert)
            
            let acceptAction = UIAlertAction(title: Apps.YES, style: .default, handler: {_ in
                // make room deactive and leave viewcontroller
                DispatchQueue.main.async {
                    let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                    
                    let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
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
     
        let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID)
        refR.child("isStarted").setValue("true")
        
        self.PlaySound(player: &self.audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "RoomBattlePlayView") as! RoomBattlePlayView
        
        viewCont.roomType = "public"
        viewCont.roomInfo = self.roomInfo
        self.isRoomStarted = true
        
        self.navigationController?.pushViewController(viewCont, animated: true)        
    }
}


//collectionview set
extension PublicRoomView:UICollectionViewDelegate,UICollectionViewDataSource{
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
    
    func ObserveRoomActive(){
        let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID)
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
                        
                        viewCont.roomType = "public"
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
            self.ShowAlert(title: "Oda Aktif Değil", message: "")
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}

//observe method
extension PublicRoomView{
    
    func ObserveUserJoining(){
        let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
        refR.observe(.childChanged, with: {(snapshot) in
          //  print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
                let index = self.joinUser.firstIndex(where: {$0.uID == "\(data["UID"]!)"})
                self.joinUser[index!].isJoined = "\(data["isJoined"]!)".bool ?? false
                self.collectionView.reloadData()
            }
        })
    }
    
    func GetInvitedUser(){
       //get invited user list
        self.joinUser.removeAll()
        let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
        refR.observe(.value, with: {(snapshot) in
            //  print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
                //print("DATA",data)
                self.joinUser.removeAll()
                for val in data{
                    if let user = val.value as? [String:Any]{
                        self.joinUser.append(JoinedUser.init(uID: "\(user["UID"]!)", userID: "\(user["userID"]!)", userName: "\(user["name"]!)", userImage: "\(user["image"]!)", isJoined: "\(user["isJoined"]!)".bool ?? false,rightAns: "\(user["rightAns"] ?? "0")",wrongAns: "\(user["wrongAns"] ?? "0")"))
                    }
                }
                self.collectionView.reloadData()
                self.ObserveUserJoining()
            }
        })
    }
}
