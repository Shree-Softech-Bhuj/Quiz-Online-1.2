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
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var leaderButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet var languageButton: UIButton!
    
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    var setting:Setting? = nil
    
      var sysConfig:SystemConfiguration!
      var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.PlayBackgrounMusic(player: &backgroundMusicPlayer, file: "snd_bg")
        
        playButton.layer.cornerRadius = playButton.frame.height / 2 //32
        startView.SetDarkShadow()
        battleButton.layer.cornerRadius = battleButton.frame.height / 2//32
        battleView.SetDarkShadow()
        selfChallange.layer.cornerRadius = selfChallange.frame.height / 2//32
        selfChallange.SetDarkShadow()
        DailyQuiz.layer.cornerRadius = selfChallange.frame.height / 2//32
        DailyQuiz.SetDarkShadow()
        
        //check setting object in user default
        if UserDefaults.standard.value(forKey:"setting") != nil {
            setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        }else{
            setting = Setting.init(sound: true, backMusic: true, vibration: true)
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
        
        
        self.CheckAppsUpdate()
    }
    override func viewDidAppear(_ animated: Bool) {
        languageButton.isHidden = true
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
            let config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
            if config.LANGUAGE_MODE == 1{
                languageButton.isHidden = false
            }
        }
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let userD:User = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            let apiURL = "user_id=\(userD.userID)"
            self.getAPIData(apiName: Apps.API_BOOKMARK_GET, apiURL: apiURL,completion: LoadBookmarkData)
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
                //                     //self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
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
    
    // play background music function
    @objc func PlayBackMusic(){
        backgroundMusicPlayer.play()
    }
    
    // stop background music function
    @objc func StopBackMusic(){
        backgroundMusicPlayer.stop()
    }
    
    @IBAction func LanguageButton(_ sender: Any){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "SelfChallengeController") as! SelfChallengeController
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            self.navigationController?.popToRootViewController(animated: true)
        }
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
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
    
    func DesignView(views:UIView...){
        for view in views{
            // view.border(color: UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0), radius: view.frame.size.height / 2, bWidth: 2)
            view.border(color: UIColor(red: 57/255, green: 129/255, blue: 156/255, alpha: 0.5), radius: view.frame.size.height / 2, bWidth: 2)
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
    
    func getDailyQues(){
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "PlayQuizView") as! PlayQuizView
        
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
            //  print("JSON",jsonObj)
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
                        DispatchQueue.main.async {
                            self.navigationController?.pushViewController(viewCont, animated: true)
                        }
                    }
                }
            }
         
        })
    }
}

