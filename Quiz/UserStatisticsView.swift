import UIKit
import GoogleMobileAds

class UserStatisticsView: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var coinsLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var attendQuesLabel: UILabel!
    @IBOutlet weak var correctQuesLabel: UILabel!
    @IBOutlet weak var inCorrectQuesLabel: UILabel!
    @IBOutlet weak var strongCatLabel: UILabel!
    @IBOutlet weak var weakCatLabel: UILabel!
    @IBOutlet weak var strongPerLabel: UILabel!
    @IBOutlet weak var weakPerLabel: UILabel!
    @IBOutlet weak var strongProgress: UIProgressView!
    @IBOutlet weak var weakProgress: UIProgressView!
    @IBOutlet weak var circleProgView: UIView!
    @IBOutlet weak var rightPerLabel: UILabel!
    @IBOutlet weak var wrongPerLabel: UILabel!
    
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var viewCategory: UIView!
    @IBOutlet weak var viewChart: UIView!
    
    @IBOutlet weak var bannerView: GADBannerView!
    
    var userDefault:User? = nil
    var Loader: UIAlertController = UIAlertController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Google AdMob Banner
               bannerView.adUnitID = Apps.BANNER_AD_UNIT_ID
               bannerView.rootViewController = self
               let request = GADRequest()
               //request.testDevices = Apps.AD_TEST_DEVICE
               GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = Apps.AD_TEST_DEVICE
               bannerView.load(request)
        
        userDefault = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print("user data-\(String(describing: userDefault))")
        userName.text = "\(Apps.HELLO) \(userDefault!.name)"
       
        self.userImage.contentMode = .scaleAspectFill
        userImage.clipsToBounds = true
        userImage.layer.cornerRadius = userImage.frame.height / 2
        userImage.layer.masksToBounds = true
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.black.cgColor
        
        DispatchQueue.main.async {
            if(self.userDefault!.image != ""){
                self.userImage.loadImageUsingCache(withUrl: self.userDefault!.image)
            }
        }
        
        strongProgress.progress = 0.0
        weakProgress.progress = 0.0
      
        //get score & coins from server
              if(Reachability.isConnectedToNetwork()){
                //  Loader = LoadLoader(loader: Loader)
                let apiURL = "id=\(userDefault!.userID)"
                  self.getAPIData(apiName: "get_user_by_id", apiURL: apiURL,completion: getUserData)
              }else{
                  ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
              }
        
        //get data from server
              if(Reachability.isConnectedToNetwork()){
                  Loader = LoadLoader(loader: Loader)
                  let apiURL = "user_id=\(userDefault!.userID)"
                  self.getAPIData(apiName: "get_users_statistics", apiURL: apiURL,completion: LoadData)
                  
              }else{
                  ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
              }
        
//        viewProfile.shadow(color: .gray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
//        viewCategory.shadow(color: .gray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
//        viewChart.shadow(color: .gray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        viewProfile.SetShadow()
        viewCategory.SetShadow()
        viewChart.SetShadow()
    }
    //load user data here
    func getUserData(jsonObj:NSDictionary){
        print(jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }else{
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                print(data)
                DispatchQueue.main.async {
                    let score = Int("\(data["all_time_score"]!)")
                    self.scoreLabel.text = "\(score!)"
                    let coins = Int("\(data["coins"]!)")
                    self.coinsLabel.text = "\(coins!)"
                    UserDefaults.standard.set(try? PropertyListEncoder().encode(UserScore.init(coins: coins!, points: score!)), forKey: "UserScore")
                    let rank = Int("\(data["all_time_rank"]!)")
                   self.rankLabel.text = "\(rank!)"
                }
            }
        }
    }
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        //print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            DispatchQueue.main.async {
                self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlert(title: Apps.ERROR, message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }else{
            //get data for category
            if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                print(data)
                DispatchQueue.main.async {
                    let ques = Int("\(data["questions_answered"]!)")
                    let corr = Int("\(data["correct_answers"]!)")
                    
                    self.attendQuesLabel.text = "\(ques!)"
                    self.correctQuesLabel.text = "\(corr!)"
                    self.inCorrectQuesLabel.text = "\(ques! - corr!)"
                    
                    self.strongCatLabel.text = "\(data["strong_category"]!)"
                    self.weakCatLabel.text = "\(data["weak_category"]!)"
                    
                    let strongP = Float("\(data["ratio1"]!)")
                    let weakP = Float("\(data["ratio2"]!)")
                    self.strongPerLabel.text = "\(Int(strongP!))%"
                    self.weakPerLabel.text = "\(Int(weakP!))%"
                    
                    self.strongProgress.progress = strongP! / 100.0
                    self.weakProgress.progress = weakP! / 100.0
                    
                    let xPosition = self.circleProgView.frame.width / 2
                    let yPosition = self.circleProgView.frame.height / 2
                    let position = CGPoint(x: xPosition, y: yPosition - 15)
                    let progressRing = CircularProgressBar(radius: 25, position: position, innerTrackColor: .green, outerTrackColor: .systemPink, fillColor: .white, lineWidth: 14)
                    self.circleProgView.layer.addSublayer(progressRing)
                    progressRing.progressValue = CGFloat(Float(corr! * 100) / Float(ques!))
                    
//                    self.rightPerLabel.text = "\(Int(CGFloat(Float(corr! * 100) / Float(ques!))))%"
//                    self.wrongPerLabel.text = "\(Int(100 - (CGFloat(Float(corr! * 100) / Float(ques!)))))%"
                    let rightPer = roundf(Float(corr! * 100) / Float(ques!))
                    let wrongPer = floorf(Float(100 - (CGFloat(Float(corr! * 100) / Float(ques!)))))
                    self.rightPerLabel.text = "\(Int(rightPer))%"
                    self.wrongPerLabel.text = "\(Int(wrongPer))%"
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
        self.navigationController?.popViewController(animated: true)
    }
    
}
