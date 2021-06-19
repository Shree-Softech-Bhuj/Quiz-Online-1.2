import UIKit

class BattleUserScoreCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var userImg:UIImageView!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userRight:UILabel!
    @IBOutlet weak var userWrong:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let radius:CGFloat = 6
        
        self.mainView.layer.cornerRadius = radius
       // self.mainView.SetShadow()
        self.userImg.layer.cornerRadius = radius
        
        self.userRight.layer.cornerRadius = 3
        self.userRight.layer.masksToBounds = true
        
        self.userWrong.layer.cornerRadius = 3
        self.userWrong.layer.masksToBounds = true
    }
    
}
