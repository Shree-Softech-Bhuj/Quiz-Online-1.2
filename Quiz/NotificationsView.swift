import UIKit
import GoogleMobileAds

class NotificationsView : UIViewController, UITableViewDelegate, UITableViewDataSource,GADBannerViewDelegate  {
    
    @IBOutlet var tableView: UITableView!

    var NotificationList: [Notifications] = []
    
     var Loader: UIAlertController = UIAlertController()
     @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Google AdMob Banner
        bannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
        bannerView.rootViewController = self
        let request = GADRequest()
        //request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        bannerView.load(request)
        
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
        //check if user entered in this view directly from notification ? if Yes then goTo Home page otherwise just go back from notification view
          if self == UIApplication.shared.keyWindow?.rootViewController {
              let goHome = self.storyboard!.instantiateViewController(withIdentifier: "ViewController")
              goHome.modalPresentationStyle = .fullScreen
              self.present(goHome, animated: true, completion: nil)
        }else{
             self.dismiss(animated: true, completion: nil)
        }       
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
        let cellIdentifier = NotificationList[indexPath.row].img != "" ? "NotifyCellNoImage" : "NotifyCell"
        
        //let cellIdentifier = "NotifyCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        cell.qstn.text = NotificationList[indexPath.row].title
        cell.ansr.text = NotificationList[indexPath.row].msg
        print("before - \(NotificationList[indexPath.row].img)")
        if(NotificationList[indexPath.row].img != ""){
            DispatchQueue.main.async {
                print("aftr - \(self.NotificationList[indexPath.row].img)")
                cell.bookImg.loadImageUsingCache(withUrl: "https://www.arenaflowers.co.in/blog/wp-content/uploads/2017/09/Summer_Flowers_Lotus.jpg") // self.NotificationList[indexPath.row].img
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
    //set height for specific cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height:CGFloat = CGFloat()
        
        if NotificationList[indexPath.row].msg.count <= 35 {
            height = 100
        } else if NotificationList[indexPath.row].msg.count <= 80 {
            height = 200
        } else if NotificationList[indexPath.row].msg.count <= 155 {
            height = 250
        } else if NotificationList[indexPath.row].msg.count > 155 {
            height = 500
        }

       // print("height at \(NotificationList[indexPath.row].msg) - \(height)")
        return height
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    func heightForView(text:String, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.text = text

        label.sizeToFit()
        return label.frame.height
    }

}
