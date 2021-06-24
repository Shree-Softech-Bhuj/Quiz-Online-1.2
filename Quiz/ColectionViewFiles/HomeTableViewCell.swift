import UIKit
import AVFoundation

protocol CellSelectDelegate {
    func didCellSelected(_ type: String,_ rowIndex: Int)
}

class HomeTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!    
    @IBOutlet weak var leftImg: UIImageView!    
    @IBOutlet weak var viewAllButton: UIButton!
    
    var homeScreen = HomeScreenController()
    
    var arrColors2 = [UIColor(named: Apps.SKY1),UIColor(named: Apps.ORANGE1),UIColor(named: Apps.PURPLE1),UIColor(named: Apps.GREEN1),UIColor(named: Apps.BLUE1),UIColor(named: Apps.PINK1)]
    var arrColors1 = [UIColor(named: Apps.SKY2),UIColor(named: Apps.ORANGE2),UIColor(named: Apps.PURPLE2),UIColor(named: Apps.GREEN2),UIColor(named: Apps.BLUE2),UIColor(named: Apps.PINK2)]
    
    var playZoneData = [Apps.DAILY_QUIZ_PLAY,Apps.RNDM_QUIZ,Apps.TRUE_FALSE,Apps.SELF_CHLNG] //,Apps.PRACTICE
    let battleData = [Apps.GROUP_BTL,Apps.RNDM_BTL] //
    let battleImgData = [Apps.GRP_BTL,Apps.RNDM] //
        
    var catData = ["Best Quiz","General Knowledge","Sports","Best Quiz","General Knowledge","Sports","Best Quiz","General Knowledge","Sports"]
    
    let numOfColumns = 7
    let prog_val = 65
    
    var initialCatData:[Category] = []
    
    var audioPlayer : AVAudioPlayer!
    var cellDelegate:CellSelectDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Apps.DAILY_QUIZ_MODE == "0"{
            playZoneData.removeFirst() 
        }
        
        if (UserDefaults.standard.value(forKey: "categories") != nil){
                initialCatData = try! PropertyListDecoder().decode([Category].self,from:(UserDefaults.standard.value(forKey: "categories") as? Data)!)
                numberOfItems = initialCatData.count
        }else{
            print("cat data not loaded")
        }
        print("value of cat - \(initialCatData.count)")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        self.clipsToBounds = true
        self.layer.masksToBounds = true
        checkForValues()
                
    }
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
        if titleLabel.text == Apps.PLAY_ZONE {
            return playZoneData.count//4
        }else if titleLabel.text == Apps.QUIZ_ZONE {
            return numOfColumns
        }else if titleLabel.text == Apps.BATTLE_ZONE {
            return battleData.count
        }else{
            return 1
        }
