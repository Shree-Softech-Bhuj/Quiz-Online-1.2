import UIKit

class BookmarkView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var playBookmark: UIButton!

    var BookQuesList: [QuestionWithE] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //get bookmark list
           if (UserDefaults.standard.value(forKey: "booklist") != nil){
                BookQuesList = try! PropertyListDecoder().decode([QuestionWithE].self,from:(UserDefaults.standard.value(forKey: "booklist") as? Data)!)
           }
        
        if BookQuesList.count == 0 {
            playBookmark.isHidden = true
        }
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func playBookButton(_ sender: Any) {
        
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let bookPlay:BookmarkPlayView = storyBoard.instantiateViewController(withIdentifier: "BookmarkPlayView") as! BookmarkPlayView
        bookPlay.BookQuesList = self.BookQuesList
        
        self.present(bookPlay, animated: true, completion: nil)
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height:CGFloat = BookQuesList[indexPath.row].image == "" ? 100 : 130
        return height
    }
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if BookQuesList.count == 0{
            let noDataLabel: UILabel  = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = Apps.NO_BOOKMARK
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return BookQuesList.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a new cell if needed or reuse an old one
        let cellIdentifier = BookQuesList[indexPath.row].image != "" ? "BookCell" : "BookCellNoImage"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TableViewCell  else {
            fatalError("The dequeued cell is not an instance.")
        }
        
        cell.qstn.text = BookQuesList[indexPath.row].question
        if(BookQuesList[indexPath.row].correctAns == "a"){
            cell.ansr.text = BookQuesList[indexPath.row].opetionA
        }else if(BookQuesList[indexPath.row].correctAns == "b"){
            cell.ansr.text = BookQuesList[indexPath.row].opetionB
        }else if(BookQuesList[indexPath.row].correctAns == "c"){
            cell.ansr.text = BookQuesList[indexPath.row].opetionC
        }else if(BookQuesList[indexPath.row].correctAns == "d"){
            cell.ansr.text = BookQuesList[indexPath.row].opetionD
        }else if(BookQuesList[indexPath.row].correctAns == "e"){
            cell.ansr.text = BookQuesList[indexPath.row].opetionE
        }

        if(BookQuesList[indexPath.row].image != ""){
            DispatchQueue.main.async {
                cell.bookImg.loadImageUsingCache(withUrl: self.BookQuesList[indexPath.row].image)
            }
        }
        cell.tfbtn.tag = indexPath.row
        cell.tfbtn.addTarget(self, action: #selector(RemoveBookmark(_:)), for: .touchUpInside)
        cell.bookView.SetShadow()
        cell.bookView.layer.cornerRadius = 0
        cell.bookView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        
        UIView.animate(withDuration: 2.0, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 6.0,options: .allowUserInteraction,
                       animations: { [weak self] in
                        cell.bookView.transform = .identity
                        
            },completion: nil)
        return cell
    }
    
    // remove from bookmark list
    @objc func RemoveBookmark(_ button:UIButton){
        BookQuesList.remove(at: button.tag)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(BookQuesList), forKey: "booklist")
        tableView.reloadData()
        if BookQuesList.count == 0{
            playBookmark.isHidden = true
        }
    }
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
}
