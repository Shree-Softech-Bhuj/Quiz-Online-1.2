import UIKit
import AVFoundation
import QuartzCore
import GoogleMobileAds

//structure for category
struct Category: Codable {
    let id:String
    let name:String
    let image:String
    let maxlvl:String
    let noOf:String
    let noOfQues:String
}
class CategoryViewController: UIViewController, GADBannerViewDelegate{
    
    @IBOutlet var collectionView: ASCollectionView!
    @IBOutlet var bannerView: GADBannerView!
    @IBOutlet weak var sBtn: UIButton!
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var isCategoryBattle = false
    
    var catData:[Category] = [] 
    var langList:[Language] = []
    var refreshController = UIRefreshControl()
    var config:SystemConfiguration?
    var apiName = "get_categories"
    var apiExPeraforLang = ""
    var numberOfItems: Int = 10
    let collectionElementKindHeader = "Header"
        
    var arrColors1 = [UIColor(named: "purple1"),UIColor(named: "sky1"),UIColor(named: "orange1"),UIColor(named: "blue1"),UIColor(named: "pink1"),UIColor(named: "green1")]
    var arrColors2 = [UIColor(named: "purple2"),UIColor(named: "sky2"),UIColor(named: "orange2"),UIColor(named: "blue2"),UIColor(named: "pink2"),UIColor(named: "green2")]
    
    var tintArr = ["purple2", "sky2","orange2","blue2","pink2","green2"] //arrColors1 & arrColors2 & tintArr - arrays should have same values/count
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Google AdMob Banner
        bannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
        bannerView.rootViewController = self
        let request = GADRequest()
        //request.testDevices = Apps.AD_TEST_DEVICE
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
        bannerView.load(request)
        
       // languageButton.isHidden = true
        
        if isKeyPresentInUserDefaults(key: DEFAULT_SYS_CONFIG){
             config = try! PropertyListDecoder().decode(SystemConfiguration.self, from: (UserDefaults.standard.value(forKey:DEFAULT_SYS_CONFIG) as? Data)!)
        }
//        if config?.LANGUAGE_MODE == 1{
//            apiName = "get_categories_by_language"
//            apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
//            languageButton.isHidden = false
//        }
        
        
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            if config?.LANGUAGE_MODE == 1{
                apiName = "get_categories_by_language"
                apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
            }
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        refreshController.addTarget(self,action: #selector(self.RefreshDataOnPullDown),for: .valueChanged)
        //catetableView.refreshControl = refreshController
        
        collectionView.delegate = self
        collectionView.asDataSource = self
        checkForValues()
    }
    func ReLaodCategory() {
        apiExPeraforLang = "&language_id=\(UserDefaults.standard.integer(forKey: DEFAULT_USER_LANG))"
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        numberOfItems = catData.count
    }
    // refresh function
    @objc func RefreshDataOnPullDown(){
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "" + apiExPeraforLang
            self.getAPIData(apiName: apiName, apiURL: apiURL,completion: LoadData)
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
        numberOfItems = catData.count
    }
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
            
        }else{
            //get data for category
            catData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    catData.append(Category.init(id: "\(val["id"]!)", name: "\(val["category_name"]!)", image: "\(val["image"]!)", maxlvl: "\(val["maxlevel"]!)", noOf: "\(val["no_of"]!)", noOfQues: "\(val["no_of_que"]!)"))
                }
            }
            
            //Add collectionView dimesnsions from ASACollection
            DispatchQueue.main.async {
                self.collectionView.register(UINib(nibName: self.collectionElementKindHeader, bundle: nil), forSupplementaryViewOfKind:  self.collectionElementKindHeader, withReuseIdentifier: "header")
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.collectionView.reloadData()
                self.numberOfItems = self.catData.count
                //self.catetableView.reloadData()
                self.refreshController.endRefreshing()
            }
        });
    }
    func checkForValues(){
        if arrColors1.count < numberOfItems{
            let dif = numberOfItems - (arrColors1.count - 1)
            print(dif)
            for i in 0...dif{
                arrColors1.append(arrColors1[i])
                arrColors2.append(arrColors2[i])
                tintArr.append(tintArr[i])
            }
        }
    }
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
}

extension CategoryViewController: ASCollectionViewDelegate {

    func loadMoreInASCollectionView(_ asCollectionView: ASCollectionView) {
        if numberOfItems > 30 {
            collectionView.enableLoadMore = false
            return
        }
       // numberOfItems += 1//0
        collectionView.loadingMore = false
        collectionView.reloadData()
        checkForValues()
    }
}

extension CategoryViewController: ASCollectionViewDataSource {

    func numberOfItemsInASCollectionView(_ asCollectionView: ASCollectionView) -> Int {
        print("int value- \(numberOfItems)")
        return numberOfItems
    }

