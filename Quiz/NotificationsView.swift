import UIKit

class NotificationsView : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!

    var NotificationList: [Notifications] = []
    
     var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //get notifications list
       // getNotifications()
        if (UserDefaults.standard.value(forKey: "notification") != nil){
                NotificationList = try! PropertyListDecoder().decode([Notifications].self,from:(UserDefaults.standard.value(forKey: "notification") as? Data)!)
           }
        
    }
    
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
            //print("RS",jsonObj.value(forKey: "data"))
           // var optE = ""
            let status = jsonObj.value(forKey: "error") as! String
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
                  //  print("title \(val["title"]!) msg  \(val["message"]!) img \(val["image"]!)")
                }
                  //  UserDefaults.standard.set(try? PropertyListEncoder().encode(NotificationList), forKey: "notification")
              }
            }
            //close loader here
            DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
                DispatchQueue.main.async {
                    self.DismissLoader(loader: self.Loader)
                }
            });
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
       
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = NotificationList[indexPath.row].img == "" ? 100 : 130
        return height
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if NotificationList.count == 0{
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = Apps.NO_NOTIFICATION
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
      //  print(NotificationList.count)
        return NotificationList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = NotificationList[indexPath.row].img != "" ? "NotifyCell" : "NotifyCellNoImage"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        cell.qstn.text = NotificationList[indexPath.row].title
//        if(NotificationList[indexPath.row].msg == "a"){
            cell.ansr.text = NotificationList[indexPath.row].msg
//        }

        if(NotificationList[indexPath.row].img != ""){
            DispatchQueue.main.async {
                cell.bookImg.loadImageUsingCache(withUrl: self.NotificationList[indexPath.row].img)
            }
        }
        cell.bookView.SetShadow()
        cell.bookView.layer.cornerRadius = 15
        cell.bookView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 6.0,options: .allowUserInteraction,
                       animations: { [weak self] in
                        cell.bookView.transform = .identity
                        
            },completion: nil)
        return cell
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