//        switch (titleLabel.text) {
//        case Apps.PLAY_ZONE:
//            print("play zone")
//            return 5
//        break
//        case Apps.BATTLE_ZONE:
//            print("battle zone")
//            return 1//2
//        break
//        case Apps.CONTEST_ZONE:
//            return 1
//        break
//        default:
//            print("default noOfSections chk -- \(String(describing: titleLabel.text))")
//            return numOfColumns
//        break
//        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cellIdentifier = "QuizZone"
        if titleLabel.text == Apps.QUIZ_ZONE{
            cellIdentifier = "QuizZone"
        }
        if titleLabel.text == Apps.PLAY_ZONE{
            cellIdentifier = "PlayZone"
        }
        if titleLabel.text == Apps.BATTLE_ZONE{
            cellIdentifier = "BattleZone"
        }
        if titleLabel.text == Apps.CONTEST_ZONE{
            cellIdentifier = "ContestZone"
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! TestCollectionViewCell
        print("titleLabel text - \(String(describing: titleLabel.text)) -cellIdentifier- \(cellIdentifier)")
        switch cellIdentifier {
            case "PlayZone":
               // cell.catTitle.frame = CGRect(x: 20, y: 0, width: 300, height: 55)
                cell.catTitle.text = "\(playZoneData[indexPath.row])"
//                cell.lockImgRight.alpha = 1
//                cell.image2.alpha = 1
//                cell.playIcon.alpha = 1
//                cell.txtPlayJoinNow.alpha = 1
//                cell.noOfQues.alpha = 0
//                cell.numOfsubCat.alpha = 0
                cell.simpleView.setGradient(arrColors1[indexPath.row + 1] ?? UIColor.blue,arrColors2[indexPath.row + 1] ?? UIColor.cyan)
            break
            case "QuizZone":
                cell.catTitle.text = initialCatData[indexPath.row].name//catData[indexPath.row]
                cell.noOfQues.layer.cornerRadius = CGFloat(cell.noOfQues.frame.height / 2)
                cell.noOfQues.layer.masksToBounds = true
                cell.noOfQues.text = "\(initialCatData[indexPath.row].noOfQues) Ques"//"11 Ques"
                cell.noOfQues.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                cell.numOfsubCat.layer.cornerRadius = CGFloat(cell.noOfQues.frame.height / 2)
                cell.numOfsubCat.layer.masksToBounds = true
                cell.numOfsubCat.text = "\(initialCatData[indexPath.row].noOf) Category"//"0 Category"
                cell.numOfsubCat.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                cell.simpleView.setGradient(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
                break
            case "BattleZone": // Apps.BATTLE_ZONE
                cell.catTitle.text = "\(battleData[indexPath.row])"
                cell.rightImgFill.image = UIImage(named: battleImgData[indexPath.row])
//                cell.rightImgFill.alpha = 1
//                cell.playIcon.alpha = 1
//                cell.txtPlayJoinNow.alpha = 1
//                cell.noOfQues.alpha = 0
//                cell.numOfsubCat.alpha = 0
                cell.simpleView.setGradient(arrColors1[indexPath.row + 4] ?? UIColor.blue,arrColors2[indexPath.row + 4] ?? UIColor.cyan)
            break
            case "ContestZone":
                cell.catTitle.text = Apps.CONTEST_PLAY_TEXT
//                cell.rightImgFill.image = UIImage(named: Apps.CONTEST_IMG)
//                cell.rightImgFill.alpha = 1
//                cell.playIcon.alpha = 1
//                cell.txtPlayJoinNow.alpha = 1
                //cell.txtPlayJoinNow.text = Apps.JOIN_NOW
                /*if deviceStoryBoard == "Ipad"{
                    cell.txtPlayJoinNow.frame = CGRect(x: 80, y: 100, width: 85, height: 30)
                    cell.playIcon.frame = CGRect(x: 40, y: 100, width: 30, height: 30)
                }else{
                    cell.txtPlayJoinNow.frame = CGRect(x: 60, y: 80, width: 85, height: 30)
                    cell.playIcon.frame = CGRect(x: 20, y: 80, width: 30, height: 30)
                }*/
                
//                cell.noOfQues.alpha = 0//.text = "100 Ques"
//                cell.numOfsubCat.alpha = 0//.text = "10 Subcategories"
                cell.simpleView.setGradient(arrColors1[indexPath.row + 3] ?? UIColor.blue,arrColors2[indexPath.row + 3] ?? UIColor.cyan)
            break
            default:
//                cell.catTitle.text = "category \(indexPath.row)"
//                cell.noOfQues.text = "11 Ques"
//                cell.noOfQues.backgroundColor = UIColor.white.withAlphaComponent(0.4)
//                cell.numOfsubCat.text = "0 Category"
//                cell.numOfsubCat.backgroundColor = UIColor.white.withAlphaComponent(0.4)
                cell.simpleView.setGradient(arrColors1[indexPath.row] ?? UIColor.blue,arrColors2[indexPath.row] ?? UIColor.cyan)
            break
        }
            return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print("size chk -- \(titleLabel.text!)")        
        
            switch (titleLabel.text) {
            case Apps.PLAY_ZONE:
              //  collectionView.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 10)
                let hh =  deviceStoryBoard == "Ipad" ? collectionView.frame.size.height :collectionView.frame.size.height - 30
                let height = (hh / 2) - 2
                let deductionVal:CGFloat = deviceStoryBoard == "Ipad" ? 200 : 100
                let width = collectionView.frame.size.width - deductionVal//100
                return CGSize(width: width, height: height)
            case Apps.BATTLE_ZONE:
                let height = (collectionView.frame.size.height / 2) - 3
                let width = collectionView.frame.size.width - 20
               // print("chk -- \(String(describing: titleLabel.text))")
                return CGSize(width: width, height: height)
            case Apps.QUIZ_ZONE:
                let testWidth = deviceStoryBoard == "Ipad" ? collectionView.frame.size.width - 120 : collectionView.frame.size.width - 20
                return CGSize(width: testWidth, height: collectionView.frame.size.height - 20)
            default: //contest zone
                print("default chk -- \(String(describing: titleLabel.text))")
                return CGSize(width: collectionView.frame.size.width - 20, height: collectionView.frame.size.height - 20)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var cellName = "categoryview" //identifier of ViewController
        print(indexPath.row)
//        print(titleLabel.text)        
        if titleLabel.text == Apps.BATTLE_ZONE {
            cellName = "battlezone-\(indexPath.row)"
        }
        if titleLabel.text == Apps.PLAY_ZONE {
            //playZoneData
            cellName = "playzone-\(indexPath.row)"
        }
        if titleLabel.text == Apps.QUIZ_ZONE {
            if initialCatData[indexPath.row].noOf == "0" {
                cellName = "LevelView"
            }else{
                cellName = "subcategoryview"
            }
        }
        if titleLabel.text == Apps.CONTEST_ZONE {
            cellName = "ContestView"
        }
        
//        switch (indexPath.row) {
//        case 0: //quiz zone
//            cellName = "subcategoryview"//cellName = "\(titleLabel.text)"
//        case 1: //play zone - playZoneData [indexPath.row]
//            cellName = "playzone-\(playZoneData[indexPath.row])"
//        case 2: //battle zone - battleData
//            cellName = "battlezone-1"
//        case 3: //contest zone
//            cellName = "ContestView"
//        default:
//            cellName = "categoryview"
//        }
      
        self.cellDelegate?.didCellSelected(cellName, indexPath.row)
    
    }
}
