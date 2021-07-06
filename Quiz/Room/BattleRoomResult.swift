import UIKit
import FirebaseDatabase

class BattleRoomResult: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var topView:UIView!
    @IBOutlet weak var backButton:UIButton!
    
    //user one
    @IBOutlet weak var user1Image:UIImageView!
    @IBOutlet weak var user1Name:UILabel!
    @IBOutlet weak var user1RightAns:UILabel!
    @IBOutlet weak var user1WrongAns:UILabel!
    @IBOutlet weak var imgView1:UIView!
    
    //user two
    @IBOutlet weak var user2Image:UIImageView!
    @IBOutlet weak var user2Name:UILabel!
    @IBOutlet weak var user2RightAns:UILabel!
    @IBOutlet weak var user2WrongAns:UILabel!
    @IBOutlet weak var imgView2:UIView!
    
    //user three
    @IBOutlet weak var user3Image:UIImageView!
    @IBOutlet weak var user3Name:UILabel!
    @IBOutlet weak var user3RightAns:UILabel!
    @IBOutlet weak var user3WrongAns:UILabel!
    @IBOutlet weak var imgView3:UIView!
    
    var joinedUsers:[JoinedUser] = []
    var roomInfo:RoomDetails?
    var roomType = "private"
    var roomCode = "00000"
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //self.backButton.SetShadow()
      /*  imgView1.layer.cornerRadius = imgView1.frame.height / 2
        imgView1.layer.borderWidth = 1
        imgView1.layer.borderColor = UIColor.white.cgColor
        user1Image.center = CGPoint(x: imgView2.frame.size.width  / 2,
                                     y: imgView2.frame.size.height / 2)
        user2Image.center = CGPoint(x: imgView1.frame.size.width  / 2,
                                     y: imgView1.frame.size.height / 2)
        user3Image.center = CGPoint(x: imgView3.frame.size.width  / 2,
                                     y: imgView3.frame.size.height / 2)
        
        imgView2.layer.cornerRadius = imgView2.frame.height / 2
        imgView2.layer.borderWidth = 1
        imgView2.layer.borderColor = UIColor.white.cgColor
        imgView3.layer.cornerRadius = imgView3.frame.height / 2
        imgView3.layer.borderWidth = 1
        imgView3.layer.borderColor = UIColor.white.cgColor
        
        self.DesignImage(images: self.user1Image,self.user2Image,self.user3Image)
        self.DesignLabel(labels: self.user1WrongAns,self.user1RightAns,self.user2RightAns,self.user2WrongAns,self.user3RightAns,self.user3WrongAns)*/
        
      //  self.mainView.SetShadow()
        self.mainView.layer.cornerRadius = 13
        
        self.joinedUsers.sort(by: { Int($0.rightAns)! > Int($1.rightAns)! })
        
      /*  if self.joinedUsers.count == 1{
            //user one
            let currUser = self.joinedUsers[0]
            if !currUser.userImage.isEmpty{
                let img = currUser.userImage
                DispatchQueue.main.async {
                    self.user1Image.loadImageUsingCache(withUrl: img)
                }
            }
            self.user1Name.text = currUser.userName
            self.user1RightAns.text = currUser.rightAns
            self.user1WrongAns.text = currUser.wrongAns
            self.joinedUsers.remove(at: 0)
            
        }else if self.joinedUsers.count == 2{
            //user one
            var currUser = self.joinedUsers[0]
            if !currUser.userImage.isEmpty{
                let img = currUser.userImage
                DispatchQueue.main.async {
                    self.user1Image.loadImageUsingCache(withUrl: img)
                }
            }
            self.user1Name.text = currUser.userName
            self.user1RightAns.text = currUser.rightAns
            self.user1WrongAns.text = currUser.wrongAns
            self.joinedUsers.remove(at: 0)
            
            //user two
            currUser = self.joinedUsers[0]
            if !currUser.userImage.isEmpty{
                let img = currUser.userImage
                DispatchQueue.main.async {
                    self.user2Image.loadImageUsingCache(withUrl: img)
                }
            }
            self.user2Name.text = currUser.userName
            self.user2RightAns.text = currUser.rightAns
            self.user2WrongAns.text = currUser.wrongAns
            self.joinedUsers.remove(at: 0)
            
            self.user3Name.superview?.isHidden = true
            
        }else if self.joinedUsers.count >= 3{
            //user one
            var currUser = self.joinedUsers[0]
            if !currUser.userImage.isEmpty{
                let img = currUser.userImage
                DispatchQueue.main.async {
                    self.user1Image.loadImageUsingCache(withUrl: img)
                }
            }
            self.user1Name.text = currUser.userName
            self.user1RightAns.text = currUser.rightAns
            self.user1WrongAns.text = currUser.wrongAns
            self.joinedUsers.remove(at: 0)
            
            //user two
            currUser = self.joinedUsers[0]
            if !currUser.userImage.isEmpty{
                let img = currUser.userImage
                DispatchQueue.main.async {
                    self.user2Image.loadImageUsingCache(withUrl: img)
                }
            }
            self.user2Name.text = currUser.userName
            self.user2RightAns.text = currUser.rightAns
            self.user2WrongAns.text = currUser.wrongAns
            self.joinedUsers.remove(at: 0)
            
            //user three
            currUser = self.joinedUsers[0]
            if !currUser.userImage.isEmpty{
                let img = currUser.userImage
                DispatchQueue.main.async {
                    self.user3Image.loadImageUsingCache(withUrl: img)
                }
            }
            self.user3Name.text = currUser.userName
            self.user3RightAns.text = currUser.rightAns
            self.user3WrongAns.text = currUser.wrongAns
            self.joinedUsers.remove(at: 0)
            
        } */
        self.tableView.reloadData()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.CompleteBattle()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func BacktoHomeAction(_ sender: Any) {
        self.CompleteBattle()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func DesignImage(images:UIImageView...){
        for image in images{
            image.layer.masksToBounds = true
            image.layer.cornerRadius = image.frame.height / 2
            
//            image.layer.borderColor = UIColor.lightGray.cgColor
//            image.layer.borderWidth = 0.5
        }
    }
    
    func DesignLabel(labels:UILabel...){
        for label in labels{
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 4
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableView.backgroundColor = .clear
        //print("total joinedUser -- \(joinedUsers.count)")
         return joinedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCell
        
        let user = self.joinedUsers[indexPath.row]
        cell.userName.text = user.userName
        cell.rankLabel.text = "\(indexPath.row + 1)"
        cell.userRightAns.text = user.rightAns
        cell.userWrongAns.text = user.wrongAns
        if user.userImage.isEmpty{
            cell.userImage.image = UIImage(systemName: "person.fill")//(named: "userAvtar")
        }else{
            DispatchQueue.main.async {
                cell.userImage.loadImageUsingCache(withUrl: user.userImage)
            }
        }
        cell.layer.cornerRadius = 20
        
        return cell
    }
    
    func CompleteBattle(){
        //let ref = Database.database().reference().child(Apps.ROOM_NAME)
        let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        //ref.child(user.UID).child("status").setValue("free")
        
      /*  if Database.database().reference().child("MultiplayerRoom").child(roomCode).child("authId").value(forKey: "authId") as! String ==  user.UID {//self.roomInfo!.roomFID == user.UID{
            let refR = Database.database().reference().child("MultiplayerRoom").child(roomCode) //Database.database().reference().child(self.roomType == "private" ? Apps.PRIVATE_ROOM_NAME : Apps.PUBLIC_ROOM_NAME).child(self.roomInfo!.roomFID)
            refR.removeValue()
        }*/
        
        let roomVal = Database.database().reference().child("MultiplayerRoom").child(roomCode)
        roomVal.observeSingleEvent(of: .value, with: { (snapshot) in
             if let data = snapshot.value as? [String:Any]{
                print(data)
                let authID = data["authId"] as! String
                print(authID)
                if authID == user.UID {
                    roomVal.removeValue()
                }
             }
        })
    }
}
