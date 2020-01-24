import UIKit
import Foundation

class OptionEmode_Controller: UIViewController {
    
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
                guard let optE = data as? [String:Any] else{
                    return //Apps.opt_E = false //"0"
                }
                let state = optE["option_e_mode"]  as! String
           //   Apps.opt_E = state
                if state == "1" {
                    Apps.opt_E = true
                }else{
                    Apps.opt_E = false
                }
                //print("\(Apps.opt_E) - option E")
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
