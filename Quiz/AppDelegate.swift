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
    var imgURL = URL(string: "")
    var isImgAttached = false
    var title : String = ""
    var body : String = ""
    
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
       varSys.ConfigureSystem()
       varSys.getNotifications()

        return true
    }
    //to receive notification in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
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
        // removeTempImg()
        print(" user info - \(userInfo)")
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
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
      print("Firebase registration token: \(fcmToken)")

      let dataDict:[String: String] = ["token": fcmToken]
      NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        //send token to application server.
         varSys.updtFCMToServer()
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
               
        if (remoteMessage.appData["notification"] as? [String:Any]) != nil { //cloud message of firebase
            //print(remoteMessage.appData["notification"]!)
            let notif = remoteMessage.appData["notification"] //receive from Firebase
            guard let DATA = notif as? [String:Any] else{
                               return
                           }
             title = DATA["title"]  as! String
             body = DATA["body"]  as! String
            showNotification(title,body) //showNotification(title,body)
            
        }else if (remoteMessage.appData["data"] as? [String:Any]) != nil {
                print("data of type ANY - \(remoteMessage.appData["data"])")
        }else if (remoteMessage.appData["data"]) != nil { //app message check
            let notif = remoteMessage.appData["data"] //receive from API - Server
            print(notif!)
            let str : String = remoteMessage.appData["data"] as! String
            let displayname = str.components(separatedBy: ",")
            //print(displayname)
            let img0 = displayname[0] //img url
            let img1 = img0.dropFirst()
            let img2 = img1.components(separatedBy: "\"")
            if img2.count > 3 { // img2[0] & img2[2] = "" and img2[1] = image according to separation applied above, so if img is attached it will depend on img2[3] if img url is attched
                if img2[3] != ""{
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
         
             let max_level = displayname[1] //max level
                print(max_level)
             let category = displayname[2] //type id
                print(category)
            let numOf = displayname[3] //numberOf
                print(numOf)
             let type = displayname[6] //type
            print(type)
            
              print("title -\(f[1])")
              print("message -\(h[1])")
                title = f[1]
                body = h[1]
            Apps.nTitle = title
            Apps.nMsg = body
            Apps.nMainCat = category
            Apps.nSubCat = numOf
            Apps.nType = type
            
            if  isImgAttached == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + 7.0, execute: {
                    self.showNotificationWithAttachment(self.title,self.body,self.imgURL!) //showNotification(title,body,img)
                })
            }else{
                showNotification(title,body)
            }
        }else{
            print("There is No Pending messages / Notifications !!")
        }
    }
    // Google Sign In
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {

    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }
    func showNotification(_ title:String,_ body:String){ //,_ img:String
        //show notification pop up with received title & body
            let content = UNMutableNotificationContent()
              content.title = title
              content.subtitle = "Subtitle"
              content.body = body
              content.sound = UNNotificationSound.default()
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "testIdentifier", content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
    }
    func showNotificationWithAttachment(_ title:String,_ body:String,_ img:URL){ //,_ img: URL
            //show notification pop up with received title & body
                let content = UNMutableNotificationContent()
                  content.title = title
                 // content.subtitle = "Subtitle"
                  content.body = body
                  content.sound = UNNotificationSound.default()
                    print("data \(img)")
        if img.path.contains("jpg"){
            print("file is present @ \(img.path)")
            let attachment = try! UNNotificationAttachment(identifier : "image", url: img, options: nil)
            content.attachments = [attachment]
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
             let request = UNNotificationRequest(identifier: "testIdentifier", content: content, trigger: trigger)
             if content.title != "" && content.body != "" {
                 UNUserNotificationCenter.current().add(request,withCompletionHandler: nil)
                         }
        }else{
             print("file is not present at given path")
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        
        print("called resignActive")
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
         print("goto background")
        // call function when app is gone to background to quit battle
         NotificationCenter.default.post(name: Notification.Name("QuitBattle"), object: nil)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
         print("back again")
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
                        removeTempImg() //to avoid overrriding, just delete existing file & then copy file here
                       try FileManager.default.copyItem(at: tempLocalUrl, to: destinationFileUrl)
                   } catch (let writeError) {
                       print("Error creating a file \(destinationFileUrl) : \(writeError)")
                   }

               } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription as Any);
               }
           }
           task.resume()
            print("passing url for img path - \(destinationFileUrl)")
        return destinationFileUrl
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

func removeTempImg(){
   let  documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationFileUrl = documentsUrl.appendingPathComponent("tempImg.jpg")
    if FileManager.default.fileExists(atPath: destinationFileUrl.path){
        try? FileManager.default.removeItem(at: destinationFileUrl)
   }
}
func actionAccordingToContent(){
    if Apps.nType == "default" {
    }else if Apps.nType == "category" {
        if Apps.nSubCat != "0" {
            //open level 1 of subcategory id given
           let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
           let levelScreen:LevelView = storyBoard.instantiateViewController(withIdentifier: "LevelView") as! LevelView
          // if subCatData[indexPath.row].maxlevel.isInt{
            levelScreen.maxLevel = Int(Apps.nMaxLvl)!
           //}
            levelScreen.catID = Int(Apps.nSubCat) ?? 0
           levelScreen.questionType = "sub"
         // present(levelScreen, animated: true, completion: nil)
              
        }else if Apps.nMainCat != "0"{
            let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let subCatView:SubCategoryView = storyBoard.instantiateViewController(withIdentifier: "SubCategoryView") as! SubCategoryView
            subCatView.catID = Apps.nMainCat //pass main category id to show subcategories regarding to main category there
            // present(subCatView, animated: true, completion: nil)
     }
   }
}
