import UIKit
import Foundation

class SystemConfig: UIViewController {
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getOptEstate()
    }
    func getOptEstate() {
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
}
