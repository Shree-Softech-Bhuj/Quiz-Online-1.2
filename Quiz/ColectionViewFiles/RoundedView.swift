import UIKit

@IBDesignable
class RoundedView: UIView {

    @IBInspectable var borderColor: UIColor = UIColor.white {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var cornerRadius: Float = 0.0 {
        didSet {
            //layer.cornerRadius = CGFloat(cornerRadius)
            let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: 15, height: 15))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            layer.mask = mask
            self.clipsToBounds = false
        }
    }

    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOpacity = 1//0.7
            layer.shadowRadius = 4//8.0
            layer.shadowOffset = CGSize(width: 3, height: 4)//(width: 0.0, height: 3.0)
        }
    }
        
}
