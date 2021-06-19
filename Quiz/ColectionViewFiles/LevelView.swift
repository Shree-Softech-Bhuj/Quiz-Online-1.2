import UIKit
import AVFoundation
import GoogleMobileAds 

var scoreLavel = 0
var mainCatID = 0

var numberOfItems: Int = 10 //6//
    
var arrColors1 = [UIColor(named: "purple1"),UIColor(named: "sky1"),UIColor(named: "orange1"),UIColor(named: "green1"),UIColor(named: "blue1"),UIColor(named: "pink1")]
var arrColors2 = [UIColor(named: "purple2"),UIColor(named: "sky2"),UIColor(named: "orange2"),UIColor(named: "green2"),UIColor(named: "blue2"),UIColor(named: "pink2")]

var tintArr = ["purple2", "sky2","orange2","green2","blue2","pink2"] //NOTE: arrColors1 & arrColors2 & tintArr - arrays should have same values/count

class LevelView: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout ,GADBannerViewDelegate { //UITableViewDelegate, UITableViewDataSource
    
//    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var adBannerView: GADBannerView!
    
    var maxLevel = 0
    var catID = 0
    var mainCatid = 0
    var questionType = "sub"
    var unLockLevel =  0
    var quesData: [QuestionWithE] = []
    
    var numberOfLevels = 10
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var audioPlayer : AVAudioPlayer!
    var sysConfig:SystemConfiguration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForValues()
        
//        tableView.delegate = self
//        tableView.dataSource = self
        
         adBannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
          adBannerView.rootViewController = self
          let request = GADRequest()
        // request.testDevices = Apps.AD_TEST_DEVICE
//        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
           adBannerView.load(request)
        
        // apps level lock unlock, no need level lock unlock remove this code
        if UserDefaults.standard.value(forKey:"\(questionType)\(catID)") != nil {
            unLockLevel = Int(truncating: UserDefaults.standard.value(forKey:"\(questionType)\(catID)") as! NSNumber)
            //print(unLockLevel)
        }
         
