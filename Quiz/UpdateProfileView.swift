import Foundation
import UIKit
import Firebase

class UpdateProfileView: UIViewController{
    
    @IBOutlet var usrImg: UIImageView!
    @IBOutlet var btnUpdate: UIButton!
    @IBOutlet var logOutBtn: UIButton!
    
    @IBOutlet var imgView: UIView!
    @IBOutlet weak var mainview: UIView!
    @IBOutlet weak var optionsView: UIView!
    
    @IBOutlet var nameTxt: FloatingTF!
    @IBOutlet var nmbrTxt: FloatingTF!
    @IBOutlet var emailTxt: FloatingTF!
    
    
    var isInitial = true
    var Loader: UIAlertController = UIAlertController()
    
    var email = ""
    var dUser:User? = nil
    let picker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        dUser = try! PropertyListDecoder().decode(User.self, from: (UserDefaults.standard.value(forKey:"user") as? Data)!)
        print(dUser!)
       usrImg.contentMode = .scaleAspectFill
       usrImg.clipsToBounds = true
       usrImg.layer.cornerRadius = usrImg.frame.height / 2
       usrImg.layer.masksToBounds = true
       usrImg.layer.borderWidth = 1.5
       usrImg.layer.borderColor = UIColor.black.cgColor
               
        
        nameTxt.text = dUser!.name
        nmbrTxt.text = dUser!.phone
        email = dUser!.email
        emailTxt.text = dUser?.email
       
        DispatchQueue.main.async {
            if(self.dUser!.image != ""){
                self.usrImg.loadImageUsingCache(withUrl: self.dUser!.image)
            }
        }
        
        emailTxt.leftViewMode = UITextFieldViewMode.always
        emailTxt.leftView = UIImageView(image: UIImage(named: "email"))
        
        nmbrTxt.leftViewMode = UITextFieldViewMode.always
        nmbrTxt.leftView = UIImageView(image: UIImage(named: "call"))
        nmbrTxt.rightViewMode = UITextFieldViewMode.always
        nmbrTxt.rightView = UIImageView(image: UIImage(systemName: "pencil"))
        
        nameTxt.leftViewMode = UITextFieldViewMode.always
        nameTxt.leftView = UIImageView(image: UIImage(named: "username"))
        nameTxt.rightViewMode = UITextFieldViewMode.always
        nameTxt.rightView = UIImageView(image: UIImage(systemName: "pencil"))
        
        //hide updt btn by default, show it on editing of any of textfields
        mainview.heightAnchor.constraint(equalToConstant: 380).isActive = true
        btnUpdate.isHidden = true
        btnUpdate.layer.cornerRadius = 15
        
        mainview.shadow(color: .black, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        optionsView.shadow(color: .black, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        logOutBtn.shadow(color: .black, offSet: CGSize(width: 3, height: 3), opacity: 0.7, radius: 30, scale: true)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    
    @IBAction func showUpdateButton(_ sender: Any) {
        if btnUpdate.isHidden == true{
            btnUpdate.isHidden = false
        }
    }      
    
    //load category data here
    func LoadData(jsonObj:NSDictionary){
        print("RS",jsonObj)
        let status = jsonObj.value(forKey: "error") as! String
        if (status == "true") {
            self.Loader.dismiss(animated: true, completion: {
                self.ShowAlert(title: "Error", message:"\(jsonObj.value(forKey: "message")!)" )
            })
        }else{
            //get data for success response
//            let msg = jsonObj.value(forKey: "message") as! String
//            print(msg)
            DispatchQueue.main.async {
                    self.Loader.dismiss(animated: true, completion: {
                    self.ShowAlertOnly(title: "Profile Update", message:"\(jsonObj.value(forKey: "message")!)" )
                })
            }
        }
        //close loader here
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5, execute: {
            DispatchQueue.main.async {
               // self.DismissLoader(loader: self.Loader)
                self.dUser!.name = self.nameTxt.text!
                //print( self.dUser!.name)
                self.dUser!.phone = self.nmbrTxt.text!
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self.dUser), forKey: "user")
                //print(self.dUser?.name)
            }
        });
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cameraButton(_ sender: Any) {
        ImagePickerManager().pickImage(self, {image in
           // self.usrImg.contentMode = .scaleAspectFill
            self.usrImg.image = image
            self.myImageUploadRequest()
        })
    }
    
