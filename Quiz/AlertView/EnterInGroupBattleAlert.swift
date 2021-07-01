import UIKit
import FirebaseDatabase

class EnterInGroupBattleAlert: UIViewController {
    
    @IBOutlet weak var joinRoomBtn: UIButton!
    
    @IBOutlet weak var gameCodeTxt: UITextField!
        
    @IBOutlet weak var bgView: UIView!
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joinRoomBtn.layer.cornerRadius = joinRoomBtn.frame.height / 2
        gameCodeTxt.layer.cornerRadius = gameCodeTxt.frame.height / 2
        gameCodeTxt.clipsToBounds = true
        gameCodeTxt.backgroundColor = UIColor.cyan.withAlphaComponent(0.6)
        
        bgView.layer.cornerRadius = 25
        
        ref = Database.database().reference().child("MultiplayerRoom")//(Apps.PUBLIC_ROOM_NAME)
       // checkForAvailability()
     }
    
    func checkForAvailability(){
        ref.observe(.value, with: { (snapshot) in
            if let data = snapshot.value as? [String:Any]{
                print(data)
//                self.roomList.removeAll()
                for val in data{
                    print("Keys in Data \(val.key)")
                    if self.gameCodeTxt.text == val.key {
                    print("game code found")
                        
                    if let room = val.value as? [String:Any]{
                         print("Values in Data -- ",room)
                        if ("\(room["isRoomActive"] ?? "true")".bool ?? true){//if ((room["isRoomActive"] != nil) == false){
//                            continue
//                            print("Is room active - true")
//                            if ("\(room["isStarted"] ?? "true")".bool ?? true){
//
//                            }
                            //go to Group battle view & add yourself with group of people present there
                            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                            let viewCont = storyboard.instantiateViewController(withIdentifier: "GroupBattleView") as! GroupBattleView
                            viewCont
                            self.navigationController?.pushViewController(viewCont, animated: true)
                            
                        }else{
                            print("Is room active - false")
                        }
//                            self.roomList.append(RoomDetails.init(ID: "\(room["roomID"]!)", roomFID: val.key, userID: "\(roomUser["userID"]!)", roomName: "\(room["roomName"]!)", catName: "\(room["category"]!)", catLavel: "\(room["catLevel"] ?? "0")", noOfPlayer: "\(room["noOfPlayer"]!)", noOfQues: "\(room["noOfQuestion"]!)", playTime: "\(room["time"]!)"))
                            }
                    }else{
                        self.ShowAlertOnly(title: Apps.GAMECODE_INVALID, message: "")
                    }
                }
            }
        })
    }
    
    @IBAction func CloseAlert(_ sender: Any){
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func GoToRoom(_ sender: Any) {
        //validate / check for code entered and if it is existing one then enter in group battle.
        //if gamecode exist in table and isRoomActive paramter is false..then alert msg should be GameRoom is Deactivated Or Game Already Started[Apps.GAME_CLOSED] andd close THIS alertView.& IF isRoomActive paramter is true..then go to Group Battle page with Wait For Players Text and wait for admin to start game. and add user in Joineduser tbl
        //before API - check for isRoomActive & isStarted from db.
        
        checkForAvailability()
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "GroupBattleView")
        self.navigationController?.pushViewController(viewCont, animated: true)
        
        //testing of api
       /* if gameCodeTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{//gameCodeTxt.text == ""{
            gameCodeTxt.placeholder = Apps.GAMEROOM_ENTERCODE
        }else{
            let apiURL = "room_id=\(gameCodeTxt.text ?? "0")"//32957"
            self.getAPIData(apiName: "get_question_by_room_id", apiURL: apiURL,completion: {jsonObj in
            print("RS - \(jsonObj)")
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
                DispatchQueue.main.async {
                    //self.ShowAlert(title: Apps.OOPS, message:"\(jsonObj.value(forKey: "message") ?? "\(Apps.ERROR_MSG)")")                    
                    self.ShowAlertOnly(title: "", message: Apps.GAMECODE_INVALID)
                }
            }else{
                //get data for category
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{}}
                //goto Group battle View 
            }
            })
        } */ //else part end
    } //goto room button
}
