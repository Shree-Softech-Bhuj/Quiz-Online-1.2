import UIKit
import Firebase
import AVFoundation

class HomeScreenController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var allTimeScoreButton: UIButton!
    @IBOutlet weak var coinsButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet var languageButton: UIButton!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    var setting:Setting? = nil
    
   var sysConfig:SystemConfiguration!
   var Loader: UIAlertController = UIAlertController()
    
    let varSys = SystemConfig()
    var userDATA:UserScore? = nil
    var dUser:User? = nil
    
    var config:SystemConfiguration?
    var apiName = "get_categories"
    var apiExPeraforLang = ""
    var catData:[Category] = []
    var langList:[Language] = []
    
    var arr = [Apps.QUIZ_ZONE,Apps.PLAY_ZONE,Apps.BATTLE_ZONE,Apps.CONTEST_ZONE]
    let leftImg = [Apps.IMG_QUIZ_ZONE,Apps.IMG_PLAYQUIZ,Apps.IMG_BATTLE_QUIZ,Apps.IMG_CONTEST_QUIZ]
    
    //battle modes
    var ref: DatabaseReference!
    var roomDetails:RoomDetails?
    var isUserBusy = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
            
        if Apps.CONTEST_MODE == "0"{
            arr.removeLast() //as contest mode is last
        }
        
        self.PlayBackgrounMusic(player: &backgroundMusicPlayer, file: "snd_bg")
        
        leaderboardButton.layer.cornerRadius = leaderboardButton.frame.height / 2//4
        leaderboardButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        allTimeScoreButton.layer.cornerRadius = leaderboardButton.frame.height / 2//4
        allTimeScoreButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        coinsButton.layer.cornerRadius = leaderboardButton.frame.height / 2//4
        coinsButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        
        //check setting object in user default
        if UserDefaults.standard.value(forKey:"setting") != nil {
            setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        }else{
            setting = Setting.init(sound: true, backMusic: false, vibration: true)
            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.setting), forKey: "setting")
        }
        
        //check score object in user default
        if UserDefaults.standard.value(forKey:"UserScore") != nil {
            //available
        }else{
            // not availabel add it to user default
            UserDefaults.standard.set(try? PropertyListEncoder().encode(UserScore.init(coins: 0, points: 0)), forKey: "UserScore")
        }
        
        //register nsnotification for latter call for play music and stop music
        NotificationCenter.default.addObserver(self,selector: #selector(self.PlayBackMusic),name: NSNotification.Name(rawValue: "PlayMusic"),object: nil) // for play music
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.StopBackMusic),name: NSNotification.Name(rawValue: "StopMusic"),object: nil) // for stop music
                
        if UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) != nil {
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
        getUserNameImg()
        self.ObserveInvitation()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if self.isUserBusy{
                self.isUserBusy = false
            }
        }
    }    
 
    //load category data here
//    func LoadData(jsonObj:NSDictionary){
//        print("RS",jsonObj)
//        let status = jsonObj.value(forKey: "error") as! String
//        if (status == "true"){
//        }else{
//            //get data for category
//            catData.removeAll()
//            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
//                for val in data{
//                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
//                }
//            }
//
//        }
//
//        //Add tableview cells
//        DispatchQueue.main.async {
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "QuizZone")
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "PlayZone")
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "BattleZone")
//            self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "ContestZone")
//        }
//    }
    
    func getUserNameImg(){
        //user name and display image
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            userName.text = "\(Apps.HELLO)  \(dUser!.name)"
          
            imgProfile.layer.cornerRadius =  imgProfile.frame.height / 2
            imgProfile.layer.masksToBounds = true//false
            imgProfile.clipsToBounds = true
            imgProfile.layer.borderWidth = 2
            imgProfile.layer.borderColor = UIColor.white.cgColor
            
            imgProfile.isUserInteractionEnabled = true
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            imgProfile.addGestureRecognizer(tapRecognizer)
            
            DispatchQueue.main.async {
                if(self.dUser!.image != ""){
                    self.imgProfile.loadImageUsingCache(withUrl: self.dUser!.image)
                }else{
                    self.imgProfile.image = UIImage(named: "guest")
                }
            }
        }else{
            userName.text = "\(Apps.HELLO) \(Apps.USER)"
            imgProfile.image = UIImage(named: "guest") //"user")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        languageButton.isHidden = true
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
            let config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
            if config.LANGUAGE_MODE == 1{
                languageButton.isHidden = false
                //open language view
                if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0{
                    LanguageButton(self)
                }
            }
        }
        
        if isKeyPresentInUserDefaults(key: "isLogedin"){
            if !UserDefaults.standard.bool(forKey: "isLogedin"){
                return
            }
        }else{
            return
        }
