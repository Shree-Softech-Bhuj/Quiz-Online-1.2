import UIKit
import AVFoundation
import GoogleMobileAds

struct SubCategory {
    let id:String
    let name:String
    let image:String
    let maxlevel:String
    let status:String
    let noOf:String
}
class subCategoryViewController: UIViewController,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,GADBannerViewDelegate{
    
    @IBOutlet var subCollectionView: UICollectionView!
    var numberOfItems: Int = 10 //6//
    
    @IBOutlet weak var adBannerView: GADBannerView!
    
    var audioPlayer : AVAudioPlayer!
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var catID:String = "0"
    var catName:String = ""
    var subCatData:[SubCategory] = []
    var refreshController = UIRefreshControl()
    
    @IBOutlet weak var titleBarTxt: UILabel!
        
    var arrColors1 = [UIColor(named: "purple1"),UIColor(named: "sky1"),UIColor(named: "orange1"),UIColor(named: "green1"),UIColor(named: "blue1"),UIColor(named: "pink1")]
    var arrColors2 = [UIColor(named: "purple2"),UIColor(named: "sky2"),UIColor(named: "orange2"),UIColor(named: "green2"),UIColor(named: "blue2"),UIColor(named: "pink2")]
    
    var tintArr = ["purple2", "sky2","orange2","green2","blue2","pink2"] //arrColors1 & arrColors2 & tintArr - arrays should have same values/count
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForValues()
        
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
        
        //refreshController.addTarget(self,action: #selector(self.RefreshDataOnPullDown),for: .valueChanged)
        //tableView.refreshControl = refreshController
        titleBarTxt.text = catName
        
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
    //load sub category data here
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
            subCatData.removeAll()
            if let data = jsonObj.value(forKey: "data") as? [[String:Any]] {
                for val in data{
                    subCatData.append(SubCategory.init(id: "\(val["id"]!)", name: "\(val["subcategory_name"]!)", image: "\(val["image"]!)", maxlevel: "\(val["maxlevel"]!)", status: "\(val["status"]!)", noOf: "\(val["no_of"]!)"))
                }
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.45, execute: {
            DispatchQueue.main.async {
                self.DismissLoader(loader: self.Loader)
                self.subCollectionView.reloadData()
                self.numberOfItems = self.subCatData.count
//                self.tableView.reloadData()
//                self.refreshController.endRefreshing()
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
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    numberOfItems
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
    let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! subcatCell
    print("indexpath row value -- \(indexPath.row) --  total count of array - \(arrColors1.count) -- total count of cells - \(numberOfItems)")
    if subCatData.count > 0 {
        gridCell.subCatLabel.text = subCatData[indexPath.row].name//"General knowledge"
        gridCell.totalQue.text = "Que: \(subCatData[indexPath.row].noOf)"
        gridCell.logoImg.loadImageUsingCache(withUrl: self.subCatData[indexPath.row].image)//UIImage(named: "quiz")
    }else{
        gridCell.subCatLabel.text = "Subcategory"
        gridCell.totalQue.text = "10"
        gridCell.logoImg.image = UIImage(named: "quiz")
    }
    gridCell.subCatLabel.textChangeAnimationToRight()
    gridCell.circleImgView.image = UIImage(named: "circle")
    gridCell.circleImgView.tintColor = UIColor.init(named: tintArr[indexPath.row])
    gridCell.bottomLineView.setGradient(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
    
    
    
//    gridCell.setShadow()
    
    return gridCell
}
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)

        let itemSpacing: CGFloat = 35 //15
        let textAreaHeight: CGFloat = 65

        let width: CGFloat = ((collectionView.bounds.width) - itemSpacing)/2  //- 20
        let height: CGFloat = width * 10/13 + textAreaHeight //10/7
        return CGSize(width: width, height: height)
        
        //return CGSize(width: (collectionView.bounds.width-32), height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("clicked cell number \(indexPath.row)")
        self.PlaySound(player: &audioPlayer, file: "click") // play sound
        self.Vibrate() // make device vibrate
        
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        let viewCont = storyboard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
        print(subCatData[indexPath.row].maxlevel)
        if self.subCatData[indexPath.row].maxlevel.isInt{
            viewCont.maxLevel = Int(self.subCatData[indexPath.row].maxlevel)!
        }
        viewCont.mainCatid = Int(self.catID)!
        viewCont.catID = Int(self.subCatData[indexPath.row].id)!
        viewCont.questionType = "sub"
        self.navigationController?.pushViewController(viewCont, animated: true)
    }
    
}
class subcatCell: UICollectionViewCell {
    
    @IBOutlet var subCatLabel: UILabel!
    @IBOutlet var totalQue: UILabel!
    @IBOutlet var circleImgView: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var gotoButton: UIButton!
}
