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
    
    let arr = [Apps.QUIZ_ZONE,Apps.PLAY_ZONE,Apps.BATTLE_ZONE,Apps.CONTEST_ZONE] //[Apps.PLAY_ZONE,Apps.BATTLE_ZONE,Apps.CONTEST_ZONE,Apps.QUIZ_ZONE]//
    let leftImg = [Apps.IMG_QUIZ_ZONE,Apps.IMG_PLAYQUIZ,Apps.IMG_BATTLE_QUIZ,Apps.IMG_CONTEST_QUIZ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "QuizZone")

        
        self.PlayBackgrounMusic(player: &backgroundMusicPlayer, file: "snd_bg")
        
        leaderboardButton.layer.cornerRadius = leaderboardButton.frame.height / 4
        leaderboardButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        languageButton.layer.cornerRadius = leaderboardButton.frame.height / 4
      //  moreButton.layer.cornerRadius = moreButton.frame.height / 4
        allTimeScoreButton.layer.cornerRadius = leaderboardButton.frame.height / 4
        allTimeScoreButton.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        coinsButton.layer.cornerRadius = leaderboardButton.frame.height / 4
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
      //  getQuestions("random")//("true/false")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true"){
        }else{
            //get data for category
            catData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
                }
            }
        }
    }
    
    func getUserNameImg(){
        //user name and display image
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            userName.text = "\(Apps.HELLO)  \(dUser!.name)"
           // userName.frame.origin = CGPoint(x: -100, y: userName.frame.origin.y)
//            userName.textChangeAnimationToRight()
            
            //imgProfile.SetShadow()
            imgProfile.layer.cornerRadius =  imgProfile.frame.height / 2
            imgProfile.layer.masksToBounds = true//false
            imgProfile.clipsToBounds = true
            
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
//            userName.textChangeAnimationToRight()
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
        if(Reachability.isConnectedToNetwork()){
            if config?.LANGUAGE_MODE == 1{
                apiName = "get_categories_by_language"
                apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
            }
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            let apiURL = "user_id=\(userD.userID)"
            self.getAPIData(apiName: Apps.API_BOOKMARK_GET, apiURL: apiURL,completion: LoadBookmarkData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        leaderboardButton.setTitle(Apps.ALL_TIME_RANK as? String , for: .normal)//(String(Apps.ALL_TIME_RANK) , for: .normal)
        allTimeScoreButton.setTitle(Apps.SCORE as? String, for: .normal)
        coinsButton.setTitle(Apps.COINS , for: .normal)
        
        varSys.getUserDetails()
//        self.DailyQuiz.alpha = 0
//        self.contestButton.alpha = 0
//        if Apps.FORCE_UPDT_MODE == "1" {
//            self.CheckAppsUpdate()
//        }
//        if Apps.DAILY_QUIZ_MODE == "1" {
//            self.DailyQuiz.alpha = 1
//        }
//        if Apps.CONTEST_MODE == "1" {
//          self.contestButton.alpha = 1
//        }
        getUserNameImg()
    }
    //load Bookmark data here
    func LoadBookmarkData(jsonObj:NSDictionary){
        // print("RS",jsonObj)
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
                //self.DismissLoader(loader: self.Loader)
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
//        if languageButton.isHidden == false{
//            if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
//                LanguageButton(self)
//            }
//        }
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
        
//        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
//        let viewCont = storyboard.instantiateViewController(withIdentifier: "CategoryView")
//        self.navigationController?.pushViewController(viewCont, animated: true)

//        performSegue(withIdentifier: "CategoryView", sender: nil)

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
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = ""
        if indexPath.row == 1 {
            cellIdentifier = "PlayZone"
        }
        if indexPath.row == 0 {
            cellIdentifier = "QuizZone"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! HomeTableViewCell
        print("test -- \(arr[indexPath.row])")
        
        cell.titleLabel.text = arr[indexPath.row]
        cell.leftImg.image = UIImage(named: leftImg[indexPath.row])
        cell.cellDelegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected - \(indexPath.row)")
    }
}
extension HomeScreenController:CellSelectDelegate{
    
    func didCellSelected(){
        print("Call FUNCTION HERE+")
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        //check if language is enabled and not selected
        if languageButton.isHidden == false{
            if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
                LanguageButton(self)
            }
        }
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "subcategoryview") //as! subCategoryViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    func viewAll() {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "categoryview") as! CategoryViewController
        self.navigationController?.pushViewController(viewCont, animated: true)
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
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
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
//        func loadTrueFalseQues(jsonObj:NSDictionary){
//
//        }
        
    }
    
    func getQuestions(_ type: String){ //type should be random,true/false or daily only
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
        viewCont.playType = "daily"
        
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
        }else if type == "true/false"{
            apiName = "get_questions_by_type"
            apiURL += "&type=2&limit=10"
            viewCont.titlebartext = "True/False"
        }else{ //Daily
            apiName = "get_daily_quiz"
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
    
}
