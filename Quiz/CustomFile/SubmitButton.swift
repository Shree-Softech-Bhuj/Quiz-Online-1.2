import UIKit

class SubmitButton: UIButton {

    override func draw(_ rect: CGRect) {
        self.layer.backgroundColor = UIColor.rgb(63, 69, 101, 1).cgColor
        self.layer.cornerRadius = 5
        updateLayerProperties()
    }
    
    func updateLayerProperties() {
        self.layer.shadowColor = UIColor.rgb(108, 158, 255, 1).cgColor
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0
        self.layer.masksToBounds = false
        
    }
}
