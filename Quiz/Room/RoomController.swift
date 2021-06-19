import UIKit
import AVFoundation
import FirebaseDatabase

class RoomController: UIViewController, LPKSearchTextFieldDelegate, UITextFieldDelegate {

    @IBOutlet weak var roomSegment: LPKSegmentedControl!
    @IBOutlet weak var roomNameField:UITextField!
    @IBOutlet weak var orLabel:UILabel!
    @IBOutlet weak var nooffQsnViewLabel:UILabel!
    @IBOutlet weak var categoryTextField: LPKSearchTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var createRoomBtn: UIButton!
    @IBOutlet weak var joinRoomBtn: UIButton!
    @IBOutlet weak var noOffQsnTextField: LPKSearchTextField!
    @IBOutlet weak var timerTextField: UITextField!
    @IBOutlet weak var noOffPlayerField:UITextField!
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var categoryView:UIView!
    @IBOutlet weak var otherView:UIView!
    @IBOutlet weak var playerView:UIView!
    @IBOutlet weak var orLabelView:UIView!
    
    @IBOutlet weak var topView:UIView!
    
    var catData:[Category] = []
    var catFields:[LPKSearchTextField] = []
    var catFieldData:[[Category]] = []
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var ref: DatabaseReference!
    
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        self.topView.addBottomBorderWithColor(color: .lightGray, width: 1.2)
        self.nooffQsnViewLabel.isHidden = true
        
