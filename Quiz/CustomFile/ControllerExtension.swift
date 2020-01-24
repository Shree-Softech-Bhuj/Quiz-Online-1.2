import Foundation
import UIKit
import AVFoundation
import Reachability
import SystemConfiguration

extension UIViewController{
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func hideCurrViewWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissCurrView))
        tap.numberOfTapsRequired = 2
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissCurrView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //play sound
    func PlaySound(player:inout AVAudioPlayer!,file:String){
        let soundURL = Bundle.main.url(forResource: file, withExtension: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: soundURL!)
        }
        catch {
            print(error)
        }
        let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        if setting.sound {
            player.play()
        }
    }
    
    func PlayBackgrounMusic(player:inout AVAudioPlayer!,file:String){
        let soundURL = Bundle.main.url(forResource: file, withExtension: "mp3")
        do {
            player = try AVAudioPlayer(contentsOf: soundURL!)
            player.numberOfLoops = -1
            player.prepareToPlay()
            
            if(UserDefaults.standard.value(forKey:"setting") == nil){
                UserDefaults.standard.set(try? PropertyListEncoder().encode(Setting.init(sound: true, backMusic: true, vibration: true)),forKey: "setting")
            }
            let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
            
            if setting.backMusic {
                player.play()
            }
        }
        catch {
            print(error)
        }
    }
    
    //do device vibration
    func Vibrate(){
        let setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        if setting.vibration {
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    
    // get api data
    func getAPIData(apiName:String, apiURL:String,completion:@escaping (NSDictionary)->Void,image:UIImageView? = nil){
        let url = URL(string: Apps.URL)!
        let postString = "access_key=\(Apps.ACCESS_KEY)&\(apiName)=1&\(apiURL)"
        print("postString -- \(postString)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        //let data = NSMutableData();
        //request.httpBody = postString.data(using: .utf8)
        
        request.httpBody = Data(postString.utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {             // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {   // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                if (jsonObj != nil)  {
                    completion(jsonObj!)
                }else{
                    let res = ["status":false,"message":"JSON Parser Error"] as NSDictionary
                    completion(res)
                    print("JSON API ERROR",String(data: data, encoding: String.Encoding.utf8))
                }
            }else{
                let res = ["status":false,"message":"Error while fetching data"] as NSDictionary
                completion(res)
                print("JSON API ERROR",String(data: data, encoding: String.Encoding.utf8))
            }
        }
        task.resume()
    }
    
    //load loader
    func LoadLoader(loader:UIAlertController)->UIAlertController{
        let pending = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        pending.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(origin: CGPoint(x:10,y:5), size: CGSize(width: 50, height: 50))) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorView.Style.gray
        loadingIndicator.startAnimating();
        
        pending.view.addSubview(loadingIndicator)
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2, execute: {
            DispatchQueue.main.async {
                self.present(pending, animated: true, completion: nil)
            }
        });
        
        return pending 
    }
    //show alert view here with any title and messages
    func ShowAlert(title:String,message:String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.cancel, handler: nil))
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        });
        
    }
    //dismiss loader
    func DismissLoader(loader:UIAlertController){
        loader.dismiss(animated: true, completion: nil)
    }
    
    // reachability class
    public class Reachability {
        class func isConnectedToNetwork() -> Bool {
            
            var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
            zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
            zeroAddress.sin_family = sa_family_t(AF_INET)
            
            let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
                $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                    SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
                }
            }
            var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
            if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
                return false
            }
            
            // Working for Cellular and WIFI
            let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
            let ret = (isReachable && !needsConnection)
            return ret
            
        }
    }
    
    
    func resetOpetionsPositions(_ btnb: UIButton,_ btnc: UIButton,_ btnd: UIButton){
//        let Xb_Position:CGFloat = 23.0 //use your X position here
//        let Yb_Position:CGFloat = 500.0 //use your Y position here
//
//        btnb.frame = CGRect(x: Xb_Position, y: Yb_Position, width: btnb.frame.width, height: btnb.frame.height)
//
//        let Xc_Position:CGFloat = 23.0 //use your X position here
//        let Yc_Position:CGFloat = 590.0 //use your Y position here
//
//        btnc.frame = CGRect(x: Xc_Position, y: Yc_Position, width: btnc.frame.width, height: btnc.frame.height)
//
//        let Xd_Position:CGFloat = 23.0 //use your X position here
//        let Yd_Position:CGFloat = 675.0 //use your Y position here
//
//        btnd.frame = CGRect(x: Xd_Position, y: Yd_Position, width: btnd.frame.width, height: btnd.frame.height)
    }
     
    func RegisterNotification(notificationName:String){
        NotificationCenter.default.addObserver(self,selector: #selector(self.Dismiss),name: NSNotification.Name(rawValue: notificationName),object: nil)
    }
    @objc func Dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    func CallNotification(notificationName:String){
        NotificationCenter.default.post(name: Notification.Name(notificationName), object: nil)
    }
    
    // set verticle progress bar here
    func setVerticleProgress(view:UIView, progress:UIProgressView){
        view.addSubview(progress)
        progress.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progress.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        progress.widthAnchor.constraint(equalToConstant: view.frame.size.height).isActive = true
        progress.heightAnchor.constraint(equalToConstant: 20).isActive = true
        progress.setProgress(0, animated: true)
    }
    
    //design four choice view function
    func SetViewWithShadow(views:UIView...){
        for view in views{
            view.layer.cornerRadius = 25
            view.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        }
    }
    
    // design opetion button
    func DesignOpetionButton(buttons: UIButton...){
        for button in buttons{
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.lineBreakMode = .byCharWrapping
        }
    }
    
    func AllignButton(buttons:UIButton...){
        let width = self.view.frame.width
        var x = (width - (CGFloat(buttons.count) * buttons[0].frame.width)) / CGFloat(buttons.count + 1)
        let tempX = x
        var count = 0
        for button in buttons{
            button.frame.origin.x = x + button.frame.width * CGFloat(count)
            x = x + tempX
            count += 1
        }
    }
}
