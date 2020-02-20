import Foundation
import UIKit
import AVFoundation

//apps seting and default value will be store here and used everywhere
struct Apps{
    //static var URL = "http://quiz.wrteam.in/api-v2.php" //version 5.3
    static var URL = "https://quizdemo.wrteam.in/api-v2.php"
    
    //static var URL = "http://vetquiz.club/api-v2.php"
    static var ACCESS_KEY = "6808"
    
    static let QUIZ_PLAY_TIME:CGFloat = 25 // set timer value for play quiz
    static var TOTAL_PLAY_QS = 10 // how many there will be total question in quiz play
    
    static let OPT_FT_COIN = 4 // how many coins will be deduct when we use this lifeline?
    static let OPT_SK_COIN = 2 // how many coins will be deduct when we use this lifeline?
    static let OPT_AU_COIN = 2 // how many coins will be deduct when we use this lifeline?
    static let OPT_RES_COIN = 2 // how many coins will be deduct when we use this lifeline?
    
    static let QUIZ_R_Q_POINTS = 5 // how many points will user get when he select right answer in play area
    static let QUIZ_W_Q_POINTS = 2 // how many points will deduct when user select wrong answer in play area
    
    static let BANNER_AD_UNIT_ID = "ca-app-pub-9494734299483429/5838705416"
    static let REWARD_AD_UNIT_ID = "ca-app-pub-9494734299483429/7263467729"
    static let INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-9494734299483429/1272774440"
    
    static let RIGHT_ANS_COLOR = UIColor.rgb(35, 176, 75,1) //right answer color
    static let WRONG_ANS_COLOR = UIColor.rgb(237, 42, 42, 1) //wrong answer color
    
    static let AD_TEST_DEVICE = ["e61b6b6ac743a9c528bcda64b4ee77a7"]
    static let APP_ID = "1467888574"
    //static let SHARE_APP = "https://itunes.apple.com/in/app/Quiz online App/1467888574?mt=8"
    static var SHARE_APP = "https://itunes.apple.com/in/app/Quiz online App/1467888574?mt=8"
   //static let MORE_APP = "itms-apps://itunes.com/apps/89C47N4UTZ"
    static var MORE_APP = "itms-apps://itunes.com/apps/89C47N4UTZ"
    static var SHARE_APP_TXT = "Hello"
    static var SHARE_MSG = "I have earned coins using this Quiz app. you can also earn coin by downloading app from below link and enter referral code while login - "
    
    static var FCM_ID = " "
    static let NO_NOTIFICATION = "Notifications not available"
    static let NOTIFICATIONS = "get_notifications"
    
    static let APP_NAME = "QUIZ"
    
    static let USERS_DATA = "get_user_by_id"
    static var REFER_CODE = "refer_code"
    static let FRIENDS_CODE = "friends_code"
    static let REFER_POINTS = "50" //50 coins added if ur referral code is used by any other user
    
    static let SYSTEM_CONFIG = "get_system_configurations"
    //static let OPTION_E = "option_e_mode"
    static var opt_E = false
        
    static let COMPLETE_LEVEL = "Congratulations you have completed this level"
    static let NOT_COMPLETE_LEVEL = "Opps! you have failed to complete this level"
    static let PLAY_AGAIN = "Play Again"
    static let NOT_ENOUGH_QUESTION_TITLE = "Not Eought Question"
    static let NO_ENOUGH_QUESTION_MSG = "This level does not have enought question to play quiz"
    static let COMPLETE_ALL_QUESTION = "You have Completed All Questions !!"
    static let LEVET_NOT_AVAILABEL = "Level not available"
    static let STATISTICS_NOT_AVAIL = "Data not available"
    static let SKIP_COINS = "SKIP. I DON'T NEED COINS"
    static let MSG_ENOUGH_COIN = "Not Enough Coins !"
    static let NEED_COIN_MSG1 = "You don't have enough coins. You need atleast"
    static let NEED_COIN_MSG2 = "coins to use this lifeline."
    static let NEED_COIN_MSG3 = "Watch a short video & get free coins."
    static let WATCH_VIDEO = "WATCH NOW"
    static let EXIT_APP_MSG = "Do you really want to quit?"
    static let NO_INTERNET_TITLE = "No Internet!"
    static let NO_INTERNET_MSG = "Please check you internet connection!"
    static let LEVEL_LOCK = "This level in lock for you"
    static let LOGOUT_MSG = "Do you really want to log out?"
    static let LIFELINE_ALREDY_USED_TITLE = "Life Line"
    static let LIFELINE_ALREDY_USED = "Already use"
    static let YES = "YES"
    static let NO = "NO"
    static let OOPS = "Oops!"
    static let ROBOT = "Robot"
    static let BACK = "Back"
    static let SHOW_ANSWER = "Show Answer"
    static let LEVEL = "Level"
    static let TRUE_ANS = "True Ans:"
    static let MATCH_DRAW = "Match Draw!"
    static let REPORT_QUESTION = "Report Question"
    static let TYPE_MSG = "Type a message"
    static let SUBMIT = "Submit"
    static let CANCEL = "Cancel"
    static let FROM_LIBRARY = "Gallary"
    static let TAKE_PHOTO = "Camera"
    static let NO_BOOKMARK = "Questions not available"
    
}


