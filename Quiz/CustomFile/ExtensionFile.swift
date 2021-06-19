import Foundation
import UIKit
import AVFoundation
import Reachability
import SystemConfiguration

//color setting that will use in whole apps
extension UIColor{
    static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat) -> UIColor {
        return UIColor.init(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
    
    static let defaultOuterColor = UIColor.rgb(224, 224, 224,1)
    static let defaultInnerColor = Apps.BASIC_COLOR
    static let defaultPulseFillColor = UIColor.rgb(248, 248, 248,1)
    
    static let Vertical_progress_true = Apps.RIGHT_ANS_COLOR //verticle proress bar color for true answer
    static let Vertical_progress_false = Apps.WRONG_ANS_COLOR // verticle progress bar color for false answer
    
}

extension UIProgressView{
    
    // set  verticle progress bar here
    static func Vertical(color: UIColor)->UIProgressView{
        let prgressView = UIProgressView() 
        prgressView.progress = 0.0
        prgressView.progressTintColor = color
        prgressView.trackTintColor = UIColor.clear
        prgressView.layer.borderColor = color.cgColor
        prgressView.layer.borderWidth = 2
        prgressView.layer.cornerRadius = 10
        prgressView.clipsToBounds = true
        prgressView.transform = CGAffineTransform(rotationAngle: .pi / -2)
        prgressView.translatesAutoresizingMaskIntoConstraints = false
        return prgressView
    }
    
    static func Horizontal(color: UIColor)->UIProgressView{
          let prgressView = UIProgressView()
          prgressView.progress = 0.0
          prgressView.progressTintColor = color
          prgressView.trackTintColor = UIColor.clear
          prgressView.layer.borderColor = color.cgColor
          prgressView.layer.borderWidth = 20
          prgressView.layer.cornerRadius = 10
          prgressView.clipsToBounds = true
         // prgressView.transform = CGAffineTransform(rotationAngle: .pi / -2)
          prgressView.translatesAutoresizingMaskIntoConstraints = false
          return prgressView
      }
}

extension Data {
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

let imageCache = NSCache<NSString, AnyObject>()
extension UIImageView {
    func loadImageUsingCache(withUrl urlString : String) {
        let url = URL(string: urlString)
        
        // check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString) as? UIImage {
            self.image = cachedImage
            
            return
        }
        
        // if not, download image from url
        if url != nil{
            URLSession.shared.dataTask(with: (url)!, completionHandler: { (data, response, error) in
                       if error != nil {
                           print(error!)
                           return
                       }
                       
                       DispatchQueue.main.async {
                           if let image = UIImage(data: data!) {
                               imageCache.setObject(image, forKey: urlString as NSString)
                               self.image = image
                           }
                       }
                       
                   }).resume()
        }
       
}
}
extension Date{
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!

    }
    
    func endOfDay() -> Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: Calendar.current.startOfDay(for: self))!
    }
    
    func endOfMonth() -> Date {
       var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfMonth())!
    }
    
    func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}
extension UITextView {
    
    func centerVertically() {
        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
        let size = sizeThatFits(fittingSize)
        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        contentOffset.y = -positiveTopOffset
    }
    
    // html tags set
    func stringFormation(_ str: String) {
        let recStr = str
        var getFont = UserDefaults.standard.float(forKey: "fontSize")
        if (getFont == 0){
            getFont = 16.0
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        self.attributedText = recStr.htmlToAttributedString
        self.font = .systemFont(ofSize: CGFloat(getFont)) //UIFont(name: "System Medium", size: CGFloat(getFont))
    }    
}
extension UILabel{
    func setLabel(){
          self.numberOfLines = 0
          let maximumLabelSize: CGSize = CGSize(width: self.frame.width, height: self.frame.height)
          let expectedLabelSize: CGSize = self.sizeThatFits(maximumLabelSize)
          // create a frame that is filled with the UILabel frame data
          var newFrame: CGRect = self.frame
        //   newFrame.size.width = expectedLabelSize.width
           newFrame.size.height = expectedLabelSize.height
          self.frame = newFrame
       }
    
    func textChangeAnimation() {
        let animationS:CATransition = CATransition()
        animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        animationS.type = CATransitionType.push
        animationS.subtype = CATransitionSubtype.fromTop
       // self.userCount1.text = "\(String(format: "%02d", rightCount))"
        animationS.duration = 1.50
        self.layer.add(animationS, forKey: "CATransition")
    }
   
    func textChangeAnimationToRight() {
        let animationS:CATransition = CATransition()
        animationS.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        animationS.type = CATransitionType.push
        animationS.subtype = CATransitionSubtype.fromLeft
       // self.userCount1.text = "\(String(format: "%02d", rightCount))"
        animationS.duration = 1.50
        self.layer.add(animationS, forKey: "CATransition")
    }
    
    func titleTextAnimation(){
//        nameLabel = UILabel(frame: CGRect(x: -300, y: 130, width: 100, height: 25))
//        nameLabel.text = "Midhet"
//        nameLabel.font = UIFont(name: "Avenir", size: 30)
//        self.view.addSubview(nameLabel)
        
        UIView.animate(withDuration: 1.5, animations: {
            self.frame.origin.x = 20
        }) {_ in
            UIView.animate(withDuration: 1.5) {
                self.frame.origin.x = 40
            }
        }
        
    }
    
}
extension UIButton {
    
