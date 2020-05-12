import UIKit

struct Leader{
    let rank:String
    let name:String
    let image:String
    let score:String
    let userID:String
}

class Leaderboard: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
     @IBOutlet var tableView: UITableView!
    
     @IBOutlet var selectionOptView: UIView!
    
     @IBOutlet var usr1: UIImageView!
     @IBOutlet var usr2: UIImageView!
     @IBOutlet var usr3: UIImageView!
    
    @IBOutlet var usr1Lbl: UILabel!
    @IBOutlet var usr2Lbl: UILabel!
    @IBOutlet var usr3Lbl: UILabel!
    
    @IBOutlet var score1Lbl: UILabel!
    @IBOutlet var score2Lbl: UILabel!
    @IBOutlet var score3Lbl: UILabel!
    
    @IBOutlet weak var user2View: UIView!
    @IBOutlet weak var user1View: UIView!
    @IBOutlet weak var user3View: UIView!
    
    @IBOutlet weak var buttonAll: UIButton!
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var LeaderData:[Leader] = []
    var thisUser:User!
    var ttlCount = 0
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        usr1.layer.cornerRadius = usr1.frame.height/2
        usr2.layer.cornerRadius = usr2.frame.height/2
        usr3.layer.cornerRadius = usr3.frame.height/2
                
        thisUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print(thisUser)
        
        getLeaders(sel: "All")//get data from server
    }
    
    //get data from server
    func getLeaders(sel : String){
       if(Reachability.isConnectedToNetwork()){
          let dateFormatterGet = DateFormatter()
          dateFormatterGet.dateFormat = "yyyy-MM-dd"
          Loader = LoadLoader(loader: Loader)
        //chk for selection from dropdown
                 if (sel == "Daily") { //daily
                    let apiURL = "from=\(dateFormatterGet.string(from: Date()))&to=\(dateFormatterGet.string(from: Date()))"
                      print(apiURL)
                      self.getAPIData(apiName: "get_datewise_leaderboard", apiURL: apiURL,completion: LoadData)
                }
                if (sel == "Monthly"){ //monthly
                    
                        var apiURL = "date=\(dateFormatterGet.string(from: Date().startOfMonth()))"
                        if offset < ttlCount {
                            apiURL += "&offset=\(offset)" //+1
                        }
                        self.getAPIData(apiName: "get_monthly_leaderboard", apiURL: apiURL,completion: LoadData)
                }
                if(sel == "All"){ //all
                     var apiURL = ""
                     if offset < ttlCount {
                         apiURL = "offset=\(offset)" //+1
                    }
                    self.getAPIData(apiName: "get_global_leaderboard", apiURL: apiURL,completion: LoadData)
                }
           }
       else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
           }
    }
    
    @IBAction func showLeaderboardOptions(_ sender: UIButton) {
        if selectionOptView.superview != nil {
            animateOut()
        }else {
            animateIn()            
        }
     }
    func animateIn(){ //for Selection Opt view
                self.view.addSubview(selectionOptView)
                var pos: CGRect = selectionOptView.frame
                pos.origin.x = buttonAll.frame.minX + 5
             //   pos.origin.x = 250
                pos.origin.y = 80
                self.selectionOptView.frame = pos
            //border to selectionOption View
            let externalBorder = CALayer()
            externalBorder.frame = CGRect(x: -1, y: -1, width: selectionOptView.frame.size.width+2, height: selectionOptView.frame.size.height+2)
            externalBorder.borderColor = UIColor.black.cgColor
            externalBorder.borderWidth = 1.0
            selectionOptView.layer.addSublayer(externalBorder)
            selectionOptView.layer.masksToBounds = false
    }
        
            func animateOut(){ //for selectionOptView view
                    self.selectionOptView.removeFromSuperview()
            }
    
    @IBAction func showAll(_ sender: UIButton) {
        animateOut()
        if let buttonTitle = sender.title(for: .normal) {
        //used "trimmed" variable instead of "buttonTitle" as buttonTitle have whitespace after All for positioning in design view so we have to remove it here
        let name: String = buttonTitle
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            //print("\(trimmed)trimmedALL")
        LeaderData.removeAll()//clear previous data
        offset = 0 //reset offset value
        getLeaders(sel: trimmed)
        buttonAll.setTitle(buttonTitle, for: .normal)
        }
    }
    @IBAction func showMonthly(_ sender: UIButton) {
        animateOut()
        if let buttonTitle = sender.title(for: .normal) {
            LeaderData.removeAll()//clear previous data
            offset = 0 //reset offset value
            getLeaders(sel: buttonTitle)
            buttonAll.setTitle(buttonTitle, for: .normal)
        }
    }
    @IBAction func showDaily(_ sender: UIButton) {
        animateOut()
        if let buttonTitle = sender.title(for: .normal) {
            LeaderData.removeAll()//clear previous data
            offset = 0 //reset offset value
            getLeaders(sel: buttonTitle)
            buttonAll.setTitle(buttonTitle, for: .normal)
        }
    }
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        print(status)
        if (status == "true") {
              DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    print("Data Not Found !!!")
                    //print(jsonObj.value(forKey: "status")!)
                    if jsonObj.value(forKey: "message")! == nil {
                        self.ShowAlert(title: "Error", message:"Data Not Found !!!" )
                    }else{
                        self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
                    }
                })
            }            
        }else{
            let strCount: String = jsonObj.value(forKey: "total") as! String //returns total count of records from response
            ttlCount = Int(strCount)! //total number of records according to filter
           
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                      LeaderData.append(Leader.init(rank: "\(val["rank"]!)", name: "\(val["name"]!)", image: "\(val["profile"]!)", score: "\(val["score"]!)", userID: "\(val["user_id"]!)"))
                   }
                offset += data.count //updated every time
                print(offset)
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                //set top 3 rank data here
                
               // print("total count is -> \(self.LeaderData.count)")
                if self.LeaderData.count < 1 {
                    self.ShowAlert(title: "No Data", message: "No data avalable to show !")
                    return
                }
                //hide views if in Daily leaderboard just contain 1 or 2 entries, otherwise show all data in default case.
                switch self.LeaderData.count{
                case 1:
                        if(!self.LeaderData[0].image.isEmpty){
                            self.usr2.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                        }
                        if (!self.LeaderData[0].name.isEmpty) && (!self.LeaderData[0].score.isEmpty) {
                                self.usr2Lbl.text = "\(self.LeaderData[0].name)"
                                self.score2Lbl.text = "\(self.LeaderData[0].score)"
                           }
                           else{
                                self.user1View.isHidden = true
                           }
                        //if there is no other users data there then just hide that view.!
                            self.user2View.isHidden = true
                            self.user3View.isHidden = true
               case 2:
                        //user 1
                        if(!self.LeaderData[1].image.isEmpty){
                          self.usr1.loadImageUsingCache(withUrl: self.LeaderData[1].image)
                        }
                        if (!self.LeaderData[1].name.isEmpty) && (!self.LeaderData[1].score.isEmpty) {
                                self.usr1Lbl.text = "\(self.LeaderData[1].name)"
                                self.score1Lbl.text = "\(self.LeaderData[1].score)"
                            if self.user2View.isHidden == true{
                                self.user2View.isHidden = false
                            }
                           }
                           else{
                              self.user2View.isHidden = true
                           }
                        //user 2
                        if(!self.LeaderData[0].image.isEmpty){
                            self.usr2.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                         }
                        if (!self.LeaderData[0].name.isEmpty) && (!self.LeaderData[0].score.isEmpty) {
                             self.usr2Lbl.text = "\(self.LeaderData[0].name)"
                             self.score2Lbl.text = "\(self.LeaderData[0].score)"
                            if self.user1View.isHidden == true{
                                self.user1View.isHidden = false
                            }
                        }
                        else{
                            self.user1View.isHidden = true
                        }
                        //if there is no other users data there then just hide that view.!
                        self.user3View.isHidden = true
             case 3:
                        //user 1
                        if(!self.LeaderData[1].image.isEmpty){
                            self.usr1.loadImageUsingCache(withUrl: self.LeaderData[1].image)
                        }
                        if (!self.LeaderData[1].name.isEmpty) && (!self.LeaderData[1].score.isEmpty) {
                                self.usr1Lbl.text = "\(self.LeaderData[1].name)"
                                self.score1Lbl.text = "\(self.LeaderData[1].score)"
                            if self.user2View.isHidden == true{
                                self.user2View.isHidden = false
                            }
                           }else{
                              self.user2View.isHidden = true
                           }
                        //user 2
                        if(!self.LeaderData[0].image.isEmpty){
                            self.usr2.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                         }
                        if (!self.LeaderData[0].name.isEmpty) && (!self.LeaderData[0].score.isEmpty) {
                             self.usr2Lbl.text = "\(self.LeaderData[0].name)"
                             self.score2Lbl.text = "\(self.LeaderData[0].score)"
                            if self.user1View.isHidden == true{
                                self.user1View.isHidden = false
                            }
                        } else{
                            self.user1View.isHidden = true
                        }
                        //user 3
                        if(!self.LeaderData[2].image.isEmpty){
                            self.usr3.loadImageUsingCache(withUrl: self.LeaderData[2].image)
                           }
                        if (!self.LeaderData[2].name.isEmpty) && (!self.LeaderData[2].score.isEmpty) {
                             self.usr3Lbl.text = "\(self.LeaderData[2].name)"
                             self.score3Lbl.text = "\(self.LeaderData[2].score)"
                            if self.user3View.isHidden == true{
                                self.user3View.isHidden = false
                            }
                        }
                        else{
                            self.user3View.isHidden = true
                        }
            default:
                    //executed if LeaderData get more than 3 records
                   self.showALLinLeaderboard()
                }
                
                self.DesignImageView(self.usr1,self.usr2,self.usr3)
                //reload data after getting it from server
                self.tableView.reloadData()
                               
                //set bottom view in every case
                    self.AddUsertoBottom()
            }
        });
    }
    func showALLinLeaderboard() {
        
              if(!self.LeaderData[1].image.isEmpty){
                  self.usr1.loadImageUsingCache(withUrl: self.LeaderData[1].image)
                  }
              if(!self.LeaderData[0].image.isEmpty){
                  self.usr2.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                 }
              if(!self.LeaderData[2].image.isEmpty){
                  self.usr3.loadImageUsingCache(withUrl: self.LeaderData[2].image)
              }
        
                self.usr1Lbl.text = "\(self.LeaderData[1].name)"
                self.usr2Lbl.text = "\(self.LeaderData[0].name)"
                self.usr3Lbl.text = "\(self.LeaderData[2].name)"

                self.score1Lbl.text = "\(self.LeaderData[1].score)"
                self.score2Lbl.text = "\(self.LeaderData[0].score)"
                self.score3Lbl.text = "\(self.LeaderData[2].score)"
        
                //show all 3 views incase hidden in previous cases
                self.user2View.isHidden = false
                self.user1View.isHidden = false
                self.user3View.isHidden = false
          }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return ttlCount - 3
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = "boardCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        let rowIndex = indexPath.row + 3
       
        if rowIndex > (LeaderData.count - 3) && offset < ttlCount {
           var nm = buttonAll.title(for: .normal)
            print("\(nm!)- btn name")
            if nm?.contains(" ") == true {
                nm = nm!.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            print(nm!)
            if nm != nil {
             getLeaders(sel: nm!)
            }
            do { //delay to load appending data
                sleep(2)
            }
        }
        cell.srLbl.text = "\(LeaderData[rowIndex].rank)"
        cell.scorLbl.text = "\(LeaderData[rowIndex].score)"
        cell.nameLbl.text = "\(LeaderData[rowIndex].name)"
        
        cell.scorLbl.roundCorners(corners: [ .bottomLeft, .topLeft], radius: 10)
        cell.scorLbl.textAlignment = NSTextAlignment.center
        cell.srLbl.roundCorners(corners: [ .bottomRight, .topRight], radius: 10)
        
        if(self.LeaderData[rowIndex].image.isEmpty) {
            cell.userImg.image = UIImage(named: "user") // set default image
        }else{
            DispatchQueue.main.async {
                cell.userImg.loadImageUsingCache(withUrl: self.LeaderData[rowIndex].image)// load image from url using cache
            }
        }

        self.DesignImageView(cell.userImg)
        cell.leadrView.frame = CGRect(origin: cell.leadrView.frame.origin, size: CGSize(width: self.view.frame.width - 20, height: cell.leadrView.frame.height))
        cell.imgView.layer.cornerRadius = cell.imgView.frame.width / 2
        cell.imgView.layer.masksToBounds = false
        cell.imgView.clipsToBounds = true
        cell.imgView.layer.borderWidth = 2
        cell.imgView.layer.borderColor = UIColor.rgb(57, 129, 156, 1.0).cgColor//UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0).cgColor

        cell.leadrView.layer.masksToBounds = true
        cell.leadrView.layer.cornerRadius = 0 //35
        cell.leadrView.shadow(color: .lightGray, offSet: CGSize(width: 2, height: 2), opacity: 0.7, radius: 35, scale: true)
        cell.leadrView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 6.0,options: .allowUserInteraction,
                       animations: { [weak self] in
                        cell.leadrView.transform = .identity
                        
            },completion: nil)
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    //check user rank is it visible to view without scroll
    func AddUsertoBottom(){        
        //if you change height belowchng the same in temp.frame.height == 60
        let bottomView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 60, width: self.tableView.frame.width, height: 60))
        bottomView.backgroundColor = UIColor.rgb(57, 129, 156, 1.0)
        print(bottomView.frame)
         let this = LeaderData.filter{$0.userID == thisUser.userID}
        
        if !this.isEmpty {
               let rankLabel = UILabel(frame: CGRect(x: 0, y: 10, width: 45, height: 30))
               rankLabel.text = this[0].rank
               rankLabel.textColor = UIColor.black
               rankLabel.textAlignment = NSTextAlignment.center
               rankLabel.backgroundColor = UIColor.white
               rankLabel.roundCorners(corners: [ .bottomRight, .topRight], radius: 10)
               bottomView.addSubview(rankLabel)
               
               let imageView = UIImageView(frame: CGRect(x: 50, y: 5, width: 40, height: 40))
               if this[0].image != ""{
                   imageView.loadImageUsingCache(withUrl: this[0].image)
               }else{
                   imageView.image = UIImage(named: "user")
               }
               imageView.layer.cornerRadius = 40 / 2
               imageView.layer.masksToBounds = true
               bottomView.addSubview(imageView)
               
               let nameLabel = UILabel(frame: CGRect(x: 105, y: 10, width: 200, height: 30))
               nameLabel.text = this[0].name
               nameLabel.textColor = UIColor.white
               bottomView.addSubview(nameLabel)
               
               let scoreLabel = UILabel(frame: CGRect(x: self.view.frame.width - 60, y: 10, width: 60, height: 30))
               scoreLabel.text = this[0].score
               scoreLabel.textColor = UIColor.black
               scoreLabel.textAlignment = .center
               scoreLabel.backgroundColor = UIColor.white
             //  scoreLabel.layer.cornerRadius = 15
               scoreLabel.roundCorners(corners: [.topLeft, .bottomLeft], radius: 10)
               scoreLabel.layer.masksToBounds = true
            
               bottomView.addSubview(scoreLabel)
               
               self.view.addSubview(bottomView)
        }else{
            //remove subview
            for temp in self.view.subviews {
                print(temp)
                print(temp.frame)
                if temp.frame.height == 60  { //temp.frame.origin == CGPoint(x: 0, y: 577)-position of bottomView which we want to remove
                     print("origin => \(temp)")
                    temp.removeFromSuperview ()
                }
            }
            print(self.view.subviews)
        }
    }
}
//selectionDropDown(A,M,D)
protocol dropDownProtocol {
    func dropDownPressed(string : String)
}
