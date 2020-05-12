import UIKit
import GoogleMobileAds

class NotificationsView : UIViewController, UITableViewDelegate, UITableViewDataSource,GADBannerViewDelegate  {
    
    @IBOutlet var tableView: UITableView!

    var NotificationList: [Notifications] = []
    
     var Loader: UIAlertController = UIAlertController()
     @IBOutlet weak var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //clear notification badges
               if Apps.badgeCount > 0 {
                   Apps.badgeCount = 0
                   UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
               }
        
        // Google AdMob Banner
        bannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
        bannerView.rootViewController = self
        let request = GADRequest()
        //request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        bannerView.load(request)
        if (UserDefaults.standard.value(forKey: "notification") != nil){
                NotificationList = try! PropertyListDecoder().decode([Notifications].self,from:(UserDefaults.standard.value(forKey: "notification") as? Data)!)
           }        
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
        print(NotificationList.count)
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
        //show 1st character of Title at left side of title and message here
        if cellIdentifier == "NotifyCellNoImage" {
           let x = cell.qstn.text!.prefix(1)
           cell.label1Char.text = String(x)
           cell.label1Char.layer.masksToBounds = true
           cell.label1Char.layer.cornerRadius = 5
           print(x)
        }
        cell.ansr.text = NotificationList[indexPath.row].msg
        if(NotificationList[indexPath.row].img != "") {
            let url: String =  self.NotificationList[indexPath.row].img
                      DispatchQueue.main.async {
                          cell.bookImg.loadImageUsingCache(withUrl: url)
                      }
            }
        cell.bookView.SetShadow()
        cell.bookView.layer.cornerRadius = 0 //15
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

        if NotificationList[indexPath.row].img != ""{
            height = 150
        }else{
            height = 100
        }
        if NotificationList[indexPath.row].msg.count <= 35 {
           height = height + 0
       } else if NotificationList[indexPath.row].msg.count <= 80 {
           height = height + 100
       } else if NotificationList[indexPath.row].msg.count <= 155 {
           height = height + 150
       } else if NotificationList[indexPath.row].msg.count > 155 {
           height = height + 400
       }
        
        return height
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
