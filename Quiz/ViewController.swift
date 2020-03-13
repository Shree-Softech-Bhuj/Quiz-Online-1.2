import UIKit
import Firebase
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var startView: UIView!
    @IBOutlet var battleView: UIView!
        
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var battleButton: UIButton!
    
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
        
        playButton.layer.cornerRadius = 32
        startView.SetDarkShadow()
        battleButton.layer.cornerRadius = 32
        battleView.SetDarkShadow()
        
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
            UserDefaults.standard.set(try? PropertyListEncoder().encode(UserScore.init(coins: 6, points: 0)), forKey: "UserScore")
        }
        
        //register nsnotification for latter call for play music and stop music
        NotificationCenter.default.addObserver(self,selector: #selector(self.PlayBackMusic),name: NSNotification.Name(rawValue: "PlayMusic"),object: nil) // for play music
        
         NotificationCenter.default.addObserver(self,selector: #selector(self.StopBackMusic),name: NSNotification.Name(rawValue: "StopMusic"),object: nil) // for stop music
        
        //show all 5 buttons even if user is not logged in, instead chng action of logout button
            self.AllignButton(buttons: leaderButton,profileButton,settingButton,logoutButton,moreButton)
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
        }else{
            logoutButton.setBackgroundImage(UIImage(named: "login"), for: .normal) //chng image for logout button
        }
        
        languageButton.isHidden = true
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
            let config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
            if config.LANGUAGE_MODE == 1{
                languageButton.isHidden = false
            }
        }
    }
    
    @IBAction func moreBtn(_ sender: UIButton) {
           let goHome = self.storyboard!.instantiateViewController(withIdentifier: "MoreOptions")
           goHome.modalPresentationStyle = .fullScreen
           goHome.modalTransitionStyle = .flipHorizontal
           self.present(goHome, animated: true, completion: nil)
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
        
        let goHome = self.storyboard!.instantiateViewController(withIdentifier: "CategoryView")
        self.present(goHome, animated: true, completion: nil)
        
    }
    
    @IBAction func battleBtn(_ sender: Any) {
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let goHome = self.storyboard!.instantiateViewController(withIdentifier: "BattleViewController")
            self.present(goHome, animated: true, completion: nil)
        }else{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
            present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func profileBtn(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let goHome = self.storyboard!.instantiateViewController(withIdentifier: "UpdateProfileView")
            self.present(goHome, animated: true, completion: nil)
        }else{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
            present(vc, animated: true, completion: nil)
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
        
        let alert = UIAlertController(title: Apps.LOGOUT_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            if Auth.auth().currentUser != nil {
                do {
                    try Auth.auth().signOut()
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "isLogedin")
                    //remove friend code
                    defaults.removeObject(forKey: "fr_code")
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
                    self.present(vc, animated: true, completion: nil)

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
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
            present(vc, animated: true, completion: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func leaderboardBtn(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            let goHome = self.storyboard!.instantiateViewController(withIdentifier: "Leaderboard")
            self.present(goHome, animated: true, completion: nil)
        }else{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
            present(vc, animated: true, completion: nil)
        }
    }
    
    func DesignView(views:UIView...){
        for view in views{
           // view.border(color: UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0), radius: view.frame.size.height / 2, bWidth: 2)
            view.border(color: UIColor(red: 57/255, green: 129/255, blue: 156/255, alpha: 0.5), radius: view.frame.size.height / 2, bWidth: 2)
        }
    }
}