    func collectionView(_ asCollectionView: ASCollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GridCell
        print("catdata values - \(catData.count) indexpath row value -- \(indexPath.row) --  total count of array - \(arrColors1.count) -- total count of cells - \(numberOfItems)")
        if catData.count > 0{
            gridCell.catLabel.text = catData[indexPath.row].name //"General knowledge"//String(format: "Item %ld ", indexPath.row) //
            gridCell.totalQue.text = "Que: \(catData[indexPath.row].noOfQues)"
            gridCell.logoImg.loadImageUsingCache(withUrl: self.catData[indexPath.row].image)//UIImage(named: "quiz")
        }else{
            gridCell.catLabel.text = "Category"
            gridCell.totalQue.text = "Que: 0"
            gridCell.logoImg.image = UIImage(named: "quiz")
        }
        gridCell.catLabel.textChangeAnimationToRight()
        gridCell.circleImgView.image = UIImage(named: "circle")
        gridCell.circleImgView.tintColor = UIColor.init(named: tintArr[indexPath.row])//UIColor.init(named: "pink1")
//        gridCell.bottomLineView.setGradient(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
//        gridCell.bottomLineView.backgroundColor = UIColor.systemRed
        gridCell.bottomLineView.backgroundColor = arrColors1[indexPath.row]
        
        gridCell.setCellShadow()
        
        return gridCell
    }

    func collectionView(_ asCollectionView: ASCollectionView, headerAtIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: ASCollectionViewElement.Header, withReuseIdentifier: "header", for: indexPath)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("clicked")
        if isCategoryBattle == true{
            let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
            let viewCont = storyboard.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController
            viewCont.isCategoryBattle = true
            viewCont.catID = Int(self.catData[indexPath.row].id)!
            self.navigationController?.pushViewController(viewCont, animated: true)
        }else{
            if catData.count > 0 {
                if(catData[indexPath.row].noOf == "0"){
                    // this category dose not have any sub category so move to direct level screen
                    let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                    let viewCont = storyboard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
                    if catData[indexPath.row].maxlvl.isInt{
                        viewCont.maxLevel = Int(catData[indexPath.row].maxlvl)!
                    }
                    viewCont.catID = Int(self.catData[indexPath.row].id)!
                    viewCont.questionType = "main"
                    self.navigationController?.pushViewController(viewCont, animated: true)
                }else{
                let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
                let viewCont = storyboard.instantiateViewController(withIdentifier: "subcategoryview") as! subCategoryViewController
                viewCont.catID = catData[indexPath.row].id
                viewCont.catName = catData[indexPath.row].name
                print("cat id and name -- \(catData[indexPath.row].id) \(catData[indexPath.row].name)")
                self.navigationController?.pushViewController(viewCont, animated: true)
                }
            }
        }
    }
        
//    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
//        return UIColor(
//            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//            alpha: CGFloat(1.0)
//        )
//    }
}

class GridCell: UICollectionViewCell {

    @IBOutlet var catLabel: UILabel!
    @IBOutlet var totalQue: UILabel!
    @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var gotoButton: UIButton!
    
   /* override public func layoutSubviews() {
        super.layoutSubviews()
        
        let subLayer = self.layer//.superlayer//sublayers?.last
        
        subLayer.cornerRadius = 5
        subLayer.shadowColor = UIColor.gray.cgColor
        subLayer.shadowOffset = CGSize(width: 3, height: 4)
        subLayer.shadowOpacity = 1
        subLayer.shadowRadius = 4
        subLayer.masksToBounds = false//subLayer!.masksToBounds = false //self.layer.
        
        //setLayerGradient()
    } */
    
    func setLayerGradient(){
        //set gradient layer
        
        let gradientLayer = CAGradientLayer()
        self.backgroundColor = .clear
        gradientLayer.colors = [arrColors1[0] ?? UIColor.blue,arrColors2[0] ?? UIColor.cyan]
        gradientLayer.startPoint = CGPoint(x: 0,y: 1)
        gradientLayer.endPoint = CGPoint(x: 1,y: 0)
        gradientLayer.locations = [0.50, 0.1]
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.bottomLineView.frame.size.width * UIScreen.main.bounds.width, height: self.bottomLineView.frame.size.height * UIScreen.main.bounds.height)
//        if let topLayer = self.layer.sublayers?.first, topLayer is CAGradientLayer
//        {
//            topLayer.removeFromSuperlayer()
//        }
        self.bottomLineView.layer.addSublayer(gradientLayer)
    }
}

//extension UIView{
//}

//extension UIImage {
//    static func gradientImageWithBounds(bounds: CGRect, colors: [CGColor]) -> UIImage {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = bounds
//        gradientLayer.colors = colors
//
//        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
//        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//
//        return image!
//    }
//}
