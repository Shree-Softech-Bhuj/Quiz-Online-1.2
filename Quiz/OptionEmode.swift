import UIKit
import Foundation

class OptionEmode_Controller: UIViewController {
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get state of option E mode
//        if Apps.OPTION_E == "0"{
//            print("opt E disabled")
//        }else{
//            print("\(Apps.OPTION_E)--opt E enabled")
//        }
        //get data from server
           if(Reachability.isConnectedToNetwork()){
            let apiURL = Apps.OPTION_E
            self.getAPIData(apiName: Apps.SYSTEM_CONFIG, apiURL: apiURL,completion: LoadData)
           }else{
               ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
           }
        /*
         if (Constant.OPTION_E_MODE.equals("1"))
                                            Session.setBoolean(Session.E_MODE, true, context);
                                        else
                                            Session.setBoolean(Session.E_MODE, false, context);
         */
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
                 let optE = data
//                guard let optE = data as? [String:Any]
//                let email = optE["email"]  as! String
                print("\(optE) - option E")
                if let str: String = (optE as AnyObject) as! String{
                    let separator = "option_e_mode\" ="
                      if let r = str.range(of: separator, options: .backwards) {
                        let prefix = String(str[..<r.lowerBound])
                        let suffix = String(str[r.upperBound...])
//                                 let prefix = str.substring(to: r.lowerBound)
//                                 let suffix = str.substring(from: r.upperBound)
                                 print("PRE - \(prefix)")
                                 print("Suffix - \(suffix)")
                             } else{
                    print("else")
                    }
                }
              
              }
          }
//        for key in jsonObj {
//            let value = jsonObj[key]
//            print("Value:\(value ?? "value") - for key:\(key)");
//        }
              
          //close loader here
          DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
              DispatchQueue.main.async {
                  self.DismissLoader(loader: self.Loader)
              }
          });
          
      }

}
