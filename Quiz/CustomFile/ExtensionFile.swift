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
    
    static let defaultOuterColor = UIColor.rgb(216, 216, 216,1)
    static let defaultInnerColor: UIColor = .rgb(96, 104, 153,1)
    static let defaultPulseFillColor = UIColor.rgb(86, 30, 63,1)
    
    static let Vertical_progress_true = Apps.RIGHT_ANS_COLOR //verticle proress bar color for true answer
    static let Vertical_progress_false = Apps.WRONG_ANS_COLOR // verticle progress bar color for false answer
    
//    static let RightAnswerColor = UIColor.rgb(35, 176, 75,1) //right answer color
//    static let WrongAnswerColor = UIColor.rgb(237, 42, 42, 1) //wrong answer color
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
        // self.image = nil
        
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
}

extension UIButton {
    
    func resizeButton() {
        
        let btnSize = titleLabel?.sizeThatFits(CGSize(width: frame.width, height: .greatestFiniteMagnitude)) ?? .zero
        let desiredButtonSize = CGSize(width: btnSize.width + titleEdgeInsets.left + titleEdgeInsets.right, height: btnSize.height + titleEdgeInsets.top + titleEdgeInsets.bottom)
        self.titleLabel?.sizeThatFits(desiredButtonSize)
    }    
}

extension UIView{
    
    func DesignViewWithShadow(){
       self.layer.cornerRadius = 10
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds,cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowRadius = 1
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor(red: 189/255, green: 189/255, blue: 189/255, alpha: 0.5).cgColor
        self.layer.borderWidth = 1
    }
    
    func SetShadow(){
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.shadowColor = UIColor.lightGray.cgColor
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
}

