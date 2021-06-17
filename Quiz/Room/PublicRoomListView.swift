//
//  PublicRoomListView.swift
//  Themiscode Q&A
//
//  Created by LPK's Mini on 25/11/20.
//  Copyright © 2020 LPK Techno. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AVFoundation

class PublicRoomListView: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var topView:UIView!
    
    
    var ref: DatabaseReference!
    var roomList:[RoomDetails] = []
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.topView.addBottomBorderWithColor(color: .lightGray, width: 1.2)
        
        ref = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME)
        self.GetAvailPublicRoom()
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func GetAvailPublicRoom(){
        ref.observe(.value, with: { (snapshot) in
            if let data = snapshot.value as? [String:Any]{
                self.roomList.removeAll()
                for val in data{
                    if let room = val.value as? [String:Any]{
                        // print("DDD",room)
                        if let roomUser = room["roomUser"] as? [String:Any]{
                            if !("\(room["isRoomActive"] ?? "false")".bool ?? false){
                                continue
                            }
                            self.roomList.append(RoomDetails.init(ID: "\(room["roomID"]!)", roomFID: val.key, userID: "\(roomUser["userID"]!)", roomName: "\(room["roomName"]!)", catName: "\(room["category"]!)", catLavel: "\(room["catLevel"] ?? "0")", noOfPlayer: "\(room["noOfPlayer"]!)", noOfQues: "\(room["noOfQuestion"]!)", playTime: "\(room["time"]!)"))
                        }
                        
                    }
                }
                self.tableView.reloadData()
            }
        })
    }
    
    var useButton = UIButton()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      
        if self.roomList.count == 0{
            
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "Herkese Açık Oda Bulunamadı. İlk Sen Oluştur."
            noDataLabel.textColor     = Apps.COLOR_DARK_RED
            noDataLabel.textAlignment = .center
            noDataLabel.numberOfLines = 0
            noDataLabel.lineBreakMode = .byWordWrapping
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
            
            useButton.frame = CGRect(x: 8, y: 4.5, width: 100, height: 35)
            useButton.isHidden = false
            tableView.addSubview(useButton)
            useButton.setTitle("Geri Dön", for: .normal)
            useButton.setTitleColor(.white, for: .normal)
            useButton.center.y = tableView.center.y
            useButton.center.x = tableView.center.x
            useButton.backgroundColor = Apps.COLOR_DARK_RED
            useButton.addTarget(self, action: #selector(ReturnBack), for: .touchUpInside)
        }else{
            useButton.isHidden = true
            useButton.removeFromSuperview()
            tableView.backgroundView = .none
        }
        return self.roomList.count
    }
    
    @objc func ReturnBack(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomListCell", for: indexPath) as! RoomListCell
        
        let index = indexPath.row
        let currRoom = self.roomList[index]
        cell.roomCatNate.text = currRoom.roomName
        cell.roomDetails.text  = "\(Apps.BULLET) \(currRoom.catName)   \(Apps.BULLET) \(currRoom.noOfQues) Soru.   \(Apps.BULLET) \(currRoom.playTime) Dakika.    \(Apps.BULLET) \(currRoom.noOfPlayer) Oyuncu."
        cell.joinButton.tag = index
        cell.joinButton.addTarget(self, action: #selector(self.JoinRoom), for: .touchUpInside)
        return cell
    }
    
    @objc func JoinRoom(button:UIButton){
        
        let currRoom = self.roomList[button.tag]
        
        let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME).child(currRoom.roomFID).child("joinUser")
      
        let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        
        var userDetails:[String:String] = [:]
        userDetails["UID"] = user.UID
        userDetails["userID"] = user.userID
        userDetails["name"] = user.name
        userDetails["image"] = user.image
        userDetails["isJoined"] = "true"
        
        refR.observeSingleEvent(of: .value, with:{(snapshot) in
            if snapshot.childrenCount >= Int(currRoom.noOfPlayer)!{
                // no space avail for this room
                self.ShowAlert(title: "Maksimum Kullanıcıya Ulaşıldı", message: "")
                return
            }else{
                // space avail 
                refR.child(user.UID).setValue(userDetails,withCompletionBlock: {(error,snapshot) in
                    if error != nil{
                        print("Public Room Join Error")
                        return
                    }
                    
                    self.PlaySound(player: &self.audioPlayer, file: "click") // play sound
                    self.Vibrate() // make device vibrate
                    
                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let viewCont = storyboard.instantiateViewController(withIdentifier: "PublicRoomView") as! PublicRoomView
                    
                    viewCont.selfUser = false
                    viewCont.roomInfo = currRoom
                    
                    self.navigationController?.pushViewController(viewCont, animated: true)
                })
            }
        })
    }

}
