import UIKit
import WebKit

class TableViewCell: UITableViewCell {
    @IBOutlet weak var cateLbl: UILabel!
    @IBOutlet weak var cateImg: UIImageView!
    
    @IBOutlet weak var sCateLbl: UILabel!
    @IBOutlet weak var sCateImg: UIImageView!
    
    @IBOutlet weak var lvlLbl: UILabel!
    @IBOutlet weak var qNoLbl: UILabel!
    @IBOutlet weak var lockImg: UIImageView!
    
    @IBOutlet weak var cellView1: UIView!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var cellView2: UIView!
    @IBOutlet weak var leadrView: UIView!

    @IBOutlet weak var scorLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var srLbl: UILabel!
    @IBOutlet weak var userImg: UIImageView!
    @IBOutlet weak var imgView: UIView!
    
    @IBOutlet weak var bookImg: UIImageView!
    @IBOutlet weak var bookView: UIView!
    @IBOutlet weak var qstn: UILabel!
    @IBOutlet weak var ansr: UILabel!
    @IBOutlet weak var tfbtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
