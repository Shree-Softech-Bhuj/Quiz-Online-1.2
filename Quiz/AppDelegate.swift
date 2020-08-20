import UIKit
import CoreData
import GoogleSignIn
import Firebase
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging
import FBSDKCoreKit
import GoogleMobileAds
import Firebase

var deviceStoryBoard = "Main"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate ,UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    let varSys = SystemConfig()
    let gcmMessageIDKey = "test.demo"
    var imgURL = URL(string: "")
    var isImgAttached = false
    var subtitle : String = ""
    var title : String = ""
    var body : String = ""
    var type : String = ""
    var category : [String] = []
    let screenBounds = UIScreen.main.bounds
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //firebase configuration
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        //get screen height & width to use it further for diff iphone screens
        Apps.screenWidth = screenBounds.width
        Apps.screenHeight = screenBounds.height
        
        //to get system configurations parameters as per requirement
       varSys.ConfigureSystem()
       varSys.LoadLanguages(completion: {})
       varSys.getNotifications()
        
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
        
        //set badge
        if Apps.badgeCount > 0 {
            application.applicationIconBadgeNumber = Apps.badgeCount
        }else{ //clear badge
            application.applicationIconBadgeNumber = 0
        }
        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        let token = Messaging.messaging().fcmToken ?? "none"
        Apps.FCM_ID = token
        print("FCM TOKEN", token)
        
        
        //check app is log in or not if not then navigate to login view controller
        if UIDevice.current.userInterfaceIdiom == .pad{
            deviceStoryBoard = "Ipad"
        }else{
            deviceStoryBoard = "Main"
        }
        let storyboard = UIStoryboard(name: deviceStoryBoard, bundle: nil)
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
            
            let navigationcontroller = UINavigationController(rootViewController: initialViewController)
            navigationcontroller.setNavigationBarHidden(true, animated: false)
            navigationcontroller.isNavigationBarHidden = true
            
            window?.rootViewController = navigationcontroller
            window?.makeKeyAndVisible()
            
        }else{
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginView")
            
            let navigationcontroller = UINavigationController(rootViewController: initialViewController)
            navigationcontroller.setNavigationBarHidden(true, animated: false)
            navigationcontroller.isNavigationBarHidden = true
            
            window?.rootViewController = navigationcontroller
            window?.makeKeyAndVisible()
            
        }
        
        return true
    }
    //to redirect back to app from google login in ios 10
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return (GIDSignIn.sharedInstance()?.handle(url as URL?))!
    }
    
    //to preview notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(Apps.badgeCount)
        completionHandler([.alert,.badge,.sound])
    }
    
    //func called when user tap on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        //deduct 1 from badgeCount As user opens notification
        if Apps.badgeCount > 0 {
            Apps.badgeCount -= 1
            UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
        }
        actionAccordingToData()
        print(" user info - \(userInfo)")
        completionHandler()
    }
    private func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        switch application.applicationState {
            
        case .inactive:
            print("Inactive")
            //Show the view with the content of the push
            completionHandler(.newData)
            
        case .background:
            print("Background")
            //Refresh the local model
            completionHandler(.newData)
            
        case .active:
            print("Active")
            //Show an in-app banner
            completionHandler(.newData)
        }
        
        print("USER INFO ",userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    private func application(application: UIApplication,didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Messaging.messaging().apnsToken = deviceToken as Data
        print("token \(deviceToken)")
    }
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print(fcmToken)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        //send token to application server.
        Apps.FCM_ID = fcmToken
        varSys.updtFCMToServer()
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        if (remoteMessage.appData["notification"] as? [String:Any]) != nil { //cloud message - firebase
            print(remoteMessage.appData["notification"]!)
            let notif = remoteMessage.appData["notification"] //receive from Firebase
            guard let DATA = notif as? [String:Any] else{
                return
            }
            if DATA["image"] != nil {
                isImgAttached = true
                let img = DATA["image"]  as! String
                imgURL = setAttachment(img)
                isImgAttached = true
            }else{
                isImgAttached = false
            }
            title = DATA["title"]  as! String
            if let s_title = DATA["subtitle"] {
                subtitle = s_title as! String
            }
            body = DATA["body"]  as! String
            if  isImgAttached == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
                    self.showNotificationWithAttachment(self.title,self.body,self.imgURL!)
                })
            }else{
                showNotification(title,body)
            }
            
        }else if (remoteMessage.appData["data"]) != nil { //app message check
            let notif = remoteMessage.appData["data"] //receive from API - Server
            print(notif!)
            let str : String = remoteMessage.appData["data"] as! String
            fragmentRemoteData(str)
            if  isImgAttached == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
                    self.showNotificationWithAttachment(self.title,self.body,self.imgURL!)
                })
            }else{
                showNotification(title,body)
            }
        }else{
            print("There is No Pending messages / Notifications !!")
        }
    }
    
    // Google Sign In
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        print("called resignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // call function when app is gone to background to quit battle
        NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
        //call function when app is live again to check opponent again
        NotificationCenter.default.post(name: Notification.Name("CheckBattle"), object: nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
        application.applicationIconBadgeNumber = Apps.badgeCount
    }
    func fragmentRemoteData(_  str:String){
        //separate parameters of response by using ","
        let displayname = str.components(separatedBy: ",")
        //print(displayname)
        let len = displayname.count
        print(len)
        let img0 = displayname[0] //img url
        let img1 = img0.dropFirst()
        let img2 = img1.components(separatedBy: "\"")
        if img2.count > 3 { // img2[0] & img2[2] = "" and img2[1] = image according to separation applied above, so if img is attached it will depend on img2[3] if img url is attched
            if img2[3] != "" && img2[3] != "null" {
                let img: String = img2[3]
                imgURL = setAttachment(img)
                isImgAttached = true
            }else{
                print("image url is blank !!!")
            }
        }
        let a = displayname[4] //title
        
        let b = displayname[5] //body or message
        
        let c = a.components(separatedBy: ":")
        let title1: String = c[1]
        
        let d = b.components(separatedBy: ":")
        let body1: String = d[1]
        
        let e: String = title1
        let f = e.components(separatedBy: "\"")
        
        let g: String = body1
        let h = g.components(separatedBy: "\"")
        print("title - \(f[1])")
        print("message - \(h[1])")
        
        let max_level0 = displayname[1] //max level
        let max_level1 = max_level0.components(separatedBy: ":")
        let max_level2 : String = max_level1[1]
        let max_level = max_level2.components(separatedBy:  "\"")
        print("max level - \(max_level[1])")
        
        let category0 = displayname[2] //type id
        let category1 = category0.components(separatedBy: ":")
        let category2 : String = category1[1]
        if category2.contains("\""){
            category = category2.components(separatedBy:  "\"")
            print("category - \(category[1])")
        }else{
            category  = ["0","0"]
        }
        
        let numOf0 = displayname[3] //numberOf
        let numOf1 = numOf0.components(separatedBy: ":")
        let numOf2: String = numOf1[1]
        
        let numOf = numOf2.components(separatedBy:  "\"")
        print("number of - \(numOf[1])")
        
        let temp = displayname[6]
        let temp0 = temp.components(separatedBy: ":")
        let temp1 = temp0[1].components(separatedBy: "}") //type
        let temp2: String = temp1[0]
        let temp3 = temp2.components(separatedBy:  "\"")
        type = temp3[1]
        print("type - \(type)")
        
        title = f[1]
        body = h[1]
        //pass variable values to global variables
        Apps.nTitle = title
        Apps.nMsg = body
        Apps.nMaxLvl = Int(max_level[1]) ?? 0
        Apps.nMainCat = category[1]
        Apps.nSubCat = numOf[1]
        Apps.nType = type
    }
    
    func showNotification(_ title:String,_ body:String){
        //show notification alert with received title & body
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle //"Subtitle"
        content.body = body
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "testIdentifier", content: content, trigger: trigger)
        
        Apps.badgeCount += 1
        UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
        print(Apps.badgeCount)
        UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
    }
    
    func showNotificationWithAttachment(_ title:String,_ body:String,_ img:URL){
        //show notification pop up with received title & body
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle //"Subtitle"
        content.body = body
        content.sound = UNNotificationSound.default
        print("data \(img)")
        if img.path.contains("jpg"){
            print("file is present @ \(img.path)")
            let attachment = try! UNNotificationAttachment(identifier : "image", url: img, options: nil)
            content.attachments = [attachment]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "testIdentifier", content: content, trigger: trigger)
            if content.title != "" && content.body != "" {
                Apps.badgeCount += 1
                UserDefaults.standard.set(Apps.badgeCount, forKey: "badgeCount")
                print(Apps.badgeCount)
                UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
            }
        }else{
            print("file is not present at given path")
        }
    }
    
    func setAttachment(_ tempImg : String) -> URL {
        // Create destination URL
        let  documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        print(documentsUrl)
        //add downloaded image as specified name below
        let destinationFileUrl = documentsUrl.appendingPathComponent("tempImg.jpg")
        //Create URL to the source file you want to download
        let iimage =  tempImg.replacingOccurrences(of: "\\", with: "")
        //print("passing url - \(iimage)")
        let fileURL = URL(string: iimage) //https://api.androidhive.info//images//minion.jpg  https://www.arenaflowers.co.in/blog/wp-content/uploads/2017/09/Summer_Flowers_Lotus.jpg
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url:fileURL!)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                }
                
                do {
                    self.removeTempImg() //to avoid overrriding, just delete existing file & then copy file here
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }
                
            } else {
                // print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
            }
        }
        task.resume()
        return destinationFileUrl
    }
    //func called when user click on notification as received
    func actionAccordingToData(){
        if Apps.nType == "default" {
            //goTo homepage
        }else if Apps.nType == "category" {
            if Apps.nSubCat != "0" {
                let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let subCatView:SubCategoryView = storyBoard.instantiateViewController(withIdentifier: "SubCategoryView") as! SubCategoryView
                subCatView.catID = Apps.nMainCat //pass main category id to show subcategories regarding to main category there
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = subCatView
                self.window?.makeKeyAndVisible()
            }else if Apps.nMainCat != "0"{
                //open level 1 of category id given
                let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let levelScreen:LevelView = storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
                levelScreen.maxLevel = Apps.nMaxLvl
                levelScreen.catID = Int(Apps.nMainCat) ?? 0
                levelScreen.questionType = "main"
                // print(levelScreen.questionType)
                // print(levelScreen.catID)
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = levelScreen
                self.window?.makeKeyAndVisible()
            }
        }
    }
    
    func removeTempImg(){ //remove Img before copying new image downloaded from url given with notification data
        let  documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationFileUrl = documentsUrl.appendingPathComponent("tempImg.jpg")
        if FileManager.default.fileExists(atPath: destinationFileUrl.path){
            try? FileManager.default.removeItem(at: destinationFileUrl)
        }
    }
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Quiz")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

