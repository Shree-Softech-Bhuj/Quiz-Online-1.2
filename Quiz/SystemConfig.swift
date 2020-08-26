import UIKit
import Foundation

class SystemConfig: UIViewController {
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var NotificationList: [Notifications] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.LoadLanguages(completion: {})
        
    }
    func updtFCMToServer(){
        //update fcm id
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            let duser =  try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
           // print(duser)
            if duser.userID != ""{
                if(Reachability.isConnectedToNetwork()){
                    let apiURL = "user_id=\(duser.userID)&fcm_id=\(Apps.FCM_ID)"
                    self.getAPIData(apiName: "update_fcm_id", apiURL: apiURL,completion: LoadResponse)
                }
            }else{
                print("user ID not available. Try again Later !")
            }
        }
    }
    //load response of updtFCMid data here
    func LoadResponse(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            
        }else{
            // on success response do code here
            let msg = jsonObj.value(forKey: "message") as! String
            print(msg)
        }
    }
    
    
    func ConfigureSystem() {
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let apiURL = ""//Apps.OPTION_E
            self.getAPIData(apiName: Apps.SYSTEM_CONFIG, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        // var optE = ""
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") {
                guard let DATA = data as? [String:Any] else{
                    return
                }
                //print(DATA)
                let state = DATA["option_e_mode"]  as! String
                if state == "1" {
                    Apps.opt_E = true
                }else{
                    Apps.opt_E = false
                }
                
                let langMode:String =  "\(DATA["language_mode"] ?? 0)"
                let config = SystemConfiguration.init(LANGUAGE_MODE: Int(langMode) ?? 0)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(config),forKey: DEFAULT_SYS_CONFIG)
                if langMode == "0" { //clear default lang. if language mode is disabled
                    UserDefaults.standard.removeObject(forKey: DEFAULT_USER_LANG)
                }
                
                let more_apps = DATA["ios_more_apps"]  as! String
                Apps.MORE_APP = more_apps
               // print("more apps link from server -- \(more_apps)")
                
                let share_apps = DATA["ios_app_link"]  as! String
                Apps.SHARE_APP = share_apps
                //print("share apps link from server -- \(share_apps)")
                
                let share_txt = DATA["shareapp_text"]  as! String
                Apps.SHARE_APP_TXT = share_txt
              //  print("share apps text from server -- \(share_txt)")
                
                let ans_mode = DATA["answer_mode"]  as! String
                Apps.ANS_MODE = ans_mode
                
                let refer_coin = DATA["refer_coin"] as! String
                Apps.REFER_COIN = refer_coin
                //print("refer coin value -- \(refer_coin)")
                
                let earn_coin = DATA["earn_coin"]  as! String
                Apps.EARN_COIN = earn_coin
               // print("earn coin value -- \(earn_coin)")
                
                let reward_coin = DATA["reward_coin"] as! String
                Apps.REWARD_COIN = reward_coin
               // print("reward coin value -- \(reward_coin)")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
            }
        });
    }
    //get notifications from API
    func getNotifications() {
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            let apiURL = ""
            self.getAPIData(apiName: Apps.NOTIFICATIONS, apiURL: apiURL,completion: LoadNotifications)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    //load category data here
    func LoadNotifications(jsonObj:NSDictionary){
       // print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                //    self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }else{
            //get data for category
            self.NotificationList.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    NotificationList.append(Notifications.init(title: "\(val["title"]!)", msg: "\(val["message"]!)", img: "\(val["image"]!)")) 
                   // print("title \(val["title"]!) msg  \(val["message"]!) img \(val["image"]!)")
                }
                UserDefaults.standard.set(try? PropertyListEncoder().encode(NotificationList), forKey: "notification")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
            }
        });
    }
    
    func LoadLanguages(completion:@escaping ()->Void){
        if(Reachability.isConnectedToNetwork()){
            let apiURL = ""//Apps.OPTION_E
            self.getAPIData(apiName: API_LANGUAGE_LIST, apiURL: apiURL,completion: { jsonObj in
                
             // print("RS- lang.",jsonObj.value(forKey: "data"))
                // var optE = ""
                let status = jsonObj.value(forKey: "error") as! String
                if (status == "true") {
                    self.Loader.dismiss(animated: true, completion: {
                        self.ShowAlert(title:Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                    })
                }else{
                    var lang_id = 0
                    //get data for category
                    var lang:[Language] = []
                    if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                        for val in data{
                            lang.append(Language.init(id: Int("\(val["id"]!)")!, name: "\(val["language"]!)", status: Int("\(val["status"]!)")!))
                            lang_id = Int("\(val["id"]!)")!
                        }
                        if data.count == 1 { // if only one language is present in admin panel, then select it by default
                            UserDefaults.standard.set(lang_id , forKey: DEFAULT_USER_LANG)
                        }
                    }
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(lang),forKey: DEFAULT_LANGUAGE)
                
                    completion()
                }
            })
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
}
