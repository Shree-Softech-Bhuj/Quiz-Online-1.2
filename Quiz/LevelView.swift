import UIKit
import AVFoundation
import GoogleMobileAds

class LevelView: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    var maxLevel = 0
    var catID = 0
    var questionType = "sub"
    var unLockLevel =  0
//    var quesData: [Question] = []
    var quesData: [QuestionWithE] = []
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var audioPlayer : AVAudioPlayer!
    
    @IBOutlet weak var adBannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        adBannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
        adBannerView.rootViewController = self
        let request = GADRequest()
        request.testDevices = Apps.AD_TEST_DEVICE
        adBannerView.load(request)
        
        // apps level lock unlock, no need level lock unlock remove this code
        if UserDefaults.standard.value(forKey:"\(questionType)\(catID)") != nil {
            unLockLevel = Int(truncating: UserDefaults.standard.value(forKey:"\(questionType)\(catID)") as! NSNumber)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !isInitial{
             self.tableView.reloadData()
        }
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    @IBAction func unwindLevel(for unwindSegue: UIStoryboardSegue) {}
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if maxLevel == 0{
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = Apps.LEVET_NOT_AVAILABEL
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return maxLevel
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = "levelCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        cell.lvlLbl.text = "\(Apps.LEVEL) \(indexPath.row + 1)"
        
        // apps lock unlock code
        if (self.unLockLevel >= indexPath.row){
            cell.lockImg.image = UIImage(named: "unlock")
        }else{
            cell.lockImg.image = UIImage(named: "lock")
        }
        
        cell.cellView2.SetShadow()
        
        cell.cellView2.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.7,
                    initialSpringVelocity: 6.0,options: .allowUserInteraction,
                    animations: { [weak self] in
                    cell.cellView2.transform = .identity
                        
            },completion: nil)
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (self.unLockLevel >= indexPath.row){
            
            let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let playView:PlayQuizView = storyBoard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
            
            playView.catID = self.catID
            playView.level = indexPath.row + 1
            playView.questionType = self.questionType
           
            
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
          
            self.getAPIData(apiName: "get_questions_by_level", apiURL: apiURL,completion: {jsonObj in
                //print("JSON",jsonObj)
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                   self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
                }else{
                    //get data for category
                    self.quesData.removeAll()
                    if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                        for val in data{
                            self.quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)"))
                        }
                        
                        //check this level has enought (10) question to play? or not
                        if self.quesData.count >= 10{
                            
                            playView.quesData = self.quesData
                            DispatchQueue.main.async {
                                self.present(playView, animated: true, completion: nil)
                            }
                        }else{
                            DispatchQueue.main.async {
                                print("This level does not have enough question",self.quesData.count)
                                self.ShowAlert(title: Apps.NOT_ENOUGH_QUESTION_TITLE, message: Apps.NO_ENOUGH_QUESTION_MSG)
                            }
                        }
                    }else{
                        
                    }
                }
            })
        }else{
            self.ShowAlert(title: Apps.OOPS, message: Apps.LEVEL_LOCK)
        }
    }
}

