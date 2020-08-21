import UIKit
import Firebase
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var startView: UIView!
    @IBOutlet var battleView: UIView!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var battleButton: UIButton!
    @IBOutlet weak var selfChallange: UIButton!
    
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var leaderButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet var languageButton: UIButton!
    
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    var setting:Setting? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.PlayBackgrounMusic(player: &backgroundMusicPlayer, file: "snd_bg")
        
        playButton.layer.cornerRadius = playButton.frame.height / 2 //32
        startView.SetDarkShadow()
        battleButton.layer.cornerRadius = battleButton.frame.height / 2//32
        battleView.SetDarkShadow()
        selfChallange.layer.cornerRadius = selfChallange.frame.height / 2//32
        selfChallange.SetDarkShadow()
        
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
        
        //        if Apps.screenHeight < 700 {
        //            leaderButton.frame = CGRect(x: 20, y: 5, width: 35, height: 35)
        //            //  leaderButton.translatesAutoresizingMaskIntoConstraints = false
        //            
        //            profileButton.frame = CGRect(x: 94, y: 5, width: 35, height: 35)
        //            // profileButton.translatesAutoresizingMaskIntoConstraints = false
        //            
        //            settingButton.frame = CGRect(x: 171, y: 5, width: 35, height: 35)
        //            // settingButton.translatesAutoresizingMaskIntoConstraints = false
        //            
        //            logoutButton.frame = CGRect(x: 254, y: 5, width: 35, height: 35)
        //            //logoutButton.translatesAutoresizingMaskIntoConstraints = false
        //            
        //            moreButton.frame = CGRect(x: 328, y: 5, width: 35, height: 35)
        //            // moreButton.translatesAutoresizingMaskIntoConstraints = false
        //        }
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
        }else{
            if deviceStoryBoard == "Ipad" {
                logoutButton.setBackgroundImage(UIImage(named: "login"), for: .normal) //chng image for logout button
            }else{
                logoutButton.setImage(UIImage(named: "login"), for: .normal) //chng image for logout button
            }
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
         //print("RS",jsonObj)
         var BookQuesList: [QuestionWithE] = []
         
         let status = jsonObj.value(forKey: "error") as! String
         if (status == "true") {
             DispatchQueue.main.async {
                 self.Loader.dismiss(animated: true, completion: {
                     //self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
                 })
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
                 self.DismissLoader(loader: self.Loader)
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