        if UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) != nil {
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
         
//        self.tableView.isHidden = true
        self.collectionView.isHidden = true
        if UserDefaults.standard.bool(forKey: "isLogedin"){
                 self.GetUserLevel()
        }else{
//            self.tableView.isHidden = false
//            self.tableView.reloadData()
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
    }
     
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
          print("Banner loaded successfully")
      }

    private func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: NSError) {
          print("Fail to receive ads")
          print(error)
      }
     
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        if !isInitial{
//            self.tableView.reloadData()
//        }
    }
    
    func checkForValues(){
        if arrColors1.count < numberOfItems{
            let dif = numberOfItems - (arrColors1.count - 1)
            print(dif)
            for i in 0...dif{
                arrColors1.append(arrColors1[i])
                arrColors2.append(arrColors2[i])
                tintArr.append(tintArr[i])
            }
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        //check if user entered in this view directly from appdelegate ? if Yes then goTo Home page otherwise just go back from notification view
        if self == UIApplication.shared.keyWindow?.rootViewController {
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
     
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
     
    
    @IBAction func unwindLevel(for unwindSegue: UIStoryboardSegue) {}
    // number of rows in table view
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if maxLevel == 0{
//            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
//            noDataLabel.text          = Apps.LEVET_NOT_AVAILABEL
//            noDataLabel.textColor     = UIColor.black
//            noDataLabel.textAlignment = .center
//            tableView.backgroundView  = noDataLabel
//            tableView.separatorStyle  = .none
//        }
//        return maxLevel
//    }
    
   
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        maxLevel//numberOfLevels //10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! levelCell
        print("indexpath row value -- \(indexPath.row) --  total count of array - \(arrColors1.count) -- total count of cells - \(numberOfItems)")
        gridCell.levelNumber.text = "\(indexPath.row + 1)"
        gridCell.circleImgView.image = UIImage(named: "circle")
        gridCell.circleImgView.tintColor = UIColor.init(named: tintArr[indexPath.row])
        if (self.unLockLevel >= indexPath.row){
            gridCell.lockButton.setImage(UIImage(named: "unlock"), for: .normal)
            gridCell.lockButton.tintColor = UIColor.gray
        }else{
            gridCell.lockButton.setImage(UIImage(named: "lock"), for: .normal)
            gridCell.lockButton.tintColor = Apps.BASIC_COLOR
        }
        
        //if level is completed successfully - set it's text and image to grey To mark that levels as done
        if (unLockLevel >= 0 && indexPath.row < unLockLevel) {
            print("values - \(unLockLevel) - \(indexPath.row)")
            gridCell.levelNumber.textColor = UIColor.rgb(168.0, 168.0, 168.0, 1.0)
            gridCell.lockButton.setImage(UIImage(named: "unlock"), for: .normal)
            gridCell.lockButton.tintColor = UIColor.gray
        }
        
        //gridCell.lockButton.setImage(UIImage(named: "lock"), for: .normal)
        gridCell.backgroundColor = .clear
        gridCell.bgView.layer.cornerRadius = (gridCell.bgView.frame.width * 0.6 * 0.8) / 2 //0.67
        gridCell.bgView.layer.masksToBounds = true
        gridCell.bgView.layer.borderColor = UIColor.lightGray.cgColor
        gridCell.bgView.layer.borderWidth = 1
        
        return gridCell
    }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                                   
            let noOfCellsInRow = 3

                let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

                let totalSpace = flowLayout.sectionInset.left
                    + flowLayout.sectionInset.right
                    + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))

                let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))

                return CGSize(width: size, height: size)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            print("clicked cell number \(indexPath.row)")
            
            if (self.unLockLevel >= indexPath.row){
                
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = storyboard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
                viewCont.playType = "main"
                
                viewCont.catID = self.catID
                viewCont.level = indexPath.row + 1
                viewCont.questionType = self.questionType
                
                self.isInitial = false
                self.PlaySound(player: &audioPlayer, file: "click") // play sound
                self.Vibrate() // make device vibrate
                self.quesData.removeAll()
                var apiURL = ""
                if(questionType == "main"){
                    apiURL = "level=\(indexPath.row + 1)&category=\(catID)"
                }else{
                    apiURL = "level=\(indexPath.row + 1)&subcategory=\(catID)"
                }
                if sysConfig.LANGUAGE_MODE != nil && sysConfig.LANGUAGE_MODE == 1{
                    let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                    apiURL += "&language_id=\(langID)"
                }
                self.getAPIData(apiName: "get_questions_by_level", apiURL: apiURL,completion: {jsonObj in
                    //print("JSON",jsonObj)
                    let status = jsonObj.value(forKey: "error") as! String
                    if (status == "true") {
                        self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                    }else{
                        //get data for category
                        self.quesData.removeAll()
                        if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                            for val in data{
                                self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                                //check if admin have added questions with 5 options? if not, then hide option E btn by setting boolean variable to false even if option E mode is Enabled.
                                //                            if let e = val["optione"] as? String {
                                //                                if e == ""{
                                //                                    Apps.opt_E = false
                                //                                }else{
                                //                                    Apps.opt_E = true
                                //                                }
                                //                            }
                            }
                            Apps.TOTAL_PLAY_QS = data.count
                            print(Apps.TOTAL_PLAY_QS)
                            
                            //check this level has enough (10) question to play? or not
                            if self.quesData.count >= Apps.TOTAL_PLAY_QS {
                                viewCont.quesData = self.quesData
                                DispatchQueue.main.async {
                                    self.navigationController?.pushViewController(viewCont, animated: true)
                                }
                            }//else{
                            //                            DispatchQueue.main.async {
                            //                                print("This level does not have enough question",self.quesData.count)
                            //                                self.ShowAlert(title: Apps.NOT_ENOUGH_QUESTION_TITLE, message: Apps.NO_ENOUGH_QUESTION_MSG)
                            //                            }
                            //                        }
                        }else{
                            
                        }
                    }
                })
            }else{
                self.ShowAlert(title: Apps.OOPS, message: Apps.LEVEL_LOCK)
            }
        }
    
}
extension LevelView{
    
    func GetUserLevel(){
        if(Reachability.isConnectedToNetwork()){
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            Loader = LoadLoader(loader: Loader)
            mainCatID = self.mainCatid
            let apiURL = self.questionType == "main" ? "user_id=\(user.userID)&category=\(self.catID)&subcategory=0" : "user_id=\(user.userID)&category=\(self.mainCatid)&subcategory=\(self.catID)"
            self.getAPIData(apiName: "get_level_data", apiURL: apiURL,completion: { jsonObj in
                 print("JSON",jsonObj)
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                    DispatchQueue.main.async {
                        self.Loader.dismiss(animated: true, completion: {
                            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                        })
                    }
                    
                }else{
                    //close loader here
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                        DispatchQueue.main.async {
                            self.DismissLoader(loader: self.Loader)
                            let data = jsonObj.value(forKey: "data") as? [String:Any]
                            print("level data \(data)")
                            self.unLockLevel = Int("\(data!["level"]!)")!
                            scoreLavel = self.unLockLevel
                            self.collectionView.isHidden = false
//                            self.tableView.isHidden = false
//                            self.tableView.delegate = self
//                            self.tableView.dataSource = self
                            
                            self.collectionView.reloadData()
                           // self.tableView.reloadData()
                            
                        }
                    });
                }
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
}

class levelCell: UICollectionViewCell { 
    
    @IBOutlet weak var bgView: UIView!
    @IBOutlet var levelNumber: UILabel!
    @IBOutlet var levelTxt: UILabel!
    @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var lockButton: UIButton!
}