    func resizeButton() {
        
        let btnSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: btnSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: btnSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
        self.titleLabel?.sizeThatFits(desiredButtonSize)
    }
    func setBorder(){
        self.layer.cornerRadius = self.frame.height / 2 //15 /// 3 //
        self.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR  //UIColor.white.cgColor
        self.layer.borderWidth = 2
    }

//    func addBottomBorder(width: CGFloat) {
//        let border = CALayer()
//        border.backgroundColor = UIColor.black.cgColor
//        border.frame = CGRect(x: 0, y: self.frame.size.height - 5, width: self.frame.size.width, height: width)
//      //  self.layer.addSublayer(border)
//        self.layer.insertSublayer(border, at: 0)
//    }
//    func removeBottomBorder(){
//        if let topLayer = self.layer.sublayers?.last, topLayer is CALayer
//        {
//        self.layer.removeFromSuperlayer()
//        }
//    }
}

extension UIView{
    
    func DesignViewWithShadow(){
       //self.layer.cornerRadius = 10
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
        self.layer.borderWidth = 1
    }
    
    func SetShadow(){
        
        //self.layer.cornerRadius = 6
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 0.7, height: 0.7)
        self.layer.masksToBounds = false
    }
    
    func SetDarkShadow(){
        self.layer.cornerRadius = self.frame.height / 2 //35
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: 0, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    //battle modes
    func addCenterBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x:0,y: self.frame.height / 2, width:self.frame.size.width, height:width)
        self.layer.addSublayer(border)
    }
}

extension UIViewController{
    func secondsToHoursMinutesSeconds (seconds : Int) -> String {
        //String(format: "%02d", (seconds % 3600) % 60)
        if seconds % 3600 == 0{
             return "60:00"
        }
        return "\(String(format: "%02d", (seconds % 3600) / 60)):\(String(format: "%02d", (seconds % 3600) % 60))"
    }
    
    func SetClickedOptionView(otpStr:String) -> UIView{
      /*  let color = Apps.BASIC_COLOR //UIColor.white //
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = .white //Apps.BASIC_COLOR//
        
        let imgView = UIView(frame: CGRect(x: 3, y: 3, width: 35, height: 35))
        imgView.layer.cornerRadius = 4
        imgView.layer.borderColor = color.cgColor
        imgView.layer.borderWidth = 1
        imgView.backgroundColor = color
        imgView.addSubview(lbl)
        return imgView*/
        let color = Apps.BASIC_COLOR //UIColor.white //
        let lbl = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        lbl.text = otpStr.uppercased()
        lbl.textAlignment = .center
        lbl.textColor = .white //Apps.BASIC_COLOR//
        
        let imgView = UIView(frame: CGRect(x: 3, y: 3, width: 35, height: 35))
        imgView.layer.cornerRadius = 4
        imgView.layer.borderColor = color.cgColor
        imgView.layer.borderWidth = 1
        imgView.backgroundColor = color
        imgView.addSubview(lbl)
        return imgView
    }
    
    
    func getTopMostViewController() -> UIViewController? {
        var topMostViewController = UIApplication.shared.keyWindow?.rootViewController

        while let presentedViewController = topMostViewController?.presentedViewController {
            topMostViewController = presentedViewController
        }

        return topMostViewController
    }
    
    func SetBookmark(quesID:String, status:String, completion:@escaping ()->Void){
         if isKeyPresentInUserDefaults(key: "user"){
             let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
             if(Reachability.isConnectedToNetwork()){
                 let apiURL = "user_id=\(user.userID)&question_id=\(quesID)&status=\(status)"
                self.getAPIData(apiName: Apps.API_BOOKMARK_SET, apiURL: apiURL,completion: {jsonObj in
                     //print("SET BOOK",jsonObj)
                    if (jsonObj.value(forKey: "data") as? [String:Any]) != nil {//if let data = jsonObj.value(forKey: "data") as? [String:Any] {
                         DispatchQueue.main.async {
                             completion()
                         }
                     }
                 })
             }
         }
     }
}


extension CALayer {

    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {

        let border = CALayer()

        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }

        border.backgroundColor = color.cgColor;

        addSublayer(border)
    }
}

extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
//battle modes
extension UITextField{
    func bordredTextfield(textField: UITextField){
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor(red: 198/255, green: 198/255, blue: 198/255, alpha: 1.0).cgColor
        textField.layer.cornerRadius = 5
        textField.backgroundColor = UIColor.white
    }
    
    func PaddingLeft(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func PaddingRight(_ amount:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    func bottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func AddAccessoryView(){
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = Apps.BASIC_COLOR
        toolBar.backgroundColor = .white
        toolBar.barTintColor = .white
        toolBar.sizeToFit()
        toolBar.addTopBorderWithColor(color: Apps.BASIC_COLOR, width: 1)
        
        let doneButton = UIBarButtonItem(title: Apps.DONE, style: UIBarButtonItem.Style.done, target: self, action: #selector(self.DismisPicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: Apps.CANCEL, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.DismisPicker))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        self.inputAccessoryView = toolBar
    }
    @objc func DismisPicker(){
        self.resignFirstResponder()
    }
    
}
