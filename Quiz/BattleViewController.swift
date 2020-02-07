import Foundation
import UIKit
import FirebaseDatabase
import GoogleMobileAds

// create battle user structer to get user's information
struct BattleUser {
    let UID:String
    let userID:String
    let name:String
    let image:String
    let matchingID:String
}
class BattleViewController: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet var user1: UIImageView!
    @IBOutlet var user2: UIImageView!
    @IBOutlet var name1: UILabel!
    @IBOutlet var name2: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet var bannerView: GADBannerView!
    
    @IBOutlet weak var battleTableView: UITableView!
    
    var ref: DatabaseReference!
    var timer:Timer!
    var seconds = 10
    
    var battleUser:BattleUser!
    var isAvail = false
    var user:User!
    
    var DataList:[BattleStatistics] = []
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ref = Database.database().reference().child("AvailUserForBattle")
       
        // Google AdMob Banner
        bannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
        bannerView.rootViewController = self
        let request = GADRequest()
        //request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        bannerView.load(request)
        
        user1.layer.cornerRadius = user1.frame.width/2
        user1.clipsToBounds = true
        
        user2.layer.cornerRadius = user2.frame.width/2
        user2.clipsToBounds = true
        
        //register nsnotification for latter call
        NotificationCenter.default.addObserver(self,selector: #selector(self.QuitBattle),name: NSNotification.Name(rawValue: "QuitBattle"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.CheckForBattle),name: NSNotification.Name(rawValue: "CheckBattle"),object: nil)
        NotificationCenter.default.addObserver(self,selector: #selector(self.CloseThisController),name: NSNotification.Name(rawValue: "CloseBattleViewController"),object: nil)
        
        self.DesignViews(views: user1,user2)
        
        user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
         self.ref.child("AvailUserForBattle").child(user.UID).removeValue()
        //set value for this user
        name1.text = user.name
        DispatchQueue.main.async {
            self.user1.loadImageUsingCache(withUrl: self.user.image)
        }
        name1.addTopBorderWithColor(color: .black, width: 2)
        name1.addBottomBorderWithColor(color: .black, width: 2)
        
        name2.addTopBorderWithColor(color: .black, width: 2)
        name2.addBottomBorderWithColor(color: .black, width: 2)
        //call function check battle
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "user_id=\(user.userID)"
            self.getAPIData(apiName: "get_battle_statistics", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
       
    }
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    //load category data here
      func LoadData(jsonObj:NSDictionary){
          print("RS",jsonObj)
        let status = Bool(jsonObj.value(forKey: "error") as! String)
        if (status!) {
              DispatchQueue.main.async {
                  self.Loader.dismiss(animated: true, completion: {
                      self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
                  })
              }
              
          }else{
              //get data for category
              DataList.removeAll()
              if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                  for val in data{
                    DataList.append(BattleStatistics.init(oppID: "\(val["opponent_id"]!)", oppName: "\(val["opponent_name"]!)", oppImage: "\(val["opponent_profile"]!)", battleStatus: "\(val["mystatus"]!)", battleDate: "\(val["date_created"]!)"))
                  }
              }
          }
          //close loader here
          DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
              DispatchQueue.main.async {
                  self.DismissLoader(loader: self.Loader)
                self.battleTableView.reloadData()
              }
          });
      }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.ref.removeAllObservers()
    }

    // function to close this controller by nsnotification
    @objc func CloseThisController(){
        self.QuitBattle()
        self.dismiss(animated: true, completion: nil)
    }
    // check for battle
    @objc func CheckForBattle(){
        
        var userDetails:[String:String] = [:]
        userDetails["userID"] = self.user.userID
        userDetails["name"] = self.user.name
        userDetails["image"] = self.user.image
        userDetails["isAvail"] = "1"
        // set data for available to battle with users in firebase database
        self.ref.child(user.UID).setValue(userDetails)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
        
         // check if user is avalable for battle
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            for fuser in (snapshot.children.allObjects as? [DataSnapshot])!{
                let data = fuser.value as? [String:String]
                if (data?["isAvail"]) != nil{
                    if((data?["isAvail"])! == "1" && fuser.key != self.user.UID){
                        // this user is avalable for battle
                        self.battleUser = BattleUser.init(UID: "\(fuser.key)", userID: "\((data?["userID"])!)", name: "\((data?["name"])!)", image: "\((data?["image"])!)",matchingID: "\(self.user.UID)")
                        self.isAvail = true
                    }
                }
            }
            if(self.isAvail){
                // if user is avalable for battle set its value for second user
                self.name2.text = self.battleUser.name
                DispatchQueue.main.async {
                    self.user2.loadImageUsingCache(withUrl: self.battleUser.image)
                }
                self.ref.child(self.battleUser.UID).child("isAvail").setValue("0")
                self.ref.child(self.battleUser.UID).child("opponentID").setValue(self.user.UID)
                self.ref.child(self.battleUser.UID).child("matchingID").setValue(self.user.UID)
                
                self.ref.child(self.user.UID).child("isAvail").setValue("0")
                self.ref.child(self.user.UID).child("opponentID").setValue(self.battleUser.UID)
                self.ref.child(self.user.UID).child("matchingID").setValue(self.user.UID)
                
                self.timer.invalidate()
                self.StartBattle()
            }else{
                // user is not avalable for battle and create computer player
                
            }
        }) { (error) in
            print(error.localizedDescription)
        }
        
        //set value when opponent select you for battle and get opponent name and image url
        ref.child(user.UID).observe(.value, with: {(snapshot) in
            
            if(snapshot.hasChild("isAvail") && snapshot.childSnapshot(forPath: "isAvail").value! as! String == "0"){
                if snapshot.hasChild("opponentID"){
                    let opponentID = snapshot.childSnapshot(forPath: "opponentID").value! as! String
                    if (opponentID != ""){
                        self.ref.child(opponentID).observeSingleEvent(of: .value, with: {(battleSnap) in
                            // this user is avalable for battle
                            self.battleUser = BattleUser.init(UID: "\(battleSnap.key)", userID: "\(battleSnap.childSnapshot(forPath: "userID").value!)", name: "\(battleSnap.childSnapshot(forPath: "name").value!)", image: "\(battleSnap.childSnapshot(forPath: "image").value!)",matchingID: "\(battleSnap.childSnapshot(forPath: "matchingID").value!)")
                            self.isAvail = true
                            self.name2.text = "\(battleSnap.childSnapshot(forPath: "name").value!)"
                            DispatchQueue.main.async {
                                self.user2.loadImageUsingCache(withUrl: "\(battleSnap.childSnapshot(forPath: "image").value!)")
                            }
                            self.StartBattle()
                        })
                    }
                }
            }else{
                self.name2.text = Apps.ROBOT
                self.user2.image = UIImage(named: "robot")
                self.isAvail = false
            }
        })
    }
    //call this function when user gone or exist from battle
    @objc func QuitBattle(){
        if timer != nil && timer.isValid{
            timer.invalidate()
        }
        // remove user data from firebase database
        self.ref.child(self.user.UID).removeValue()
        self.ref.removeAllObservers()
//        if isAvail{
//            self.ref.child(self.battleUser.UID).child("isAvail").setValue("1")
//            self.ref.child(self.battleUser.UID).child("opponentID").setValue("")
//        }
    }
    
    @objc func incrementCount() {
        let html = """
<html>
<body>
<span style="color: #ff6600;font-size: 40px;">\(String(format: "%02d", seconds))</span><span style="color: #ff9900;font-size: 20px;">sec</span>
</body>
</html>
"""
        let data = Data(html.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
           timerLabel.attributedText = attributedString
        }
        seconds -= 1
        if seconds < 0 {
            // invalidate timer and no user is avalable for battle
            timer.invalidate()
            self.seconds = 10
            self.ShowRobotAlert()
        }
    }
    
    // set Custom Design function
    func DesignViews(views:UIView...){
        for view in views{
            view.layer.borderWidth = 2
            view.layer.borderColor = UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0).cgColor
            view.SetShadow()
            view.layer.cornerRadius = 10
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        if timer != nil{
            let alert = UIAlertController(title: "", message: "Are you sure , You want to leave ?", preferredStyle: UIAlertController.Style.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "No", style: UIAlertAction.Style.default, handler: nil))
            alert.addAction(UIAlertAction(title: "Yes", style: UIAlertAction.Style.destructive, handler: { action in
                self.QuitBattle()
                self.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            alert.view.tintColor = UIColor.red //alert Action font color changes to red
        }else{
            self.QuitBattle()
            self.dismiss(animated: true, completion: nil)
        }        
    }
    
    @IBAction func CheckBattleButton(_ sender:Any){
         self.CheckForBattle()
    }
    //start battle and pass data to battleplaycontroller
    func StartBattle(){
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let bpc: BattlePlayController = storyBoard.instantiateViewController(withIdentifier: "BattlePlayController") as! BattlePlayController
        bpc.battleUser = self.battleUser
        self.present(bpc, animated: true, completion: nil)
    }
    
    //Show robot alert view to ask user play with robot or try again
    func ShowRobotAlert(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let alert = storyboard.instantiateViewController(withIdentifier: "RobotAlert") as! RobotAlert
        alert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        alert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        alert.imageUrl = user.image
        alert.parentController = self
        self.present(alert, animated: true, completion: nil)
    }
}

extension BattleViewController: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if DataList.count == 0{
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = ""//Apps.STATISTICS_NOT_AVAIL
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return self.DataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = "BattleStatisticsCell"
        
        guard let cell = self.battleTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BattleStatisticsCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        let data = DataList[indexPath.row]
        if !(user.image.isEmpty){
            DispatchQueue.main.async {
                cell.userImage.loadImageUsingCache(withUrl: self.user.image)
            }
        }
        cell.userName.text = user.name
        
        if !data.oppImage.isEmpty{
            DispatchQueue.main.async {
                cell.opponentImage.loadImageUsingCache(withUrl: data.oppImage)
            }
        }
        cell.opponentName.text = data.oppName
        
        cell.matchStatusLabel.text = data.battleStatus
        
        return cell
    }
    
    
    
}
