import UIKit

class RoomListCell: UITableViewCell {

    @IBOutlet weak var roomCatNate:UILabel!
    @IBOutlet weak var roomDetails:UILabel!
    @IBOutlet weak var roomView:GradientView!
    @IBOutlet weak var joinButton:UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.roomView.layer.cornerRadius = 10
        self.joinButton.layer.cornerRadius = 3
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
