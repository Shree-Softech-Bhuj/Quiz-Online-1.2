import Foundation
import UIKit

class TestHomeView: UIViewController {
    
    @IBOutlet weak var scroll: UIScrollView!
    
    @IBOutlet weak var dataTopView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let arrColors1 = [UIColor.red,UIColor.blue,UIColor.green,UIColor.yellow, UIColor.gray, UIColor.brown]
    let arrColors2 = [UIColor.lightGray,UIColor.systemTeal,UIColor.systemGray2,UIColor.systemOrange, UIColor.systemPink, UIColor.systemIndigo]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
extension TestHomeView: UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "catCell", for: indexPath) as? CollectionViewCell
        cell?.CatNumber.text = String(indexPath.row + 1)
       // cell?.backgroundColor = UIColor.random(from: arrColors1)
        for i in 0...(arrColors1.count - 1) {
            cell?.setGradienttt(arrColors1[i], arrColors2[i])
        }
       // cell?.setGradienttt(UIColor.random(from: arrColors1) ?? UIColor.blue,UIColor.random(from: arrColors2) ?? UIColor.blue)//(UIColor.red, UIColor.blue)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //open respected category levels / any other screen
        print("click worked -- cell - \(indexPath.row)")
    }
}


