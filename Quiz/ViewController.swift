import UIKit
import Firebase
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var startView: UIView!
    @IBOutlet var battleView: UIView!
    @IBOutlet var bookBtn: UIButton!
    @IBOutlet var insBtn: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var battleButton: UIButton!
    
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var leaderButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    
    var audioPlayer : AVAudioPlayer!
    var backgroundMusicPlayer: AVAudioPlayer!
    var setting:Setting? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.PlayBackgrounMusic(player: &backgroundMusicPlayer, file: "snd_bg")
        
        DesignView(views: startView,battleView)
        DesignButton(btns:insBtn,bookBtn)
        
        playButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: playButton.frame.width / 4, bottom: 0, right: 0)
        battleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: playButton.frame.width / 4, bottom: 0, right: 0)
        
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
        
        //show all 4 buttons even if user is not logged in, instead chng action of logout button
            self.AllignButton(buttons: leaderButton,profileButton,settingButton,logoutButton)
        
        if UserDefaults.standard.bool(forKey: "isLogedin"){
            //self.AllignButton(buttons: leaderButton,profileButton,settingButton,logoutButton)
            //logoutButton.isHidden = false
        }else{
            //self.AllignButton(buttons: leaderButton,profileButton,settingButton)
            //logoutButton.isHidden = true
            logoutButton.setBackgroundImage(UIImage(named: "back"), for: .normal) //chng img for logout button
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
    
    @IBAction func BookmarkBtn(_ sender: Any) {
        //click sound
         self.PlaySound(player: &audioPlayer, file: "click")
        
        let goHome = self.storyboard!.instantiateViewController(withIdentifier: "BookmarkView")
        self.present(goHome, animated: true, completion: nil)
        
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

    
    //close on tap outside
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "closeMenuViaNotification"), object: nil)
        view.endEditing(true)
    }
    @IBAction func unwind(for unwindSegue: UIStoryboardSegue) {}
    // open menu
    @IBAction func toggleMenu(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "toggleMenu"), object: nil)
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
    
    //design uibutton view
    func DesignButton(btns:UIButton...){
        for btn in btns{
            btn.border(color: UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0), radius: btn.frame.size.height / 2, bWidth: 2)
        }
    }
    func DesignView(views:UIView...){
        for view in views{
            view.border(color: UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0), radius: view.frame.size.height / 2, bWidth: 2)
        }
    }
}

