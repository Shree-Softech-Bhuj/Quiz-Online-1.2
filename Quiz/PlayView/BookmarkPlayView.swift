

import Foundation
import UIKit
import AVFoundation


let bookProgressBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_true)
let bookProgressFalseBar = UIProgressView.Vertical(color: UIColor.Vertical_progress_false)

class BookmarkPlayView: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet var qstnNo: UILabel!
    
    @IBOutlet var btnA: UIButton!
    @IBOutlet var btnB: UIButton!
    @IBOutlet var btnC: UIButton!
    @IBOutlet var btnD: UIButton!
    
    @IBOutlet var speakBtn: UIButton!
    @IBOutlet var zoomBtn: UIButton!
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var zoomScroll: UIScrollView!
    @IBOutlet var lblQuestion: UITextView!
    @IBOutlet weak var questionImage: UIImageView!
    @IBOutlet weak var mainQuestionLbl: UITextView!
    @IBOutlet var mainQuestionView: UIView!
    @IBOutlet var progressview: UIView!
    
    @IBOutlet var trueLbl: UILabel!
    @IBOutlet var falseLbl: UILabel!
    @IBOutlet weak var progFalseView: UIView!
    @IBOutlet weak var proTrueView: UIView!
    
    var progressRing: CircularProgressBar!
    var timer: Timer!
    var player: AVAudioPlayer?
    
    var count:CGFloat = 0
    var currentQuestionPos = 0
    var BookQuesList:[Question] = []
    var trueCount = 0
    var falseCount = 0
    var zoomScale:CGFloat = 1
    
    @IBOutlet weak var showAns: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttons = [btnA,btnB,btnC,btnD]
        
        //get bookmark list
        if (UserDefaults.standard.value(forKey: "booklist") != nil){
            BookQuesList = try! PropertyListDecoder().decode([Question].self, from:(UserDefaults.standard.value(forKey: "booklist") as? Data)!)
        }
        
        //set four option's view shadow
        self.SetViewWithShadow(views: btnA,btnB,btnC,btnD)
        
        self.mainQuestionView.DesignViewWithShadow()
        
        let xPosition = progressview.center.x - 10
        let yPosition = progressview.center.y - 5
        let position = CGPoint(x: xPosition, y: yPosition)
        progressRing = CircularProgressBar(radius: (progressview.frame.size.height - 10) / 2, position: position, innerTrackColor: .defaultInnerColor, outerTrackColor: .defaultOuterColor, lineWidth: 6)
        progressview.layer.addSublayer(progressRing)
        
        self.setVerticleProgress(view: proTrueView, progress: bookProgressBar)// true progres bar
        self.setVerticleProgress(view: progFalseView, progress: bookProgressFalseBar)// false progress bar
        
        zoomScroll.minimumZoomScale = 1.0
        zoomScroll.maximumZoomScale = 6.0
        zoomScroll.zoomScale = 1
        self.zoomScroll.contentSize = questionImage.frame.size
        self.zoomScroll.delegate = self
        
        self.LoadQuestion()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showAnswer(_ sender: Any) {
        
        for button in buttons{
            if button.tag == 1{
                showAns.setTitle("\(Apps.TRUE_ANS) \(button.title(for: .normal)!)", for: .normal)
            }
        }
    }
    
    @IBAction func ZoomBtn(_ sender: Any) {
        zoomScale += 1
        self.zoomScroll.zoomScale = zoomScale
    }
    
    @IBAction func speakButton(_ sender: Any) {
        let speechSynthesizer = AVSpeechSynthesizer()
        let speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "\(BookQuesList[currentQuestionPos].question)")
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.0
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        speechSynthesizer.speak(speechUtterance)
        
    }
    
    @IBAction func settingButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "AlertView") as! AlertViewController
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return questionImage
    }
    
    // Note only works when time has not been invalidated yet
    @objc func resetProgressCount() {
        
        buttons.forEach{$0.isUserInteractionEnabled = true}
        if self.timer != nil && self.timer.isValid{
            timer.invalidate()
        }
        progressRing.innerTrackShapeLayer.strokeColor = UIColor.defaultInnerColor.cgColor
        self.zoomScroll.zoomScale = 1
        self.zoomScale = 1
        showAns.setTitle(Apps.SHOW_ANSWER, for: .normal)
        count = 0
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(incrementCount), userInfo: nil, repeats: true)
        timer.fire()
    }
    @objc func incrementCount() {
        count += 0.1
        progressRing.progress = CGFloat(Apps.QUIZ_PLAY_TIME - count)
        if count >= 20{
            progressRing.innerTrackShapeLayer.strokeColor = Apps.WRONG_ANS_COLOR.cgColor
        }
        if count >= Apps.QUIZ_PLAY_TIME { // set timer here
            timer.invalidate()
            currentQuestionPos += 1
            LoadQuestion()
        }
    }
    
    //load question here
    func LoadQuestion(){
        
        MakeChoiceBtnDefault(btns: btnA,btnB,btnC,btnD)// enable button and restore to its default value
        
        if(currentQuestionPos  < BookQuesList.count ) {
            resetProgressCount()
            if(BookQuesList[currentQuestionPos].image == ""){
                // if question dose not contain images
                mainQuestionLbl.text = BookQuesList[currentQuestionPos].question
                mainQuestionLbl.centerVertically()
                //hide some components
                lblQuestion.isHidden = true
                questionImage.isHidden = true
                zoomBtn.isHidden = true
                
                mainQuestionLbl.isHidden = false
            }else{
                // if question has image
                lblQuestion.text = BookQuesList[currentQuestionPos].question
                lblQuestion.centerVertically()
                questionImage.loadImageUsingCache(withUrl: BookQuesList[currentQuestionPos].image)
                //show some components
                lblQuestion.isHidden = false
                questionImage.isHidden = false
                zoomBtn.isHidden = false
                
                mainQuestionLbl.isHidden = true
            }
            self.SetButtonOpetion(opestions: BookQuesList[currentQuestionPos].opetionA,BookQuesList[currentQuestionPos].opetionB,BookQuesList[currentQuestionPos].opetionC,BookQuesList[currentQuestionPos].opetionD,BookQuesList[currentQuestionPos].correctAns)

            
            qstnNo.text = "\(currentQuestionPos + 1)/\(BookQuesList.count)"
            
        } else {
            // If there are no more questions show the results
            //self.dismiss(animated: true, completion: nil)
            scroll.isHidden = true
            showAns.isHidden = true
            
            let view = UIView(frame: CGRect(x: 0, y: (self.view.frame.height / 2) - 100, width: self.view.frame.width, height: 100))
            
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: view.frame.width, height: 30))
            label.text = Apps.COMPLETE_ALL_QUESTION
            label.textAlignment = .center
            label.textColor = .gray
            view.addSubview(label)
            
            let button = SubmitButton(frame: CGRect(x: (self.view.frame.width / 2) - 50, y: 50, width: 100, height: 40))
            button.setTitle(Apps.BACK, for: .normal)
            button.titleLabel?.textAlignment = .center
            button.addTarget(self, action: #selector(self.backButton(_:)), for: .touchUpInside)
            view.addSubview(button)
            
            self.view.addSubview(view)
        }
        
    }
    
    // right answer operation function
    func rightAnswer(btn:UIView){
        
        //make timer invalidate
        timer.invalidate()
        
        //score count
        trueCount += 1
        trueLbl.text = "\(trueCount)"
        bookProgressBar.setProgress(Float(trueCount) / Float(10), animated: true)
        
        btn.backgroundColor = Apps.RIGHT_ANS_COLOR
        btn.tintColor = UIColor.white
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.3
        animation.repeatCount = 2
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: btn.center.x, y: btn.center.y - 5))
        animation.toValue = NSValue(cgPoint: CGPoint(x: btn.center.x, y: btn.center.y + 5))
        btn.layer.add(animation, forKey: "position")
        
        // sound
        self.PlaySound(player: &player, file: "right")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increament for next question
            self.LoadQuestion()
        })
    }
    
    // wrong answer operation function
    func wrongAnswer(btn:UIView?){
        
        //make timer invalidate
        timer.invalidate() //by me
        
        //score count
        falseCount += 1
        falseLbl.text = "\(falseCount)"
        bookProgressFalseBar.setProgress(Float(falseCount) / Float(10), animated: true)
        
        btn?.backgroundColor = Apps.WRONG_ANS_COLOR
        btn?.tintColor = UIColor.white
        
        // sound
        self.PlaySound(player: &player, file: "wrong")
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            // load next question after 1 second
            self.currentQuestionPos += 1 //increament for next question
            self.LoadQuestion()
        })
    }
    
    // set default to four choice button
    func MakeChoiceBtnDefault(btns:UIButton...){
        for btn in btns {
            btn.backgroundColor = UIColor.white
            btn.shadow(color: .lightGray, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
            btn.subviews.forEach({
                if($0.tag == 11){
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    // set button opetion's
    var buttons:[UIButton] = []
    func SetButtonOpetion(opestions:String...){
        clickedButton.removeAll()
        let ans = ["a","b","c","d"]
        var rightAns = ""
        if ans.contains("\(opestions.last!.lowercased())") {
            rightAns = opestions[ans.index(of: opestions.last!.lowercased())!]
        }else{
            
            self.ShowAlert(title: "Invalid Question", message: "This Question has wrong value.")
            rightAnswer(btn: btnA)
        }
        buttons.shuffle()
        var index = 0
        for button in buttons{
            button.setTitle(opestions[index], for: .normal)
            if opestions[index] == rightAns{
                button.tag = 1
            }else{
                button.tag = 0
            }
            button.addTarget(self, action: #selector(ClickButton), for: .touchUpInside)
            button.addTarget(self, action: #selector(ButtonDown), for: .touchDown)
            index += 1
        }
    }
    
    // opetion buttons click action
    @objc func ClickButton(button:UIButton){
        if clickedButton.first?.title(for: .normal) == button.title(for: .normal){
            buttons.forEach{$0.isUserInteractionEnabled = false}
            if button.tag == 1{
                rightAnswer(btn: button)
            }else{
                wrongAnswer(btn: button)
            }
        }
    }
    
    var clickedButton:[UIButton] = []
    @objc func ButtonDown(button:UIButton){
        clickedButton.append(button)
    }
}
