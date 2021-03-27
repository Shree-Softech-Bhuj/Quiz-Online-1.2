import UIKit
import StoreKit
import AVFoundation
import AudioToolbox

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

class AlertViewController: UIViewController {

  @IBOutlet var bodyView: UIView!
  @IBOutlet var hedr: UIButton!
  @IBOutlet var fotr: UIButton!
  @IBOutlet var soundToggle: UISwitch!
  @IBOutlet var vibToggle: UISwitch!
  @IBOutlet var musicToggle: UISwitch!
    
  @IBOutlet weak var soundView: UIView!
  @IBOutlet weak var vibrationView: UIView!
  @IBOutlet weak var bgMusicView: UIView!
  @IBOutlet weak var fontView: UIView!
  @IBOutlet weak var rateusView: UIView!
    
    var soundEnabled = true
    var vibEnabled = true
    var isPlayView = false
    
    let step:Float=10
    
    var backgroundMusicPlayer: AVAudioPlayer!
    
    var setting:Setting? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        bodyView.layer.cornerRadius = 20
        hedr.roundCorners(corners: [.topLeft, .topRight], radius: 20)
        fotr.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 20)
        
        //get setting value from user default
        setting = try! PropertyListDecoder().decode(Setting.self, from: (UserDefaults.standard.value(forKey:"setting") as? Data)!)
        
        soundToggle.isOn = setting!.sound
        vibToggle.isOn = setting!.vibration
        musicToggle.isOn = setting!.backMusic
    
        addElementsToStackView()
    }   
    
    func addElementsToStackView(){
            
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 7
        stackView.backgroundColor = Apps.BASIC_COLOR//UIColor.systemGray5
        stackView.layer.cornerRadius = 20
        bodyView.addSubview(stackView)
        
       stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          // Attaching the content's edges to the scroll view's edges
          stackView.leadingAnchor.constraint(equalTo: bodyView.leadingAnchor),
          stackView.trailingAnchor.constraint(equalTo: bodyView.trailingAnchor),
          stackView.topAnchor.constraint(equalTo: bodyView.topAnchor),
          stackView.bottomAnchor.constraint(equalTo: bodyView.bottomAnchor),

          // Satisfying size constraints
          stackView.widthAnchor.constraint(equalTo: bodyView.widthAnchor)
        ])
            stackView.distribution = .fillEqually
            bodyView.backgroundColor = .clear
            stackView.addArrangedSubview(hedr)
            stackView.addArrangedSubview(soundView)
            stackView.addArrangedSubview(vibrationView)
            stackView.addArrangedSubview(bgMusicView)
            stackView.addArrangedSubview(fontView)
            stackView.addArrangedSubview(rateusView)
            stackView.addArrangedSubview(fotr)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func soundSwitch(sender: AnyObject) {
        setting?.sound = soundToggle.isOn
    }
    
    @IBAction func vibSwitch(sender: AnyObject) {
        setting?.vibration = vibToggle.isOn
    }
    
    @IBAction func musicSwitch(sender: AnyObject) {
        setting?.backMusic = musicToggle.isOn
    }
    
    @IBAction func DismissAlertView(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    // Font size slider
    @IBAction func sliderButton(_ sender: AnyObject) {
        //get the Slider values from UserDefaults
        let defaultSliderValue = UserDefaults.standard.float(forKey: "fontSize")*3
        
        //create the Alert message with extra return spaces
        let sliderAlert = UIAlertController(title:Apps.FONT_TITLE, message: Apps.FONT_MSG, preferredStyle: .alert)
        
        //create a Slider and fit within the extra message spaces
        //let screenSize: CGRect = sliderAlert.view.bounds
        let mySlider = UISlider(frame:CGRect(x: 10, y: 100, width: 250, height: 20))
        
        mySlider.minimumValue = 40
        mySlider.maximumValue = 100
        mySlider.isContinuous = true
        mySlider.tintColor = UIColor.green
        mySlider.setValue(defaultSliderValue, animated:true)
        mySlider.addTarget(self, action: #selector(AlertViewController.sliderValueDidChange(_:)), for: .valueChanged)
        
        sliderAlert.view.addSubview(mySlider)
        //OK button action
        let sliderAction = UIAlertAction(title: Apps.OK, style: .default, handler: { (result : UIAlertAction) -> Void in
            UserDefaults.standard.set(mySlider.value/4, forKey: "fontSize")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReloadFont"), object: nil)
        })
        //Add buttons to sliderAlert
        sliderAlert.addAction(sliderAction)
        //present the sliderAlert message
        self.present(sliderAlert, animated: true, completion: nil)
    }
    
    @objc func sliderValueDidChange(_ sender:UISlider!)
    {
        // Use this code below only if you want UISlider to snap to values step by step
        let roundedStepValue = round(sender.value / step) * step
        sender.value = roundedStepValue
        
         //UserDefaults.standard.set(CGFloat(roundedStepValue)/3, forKey: "fontSize")
        
        let i = CGFloat(roundedStepValue)/3
        
   
        UserDefaults.standard.set(i, forKey: "size")  //Integer
    }
    
    @IBAction func okBtn(_ sender: Any) {
        if setting!.backMusic {
            NotificationCenter.default.post(name: Notification.Name("PlayMusic"), object: nil)
        }else{
            NotificationCenter.default.post(name: Notification.Name("StopMusic"), object: nil)
        }
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.setting), forKey: "setting")
        
        //font size
        let size = UserDefaults.standard.integer(forKey: "size")
        UserDefaults.standard.set(size, forKey: "fontSize")
    
        self.dismiss(animated: true, completion: {
            if self.isPlayView{
                NotificationCenter.default.post(name: Notification.Name("ResumeTimer"), object: nil)
            }
        })
    }
    @IBAction func ShareBtn(_ sender: Any) {
       // let str  = Apps.APP_NAME
        let str = Apps.SHARE_APP_TXT
        let shareUrl = Apps.SHARE_APP
        let textToShare = str + "\n" + shareUrl
        let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
        present(vc, animated: true)
        if let popOver = vc.popoverPresentationController {
            popOver.sourceView = self.view
        }
    }
    
    @IBAction func MoreAppsBtn(_ sender: Any) {
        let url=NSURL(string: Apps.MORE_APP)
         if #available(iOS 10.0, *) {
            UIApplication.shared.canOpenURL(url! as URL) // open is used with only supported iOS 10+
         }else {
            UIApplication.shared.openURL(url! as URL)
        }
    }
    
    @IBAction func RateUsBtn(_ sender: Any) {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "\(Apps.APP_ID)") {
           if #available(iOS 10.0, *) {
            UIApplication.shared.canOpenURL(url)
            }else {
               UIApplication.shared.openURL(url)
           }
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