//        call and get API response for categories
//        if(Reachability.isConnectedToNetwork()){
//            if config?.LANGUAGE_MODE == 1{
//                apiName = "get_categories_by_language"
//                apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
//            }
//            let apiURL = "" + apiExPeraforLang
//            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
//        }else{
//            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
//        }
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            let apiURL = "user_id=\(userD.userID)"
            self.getAPIData(apiName: Apps.API_BOOKMARK_GET, apiURL: apiURL,completion: LoadBookmarkData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        leaderboardButton.setTitle(Apps.ALL_TIME_RANK as? String , for: .normal)
        allTimeScoreButton.setTitle(Apps.SCORE as? String, for: .normal)
        coinsButton.setTitle(Apps.COINS , for: .normal)
        
        varSys.getUserDetails()

        getUserNameImg()
    }
    //load Bookmark data here
    func LoadBookmarkData(jsonObj:NSDictionary){
        var BookQuesList: [QuestionWithE] = []
        
        let status = "\(jsonObj.value(forKey: "error") ?? "1")".bool ?? true
        if (status) {
        }else{
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    BookQuesList.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"] ?? "0")"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
            }
        });
    }
    @objc func imageTapped(gestureRecognizer: UITapGestureRecognizer) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "UpdateProfileView")
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func moreBtn(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "MoreOptions")
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }    
    
    // play background music function
    @objc func PlayBackMusic(){
        backgroundMusicPlayer.play()
    }
    
    // stop background music function
    @objc func StopBackMusic(){
        backgroundMusicPlayer.stop()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    func showAllCategories(){
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        //check if language is enabled and not selected

        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    @IBAction func leaderboardBtn(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "Leaderboard")
            self.navigationController?.pushViewController(viewCont, animated: true)
            
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func LanguageButton(_ sender: Any){
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "LanguageView") as! LanguageView
        view.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        view.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(view, animated: true, completion: nil)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "QuizZone"
        if indexPath.row == 1 {
            cellIdentifier = "PlayZone"
        }
        if indexPath.row == 0 {
            cellIdentifier = "QuizZone"
        }
        if indexPath.row == 2 {
            cellIdentifier = "BattleZone"
        }
        if indexPath.row == 3 {
            cellIdentifier = "ContestZone"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomeTableViewCell
        print("test -- \(arr[indexPath.row])")
        
        cell.titleLabel.text = arr[indexPath.row]
        cell.leftImg.image = UIImage(named: leftImg[indexPath.row])
        
        cell.cellDelegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightVal:CGFloat = 0
        if indexPath.row == 1 || indexPath.row == 2 { //playzone OR BattleZone
            heightVal = (deviceStoryBoard == "Ipad" ? 800 : 400)
            return heightVal
        }else{
            heightVal = (deviceStoryBoard == "Ipad" ? 400 : 300)
            return heightVal
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected - \(indexPath.row)")
    }
    
    @IBAction func viewAllCategory(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
}
extension HomeScreenController:CellSelectDelegate{
        
   
    func didCellSelected(_ type: String,_ rowIndex: Int){
        print("Call FUNCTION HERE+ \(type) -- catdata total \(catData.count) -- row Index - \(rowIndex)")
                
        //[Apps.DAILY_QUIZ_PLAY,Apps.RNDM_QUIZ,Apps.TRUE_FALSE,Apps.SELF_CHLNG]
        if type == "playzone-0"{
            getQuestions("daily")//("true/false"))
        }else if type == "playzone-1"{
            getQuestions("random")//("true/false"))
        }else if type == "playzone-2"{
            getQuestions("true/false")
        }else if type == "playzone-3"{ //self challenge
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = storyboard.instantiateViewController(withIdentifier: "SelfChallengeController")
                self.navigationController?.pushViewController(viewCont, animated: true)
        }else if type == "battlezone-0"{
            if UserDefaults.standard.bool(forKey: "isLogedin"){
              let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
              let viewCont = storyboard.instantiateViewController(withIdentifier: "GroupBattleTypeSelection")
//                viewCont.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//                viewCont.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
//                self.present(viewCont, animated: true, completion: nil)
                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
              self.navigationController?.popToRootViewController(animated: true)
            }
        }else if type == "battlezone-1"{
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                if Apps.RANDOM_BATTLE_WITH_CATEGORY == "1"{
                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let viewCont = storyboard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
                    //pass value to identify to jump to battle and not play quiz view.
                    viewCont.isCategoryBattle = true
                    self.navigationController?.pushViewController(viewCont, animated: true)
                }else{
                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let viewCont = storyboard.instantiateViewController(withIdentifier: "BattleViewController")
                    self.navigationController?.pushViewController(viewCont, animated: true)
                }
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else if type == "ContestView" {
            if UserDefaults.standard.bool(forKey: "isLogedin"){
              let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
              let viewCont = storyboard.instantiateViewController(withIdentifier: type)
              self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
              self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            self.PlaySound(player: &audioPlayer, file: "click") // play sound
            self.Vibrate() // make device vibrate
            //check if language is enabled and not selected
            if languageButton.isHidden == false{
                if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
                    LanguageButton(self)
                }
            }
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        
            if type == "subcategoryview"{
                let viewCont = storyboard.instantiateViewController(withIdentifier: type) as! subCategoryViewController
                if (UserDefaults.standard.value(forKey: "categories") != nil){
                    self.catData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
                }
                viewCont.catID = catData[rowIndex].id
                viewCont.catName = catData[rowIndex].name
                print("call subcategoryview with id and name - \(catData[rowIndex].id) - \(catData[rowIndex].name)")
                self.navigationController?.pushViewController(viewCont, animated: true)
            }else if type == "LevelView"{
                let viewCont = storyboard.instantiateViewController(withIdentifier: type) as! LevelView
                if (UserDefaults.standard.value(forKey: "categories") != nil){
                    self.catData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
                }
                if catData[rowIndex].maxlvl.isInt{
                    viewCont.maxLevel = Int(catData[rowIndex].maxlvl)!
                }
                viewCont.catID = Int(self.catData[rowIndex].id)!
                viewCont.questionType = "main"
                self.navigationController?.pushViewController(viewCont, animated: true)
            }else{
                let viewCont = storyboard.instantiateViewController(withIdentifier: type)
                self.navigationController?.pushViewController(viewCont, animated: true)
            }            
        }
    }
    
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
    
    func isUpdateAvailable(completion: @escaping (Bool?, Error?) -> Void) throws -> URLSessionDataTask {
        guard let info = Bundle.main.infoDictionary,
            let currentVersion = info["CFBundleShortVersionString"] as? String,
            let identifier = info["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                throw VersionError.invalidBundleInfo
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }
                let json = try JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? [String: Any]
                guard let result = (json?["results"] as? [Any])?.first as? [String: Any], let version = result["version"] as? String else {
                    throw VersionError.invalidResponse
                }
                completion(version != currentVersion, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()
        return task
    }
    
    func CheckAppsUpdate(){
        _ = try? isUpdateAvailable { (update, error) in
            if let error = error {
                print("APPS UPDATE",error)
            } else if let update = update {
                print("Apps UPDATE SU",update)
            }
        }
    }
    
    func popupUpdateDialogue(){
        let alert = UIAlertController(title: Apps.UPDATE_TITLE, message: Apps.UPDATE_MSG, preferredStyle: .alert)
        
        let okBtn = UIAlertAction(title: Apps.UPDATE_BUTTON, style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: Apps.SHARE_APP),
                UIApplication.shared.canOpenURL(url){
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        })
        let noBtn = UIAlertAction(title:Apps.UPDATE_SKIP , style: .destructive, handler: {(_ action: UIAlertAction) -> Void in
        })
        alert.addAction(okBtn)
        alert.addAction(noBtn)
        self.present(alert, animated: true, completion: nil)
        
    }
    func getQues(_ type: Int){
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
        
        if type == 1{
            viewCont.playType = "RandomQuiz"
        }else{
            viewCont.playType = "TrueFalse"
        }
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        var quesData: [QuestionWithE] = []
        var apiURL = ""
        
       //if sysConfig.LANGUAGE_MODE == 1{
          //  let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
            apiURL = "&type=\(type)&limit=10" //type 1 -> random quiz and type 2 -> true-false
       // }
        
        Loader = LoadLoader(loader: Loader)
        self.getAPIData(apiName: "get_questions_by_type", apiURL: apiURL,completion: {jsonObj in
            print("JSON",jsonObj)
            //close loader here
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                DispatchQueue.main.async {
                    self.DismissLoader(loader: self.Loader)
                }
            });
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
                //self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            }else{
//                loadTrueFalseQues(jsonObj: jsonObj)
                quesData.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                    for val in data{
                        quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                    }
                    Apps.TOTAL_PLAY_QS = data.count
                    //check this level has enough (10) question to play? or not
                    if quesData.count >= Apps.TOTAL_PLAY_QS {
                        viewCont.quesData = quesData
                        DispatchQueue.global().asyncAfter(deadline: .now() + 0.6, execute: {
                            DispatchQueue.main.async {
                                self.navigationController?.pushViewController(viewCont, animated: true)
                            }
                        })
                       
                    }
                }
            }
        })        
    }
    
    func getQuestions(_ type: String){ //type should be random,true/false or daily only
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
        //viewCont.playType = "daily"
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        var quesData: [QuestionWithE] = []
        var apiURL = ""
        var apiName = "get_daily_quiz"
        
        if sysConfig.LANGUAGE_MODE == 1{
            let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
            apiURL += "language_id=\(langID)"
        }
        
        Loader = LoadLoader(loader: Loader)
        if type == "random"{
            apiName = "get_questions_by_type" //"get_random_questions"
            apiURL += "&type=1&limit=10&"//type:1  //1=normal ,2 = true/false
            viewCont.titlebartext = "Random Quiz"
            viewCont.playType = "RandomQuiz"
        }else if type == "true/false"{
            apiName = "get_questions_by_type"
            apiURL += "&type=2&limit=10"
            viewCont.titlebartext = "True/False"
            viewCont.playType = "True/False"
        }else{ //Daily
            apiName = "get_daily_quiz"
            viewCont.playType = "daily"
        }
        self.getAPIData(apiName: "\(apiName)", apiURL: apiURL,completion: {jsonObj in
            print("JSON",jsonObj)
            //close loader here
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                DispatchQueue.main.async {
                    self.DismissLoader(loader: self.Loader)
                }
            });
            let status = jsonObj.value(forKey: "error") as! String
            if (status == "true") {
                //self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                //show random 10 questions if there are no questions in daily quiz.
                var apiURL = ""
                if self.sysConfig.LANGUAGE_MODE == 1{
                       let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
                       apiURL = "&language_id=\(langID)" //+=
               }
                self.getAPIData(apiName: "get_random_questions_for_computer", apiURL: apiURL,completion: loadQuestions)
                
            }else{
               loadQuestions(jsonObj: jsonObj)
            }
        })
        
        func loadQuestions(jsonObj:NSDictionary){
            //get data for category
            quesData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    quesData.append(QuestionWithE.init(id: "\(val["id"]!)", question: "\(val["question"]!)", opetionA: "\(val["optiona"]!)", opetionB: "\(val["optionb"]!)", opetionC: "\(val["optionc"]!)", opetionD: "\(val["optiond"]!)", opetionE: "\(val["optione"]!)", correctAns: ("\(val["answer"]!)").lowercased(), image: "\(val["image"]!)", level: "\(val["level"]!)", note: "\(val["note"]!)", quesType: "\(val["question_type"]!)"))
                    
                }
                
                Apps.TOTAL_PLAY_QS = data.count
                
                //check this level has enough (10) question to play? or not
                if quesData.count >= Apps.TOTAL_PLAY_QS {
                    viewCont.quesData = quesData
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.6, execute: {
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }
                    })
                   
                }
            }
        }
        
    }
    
    //battle modes
    @objc func MakeUserOnline(){
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if let userDT = UserDefaults.standard.value(forKey:"user"){
                let user = try! PropertyListDecoder().decode(User.self, from: (userDT as? Data)!)
                var userDetails:[String:String] = [:]
                // userDetails["UID"] = user.UID
                userDetails["userID"] = user.userID
                userDetails["name"] = user.name
                userDetails["image"] = user.image
                userDetails["status"] = "free"
                // set data for available to battle with users in firebase database
                self.ref.child(user.UID).setValue(userDetails)
            }
        }
    }
    
    @objc func MakeUserOffiline(){
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            if let userDT = UserDefaults.standard.value(forKey:"user"){
                let ref = Database.database().reference().child(Apps.ROOM_NAME)
                let user = try! PropertyListDecoder().decode(User.self, from: (userDT as? Data)!)
                ref.child(user.UID).removeValue()
            }
        }
    }
    
    @objc func ShowInvitationAlert(){
        
        if self.isUserBusy{
            ref.removeAllObservers()
            return
        }        
        
        
        let alert = UIAlertController(title: "Game Invitation", message: "You have been invited to room \(self.roomDetails!.roomName) by your friend", preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "Invitation Accepted", style: .default, handler: {_ in
            print("Invitation accepted")
            
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = storyboard.instantiateViewController(withIdentifier: "PrivateRoomView") as! PrivateRoomView
                
                viewCont.roomInfo = self.roomDetails
                viewCont.selfUser = false
                self.isUserBusy = true
                
                self.navigationController?.pushViewController(viewCont, animated: true)
                let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
                let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomDetails!.roomFID).child("joinUser").child(user.UID)
                refR.child("isJoined").setValue("true")
                
                self.ref.child(user.UID).child("status").setValue("busy")
            }
        })
        let rejectAction = UIAlertAction(title: "Invitation Rejected", style: .cancel, handler: {_ in
            print("Invitation rejected")
            
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            
            let refR = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME).child(self.roomDetails!.roomFID).child("joinUser")
            refR.child(user.UID).removeValue()
            
            self.ref.removeAllObservers()
            refR.removeAllObservers()
            
            let refOnline = Database.database().reference().child(Apps.ROOM_NAME).child(user.UID)
            refOnline.child("status").setValue("free")
            refOnline.removeAllObservers()
            
        })
        
        alert.addAction(acceptAction)
        alert.addAction(rejectAction)
        
        self.present(alert, animated: true, completion: nil)
        
        if Apps.badgeCount > 0 {
            Apps.badgeCount -= 1
            UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")           
        }
        UIApplication.shared.applicationIconBadgeNumber = Apps.badgeCount
    }
    
    func ObserveInvitation(){
        if self.isUserBusy{
            ref.removeAllObservers()
            return
        }
        if UserDefaults.standard.bool(forKey: "isLogedin"){
        let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        let  ref = Database.database().reference().child(Apps.PRIVATE_ROOM_NAME)
        ref.observe(.value, with: { (snapshot) in
            if let data = snapshot.value as? [String:Any]{
                for val in data{
                    if let fireroom = val.value as? [String:Any]{
                        if  "\(fireroom["isStarted"] ?? "false")".bool ?? false{
                            // room is already started
                            continue
                        }
                        if "\(fireroom["isRoomActive"] ?? "false")".bool ?? false {
                            // room is active still & room is not started
                        }else{
                            //room is deactive by room owner
                            continue
                        }
                        if let roomUser = fireroom["roomUser"] as? [String:Any]{
                            if  let joinUser = fireroom["joinUser"] as? [String:Any]{
                                for ju in joinUser{
                                    if let udj = ju.value as? [String:Any]{
                                        if "\(udj["userID"]!)" == "\(roomUser["userID"] ?? "0")"{
                                            // same user do not show any invitation alert
                                            continue
                                        }else{
                                            if joinUser.keys.contains(user.UID){
                                                if let uUser = joinUser[user.UID] as? [String:Any]{
                                                    // print("UU USER",uUser)
                                                    if uUser["userID"] as! String == "\(roomUser["userID"] ?? "0")"{
                                                        // same user do not show any invitation alert
                                                        continue
                                                    }
                                                }
                                                //print("User got invitation here")
                                                self.roomDetails = RoomDetails.init(ID:  "\(fireroom["roomID"]!)", roomFID: val.key, userID: "\(roomUser["userID"] ?? "0")", roomName: "\(fireroom["roomName"]!)", catName: "\(fireroom["category"]!)", catLavel: "\( fireroom["catLavel"] ?? "0")", noOfPlayer: "\(fireroom["noOfPlayer"]!)", noOfQues: "\(fireroom["noOfQuestion"]!)", playTime: "\( fireroom["time"]!)")
                                                
                                                self.ShowInvitationAlert()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                    }
                }
            }
        })
        }
    }
    
    func timeFormatter(_ totalSeconds: Int) -> String {
            let seconds: Int = totalSeconds % 60
            let minutes: Int = (totalSeconds / 60) % 60
//            let hours: Int = (totalSeconds / 60 / 60) % 24
//            let days: Int = (totalSeconds / 60 / 60 / 24)
            return String(format: "%02d : %02d", minutes, seconds)
        }
    
}
