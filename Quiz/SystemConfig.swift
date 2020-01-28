import UIKit
import Foundation

class SystemConfig: UIViewController {
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    var NotificationList: [Notifications] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        //print("RS",jsonObj.value(forKey: "data"))
        // var optE = ""
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "status")!)" )
            })
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") {
                guard let DATA = data as? [String:Any] else{
                    return
                }
                
                let state = DATA["option_e_mode"]  as! String
                if state == "1" {
                    Apps.opt_E = true
                }else{
                    Apps.opt_E = false
                }
                
                let langMode:String =  "\(DATA["language_mode"] ?? 0)"
                let config = SystemConfiguration.init(LANGUAGE_MODE: Int(langMode) ?? 0)
                UserDefaults.standard.set(try? PropertyListEncoder().encode(config),forKey: DEFAULT_SYS_CONFIG)
                //print("\(Apps.opt_E) - option E")                
                
                let more_apps = DATA["more_apps"]  as! String
                Apps.MORE_APP = more_apps
                print("more apps link from server -- \(more_apps)")
                
                let share_apps = DATA["app_link"]  as! String
                Apps.SHARE_APP = share_apps
                print("share apps link from server -- \(share_apps)")
                
                let share_txt = DATA["shareapp_text"]  as! String
                Apps.SHARE_APP_TXT = share_txt
                print("share apps text from server -- \(share_txt)")
                
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
           
            let status = jsonObj.value(forKey: "error") as! String
//            let msg = jsonObj.value(forKey: "message") as! String
//            print(msg)
            if (status == "true") {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "status")!)" )
                })
            }else{
                //get data for category
                self.NotificationList.removeAll()
                if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                  for val in data{
                    NotificationList.append(Notifications.init(title: "\(val["title"]!)", msg: "\(val["message"]!)", img: "\(val["image"]!)"))
                    print("title \(val["title"]!) msg  \(val["message"]!) img \(val["image"]!)")
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
                
                //print("RS",jsonObj.value(forKey: "data"))
                       // var optE = ""
                       let status = jsonObj.value(forKey: "error") as! String
                       if (status == "true") {
                           self.Loader.dismiss(animated: true, completion: {
                               self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "status")!)" )
                           })
                       }else{
                           //get data for category
                        var lang:[Language] = []
                           if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                               for val in data{
                                lang.append(Language.init(id: Int("\(val["id"]!)")!, name: "\(val["language"]!)", status: Int("\(val["status"]!)")!))
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
