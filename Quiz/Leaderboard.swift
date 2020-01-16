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
    
       
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        usr1.layer.cornerRadius = usr1.frame.height/2
        usr2.layer.cornerRadius = usr2.frame.height/2
        usr3.layer.cornerRadius = usr3.frame.height/2
                
        thisUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
           
        getLeaders(sel: "All")//get data from server
    }
    
    //get data from server
    func getLeaders(sel : String){
       if(Reachability.isConnectedToNetwork()){
          let dateFormatterGet = DateFormatter()
          dateFormatterGet.dateFormat = "yyyy-MM-dd"
          Loader = LoadLoader(loader: Loader)
        //chk for selection from dropdownload
                 if (sel == "Daily") { //daily
                    let apiURL = "from=\(dateFormatterGet.string(from: Date()))&to=\(dateFormatterGet.string(from: Date()))"
                      print(apiURL)
                      self.getAPIData(apiName: "get_datewise_leaderboard", apiURL: apiURL,completion: LoadData)
                }
                if (sel == "Monthly"){ //monthly
                        let apiURL = "date=\(dateFormatterGet.string(from: Date().startOfMonth()))"
                        self.getAPIData(apiName: "get_monthly_leaderboard", apiURL: apiURL,completion: LoadData)
                }
                if(sel == "All"){ //all
                    let apiURL = "" //no need of date
                    self.getAPIData(apiName: "get_global_leaderboard", apiURL: apiURL,completion: LoadData)
                }
           }
       else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
           }
    }
    
    @IBAction func showLeaderboardOptions(_ sender: UIButton) {
//        if let buttonTitle = sender.title(for: .normal) {
//            //getLeaders(sel: buttonTitle) //should be called at click of dropdown after chnging nm of button
//            print(buttonTitle)
//        }
        if selectionOptView.superview != nil {
            animateOut()
        }else {
            animateIn()            
        }
     }
    func animateIn(){ //for Selection Opt view
                self.view.addSubview(selectionOptView)
                var pos: CGRect = selectionOptView.frame
                pos.origin.x = 275
                pos.origin.y = 80
                self.selectionOptView.frame = pos
    //            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseIn, animations: {
    //                self.selectionOptView.frame = pos
    //            }) { finished in
    //            }
               // selectionOptView.transform = selectionOptView.transform.translatedBy(x: -200, y: -200)
                //selectionOptView.center = self.view.center
                // selectionOptView.transform = CGAffineTransform(translationX: 50, y: 50)
                //selectionOptView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                //selectionOptView.transform = CGAffineTransform.identity
               // selectionOptView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
                    //selectionOptView.alpha=0
        
    //            UIView.animate(withDuration: 0.4){
    //                self.selectionOptView.alpha = 1
    //               self.selectionOptView.transform = CGAffineTransform.identity
    //            }
        /***/
            //border to selectionOption View
            let externalBorder = CALayer()
            externalBorder.frame = CGRect(x: -1, y: -1, width: selectionOptView.frame.size.width+2, height: selectionOptView.frame.size.height+2)
            externalBorder.borderColor = UIColor.black.cgColor
            externalBorder.borderWidth = 1.0
            selectionOptView.layer.addSublayer(externalBorder)
            selectionOptView.layer.masksToBounds = false
            /***/
    }
        
            func animateOut(){ //for selectionOptView view
//                UIView.animate(withDuration: 0.3, animations: {
//                   // self.selectionOptView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
//                    self.selectionOptView.alpha = 0
//                }) {(success:Bool) in
                    self.selectionOptView.removeFromSuperview()
                //}
            }
    
    @IBAction func showAll(_ sender: UIButton) {
        animateOut()
        //self.selectionOptView.removeFromSuperview()
        if let buttonTitle = sender.title(for: .normal) {
        //used "trimmed" variable instead of "buttonTitle" as buttonTitle have whitespace after All for positioning in design view so we have to remove it here
        let name: String = buttonTitle
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
            //print("\(trimmed)trimmedALL")
        getLeaders(sel: trimmed)
        buttonAll.setTitle(buttonTitle, for: .normal)
        }
       //self.selectionOptView.removeFromSuperview()
    }
    @IBAction func showMonthly(_ sender: UIButton) {
        animateOut()
        //self.selectionOptView.removeFromSuperview()
        if let buttonTitle = sender.title(for: .normal) {
        getLeaders(sel: buttonTitle)
        buttonAll.setTitle(buttonTitle, for: .normal)
        }
    }
    @IBAction func showDaily(_ sender: UIButton) {
        animateOut()
        //self.selectionOptView.removeFromSuperview()
        if let buttonTitle = sender.title(for: .normal) {
        getLeaders(sel: buttonTitle)
        buttonAll.setTitle(buttonTitle, for: .normal)
        }
    }
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
//        if status != nil{
//            print("status is not nil")
//        }else{
//            print("status is nil")
//        }
        print(status)
        if (status == "true") {
              DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    print("Data Not Found !!!")
                    print(jsonObj.value(forKey: "status")!)
                    self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "status")!)" )
                })
            }
            
        }else{
            //get data for category
            LeaderData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    LeaderData.append(Leader.init(rank: "\(val["rank"]!)", name: "\(val["name"]!)", image: "\(val["profile"]!)", score: "\(val["score"]!)", userID: "\(val["user_id"]!)"))
                }
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
                                //self.usr1.loadImageUsingCache(withUrl: self.LeaderData[1].image)
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
                                //self.usr1.loadImageUsingCache(withUrl: self.LeaderData[1].image)
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
                           //  self.usr2.loadImageUsingCache(withUrl: self.LeaderData[0].image)
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
                                //self.usr1.loadImageUsingCache(withUrl: self.LeaderData[1].image)
                           }else{
                              self.user2View.isHidden = true
                            //print("no data for user 1")
                           }
                        //user 2
                        if(!self.LeaderData[0].image.isEmpty){
                            self.usr2.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                         }
                        if (!self.LeaderData[0].name.isEmpty) && (!self.LeaderData[0].score.isEmpty) {
                             self.usr2Lbl.text = "\(self.LeaderData[0].name)"
                             self.score2Lbl.text = "\(self.LeaderData[0].score)"
                           //  self.usr2.loadImageUsingCache(withUrl: self.LeaderData[0].image)
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
                            // self.usr3.loadImageUsingCache(withUrl: self.LeaderData[2].image)
                        }
                        else{
                            self.user3View.isHidden = true
                        }
            default:
                    //executed if LeaderData get more than 3 records
                   self.showALLinLeaderboard()
                }
                
        /* without hiding any of 3 views  - option of switch case above
                 
                 if(!self.LeaderData[1].image.isEmpty){
                        self.usr1.loadImageUsingCache(withUrl: self.LeaderData[1].image)
                        }
                    if(!self.LeaderData[0].image.isEmpty){
                        self.usr2.loadImageUsingCache(withUrl: self.LeaderData[0].image)
                       }
                    if(!self.LeaderData[2].image.isEmpty){
                        self.usr3.loadImageUsingCache(withUrl: self.LeaderData[2].image)
                    }
                // if (!self.LeaderData[0].name.isEmpty) && (!self.LeaderData[0].score.isEmpty) && (!self.LeaderData[0].image.isEmpty){
               // self.usr1Lbl.text = "\(self.LeaderData[1].name)"
              //  self.usr2Lbl.text = "\(self.LeaderData[0].name)"
             //   self.usr3Lbl.text = "\(self.LeaderData[2].name)"
                
               // self.score1Lbl.text = "\(self.LeaderData[1].score)"
               // self.score2Lbl.text = "\(self.LeaderData[0].score)"
              //  self.score3Lbl.text = "\(self.LeaderData[2].score)"
      */
                
                self.DesignImageView(images: self.usr1,self.usr2,self.usr3)
                //reload data after getting it from server
                self.tableView.reloadData()
                
                //set bottom view if user rank is more than 10
                let this = self.LeaderData.filter{$0.userID == self.thisUser.userID}
                if this.count > 0 && Int(this[0].rank)! > 10 {
                    self.AddUsertoBottom()
                }
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
         self.dismiss(animated: true, completion: nil)
    }

    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return LeaderData.count - 3
        
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = "boardCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        let rowIndex = indexPath.row + 3
        cell.srLbl.text = "\(LeaderData[rowIndex].rank)"
        cell.scorLbl.text = "\(LeaderData[rowIndex].score)"
        cell.nameLbl.text = "\(LeaderData[rowIndex].name)"
        
        if(self.LeaderData[rowIndex].image.isEmpty) {
            cell.userImg.image = UIImage(named: "user") // set default image
        }else{
            DispatchQueue.main.async {
                cell.userImg.loadImageUsingCache(withUrl: self.LeaderData[rowIndex].image)// load image from url using cache
            }
        }

        self.DesignImageView(images: cell.userImg)
        cell.leadrView.frame = CGRect(origin: cell.leadrView.frame.origin, size: CGSize(width: self.view.frame.width - 20, height: cell.leadrView.frame.height))
        cell.imgView.layer.cornerRadius = cell.imgView.frame.width / 2
        cell.imgView.layer.masksToBounds = false
        cell.imgView.clipsToBounds = true
        cell.imgView.layer.borderWidth = 2
        cell.imgView.layer.borderColor = UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0).cgColor

        cell.leadrView.layer.masksToBounds = true
        cell.leadrView.layer.cornerRadius = 35
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
    
    //design image view
    func DesignImageView(images:UIImageView...){
        for image in images{
            image.layer.backgroundColor = UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0).cgColor
            image.layer.masksToBounds = false
            image.clipsToBounds = true
            image.layer.cornerRadius = image.frame.width / 2
        }
    }
    //check user rank is it visible to view without scroll
    func AddUsertoBottom(){
        let bottomView = UIView(frame: CGRect(x: 0, y: self.view.frame.height - 50, width: self.tableView.frame.width, height: 50))
        bottomView.backgroundColor = UIColor.white
        
        let this = LeaderData.filter{$0.userID == thisUser.userID}
        let rankLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
        rankLabel.text = this[0].rank
        rankLabel.textColor = UIColor.blue
        bottomView.addSubview(rankLabel)
        
        let imageView = UIImageView(frame: CGRect(x: 45, y: 5, width: 40, height: 40))
        if this[0].image != ""{
            imageView.loadImageUsingCache(withUrl: this[0].image)
        }else{
            imageView.image = UIImage(named: "user")
        }
        imageView.layer.cornerRadius = 40 / 2
        imageView.layer.masksToBounds = true
        bottomView.addSubview(imageView)
        
        let nameLabel = UILabel(frame: CGRect(x: 95, y: 10, width: 200, height: 30))
        nameLabel.text = this[0].name
        bottomView.addSubview(nameLabel)
        
        let scoreLabel = UILabel(frame: CGRect(x: self.view.frame.width - 60, y: 10, width: 50, height: 30))
        scoreLabel.text = this[0].score
        scoreLabel.textColor = UIColor.red
        scoreLabel.textAlignment = .center
        scoreLabel.backgroundColor = UIColor.lightGray
        scoreLabel.layer.cornerRadius = 15
        scoreLabel.layer.masksToBounds = true
        bottomView.addSubview(scoreLabel)
        
        self.view.addSubview(bottomView)
    }
}

//selectionDropDown(A,M,D)
protocol dropDownProtocol {
    func dropDownPressed(string : String)
}
