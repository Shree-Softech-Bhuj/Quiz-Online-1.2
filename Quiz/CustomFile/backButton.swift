import Foundation
import UIKit

class backButton: UIButton {
    @IBInspectable var cornerRadius: CGFloat = 3 { didSet{ updateCornerRadius() }}
    
    
    func updateCornerRadius() {
        self.layer.cornerRadius = cornerRadius
    }
    func SetbgShadow(){
       // self.layer.cornerRadius = 3
        self.layer.shadowColor = UIColor.white.cgColor //lightGray
        self.layer.shadowOffset = CGSize(width: 3, height: 4)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
    
    override func awakeFromNib() {
//        self.contentMode = .center
//        self.imageView?.contentMode = .center
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0) //left: 5
        self.backgroundColor = UIColor.white
        SetbgShadow()
    }
}
