import UIKit
import AVFoundation
import GoogleMobileAds

struct SubCategory {
    let id:String
    let name:String
    let image:String
    let maxlevel:String
    let status:String
}

class SubCategoryView: UIViewController, UITableViewDelegate, UITableViewDataSource,GADBannerViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var adBannerView: GADBannerView!
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var catID:String = "0"
    var catName:String = ""
    var subCatData:[SubCategory] = []
    var refreshController = UIRefreshControl()
    
    @IBOutlet weak var titleBarTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        adBannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
        adBannerView.rootViewController = self
        let request = GADRequest()
        //request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        adBannerView.load(request)
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "main_id=\(catID)"
            self.getAPIData(apiName: "get_subcategory_by_maincategory", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        
        refreshController.addTarget(self,action: #selector(self.RefreshDataOnPullDown),for: .valueChanged)
        tableView.refreshControl = refreshController
        titleBarTxt.text = catName
    }
    
    // refresh function
    @objc func RefreshDataOnPullDown(){
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "main_id=\(catID)"
            self.getAPIData(apiName: "get_subcategory_by_maincategory", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    //load sub category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            //get data for category
            subCatData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    subCatData.append(SubCategory.init(id: "\(val["id"]!)", name: "\(val["subcategory_name"]!)", image: "\(val["image"]!)", maxlevel: "\(val["maxlevel"]!)", status: "\(val["status"]!)"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.tableView.reloadData()
                self.refreshController.endRefreshing()
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        //check if user entered in this view directly from notification ? if Yes then goTo Home page otherwise just go back from notification view
        if self == UIApplication.shared.keyWindow?.rootViewController {
            self.navigationController?.popToRootViewController(animated: true)
        }else{
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subCatData.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = "SubCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        // Name
        cell.sCateLbl.text = subCatData[indexPath.row].name
        
        if(subCatData[indexPath.row]).image == "" {
            cell.sCateImg.image = UIImage(named: "score")
        }else{
            DispatchQueue.main.async {
                cell.sCateImg.loadImageUsingCache(withUrl: self.subCatData[indexPath.row].image)
            }
        }
        
        //cell.sCateImg.layer.borderColor = UIColor.lightGray.cgColor
        //cell.sCateImg.layer.borderWidth = 0.8
        // cell.sCateImg.layer.cornerRadius = cell.sCateImg.frame.size.height/2
        cell.sCateImg.layer.masksToBounds = true
        
    
        
        cell.cellView1.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 6.0,options: .allowUserInteraction,
                       animations: { [weak self] in
                        cell.cellView1.transform = .identity
            },completion: nil)
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
        
        if self.subCatData[indexPath.row].maxlevel.isInt{
            viewCont.maxLevel = Int(self.subCatData[indexPath.row].maxlevel)!
        }
        viewCont.catID = Int(self.subCatData[indexPath.row].id)!
        viewCont.questionType = "sub"
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
}
extension UIView {
    
    func navBar(navBar: UINavigationBar){
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
    }
    
    func shadow(color : UIColor, offSet:CGSize, opacity: Float = 0.7, radius: CGFloat = 30, scale: Bool = true){
        DispatchQueue.main.async {
            self.layer.masksToBounds = false
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOpacity = opacity
            self.layer.shadowOffset = offSet
            self.layer.shadowRadius = radius
        }
        DispatchQueue.main.async {
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
        }
    }
    
    func border(color : UIColor, radius: CGFloat = 28, bWidth : CGFloat = 2){
        layer.masksToBounds = false
        layer.borderColor = UIColor(red: 63/255, green: 69/255, blue: 101/255, alpha: 1.0).cgColor
        layer.borderWidth = 2
        layer.cornerRadius = radius
    }
    
    func applyGradient(colors: [CGColor])
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.3)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.8)
        gradientLayer.frame = self.bounds
        gradientLayer.cornerRadius = 30
        self.layer.addSublayer(gradientLayer)
    }
}