        self.pickerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 180)
       // roomNameField.addBottomBorderWithColor(color: Apps.COLOR_DARK_RED, width: 1)
        roomNameField.layer.cornerRadius = 10
        roomNameField.PaddingLeft(10)
        roomNameField.attributedPlaceholder = NSAttributedString(string: "Oda Adi Girin",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        let rect = CGRect(origin: roomSegment.frame.origin, size: CGSize(width: roomSegment.frame.size.width, height: 50))
        roomSegment.frame = rect
        //roomLabel.layer.addBorder(edge: .none, color: Apps.COLOR_DARK_RED, thickness: 1)
        
        noOffPlayerField.attributedPlaceholder = NSAttributedString(string: "0",
                                                                    attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        noOffPlayerField.inputView = self.pickerView
        noOffPlayerField.AddAccessoryView()
        
        orLabelView.addCenterBorderWithColor(color: Apps.BASIC_COLOR, width: 1)
        
        let font = UIFont.systemFont(ofSize: 20)
        let normalText = [NSAttributedString.Key.foregroundColor: UIColor.lightGray,NSAttributedString.Key.font:font]
        let selected = [NSAttributedString.Key.foregroundColor: Apps.BASIC_COLOR]
        roomSegment.setTitleTextAttributes(normalText, for: .normal)
        roomSegment.setTitleTextAttributes(selected, for: .selected)
        
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.createRoomBtn.frame.maxY + 20)
        mainView.frame = CGRect(x: self.mainView.frame.origin.x, y: self.mainView.frame.origin.y, width: self.mainView.frame.width, height: 1150)
        
        categoryTextField.attributedPlaceholder = NSAttributedString(string: Apps.SELECT_CATGORY, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        noOffQsnTextField.attributedPlaceholder = NSAttributedString(string: Apps.NO_OFF_QSN, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        timerTextField.attributedPlaceholder = NSAttributedString(string: Apps.TIMER, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        
        self.noOffPlayerField.bottomBorderWithColor(color: .lightGray, width: 1)
        self.playerView.layer.cornerRadius = 10
        self.createRoomBtn.layer.cornerRadius = 10
        self.joinRoomBtn.layer.cornerRadius = 10
        
        //self.orLabelView.layer.addBorder(edge: .none, color: Apps.COLOR_DARK_RED, thickness: 1)
        self.orLabelView.bringSubviewToFront(self.orLabel)
        
        self.InitTextField(fields: categoryTextField)
        self.InitTextField(fields: timerTextField)
        
        self.noOffQsnTextField.bordredTextfield(textField: self.noOffQsnTextField)
        self.noOffQsnTextField.PaddingLeft(10)
        self.noOffQsnTextField.delegate = self
        self.noOffQsnTextField.tag = 0
       // self.noOffQsnTextField.addTarget(self, action: #selector(self.ValidateField), for: .editingChanged)
        self.noOffQsnTextField.LPKSearchdelegate = self
        self.noOffQsnTextField.layer.cornerRadius = 10
        self.noOffQsnTextField.layer.borderColor = UIColor.white.cgColor
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "visible_in=both"
            self.getAPIData(apiName: "get_categories", apiURL: apiURL,completion: LoadData)
            
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func InitTextField(fields:LPKSearchTextField...){
        for field in fields{
            field.bordredTextfield(textField: field)
            field.PaddingLeft(10)
            field.LPKSearchdelegate = self
            field.inputView = UIView()
            field.isFilter = false
            field.layer.cornerRadius = 10
            field.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func InitTextField(fields:UITextField...){
        for field in fields{
            field.bordredTextfield(textField: field)
            field.PaddingLeft(10)
            field.layer.cornerRadius = 10
            field.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    @objc func ValidateField(textfield:UITextField){
       
        if let text = Int(textfield.text!){
            if text <= textfield.tag && text >= 5{
              //  print("Yes you can do this")
            }else{
                textfield.text = "0"
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = "\(jsonObj.value(forKey: "error")!)".bool ?? true
        if (status) {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
            
        }else{
            //get data for category
            catData.removeAll()
            var searchData:[SearchData] = []
            
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                let levelName = jsonObj.value(forKey: "level_name") as! String
                let apiNameID = self.NameValue(name: levelName)
                for val in data{
//                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val[apiNameID.nameValue]!)", image: "\(val["image"]!)", noOffQues: "\(val["no_of_que"]!)", isPaid: "\(val["is_paid"] ?? false)".bool!, lang_id: "\(val["language_id"]!)", isLevelExist: "\(val["level_exist"]!)".bool!, time: "\(val["time"]!)", visible: "\(val["visible_in"] ?? "")", levelName: levelName,isRandom: "\(val["is_random"] ?? false)".bool!,quesLimit:"\(val["que_limit"] ?? "0")"))
                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
                    searchData.append(SearchData.init(id: "\(val["id"]!)", name: "\(val[apiNameID.nameValue]!)"))
                }
            }
            //close loader here
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                DispatchQueue.main.async {
                    self.DismissLoader(loader: self.Loader)
                    self.catData.sort { (obj1, obj2) -> Bool in
                        return Int(obj1.noOfQues)! > Int(obj2.noOfQues)!
                    }
                    
                    let datas = self.catData.flatMap({ $0.id })
                    self.categoryTextField.addData(data: searchData)
                }
            });
        }
    }
    
    //load category data here
    func LoadDataCat(jsonObj:NSDictionary){
       // print("RS",jsonObj)
        let status = "\(jsonObj.value(forKey: "error")!)".bool ?? true
        if (status) {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
            
        }else{
            //get data for category
            var subCatData:[Category] = []
            var searchData:[SearchData] = []
            
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                let levelName = jsonObj.value(forKey: "level_name") as! String
                let apiNameID = self.NameValue(name: levelName)
                for val in data{
                    if "\(val["is_random"] ?? false)".bool!{
                        continue
                    }
//                    subCatData.append(Category.init(id: "\(val["id"]!)", name: "\(val[apiNameID.nameValue]!)", image: "\(val["image"]!)", noOffQues: "\(val["no_of_que"]!)", isPaid: "\(val["is_paid"] ?? false)".bool!, lang_id: "\(val["language_id"]!)", isLevelExist: "\(val["level_exist"]!)".bool!, time: "\(val["time"]!)", visible: "\(val["visible_in"] ?? "")", levelName: levelName,isRandom: "\(val["is_random"] ?? false)".bool!,quesLimit:"\(val["que_limit"] ?? "0")" ))
                    subCatData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
                    
                    searchData.append(SearchData.init(id: "\(val["id"]!)", name: "\(val[apiNameID.nameValue]!)"))
                }
                
                if subCatData.count > 0{
                    self.catFieldData.append(subCatData)
                }else{
                   
                }
            }
            //close loader here
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                DispatchQueue.main.async {
                    self.DismissLoader(loader: self.Loader)
//                    subCatData.sort { (obj1, obj2) -> Bool in
//                        return Int(obj1.noOffQues)! > Int(obj2.noOffQues)!
//                    }
                    if subCatData.count > 0{
                        self.addCatField()
                        self.catFields.last!.LPKSearchdelegate = self
                        self.catFields.last!.addData(data: searchData)
                      
                        
                    }else{
                        self.nooffQsnViewLabel.isHidden = false
                       // self.questionView.isHidden = false
                    }
                    
                }
            });
        }
    }
    
    //search textfield delegate
    func OnSelect(textField: UITextField, selectedData: SearchData) {
        //print("SELECTED",selectedData.id,selectedData.name)
        
        switch textField {
        case self.categoryTextField:
           /* if self.catData.first(where: {$0.id == selectedData.id})!.isLevelExist{
                if(Reachability.isConnectedToNetwork()){
                    Loader = LoadLoader(loader: Loader)
                    self.clearCatField()
                    // let apiParam = self.GetAPIParam(name: "level\(self.catFields.count+1)")
                    let apiParam = self.GetAPIParam(name: "category")
                    let apiURL = "\(apiParam.ParamID)=\(selectedData.id)"
                    self.getAPIData(apiName: apiParam.Name, apiURL: apiURL,completion: LoadDataCat)
                }else{
                    ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
                }
            }else{
               
            } */
            break
        case self.noOffQsnTextField:
            break
        case self.timerTextField:
            break
        default:

            let index = self.catFields.index(of: self.catFields.first(where: {$0 == textField})!)
            if index! < self.catFields.count - 1{
                for i in stride(from: self.catFields.count - 1, to: index!, by: -1) {
                    self.catFieldData.remove(at: i)
                    self.catFields[i].removeFromSuperview()
                    self.catFields.remove(at: i)
                    resetView()
                }
            }
          
            if  let data = self.catFieldData[index!].first(where: {$0.id == selectedData.id}){
                if let noOfQues = Int(data.noOfQues){
                    self.noOffQsnTextField.tag = noOfQues
                    self.nooffQsnViewLabel.text = "En fazla \(noOfQues) soru sınırı seçin"
                }
                
               /* if !data.isLevelExist{
                    return
                }*/
            }
            
            if(Reachability.isConnectedToNetwork()){
                Loader = LoadLoader(loader: Loader)
                let apiParam = self.GetAPIParam(name: "level\(self.catFields.count)")
                // let apiParam = self.GetAPIParam(name: "category")
                let apiURL = "\(apiParam.ParamID)=\(selectedData.id)"
                self.getAPIData(apiName: apiParam.Name, apiURL: apiURL,completion: LoadDataCat)
            }else{
                ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
            }
            break
        }
    }
    
    func addCatField(){
        let newFrame = self.categoryTextField.frame
        
        let field = LPKSearchTextField(frame: CGRect(x: newFrame.origin.x, y: newFrame.height + 10, width: newFrame.width, height: newFrame.height))
        field.bordredTextfield(textField: field)
        field.textColor = Apps.BASIC_COLOR
        field.PaddingLeft(10)
        field.font = self.categoryTextField.font
        field.attributedPlaceholder = NSAttributedString(string: Apps.SELECT_CATGORY, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.categoryView.addSubview(field)
        field.LPKSearchdelegate = self
        field.inputView = UIView()
        field.isFilter = false
        self.InitTextField(fields: field)
       // field.addData(data: [SearchData.init(id: "1", name: "ABC"),SearchData.init(id: "2", name: "CAT A"),SearchData.init(id: "3", name: "XYZ")])
        
        self.catFields.append(field)
        resetView()
    }
    
    func clearCatField(){
        for field in self.catFields{
            field.removeFromSuperview()
        }
        self.catFields.removeAll()
        self.catFieldData.removeAll()
        self.nooffQsnViewLabel.isHidden = true
      //  self.questionView.isHidden = true
        resetView()
    }
    
    func resetView(){
        
        let newFrame = self.categoryTextField.frame
        var y:CGFloat = 5
        let height:CGFloat = 60
        for field in self.catFields{
            y += height
            field.frame = CGRect(x: newFrame.origin.x, y: CGFloat(y), width: newFrame.width, height: newFrame.height)
        }
        
        self.categoryView.frame = CGRect(x: self.categoryView.frame.origin.x, y: self.categoryView.frame.origin.y, width: self.categoryView.frame.width, height: y + 65)
        self.otherView.frame = CGRect(x: self.otherView.frame.origin.x, y: self.categoryView.frame.height + self.categoryView.frame.origin.y, width: self.otherView.frame.width, height: self.otherView.frame.height)
        
      //  self.createRoomBtn.frame = CGRect(x: self.createRoomBtn.frame.origin.x, y: self.otherView.frame.origin.y + self.otherView.frame.height, width: self.createRoomBtn.frame.width, height: self.createRoomBtn.frame.height)
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.categoryView.frame.height + self.otherView.frame.height + 100)
        mainView.frame = CGRect(x: self.mainView.frame.origin.x, y: self.mainView.frame.origin.y, width: self.mainView.frame.width, height: self.categoryView.frame.height + self.otherView.frame.height + 100)
    }
}

extension RoomController{
    
    @IBAction func CreateRoomAction(_ sender: Any) {
        if self.roomNameField.text!.isEmpty{
            self.ShowAlert(title: "Uyarı", message: "Oda adı boş olamaz")
            return
        }
        
        if self.noOffQsnTextField.text!.isEmpty{
            self.ShowAlert(title: "Uyarı", message: "Soruların hiçbiri seçilmemelidir")
            return
        }
        
        if self.timerTextField.text!.isEmpty{
            self.ShowAlert(title: "Uyarı", message: "Zaman seçilmelidir")
            return
        }
        
        if self.noOffPlayerField.text!.isEmpty{
            self.ShowAlert(title: "Uyarı", message: "Hiçbir oyuncu boş olamaz")
            return
        }
        
        if let text = Int(self.noOffQsnTextField.text!){
            if text <= 0{
                self.ShowAlert(title: "Uyarı", message: "Soru Sayısı Sıfır Olamaz")
                return
            }
        }
        if let text = Int(self.noOffQsnTextField.text!){
            if text > self.noOffQsnTextField.tag{
                self.ShowAlert(title: "Uyarı", message: "En fazla \(self.noOffQsnTextField.tag) soru sınırı seçin")
                return
            }
        }
        
        if self.roomSegment.selectedSegmentIndex == 0{
            // private room
            self.CreatePrivateRoom()
        }else if self.roomSegment.selectedSegmentIndex == 1{
          // public room
            self.CreatePublicRoom()
        }
    }
    
    @IBAction func JoinRoomAction(_ sender: Any) {
        self.PlaySound(player: &self.audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "PublicRoomListView") as! PublicRoomListView
        
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
    func CreatePrivateRoom(){
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if let userDT = UserDefaults.standard.value(forKey:"user"){
           
                let user = try! PropertyListDecoder().decode(User.self, from: (userDT as? Data)!)
                var userDetails:[String:String] = [:]
                // userDetails["UID"] = user.UID
                userDetails["userID"] = user.userID
                userDetails["name"] = user.name
                userDetails["image"] = user.image
                
                let gameRoomCode = randomNumberForBattle()                
                var roomDetails = RoomDetails.init(ID: "", roomFID: gameRoomCode, userID: user.userID, roomName: "", catName: "\(self.catFields.last!.selectedData!.name)", catLavel: "\(self.catFields.count + 1)", noOfPlayer: "\(self.noOffPlayerField.text!)", noOfQues: "\(self.noOffQsnTextField.text!)", playTime: "\(self.timerTextField.text!)")
                
                //var roomDetails = RoomDetails.init(ID: "", roomFID: user.UID, userID: user.userID, roomName: "\(self.roomNameField.text!)", catName: "\(self.catFields.last!.selectedData!.name)", catLavel: "\(self.catFields.count + 1)", noOfPlayer: "\(self.noOffPlayerField.text!)", noOfQues: "\(self.noOffQsnTextField.text!)", playTime: "\(self.timerTextField.text!)")
                /*
                        user_id:1
                        room_id:1
                        room_type:public / private
                        language_id:2   //{optional}
                        category:1      // required if room category enable form panel
                        no_of_que:10
                 
                 */
                
                
                let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME)
                roomDetails.ID = refR.childByAutoId().key!
                
                var fireRoom:[String:Any] = [:]
                fireRoom["roomName"] = roomDetails.roomName
                fireRoom["category"] = roomDetails.catName
                fireRoom["catLevel"] = roomDetails.catLavel
                fireRoom["noOfPlayer"] = roomDetails.noOfPlayer
                fireRoom["noOfQuestion"] = roomDetails.noOfQues
                fireRoom["roomID"] = roomDetails.ID
                fireRoom["time"] = roomDetails.playTime
                fireRoom["roomUser"] = ["image":user.image,"name":user.name,"userID":user.userID]
                fireRoom["isRoomActive"] = "true"
                fireRoom["isStarted"] = "false"
                
                Loader = LoadLoader(loader: Loader)
                
                refR.child(user.UID).setValue(fireRoom)
                refR.child(user.UID).child("roomUser").setValue(userDetails,withCompletionBlock: {(error,snapshote) in
                    if error != nil{
                        print("Error")
                        return
                    }
                })
                
                /*
                        user_id:1
                        room_id:1
                        language_id:2   //{optional}
                        category:1      // required if room category enable form panel
                        no_of_que:10
                 */
                
                if(Reachability.isConnectedToNetwork()){
                    let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                    //let levelName = self.catFields.count == 0 ? "category" : "level\(self.catFields.count)"
                    let gameRoomCode = randomNumberForBattle()
                    var apiURL = ""
                    if Apps.GROUP_BATTLE_WITH_CATEGORY == "1" {
                        apiURL = "user_id=\(user.userID)&room_id=\(gameRoomCode)&room_type=private&category=\(self.categoryTextField.selectedData!.id)&no_of_que=\(roomDetails.noOfQues)"
                    }else{
                        apiURL = "user_id=\(user.userID)&room_id=\(gameRoomCode)&room_type=private&category=&no_of_que=\(roomDetails.noOfQues)"
                    }
                    
                    
                 //   apiURL = "user_id=\(user.userID)&room_id=\(user.UID)&room_type=private&category_id=\(self.categoryTextField.selectedData!.id)&no_of_que=\(roomDetails.noOfQues)&level_name=\(levelName)&level_id=\(self.catFields.last!.selectedData!.id)"
                    
                    self.getAPIData(apiName: "create_room", apiURL: apiURL,completion: {jsonObj in
                        //print("JSON",jsonObj)
                        let status = "\(jsonObj.value(forKey: "error")!)".bool ?? true
                        if (status) {
                            self.ShowAlert(title: "Error", message: "\(jsonObj.value(forKey: "message")!)")
                            return
                        }else{
                            
                            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: {
                                DispatchQueue.main.async {
                                    self.DismissLoader(loader: self.Loader)
                                    
                                    self.PlaySound(player: &self.audioPlayer, file: "click") // play sound
                                    self.Vibrate() // make device vibrate
                                    
                                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                                    let viewCont = storyboard.instantiateViewController(withIdentifier: "PrivateRoomView") as! PrivateRoomView
                                    
                                    viewCont.roomInfo = roomDetails
                                    
                                    self.navigationController?.pushViewController(viewCont, animated: true)
                                }
                            })
                           
                        }
                    })
                    
                }else{
                    ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
                }
                
            }
        }
    }
    
    func CreatePublicRoom(){
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if let userDT = UserDefaults.standard.value(forKey:"user"){
                let user = try! PropertyListDecoder().decode(User.self, from: (userDT as? Data)!)
                var userDetails:[String:String] = [:]
                // userDetails["UID"] = user.UID
                userDetails["userID"] = user.userID
                userDetails["name"] = user.name
                userDetails["image"] = user.image
                
                var roomDetails = RoomDetails.init(ID: "", roomFID: user.UID, userID: user.userID, roomName: "\(self.roomNameField.text!)", catName: "\(self.catFields.last!.selectedData!.name)", catLavel: "\(self.catFields.count + 1)", noOfPlayer: "\(self.noOffPlayerField.text!)", noOfQues: "\(self.noOffQsnTextField.text!)", playTime: "\(self.timerTextField.text!)")
                
                let refR = Database.database().reference().child(Apps.PUBLIC_ROOM_NAME)
                roomDetails.ID = refR.childByAutoId().key!
                
                var fireRoom:[String:Any] = [:]
                fireRoom["roomName"] = roomDetails.roomName
                fireRoom["category"] = roomDetails.catName
                fireRoom["catLevel"] = roomDetails.catLavel
                fireRoom["noOfPlayer"] = roomDetails.noOfPlayer
                fireRoom["noOfQuestion"] = roomDetails.noOfQues
                fireRoom["roomID"] = roomDetails.ID
                fireRoom["time"] = roomDetails.playTime
                fireRoom["roomUser"] = ["image":user.image,"name":user.name,"userID":user.userID]
                fireRoom["isRoomActive"] = "true"
                fireRoom["isStarted"] = "false"
                
                Loader = LoadLoader(loader: Loader)
                
                refR.child(user.UID).setValue(fireRoom)
                refR.child(user.UID).child("roomUser").setValue(userDetails,withCompletionBlock: {(error,snapshote) in
                    if error != nil{
                        print("Error")
                        return
                    }
                })
                
                if(Reachability.isConnectedToNetwork()){
                    let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                    let levelName = self.catFields.count == 0 ? "category" : "level\(self.catFields.count)"
                    let apiURL = "user_id=\(user.userID)&room_id=\(roomDetails.ID)&room_type=public&category_id=\(self.categoryTextField.selectedData!.id)&no_of_que=\(roomDetails.noOfQues)&level_name=\(levelName)&level_id=\(self.catFields.last!.selectedData!.id)"
                    self.getAPIData(apiName: "create_room", apiURL: apiURL,completion: {jsonObj in
                       // print("JSON",jsonObj)
                        let status = "\(jsonObj.value(forKey: "error")!)".bool ?? true
                        if (status) {
                            self.ShowAlert(title: "Error", message: "\(jsonObj.value(forKey: "message")!)")
                            return
                        }else{
                            
                            DispatchQueue.global().asyncAfter(deadline: .now() + 0.3, execute: {
                                DispatchQueue.main.async {
                                    self.DismissLoader(loader: self.Loader)
                                    
                                    self.PlaySound(player: &self.audioPlayer, file: "click") // play sound
                                    self.Vibrate() // make device vibrate
                                    
                                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                                    let viewCont = storyboard.instantiateViewController(withIdentifier: "PublicRoomView") as! PublicRoomView
                    
                                    viewCont.roomInfo = roomDetails
                                    
                                    self.navigationController?.pushViewController(viewCont, animated: true)
                                }
                            })
                        }
                    })
                    
                }else{
                    ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
                }
            }
        }
    }
}
class LPKSegmentedControl: UISegmentedControl{
    private let segmentInset: CGFloat = 5       //your inset amount
    private let segmentImage: UIImage? = UIImage(color: UIColor.white)    //your color

    override func layoutSubviews(){
        super.layoutSubviews()

        //background
        layer.cornerRadius = bounds.height/2
        //foreground
        let foregroundIndex = numberOfSegments
        if subviews.indices.contains(foregroundIndex), let foregroundImageView = subviews[foregroundIndex] as? UIImageView
        {
            foregroundImageView.bounds = foregroundImageView.bounds.insetBy(dx: segmentInset, dy: segmentInset)
            foregroundImageView.image = segmentImage    //substitute with our own colored image
            foregroundImageView.layer.removeAnimation(forKey: "SelectionBounds")    //this removes the weird scaling animation!
            foregroundImageView.layer.masksToBounds = true
            foregroundImageView.layer.cornerRadius = foregroundImageView.bounds.height/2
        }
    }
}

extension UIImage{
    
    //creates a UIImage given a UIColor
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension RoomController:UIPickerViewDataSource,UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row+2)"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.noOffPlayerField.text = "\(row+2)"
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
