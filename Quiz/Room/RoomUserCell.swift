import UIKit

class RoomUserCell: UICollectionViewCell {
    
    @IBOutlet weak var userImage:UIImageView!
    @IBOutlet weak var userName:UILabel!
    
    var joinUser:JoinedUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.userImage.layer.cornerRadius = 10
        userImage.layer.borderWidth = 2
        userImage.layer.masksToBounds = true
    }
    
    func ConfigCell(){
        if  let currUser = self.joinUser{ 
            
            let user = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
            
            if user.UID == currUser.uID{
                userImage.layer.borderColor = Apps.BASIC_COLOR_CGCOLOR
            }else{
                userImage.layer.borderColor = UIColor.white.cgColor
            }
            if !currUser.userImage.isEmpty{
                userImage.loadImageUsingCache(withUrl: currUser.userImage)
            }else{
                userImage.image = UIImage(systemName: "person.fill")//(named: "userAvtar")
            }
            userName.text = currUser.userName
            if currUser.isJoined{
                userName.textColor = Apps.BASIC_COLOR
            }else{
                userName.textColor = .lightGray
            }
        }else{
            userName.text = "???"
            userImage.image = UIImage(systemName: "person.fill")//(named: "userAvtar")
            userName.textColor = Apps.BASIC_COLOR
            
            userImage.layer.borderColor = UIColor.white.cgColor
        }
    }
}
