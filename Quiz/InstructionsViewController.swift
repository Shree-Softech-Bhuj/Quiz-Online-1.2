import UIKit

class InstructionsViewController: UIViewController {

    
    @IBOutlet weak var fifty_fifty: UIImageView!
    @IBOutlet weak var skip: UIImageView!
    @IBOutlet weak var audi: UIImageView!
    @IBOutlet weak var timer: UIImageView!
    @IBOutlet weak var score: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fifty_fifty.layer.cornerRadius = 25
        skip.layer.cornerRadius = 25
        audi.layer.cornerRadius = 25
        timer.layer.cornerRadius = 25
        score.layer.cornerRadius = 25

    }
    
    @IBAction func backButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
