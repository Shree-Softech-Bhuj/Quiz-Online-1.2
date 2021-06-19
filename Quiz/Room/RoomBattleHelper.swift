import Foundation
import CallKit
import UIKit
import FirebaseDatabase

extension RoomBattlePlayView:UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.joinedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BattleUserScoreCell", for: indexPath) as! BattleUserScoreCell
        
        let index = indexPath.row
        let currUser = self.joinedUsers[index]
        cell.userName.text = currUser.userName
        if currUser.userImage != ""{
            DispatchQueue.main.async {
                cell.userImg.loadImageUsingCache(withUrl: currUser.userImage)
            }
        }else{
            cell.userImg.image = UIImage(systemName: "person.fill")//(named: "userAvtar")
        }
        cell.userRight.text = currUser.rightAns
        cell.userWrong.text = currUser.wrongAns
        
        //same user
        if self.user.UID == currUser.uID{
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
            cell.mainView.layer.masksToBounds = true
        }else{
            cell.mainView.layer.borderWidth = 1
            cell.mainView.layer.masksToBounds = true
            cell.mainView.layer.borderColor = UIColor.white.cgColor
        }
        //user leave
        if currUser.isLeave ?? false{
            cell.mainView.backgroundColor = .lightGray
        }else{
            cell.mainView.backgroundColor = .white
        }
        
        return cell
    }
    
    func ObserveUser(){
        self.joinedUsers.removeAll()
        let refR = Database.database().reference().child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID).child("joinUser")
        refR.observe(.value, with: {(snapshot) in
          //  print("Observe val",snapshot)
            if let data = snapshot.value as? [String:Any]{
              //  print("DATA",data)
                self.joinedUsers.removeAll()
                for val in data{
                    if let user = val.value as? [String:Any]{
                        self.joinedUsers.append(JoinedUser.init(uID: "\(user["UID"]!)", userID: "\(user["userID"]!)", userName: "\(user["name"]!)", userImage: "\(user["image"]!)", isJoined: "\(user["isJoined"]!)".bool ?? false,rightAns: "\(user["rightAns"] ?? "0")",wrongAns: "\(user["wrongAns"] ?? "0")",isLeave:  "\(user["isLeave"] ?? "false")".bool ?? false))
                    }
                }
                self.collectionView.reloadData()
                
                if self.joinedUsers.count == 1 || self.joinedUsers.count == 2 {
                    self.DesignViews(battleHeight: 50)
                }else if self.joinedUsers.count == 3 || self.joinedUsers.count == 4 {
                    self.DesignViews(battleHeight: 100)
                }else if self.joinedUsers.count == 5 || self.joinedUsers.count == 6 {
                    self.DesignViews(battleHeight: 150)
                }
                
                self.CheckPlayerAttemp()
                
                let count = self.joinedUsers.filter({ $0.isLeave ?? false }).count
                if (count == self.joinedUsers.count - 1){
                    print("All User have been left")
                    if !self.hasLeave{
                        self.AllUserLeft()
                    }
                }
             
            }
        })
    }
    
    func AllUserLeft(){
        
        if self.isCompleted{
            return
        }
        
        let alert = UIAlertController(title: "\(Apps.NO_PLYR_LEFT)",message: "",preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertActionStyle.default, handler: {
//            (alertAction: UIAlertAction!) in
//            alert.dismiss(animated: true, completion: nil)
//        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            //  if let validTimer = self.timer?.isValid {
            self.LeaveBattleProc()
           
        }))
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
    func CheckPlayerAttemp(){
        if self.isCompleted{
            return
        }
        
        var isAllAttempt = false
        for val in self.joinedUsers{
            if val.isJoined && !val.isLeave!{
                if (Int(val.rightAns)! + Int(val.wrongAns)!) == self.quesData.count{
                    isAllAttempt = true
                }else{
                    isAllAttempt = false
                    break
                }
            }
        }
        
        if isAllAttempt{
            self.CompleteBattle()
            self.isCompleted = true
        }
    }
}

extension RoomBattlePlayView: CXCallObserverDelegate {
    
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
