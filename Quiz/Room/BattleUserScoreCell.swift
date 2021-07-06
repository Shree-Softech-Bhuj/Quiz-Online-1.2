import UIKit

class BattleUserScoreCell: UICollectionViewCell {
    
    @IBOutlet weak var mainView:UIView!
    @IBOutlet weak var userImg:UIImageView!
    @IBOutlet weak var userName:UILabel!
    @IBOutlet weak var userRight:UILabel!
    @IBOutlet weak var userWrong:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
       // let radius:CGFloat = 15//6
       // self.mainView.setGradient(UIColor(named: Apps.BLUE1) ?? UIColor.systemBlue ,UIColor(named: Apps.BLUE2) ?? UIColor.cyan)
       // self.mainView.layer.cornerRadius = radius
       // self.mainView.layer.masksToBounds = true
       // self.mainView.SetShadow()
        self.userImg.layer.cornerRadius = self.userImg.frame.height / 2 //radius
        
        self.userRight.layer.cornerRadius = self.userRight.frame.height / 3//15//3
        self.userRight.layer.masksToBounds = true
        
        self.userWrong.layer.cornerRadius = self.userWrong.frame.height / 3 //15//3
        self.userWrong.layer.masksToBounds = true
    }
    
}
