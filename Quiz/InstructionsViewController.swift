import UIKit

class InstructionsViewController: UIViewController {

    
    @IBOutlet weak var fifty_fifty: UIImageView!
    @IBOutlet weak var skip: UIImageView!
    @IBOutlet weak var audi: UIImageView!
    @IBOutlet weak var timer: UIImageView!
    @IBOutlet weak var score: UIImageView!
    @IBOutlet var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fifty_fifty.layer.cornerRadius = 25
        skip.layer.cornerRadius = 25
        audi.layer.cornerRadius = 25
        timer.layer.cornerRadius = 25
        score.layer.cornerRadius = 25
       
        self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: 660)
    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}
