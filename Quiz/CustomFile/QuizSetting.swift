import Foundation
import UIKit
import AVFoundation

//apps setting and default value will be store here and used everywhere
struct Apps{
    static var URL = "https://quizdemo.wrteam.in/api-v2.php"//"http://newquiz.wrteam.in/api-v2.php"
    static var ACCESS_KEY = "6808"
    
    static let QUIZ_PLAY_TIME:CGFloat = 25 // set timer value for play quiz
    static var TOTAL_PLAY_QS = 10 // how many there will be total question in quiz play
    
    static let OPT_FT_COIN = 4 // how many coins will be deduct when we use this lifeline?
    static let OPT_SK_COIN = 4 // how many coins will be deduct when we use this lifeline?
    static let OPT_AU_COIN = 4 // how many coins will be deduct when we use this lifeline?
    static let OPT_RES_COIN = 4 // how many coins will be deduct when we use this lifeline?
    
    static let QUIZ_R_Q_POINTS = 5 // how many points will user get when he select right answer in play area
    static let QUIZ_W_Q_POINTS = 2 // how many points will deduct when user select wrong answer in play area
    
    static let BANNER_AD_UNIT_ID = "ca-app-pub-9494734299483429/5838705416"
    static let REWARD_AD_UNIT_ID = "ca-app-pub-9494734299483429/7263467729"
    static let INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-9494734299483429/1272774440"
    static let AD_TEST_DEVICE = ["e61b6b6ac743a9c528bcda64b4ee77a7","8099b28d92fa3eae7101498204255467"]
    
    static let RIGHT_ANS_COLOR = UIColor.rgb(35, 176, 75,1) //right answer color
    static let WRONG_ANS_COLOR = UIColor.rgb(237, 42, 42, 1) //wrong answer color    
    
    static let APP_ID = "1467888574"
    static var SHARE_APP = "https://itunes.apple.com/in/app/Quiz online App/1467888574?mt=8"
    static var MORE_APP = "itms-apps://itunes.com/apps/89C47N4UTZ"
    static var SHARE_APP_TXT = "Hello"
    static var SHARE_MSG = "I have earned coins using this Quiz app. you can also earn coin by downloading app from below link and enter referral code while login - "
    static var ANS_MODE = "0"
    
    static var screenHeight = CGFloat(0)
    static var screenWidth = CGFloat(0)
    
    static var FCM_ID = " "
    static let NO_NOTIFICATION = "Notifications not available"
    static let NOTIFICATIONS = "get_notifications"
    
    //variables to store push notification response parameters
    static var nTitle = ""
    static var nMsg = ""
    static var nImg = ""
    static var nMaxLvl = 0
    static var nMainCat = ""
    static var nSubCat = ""
    static var nType = ""
    static var badgeCount = UserDefaults.standard.integer(forKey: "badgeCount")
    
    static let APP_NAME = "QUIZ"
    
    static let USERS_DATA = "get_user_by_id"
    static var REFER_CODE = "refer_code"
    static let FRIENDS_CODE = "friends_code"
    //static let REFER_POINTS = "50" //50 coins added if ur referral code is used by any other user
    
    static let SYSTEM_CONFIG = "get_system_configurations"
    //static let OPTION_E = "option_e_mode"
    static var opt_E = false
    //static var REFER_STRING = "Refer a Friend, and you will get 100 coins each time your referral code is used and your friend will get 50 coins by using your referral code"
    static var REFER_COIN = "0"// added to friend's coins
    static var EARN_COIN = "0" //added to user's own coins
    static var REWARD_COIN = "4" //used to add coins to user coins when he/she watch reward video ad
        
    static let COMPLETE_LEVEL = "Congratulations !! \n You have completed the level."
    static let NOT_COMPLETE_LEVEL = "Oops!  Level not Completed.  Play again !"
    static let PLAY_AGAIN = "Play Again"
    static let NOT_ENOUGH_QUESTION_TITLE = "Not Enough Question"
    static let NO_ENOUGH_QUESTION_MSG = "This level does not have enough question to play quiz"
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
    static let LEVEL = "Level :"
    static let TRUE_ANS = "True Ans:"
    static let MATCH_DRAW = "Match Draw!"
    static let REPORT_QUESTION = "Report Question"
    static let TYPE_MSG = "Type a message"
    static let SUBMIT = "Submit"
    static let CANCEL = "Cancel"
    static let FROM_LIBRARY = "Gallary"
    static let TAKE_PHOTO = "Camera"
    static let NO_BOOKMARK = "Questions not available"
    static let LEAVE_MSG = "Are you sure , You want to leave ?"
    static let ERROR = "Error"
    static let ERROR_MSG = "Error while fetching data"
    static let MSG_NM = "Please Enter Name"
    static let MSG_ERR = "Error Creating User"
    static let PROFILE_UPDT = "Profile Update"
    static let WARNING = "Warning"
    static let WAIT = "Please wait..."
    static let DISMISS = "Dismiss"
    static let OK = "OK"
    static let HELLO = "Hello,"
    static let USER = "User"
    static let INVALID_QUE = "Invalid Question"
    static let INVALID_QUE_MSG = " This Question has wrong value."
    static let ENTER_MAILID = "Please enter email id."
    //---REVIEW---
    static let EXTRA_NOTE = "Extra Note"
    static let UN_ATTEMPTED = "Un-Attepmted"
    //---RESET PASSWORD---
    static let RESET_FAILED = "Reset Failed"
    static let RESET_TITLE = "To Reset Password, Email sent successfully"
    static let RESET_MSG = "Check your mail"
    //---ALERT MSG ------
    static let NO_DATA_TITLE = "No Data"
    static let NO_DATA = "Data Not Found !!!"
    //---LOGIN ALERTS---
    static let APPLE_LOGIN_TITLE =  "Not Supported"
    static let APPLE_LOGIN_MSG = "Apple sign in not supported in your device. try another sign method"
     static let VERIFY_MSG = "Please Verify Email First & Go Ahead !"
     static let VERIFY_MSG1 = "User verification email sent"
     static let CORRECT_DATA_MSG = "Please enter correct username and password"
    //--REFER CODE----
    static let REFER_CODE_COPY = "Refer Code Copied to Clipboard"
    static let REFER_MSG1 = "Refer a Friend, and you will get"
    static let REFER_MSG2 = "coins each time your referral code is used and your friend will get"
    static let REFER_MSG3 = "coins by using your referral code "
    //----SELF CHALLENGE ---
    static let ALERT_TITLE = "Select Quiz Question"
    static let ALERT_TITLE1 = "Select Quiz Play time"
    static let BACK_MSG = "You haven't submitted this test yet."
    static let SUBMIT_TEST = "You want to submit this test?"
    static let RESULT_TXT = "You have completed the challenge \n in"
    static let SECONDS = "Sec"
    static let CHLNG_TIME = "Challenge time:"
    //---FONT----
    static let FONT_TITLE =  "Font Size"
    static let FONT_MSG = "Increase/Decrease Font Size\n\n\n\n\n\n"
    //---IMAGE---
    static let IMG_TITLE =  "Choose Image"
    static let NO_CAMERA = "You don't have camera"
    //---BATTLE----
    static let GAME_OVER = "The Game Is over! Play Again "
    static let WIN_BATTLE = "you win the Battle"
    static let CONGRATS = "Congratulations!!"
    static let OPP_WIN_BATTLE = "win the Battle"
    static let LOSE_BATTLE = "Better Luck Next Time"
    static let LANG = "en-US"
    
}
