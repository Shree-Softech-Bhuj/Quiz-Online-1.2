import UIKit
import AVFoundation

protocol CellSelectDelegate {
    func didCellSelected(_ type: String)
}

class HomeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var titleLabel: UILabel!    
    @IBOutlet weak var leftImg: UIImageView!    
    @IBOutlet weak var viewAllButton: UIButton!
    
    var homeScreen = HomeScreenController()
    
    var arrColors2 = [UIColor(named: Apps.SKY1),UIColor(named: Apps.ORANGE1),UIColor(named: Apps.PURPLE1),UIColor(named: Apps.GREEN1),UIColor(named: Apps.BLUE1),UIColor(named: Apps.PINK1)]
    var arrColors1 = [UIColor(named: Apps.SKY2),UIColor(named: Apps.ORANGE2),UIColor(named: Apps.PURPLE2),UIColor(named: Apps.GREEN2),UIColor(named: Apps.BLUE2),UIColor(named: Apps.PINK2)]
    
    //let arrCAT = ["General Knowledge","Movies","Movies","Movies","Movies","Movies","Movies","Movies"]
    
    let playZoneData = [Apps.DAILY_QUIZ_PLAY,Apps.RNDM_QUIZ,Apps.TRUE_FALSE,Apps.SELF_CHLNG] //,Apps.PRACTICE
    let battleData = [Apps.RNDM_BTL] //Apps.GROUP_BTL,
    let battleImgData = [Apps.RNDM] //Apps.GRP_BTL,
    
    let numOfColumns = 7
    let prog_val = 65
    
    var audioPlayer : AVAudioPlayer!
    var cellDelegate:CellSelectDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //viewAllButton.alpha = 0
      
        collectionView.delegate = self
        collectionView.dataSource = self
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        checkForValues()
                
    }
    
