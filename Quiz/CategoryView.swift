import UIKit
import AVFoundation
import GoogleMobileAds

//structure for category
struct Category {
    let id:String
    let name:String
    let image:String
    let maxlvl:String
    let noOf:String
}
class CategoryView: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {

    @IBOutlet var catetableView: UITableView!
    @IBOutlet var bannerView: GADBannerView!
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var catData:[Category] = []
    var langList:[Language] = []
    var refreshController = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Google AdMob Banner
        bannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
        bannerView.rootViewController = self
        let request = GADRequest()
        //request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        bannerView.load(request)

    
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = ""
            self.getAPIData(apiName: "get_categories", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        refreshController.addTarget(self,action: #selector(self.RefreshDataOnPullDown),for: .valueChanged)
        catetableView.refreshControl = refreshController
    }
    
    // refresh function
    @objc func RefreshDataOnPullDown(){
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = ""
            self.getAPIData(apiName: "get_categories", apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "status")!)" )
            })
            
        }else{
            //get data for category
            catData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.catetableView.reloadData()
                self.refreshController.endRefreshing()
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
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return catData.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = "cateCell"
        
        guard let cell = self.catetableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        // Name
        cell.cellView.SetShadow()
        
        cell.cateLbl.text = self.catData[indexPath.row].name
        if(catData[indexPath.row]).image == "" {
            cell.cateImg.image = UIImage(named: "score") // set default image
        }else{
            DispatchQueue.main.async {
                cell.cateImg.loadImageUsingCache(withUrl: self.catData[indexPath.row].image)// load image from url using cache
            }
        }
        
        cell.cateImg.layer.borderColor = UIColor.lightGray.cgColor
        cell.cateImg.layer.borderWidth = 0.8
        cell.cateImg.layer.cornerRadius = cell.cateImg.frame.size.height/2
        cell.cateImg.layer.masksToBounds = true

        cell.cellView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 6.0,options: .allowUserInteraction,
                       animations: { [weak self] in
                        cell.cellView.transform = .identity},completion: nil)
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        if(catData[indexPath.row].noOf == "0"){
            // this category dose not have any sub category so move to direct level screen
            let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let levelScreen:LevelView = storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
            if self.catData[indexPath.row].maxlvl.isInt{
                levelScreen.maxLevel = Int(self.catData[indexPath.row].maxlvl)!
            }
            levelScreen.catID = Int(self.catData[indexPath.row].id)!
            levelScreen.questionType = "main"
            self.present(levelScreen, animated: true, completion: nil)
        }else{
            // this category have sub category so move to sub category screen
            let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let subCatView:SubCategoryView = storyBoard.instantiateViewController(withIdentifier: "SubCategoryView") as! SubCategoryView
            subCatView.catID = catData[indexPath.row].id
            self.present(subCatView, animated: true, completion: nil)
        }
    }
}
