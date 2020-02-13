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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GIDSignInDelegate ,UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    let varSys = SystemConfig()
    let gcmMessageIDKey = "gcm.message_id"
    
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //firebase configuration
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
                
        //check app is log in or not if not than navigate to login view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if UserDefaults.standard.bool(forKey: "isLogedin") {
            // if app is loged in then navigate to menuview controller
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "ViewController")
            // navigationController
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        }else{
            // if app is not loged in than navigate to loginview controller
            self.window = UIWindow(frame: UIScreen.main.bounds)
            let initialViewController = storyboard.instantiateViewController(withIdentifier: "LoginView")
            //let initialViewController = storyboard.instantiateViewController(withIdentifier: "SignUpView")//for testing only
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
            
        }
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

        Messaging.messaging().delegate = self
        Messaging.messaging().shouldEstablishDirectChannel = true
        
        let token = Messaging.messaging().fcmToken ?? "none"
        Apps.FCM_ID = token
        print("TOKEN - \(token)")
        
        //to get system configurations parameters as per requirement
      // let varSys = SystemConfig()
       varSys.ConfigureSystem()
       varSys.getNotifications()
       //varSys.updtFCMToServer()
        
        saveImgFromURL("https://quizdemo.wrteam.in/images/notifications/images/notifications/1581411372.827.jpg")
        
        //FirebaseApp.configure()
        return true
    }
    //to receive notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    
        //print("notification done")
    }
    
    //func called when user clicks on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
            print("message :  \(userInfo)")
           // openPostDetail(userInfo: userInfo) // my function to display post detail viewController
        }
        
        //go To Notification Page
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let initialViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NotificationsView")
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
        
        // Print full message.
        //analyse(notification: userInfo)
        completionHandler()
    }
    private func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("DEVICE TOKEN = \(String(describing: deviceToken))")
    }
    
    private func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
            // The token is not currently available.
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let handled = ApplicationDelegate.shared.application(app, open: url, options: options)
        
        return handled
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        if let messageID = userInfo[gcmMessageIDKey] {
//          print("Message ID: \(messageID)")
//        }
        // Print full message.
        print("USER INFO ",userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print("Firebase registration token: \(fcmToken)")

      let dataDict:[String: String] = ["token": fcmToken]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        //send token to application server.
         varSys.updtFCMToServer()
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
        var title : String = ""
        var body : String = ""
        
        if (remoteMessage.appData["notification"] as? [String:Any]) != nil { //cloud message of firebase
            //print(remoteMessage.appData["notification"]!)
            let notif = remoteMessage.appData["notification"]
            guard let DATA = notif as? [String:Any] else{
                               return
                           }
          // print("Data -\(DATA)")
             title = DATA["title"]  as! String
             body = DATA["body"]  as! String // body = DATA["message"] as! String incase of data instead of notification here
            
            //print("title -\(title)")
            //print("body -\(body)")
            showNotification(title,body,"") //showNotification(title,body)
        }else if (remoteMessage.appData["data"]) != nil { //app message check
            let notif = remoteMessage.appData["data"]
            print(notif!)
            let str : String = remoteMessage.appData["data"] as! String
            
            let displayname = str.components(separatedBy: ",")
            print(displayname)
            var img = displayname[0] //img url
                        
            let a = displayname[4] //title
            let b = displayname[5] //body or message
            img = "https://quizdemo.wrteam.in/images/notifications/images/notifications/1581411372.827.jpg"
            let c = a.components(separatedBy: ":")
            let title1: String = c[1]
            let d = b.components(separatedBy: ":")
            let body1: String = d[1]
            let e: String = title1
            let f = e.components(separatedBy: "\"")
            let g: String = body1
            let h = g.components(separatedBy: "\"")
//            let reversedSlash: String = str1.replacingOccurrences(of: "\\" , with: "")
//            print(reversedSlash)
              print("img url - \(img)")
              print("title -\(f[1])")
              print("message -\(h[1])")
                title = f[1]
                body = h[1]
                //img = img1[1]
                showNotification(title,body,img) //showNotification(title,body,img)
           
        }else{
            print("There is No Pending message !!")
        }
    }
    // Google Sign In
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    func showNotification(_ title:String,_ body:String,_ img:String ){ //,_ img:String
        //show notification pop up with received title & body
            let content = UNMutableNotificationContent()
              content.title = title
              content.subtitle = "Subtitle"
              content.body = body
              content.sound = UNNotificationSound.default()

        let url = UIImage(named: "testImg")
        let attachment = UNNotificationAttachment.create(identifier: "image", image: url!, options: nil)
        content.attachments = [attachment!]
          
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "testIdentifier", content: content, trigger: trigger)
       
        if content.title != "" && content.body != "" {
            UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
        }
    }
    func applicationWillResignActive(_ application: UIApplication) {
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
    }
    func saveImgFromURL(_ imgURL: String){
       let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
       if let url = URL(string: imgURL) {
           URLSession.shared.downloadTask(with: url) { location, response, error in
               guard let location = location else {
                   print("download error:", error ?? "")
                   return
               }
               // move the downloaded file from the temporary location url to your app documents directory
               do {
                   try FileManager.default.moveItem(at: location, to: documents.appendingPathComponent(response?.suggestedFilename ?? url.lastPathComponent))
               } catch {
                   print(error)
               }
           }.resume()
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

extension UNNotificationAttachment {
/// Save the image to disk
static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
    let fileManager = FileManager.default
    let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
    let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
    do {
        try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
        let imageFileIdentifier = identifier+".png"
        let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
        guard let imageData = UIImagePNGRepresentation(image) else {
            return nil
        }
        try imageData.write(to: fileURL)
        let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
        return imageAttachment
    } catch {
        print("error " + error.localizedDescription)
    }
    return nil
  }
}