    @IBAction func logoutBtn(_ sender: Any) {
        
        let alert = UIAlertController(title: Apps.LOGOUT_MSG,message: "",preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Apps.NO, style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: Apps.YES, style: UIAlertActionStyle.default, handler: {
            (alertAction: UIAlertAction!) in
            if Auth.auth().currentUser != nil {
                do {
                    try Auth.auth().signOut() 
                    UserDefaults.standard.removeObject(forKey: "isLogedin")
                    //remove friend code 
                    UserDefaults.standard.removeObject(forKey: "fr_code")
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginView")
                    self.present(vc, animated: true, completion: nil)
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }
        }))
        
        alert.view.tintColor = UIColor.black  // change text color of the buttons
        alert.view.layer.cornerRadius = 25   // change corner radius
        
        present(alert, animated: true, completion: nil)
    }
    
      @IBAction func updateButton(_ sender: Any) {
        //get data from server
        if(Reachability.isConnectedToNetwork()){
            Loader = LoadLoader(loader: Loader)
            let apiURL = "email=\(String(describing: emailTxt.text!))&name=\(String(describing: nameTxt.text!))&mobile=\(String(describing: nmbrTxt.text!))"
           // print(apiURL)
            self.getAPIData(apiName: "update_profile", apiURL: apiURL,completion: LoadData)
            //print("Data updated")
        }else{
            ShowAlert(title: Apps.NO_INTERNET_TITLE, message:Apps.NO_INTERNET_MSG)
        }
    }
    
    @IBAction func userStatisticsButton(_ sender: Any){
        let view = self.storyboard!.instantiateViewController(withIdentifier: "UserStatistics")
        self.present(view, animated: true, completion: nil)
    }
    
    @IBAction func leaderboardButton(_ sender: Any){
        let view = self.storyboard!.instantiateViewController(withIdentifier: "Leaderboard")
        self.present(view, animated: true, completion: nil)
    }
    
    @IBAction func bookmarksButton(_ sender: Any){
        let view = self.storyboard!.instantiateViewController(withIdentifier: "BookmarkView")
        self.present(view, animated: true, completion: nil)
    }
        
    @IBAction func inviteFriendsButton(_ sender: Any){
        let view = self.storyboard!.instantiateViewController(withIdentifier: "ReferAndEarn")
        self.present(view, animated: true, completion: nil)
    }
    
    
    
    func myImageUploadRequest(){
        
        let url = URL(string: Apps.URL)
        var request = URLRequest(url:url!);
        request.httpMethod = "POST";
        let user_id = "\(self.dUser!.userID)"
        let param = [
            "access_key"  : "\(Apps.ACCESS_KEY)",//"6808",
            "upload_profile_image"    : "1",
            "user_id"    : user_id
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        let imageData = UIImageJPEGRepresentation(self.usrImg.image!, 0.5)
      
        if(imageData==nil)  {return; }
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "image", imageDataKey: imageData!, boundary: boundary) as Data
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {             // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {   // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
                return
            }
            
            if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                if (jsonObj != nil)  {
                    print("JSON",jsonObj!)
                    let status = jsonObj!.value(forKey: "error") as! NSNumber as! Bool
                    if (status) {
                        self.Loader.dismiss(animated: true, completion: {
                            self.ShowAlert(title: "Error", message:"\(jsonObj!.value(forKey: "message")!)" )
                        })
                        
                    }else{
                        //get data for success response
                        self.dUser?.image = jsonObj!.value(forKey: "file_path") as! String
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.dUser), forKey: "user")
                    }
                }else{
                }
            }
        }
        task.resume()        
    }
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: Data, boundary: String) -> Data {
        var body = Data();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
        
        let filename = "\(Date().currentTimeMillis()).jpg"
        let mimetype = "image/jpg"
        
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString(string: "Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString(string: "\r\n")
        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
