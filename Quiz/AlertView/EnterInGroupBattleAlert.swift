import UIKit
import FirebaseDatabase

class EnterInGroupBattleAlert: UIViewController, UITextFieldDelegate  {
    
    @IBOutlet weak var joinRoomBtn: UIButton!
    @IBOutlet weak var gameCodeTxt: UITextField!
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    var ref: DatabaseReference!
    var roomList:[RoomDetails] = []
    var availRooms = ["00000","11111"]
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        
        self.hideKeyboardWhenTappedAround()
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 600)
        
        joinRoomBtn.layer.cornerRadius = joinRoomBtn.frame.height / 2
        gameCodeTxt.layer.cornerRadius = gameCodeTxt.frame.height / 2
        gameCodeTxt.clipsToBounds = true
        gameCodeTxt.backgroundColor = UIColor.cyan.withAlphaComponent(0.6)
        
        bgView.layer.cornerRadius = 25
        
        ref = Database.database().reference().child("MultiplayerRoom")//(Apps.PUBLIC_ROOM_NAME)
       // checkForAvailability()
     }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0,y: textField.center.y-40), animated: true)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
    }
    func checkForAvailability(){
        ref.observeSingleEvent(of: .value, with: { (snapshot) in//ref.observe(.value, with: { (snapshot) in
             if let data = snapshot.value as? [String:Any]{//myCondition:
                print(data)
                self.roomList.removeAll()
                self.availRooms.removeAll()
                for val in data{
                    self.availRooms.append(val.key)
                }
                  if self.availRooms.contains(self.gameCodeTxt.text!){
                    print("game code found")
                    for val in data{
                        if self.gameCodeTxt.text == val.key {
                            print(val.key)
                            if let room = val.value as? [String:Any]{
                                if ("\(room["isRoomActive"] ?? "true")".bool ?? true){ //if ((room["isRoomActive"] != nil) == false){
//                                    print(room["isStarted"]!)
                                    if !("\(room["isStarted"] ?? "true")".bool ?? true){ //?? "false"
                                        if let roomUser = room["roomUser"] as? [String:Any]{
                                        self.roomList.append(RoomDetails.init(ID: "\(room["authId"]!)", roomFID: "\(self.gameCodeTxt.text ?? "0000")", userID: "\(roomUser["userID"]!)", roomName: "", catName: "", catLavel: "0", noOfPlayer: "", noOfQues: "0", playTime: ""))
                                        //continue
                                        print("true - enter in room - \(self.roomList)")
                                        self.gotoGroupBattleView()
                                        //break myCondition
                                        return//exit(0)//break
                                        }// end of roomUser If let
                                    }else{
                                        DispatchQueue.main.async {
                                            self.ShowAlert(title: Apps.GAME_CLOSED, message: "")
                                            self.CloseAlert(self)
                                            }
                                        }
                                 
                                }else{
                                print("Is room active - false")
                                DispatchQueue.main.async {
                                    self.ShowAlert(title: Apps.GAME_CLOSED, message: "")
                                    self.CloseAlert(self) 
                                    }
                                }
                          }
                        }else{
                          //  print("entered roomcode match not found")
                        }
                    }
                }else{
                    print("gameCode not found")
                    self.ShowAlert(title: Apps.GAMECODE_INVALID, message: "")
                } //if of gamecodeText
            }
        })
    }
    func gotoGroupBattleView(){
        //go to Group battle view & add yourself with group of people present there
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "GroupBattleView") as! GroupBattleView
        viewCont.isUserJoininig = true
//                                        viewCont.gameCode.text = self.gameCodeTxt.text
        viewCont.gameRoomCode = self.gameCodeTxt.text ?? "00000"
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    @IBAction func CloseAlert(_ sender: Any){
        //self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func GoToRoom(_ sender: Any) {
        //validate / check for code entered and if it is existing one then enter in group battle.
        //if gamecode exist in table and isRoomActive paramter is false..then alert msg should be GameRoom is Deactivated Or Game Already Started[Apps.GAME_CLOSED] andd close THIS alertView.& IF isRoomActive paramter is true..then go to Group Battle page with Wait For Players Text and wait for admin to start game. and add user in Joineduser tbl
        //before API - check for isRoomActive & isStarted from db.
        
        if gameCodeTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines) == ""{//gameCodeTxt.text == ""{
             gameCodeTxt.placeholder = Apps.GAMEROOM_ENTERCODE
        }else{
            checkForAvailability()
        }
        
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