//    @IBAction func viewAllButton(_ sender: Any) {
//        homeScreen.showAllCategories()
//    }
    func checkForValues(){
        if arrColors1.count < numOfColumns{
            let dif = numOfColumns - (arrColors1.count - 1)
            print(dif)
            for i in 0...dif{
                arrColors1.append(arrColors1[i])
                arrColors2.append(arrColors2[i])
                tintArr.append(tintArr[i])
            }
        }
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("titleLabel text in number of sections- \(String(describing: titleLabel.text))")
        switch (titleLabel.text) {
        case Apps.PLAY_ZONE:
            print("play zone")
            return 5
        break
        case Apps.BATTLE_ZONE:
            print("battle zone")
            return 2
        break
        case Apps.CONTEST_ZONE:
            return 1
        break
        default:
            print("default noOfSections chk -- \(String(describing: titleLabel.text))")
            return numOfColumns
        break
        }
        
//        if titleLabel.text! == "Battle Zone"{ //Apps.BATTLE_ZONE {
//           return 2
//       }else if titleLabel.text! == Apps.QUIZ_ZONE {
//            return numOfColumns
//        }else if titleLabel.text! == Apps.PLAY_ZONE {
//            return 5
//        }else{
//            return 1
//        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellIdentifier = "QuizZone"
//        if indexPath.row == 1 {
//            cellIdentifier = "PlayZone"
//        }
//        if indexPath.row == 0 {
//            cellIdentifier = "QuizZone"
//        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TestCollectionViewCell
        print("titleLabel text - \(String(describing: titleLabel.text))")
        switch cellIdentifier {
            case Apps.PLAY_ZONE:
                cell.catTitle.frame = CGRect(x: 20, y: 0, width: 300, height: 55)
                cell.catTitle.text = "\(playZoneData[indexPath.row])"
                cell.lockImgRight.alpha = 1
                cell.image2.alpha = 1
                cell.playIcon.alpha = 1
                cell.txtPlayJoinNow.alpha = 1
                cell.noOfQues.alpha = 0
                cell.numOfsubCat.alpha = 0
                cell.simpleView.setGradient(arrColors1[indexPath.row + 1] ?? UIColor.blue,arrColors2[indexPath.row + 1] ?? UIColor.cyan)//((arrColors1.randomElement() ?? UIColor.blue)!,(arrColors2.randomElement() ?? UIColor.blue)!)
            break
            case Apps.BATTLE_ZONE:
                cell.catTitle.text = "\(battleData[indexPath.row])"
                cell.rightImgFill.image = UIImage(named: battleImgData[indexPath.row])
                cell.rightImgFill.alpha = 1
                cell.playIcon.alpha = 1
                cell.txtPlayJoinNow.alpha = 1
                cell.noOfQues.alpha = 0
                cell.numOfsubCat.alpha = 0
                cell.simpleView.setGradient(arrColors1[indexPath.row + 2] ?? UIColor.blue,arrColors2[indexPath.row + 2] ?? UIColor.cyan)
            break
            case Apps.CONTEST_ZONE:
                cell.catTitle.text = Apps.CONTEST_PLAY_TEXT
                cell.rightImgFill.image = UIImage(named: Apps.CONTEST_IMG)
                cell.rightImgFill.alpha = 1
                cell.playIcon.alpha = 1
                cell.txtPlayJoinNow.alpha = 1
                cell.txtPlayJoinNow.text = Apps.JOIN_NOW
                cell.txtPlayJoinNow.frame = CGRect(x: 60, y: 80, width: 85, height: 30)
                cell.playIcon.frame = CGRect(x: 20, y: 80, width: 30, height: 30)
                cell.noOfQues.alpha = 0//.text = "100 Ques"
                cell.numOfsubCat.alpha = 0//.text = "10 Subcategories"
                cell.simpleView.setGradient(arrColors1[indexPath.row + 1] ?? UIColor.blue,arrColors2[indexPath.row + 1] ?? UIColor.cyan)
            break
            default:
                cell.catTitle.text = "category \(indexPath.row)"
                //cell.catTitle.textChangeAnimationToRight()
                cell.noOfQues.text = "11 Ques"
                cell.noOfQues.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                cell.numOfsubCat.text = "0 Category"
                cell.numOfsubCat.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                cell.simpleView.setGradient(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
            break
        }
        
        cell.noOfQues.layer.cornerRadius = CGFloat(cell.noOfQues.frame.height / 2)
        cell.noOfQues.layer.masksToBounds = true
        cell.numOfsubCat.layer.cornerRadius = CGFloat(cell.noOfQues.frame.height / 2)
        cell.numOfsubCat.layer.masksToBounds = true
            
            return cell
        
      /*  if titleLabel.text == Apps.QUIZ_ZONE {
            
            print("titleLabel text should be QZ- \(String(describing: titleLabel.text))")
//            if homeScreen.catData[0] != nil{
//                print("catData -- \(homeScreen.catData[indexPath.row].name)")
//            }
            cell.catTitle.text = "category \(indexPath.row)"
            //cell.catTitle.textChangeAnimationToRight()
            cell.noOfQues.text = "100 Ques"
            cell.noOfQues.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            cell.numOfsubCat.text = "10 Subcategories"
            cell.numOfsubCat.backgroundColor = UIColor.white.withAlphaComponent(0.4)
            //cell.progress.text = "Progress \(prog_val)%"
        }else if titleLabel.text == Apps.BATTLE_ZONE {
            
            print("titleLabel text should be BZ- \(String(describing: titleLabel.text))")
            cell.catTitle.text = "\(battleData[indexPath.row])"
            
            cell.rightImgFill.image = UIImage(named: battleImgData[indexPath.row])
            cell.rightImgFill.alpha = 1
            cell.playIcon.alpha = 1
            cell.txtPlayJoinNow.alpha = 1
            
            cell.noOfQues.alpha = 0
            cell.numOfsubCat.alpha = 0
        }else if titleLabel.text == Apps.PLAY_ZONE {
            
            print("titleLabel text should be PZ- \(String(describing: titleLabel.text))")
            cell.catTitle.frame = CGRect(x: 20, y: 0, width: 300, height: 55) 
            cell.catTitle.text = "\(playZoneData[indexPath.row])"
            cell.lockImgRight.alpha = 1
            cell.image2.alpha = 1
            cell.playIcon.alpha = 1
            cell.txtPlayJoinNow.alpha = 1
            
            cell.noOfQues.alpha = 0
            cell.numOfsubCat.alpha = 0
        }else{
            
            print("titleLabel text ELSE case - \(String(describing: titleLabel.text))")
            cell.catTitle.text = Apps.CONTEST_PLAY_TEXT
            cell.rightImgFill.image = UIImage(named: Apps.CONTEST_IMG)
            cell.rightImgFill.alpha = 1
            cell.playIcon.alpha = 1
            cell.txtPlayJoinNow.alpha = 1
            cell.txtPlayJoinNow.text = Apps.JOIN_NOW
            cell.txtPlayJoinNow.frame = CGRect(x: 60, y: 80, width: 85, height: 30)
            cell.playIcon.frame = CGRect(x: 20, y: 80, width: 30, height: 30)
            
            cell.noOfQues.alpha = 0//.text = "100 Ques"
            cell.numOfsubCat.alpha = 0//.text = "10 Subcategories"
           // cell.progress.text = "Progress \(prog_val)%"
        }
        cell.simpleView.setGradient(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
        cell.noOfQues.layer.cornerRadius = CGFloat(cell.noOfQues.frame.height / 2)
        cell.noOfQues.layer.masksToBounds = true
        cell.numOfsubCat.layer.cornerRadius = CGFloat(cell.noOfQues.frame.height / 2)
        cell.numOfsubCat.layer.masksToBounds = true
            
            return cell */
//        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("size chk -- \(titleLabel.text!)")
        
        switch (titleLabel.text) {
        case Apps.PLAY_ZONE:
          //  collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)
            let height = (collectionView.frame.size.height / 2) - 2
            let width = collectionView.frame.size.width - 100
            print("chk -- \(String(describing: titleLabel.text))")
            return CGSize(width: width, height: height)
        case Apps.BATTLE_ZONE:
            let height = (collectionView.frame.size.height / 2) - 3
            let width = collectionView.frame.size.width - 20
            print("chk -- \(String(describing: titleLabel.text))")
            return CGSize(width: width, height: height)
        default:
            print("default chk -- \(String(describing: titleLabel.text))")
            return CGSize(width: collectionView.frame.size.width - 20, height: collectionView.frame.size.height - 20)
        }
//        if titleLabel.text == Apps.PLAY_ZONE {
// //            collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)
//            let height = (collectionView.frame.size.height / 2) - 2
//            let width = collectionView.frame.size.width - 100
//            return CGSize(width: width, height: height)
//
//        }else if titleLabel.text == "Battle Zone"{//Apps.BATTLE_ZONE {
//
//            let height = (collectionView.frame.size.height / 2) - 3
//            let width = collectionView.frame.size.width - 20
//            return CGSize(width: width, height: height)
//        }else{
//            return CGSize(width: collectionView.frame.size.width - 20, height: collectionView.frame.size.height - 20)
//        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cellName = "" //identifier of ViewController
        
        switch (indexPath.row) {
        case 0: //quiz zone
            cellName = "subcategoryview"//cellName = "\(titleLabel.text)"
        case 1: //play zone - playZoneData [indexPath.row]
            cellName = "playzone-\(playZoneData[indexPath.row])"
        case 2: //battle zone
            cellName = "subcategoryview"
        case 3: //contest zone
            cellName = "ContestView"
        default:
            cellName = "categoryview"
        }
        self.cellDelegate?.didCellSelected(cellName)
    }
}
