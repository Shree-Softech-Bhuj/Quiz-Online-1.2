import UIKit
import Firebase
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var startView: UIView!
    @IBOutlet var battleView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var battleButton: UIButton!
    @IBOutlet weak var selfChallange: UIButton!
    @IBOutlet weak var DailyQuiz: UIButton!
    @IBOutlet weak var contestButton: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var leaderButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet var languageButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnsView: UIView!
    @IBOutlet weak var bgView: UIImageView!
    @IBOutlet weak var randomQuizBtn: UIButton!
    @IBOutlet weak var trueFalseBtn: UIButton!
    @IBOutlet weak var bookrmarksBtn: UIButton!
    
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet weak var allTimeScoreButton: UIButton!
    @IBOutlet weak var coinsButton: UIButton!
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.PlayBackgrounMusic(player: &backgroundMusicPlayer, file: "snd_bg")
        
        playButton.layer.cornerRadius = playButton.frame.height / 4//32
        //startView.SetDarkShadow()
        battleButton.layer.cornerRadius = battleButton.frame.height / 4//32
        //battleView.SetDarkShadow()
        selfChallange.layer.cornerRadius = selfChallange.frame.height / 4//32
        //selfChallange.SetDarkShadow()
        DailyQuiz.layer.cornerRadius = selfChallange.frame.height / 4//32
        //DailyQuiz.SetDarkShadow()
        contestButton.layer.cornerRadius = contestButton.frame.height / 4//32
        //contestButton.SetDarkShadow()
        
      //  btnsView.layer.cornerRadius = btnsView.frame.height / 6//32
        bgView.layer.cornerRadius = bgView.frame.height / 6//32
        bookrmarksBtn.layer.cornerRadius = bookrmarksBtn.frame.height / 4
        trueFalseBtn.layer.cornerRadius = trueFalseBtn.frame.height / 4
        randomQuizBtn.layer.cornerRadius = randomQuizBtn.frame.height / 4
        
        leaderboardButton.layer.cornerRadius = leaderboardButton.frame.height / 4
        languageButton.layer.cornerRadius = leaderboardButton.frame.height / 4
        
        allTimeScoreButton.layer.cornerRadius = leaderboardButton.frame.height / 4
        coinsButton.layer.cornerRadius = leaderboardButton.frame.height / 4
        
        
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
        
        //show all 5 buttons even if user is not logged in, instead chng action of logout button
        self.AllignButton(buttons: leaderButton,profileButton,settingButton,logoutButton,moreButton)
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
        }else{
            if deviceStoryBoard == "Ipad" {
                logoutButton.setBackgroundImage(UIImage(named: "login"), for: .normal) //chng image for logout button
            }else{
                logoutButton.setImage(UIImage(named: "login"), for: .normal) //chng image for logout button
            }
        }
        
        if UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) != nil {
            sysConfig = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
        getUserNameImg()
    }
    func getUserNameImg(){
        //user name and display image
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            userName.text = "\(Apps.HELLO)  \(dUser!.name)"
            
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
            imgProfile.image = UIImage(named: "guest") //"user")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        languageButton.isHidden = true
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
            let config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
            if config.LANGUAGE_MODE == 1{
                languageButton.isHidden = false
            }
        }
        
        if isKeyPresentInUserDefaults(key: "isLogedin"){
            if !UserDefaults.standard.bool(forKey: "isLogedin"){
                return
            }
        }else{
            return
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
        allTimeScoreButton.setTitle(Apps.SCORE as! String, for: .normal)
        coinsButton.setTitle(Apps.COINS , for: .normal)
        
        varSys.getUserDetails()
        self.DailyQuiz.alpha = 0
        self.contestButton.alpha = 0
        if Apps.FORCE_UPDT_MODE == "1" {
            self.CheckAppsUpdate()
        }
        if Apps.DAILY_QUIZ_MODE == "1" {
            self.DailyQuiz.alpha = 1
        }
        if Apps.CONTEST_MODE == "1" {
          self.contestButton.alpha = 1
        }
        getUserNameImg()
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
    @IBAction func showBookmarks(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "BookmarkView")
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    @IBAction func playTrueFalse(_ sender: Any) {
        if(Reachability.isConnectedToNetwork()){
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                self.getQues(2)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    @IBAction func playRandomQuiz(_ sender: Any) {
        if(Reachability.isConnectedToNetwork()){
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                self.getQues(1)
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        
    }
    
    //load Bookmark data here
    func LoadBookmarkData(jsonObj:NSDictionary){
        // print("RS BK",jsonObj)
        var BookQuesList: [QuestionWithE] = []
        
        let status = "\(jsonObj.value(forKey: "error") ?? "1")".bool ?? true
        if (status) {
            DispatchQueue.main.async {
                //                 self.Loader.dismiss(animated: true, completion: {
                //                     //self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                //                 })
            }
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
    
    @IBAction func moreBtn(_ sender: UIButton) {
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "MoreOptions")
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    @IBAction func showContest(_ sender: Any) {
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        //check if language is enabled and not selected
//        if languageButton.isHidden == false{
//            if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
//                LanguageButton(self)
//            }
//        }
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "ContestView")
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    // play background music function
    @objc func PlayBackMusic(){
        backgroundMusicPlayer.play()
    }
    
    // stop background music function
    @objc func StopBackMusic(){
        backgroundMusicPlayer.stop()
    }
    
    @IBAction func LanguageButton(_ sender: Any){
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let view = storyboard.instantiateViewController(withIdentifier: "LanguageView") as! LanguageView
        view.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        view.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(view, animated: true, completion: nil)
    }
    
    @IBAction func playBtn(_ sender: Any) {
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        //check if language is enabled and not selected
        if languageButton.isHidden == false{
            if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
                LanguageButton(self)
            }
        }
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "CategoryView")
        self.navigationController?.pushViewController(viewCont, animated: true)
        
    }
    
    @IBAction func battleBtn(_ sender: Any) {
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        //check if language is enabled and not selected
        if languageButton.isHidden == false{
            if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
                LanguageButton(self)
            }
        }
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "BattleViewController")
            self.navigationController?.pushViewController(viewCont, animated: true)
            
        }else{            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    @IBAction func SelfChallengeBtn(_ sender: Any) {
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        //check if language is enabled and not selected
        if languageButton.isHidden == false{
            if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
                LanguageButton(self)
            }
        }
        
//        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "SelfChallengeController") as! SelfChallengeController
            self.navigationController?.pushViewController(viewCont, animated: true)
//        }else{
//            self.navigationController?.popToRootViewController(animated: true)
//        }
    }
    
    @IBAction func DailyQuiz(_ sender: Any) {
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        //check if language is enabled and not selected
        if languageButton.isHidden == false{
            if UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG) == 0 {
                LanguageButton(self)
            }
        }
        
        if(Reachability.isConnectedToNetwork()){
            if UserDefaults.standard.bool(forKey: "isLogedin"){
                self.getDailyQues()
            }else{
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
  
    @IBAction func profileBtn(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "UpdateProfileView")
            self.navigationController?.pushViewController(viewCont, animated: true)
            
        }else{
            
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    @IBAction func privacyBtn(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        
        if !isKeyPresentInUserDefaults(key: "user"){
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
        let userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        
        let alert = UIAlertController(title: Apps.LOGOUT_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertAction.Style.default, handler: {
            (alertAction: UIAlertAction!) in
            if userD.userType == "apple"{
                // if app is not loged in than navigate to loginview controller
                UserDefaults.standard.set(false, forKey: "isLogedin")
                UserDefaults.standard.removeObject(forKey: "user")
                
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginView")
                
                let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                navigationcontroller.setNavigationBarHidden(true, animated: false)
                navigationcontroller.isNavigationBarHidden = true
                
                UIApplication.shared.keyWindow?.rootViewController = navigationcontroller
                
                let firebaseAuth = Auth.auth()
                do {
                  try firebaseAuth.signOut()
                } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
                }
              
                return
            }
            if Auth.auth().currentUser != nil {
                do {
                    try Auth.auth().signOut()
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "isLogedin")
                    
                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginView")
                    
                    let navigationcontroller = UINavigationController(rootViewController: initialViewController)
                    navigationcontroller.setNavigationBarHidden(true, animated: false)
                    navigationcontroller.isNavigationBarHidden = true
                    
                    UIApplication.shared.keyWindow?.rootViewController = navigationcontroller
                    return
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }))
        
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            present(alert, animated: true, completion: nil)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
            return
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
}

extension ViewController{
    
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
    func getDailyQues(){
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
        viewCont.playType = "daily"
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        var quesData: [QuestionWithE] = []
        var apiURL = ""
        
        if sysConfig.LANGUAGE_MODE == 1{
            let langID = UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG)
            apiURL += "language_id=\(langID)"
        }
        
        Loader = LoadLoader(loader: Loader)
        self.getAPIData(apiName: "get_daily_quiz", apiURL: apiURL,completion: {jsonObj in
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

