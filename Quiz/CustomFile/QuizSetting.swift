import Foundation
import UIKit
import AVFoundation

//apps setting and default value will be store here and used everywhere
struct Apps{
    static var URL = "http://quizdemo.wrteam.in/api-v2.php" //"http://newquiz.wrteam.in/api-v2.php"//
    static var ACCESS_KEY = "6808"
    
    static let JWT = "set_your_strong_jwt_secret_key" //"quiz@123"
    
    //set values
    static let QUIZ_PLAY_TIME:CGFloat = 25 // set timer value for play quiz
       
    static let OPT_FT_COIN = 4 // how many coins will be deduct when we use 50-50 lifeline?
    static let OPT_SK_COIN = 4 // how many coins will be deduct when we use SKIP lifeline?
    static let OPT_AU_COIN = 4 // how many coins will be deduct when we use AUDIENCE POLL lifeline?
    static let OPT_RES_COIN = 4 // how many coins will be deduct when we use RESET TIMER lifeline?
    
    static let QUIZ_R_Q_POINTS = 4 // how many points will user get when he select right answer in play area
    static let QUIZ_W_Q_POINTS = 2 // how many points will deduct when user select wrong answer in play area
    static let CONTEST_RIGHT_POINTS = 3 // how many points will user get when he select right answer in Contest
    
    static var REWARD_COIN = "4" //used to add coins to user coins when user watch reward video ad
    
    static let BANNER_AD_UNIT_ID = "ca-app-pub-3940256099942544/2934735716"//"ca-app-pub-9494734299483429/5838705416"
    static let REWARD_AD_UNIT_ID = "ca-app-pub-3940256099942544/1712485313"//"ca-app-pub-9494734299483429/7263467729"
    static let INTERSTITIAL_AD_UNIT_ID = "ca-app-pub-3940256099942544/4411468910"//"ca-app-pub-9494734299483429/1272774440"
    static let APP_OPEN_UNIT_ID = "ca-app-pub-3940256099942544/5662855259"
    static let AD_TEST_DEVICE = ["e61b6b6ac743a9c528bcda64b4ee77a7","8099b28d92fa3eae7101498204255467"]
    
    static let RIGHT_ANS_COLOR = UIColor.rgb(35, 176, 75,1) //right answer color
    static let WRONG_ANS_COLOR = UIColor.rgb(237, 42, 42, 1) //wrong answer color
   
    static let BASIC_COLOR = UIColor.rgb(29, 108, 186, 1.0)//(0, 194, 217, 1.0)//(57, 129, 156, 1.0)
    static let BASIC_COLOR_CGCOLOR = UIColor.rgb(29, 108, 186, 1.0).cgColor//(0, 194, 217, 1.0)//rgb(57, 129, 156, 1.0)
    
    //gradient Colors
    let purple1 = UIColor.rgb(158, 89, 225, 1)
    let purple2 = UIColor.rgb(241, 125, 196, 1.0)
    
    let sky1 = UIColor.rgb(67,155,210,1.0)
    let sky2 = UIColor.rgb(115,225,192,1.0)
    
    let orange1 = UIColor.rgb(227,119,67,1.0)
    let orange2 = UIColor.rgb(237,159,63,1.0)
    
    let blue1 = UIColor.rgb(29,108,186,1.0)
    let blue2 = UIColor.rgb(84,193,255,1.0)
    
    let pink1 = UIColor.rgb(195,15,142,1.0)
    let pink2 = UIColor.rgb(251,82,147,1.0)
    
    let green1 = UIColor.rgb(60,131,70,1.0)
    let green2 = UIColor.rgb(139,209,136,1.0)
    
    //App Information - set from admin panel
    static var SHARE_APP = "https://itunes.apple.com/in/app/Quiz online App/1467888574?mt=8"
    static var MORE_APP = "itms-apps://itunes.com/apps/89C47N4UTZ"
    static var SHARE_APP_TXT = "Hello"
    static var TOTAL_PLAY_QS = 10 // how many there will be total question in quiz play
    
    static var ANS_MODE = "0"
    static var FORCE_UPDT_MODE = "1"
    static var CONTEST_MODE = "1"
    static var DAILY_QUIZ_MODE = "1"
    static var FIX_QUE_LVL = "0"
    static var RANDOM_BATTLE_WITH_CATEGORY = "1"
    static var GROUP_BATTLE_WITH_CATEGORY = "1"
    
    static var screenHeight = CGFloat(0)
    static var screenWidth = CGFloat(0)
    
    //variables to store push notification response parameters
    static var nTitle = ""
    static var nMsg = ""
    static var nImg = ""
    static var nMaxLvl = 0
    static var nMainCat = ""
    static var nSubCat = ""
    static var nType = ""
    static var badgeCount = UserDefaults.standard.integer(forKey: "badgeCount")
    
    //APis - static values
    static let USERS_DATA = "get_user_by_id"
    static var REFER_CODE = "refer_code"
    static let FRIENDS_CODE = "friends_code"
    static let SYSTEM_CONFIG = "get_system_configurations"
    static let NOTIFICATIONS = "get_notifications"
    static let API_BOOKMARK_GET = "get_bookmark"
    static let API_BOOKMARK_SET = "set_bookmark"
    
    static var opt_E = false
    static var ALL_TIME_RANK:Any = "0" //0//
    static var COINS = "0"
    static var SCORE: Any = "0"
    static var REFER_COIN = "0"// added to friend's coins
    static var EARN_COIN = "0" //added to user's own coins
    
    static var FCM_ID = " "
    //-----------Home ViewController Strings-------------
    static let QUIZ_ZONE = "Quiz Zone"
    static let PLAY_ZONE = "Play Zone"
    static let BATTLE_ZONE = "Battle Zone"
    static let CONTEST_ZONE = "Contest Zone"
    static let IMG_QUIZ_ZONE = "quizzone"
    static let IMG_PLAYQUIZ = "playquiz"
    static let IMG_BATTLE_QUIZ = "battlequiz"
    static let IMG_CONTEST_QUIZ = "contestquiz"
    
    static let DAILY_QUIZ_PLAY = "Daily Quiz"
    static let RNDM_QUIZ = "Random Quiz"
    static let TRUE_FALSE = "True / False"
    static let SELF_CHLNG = "Self Challenge"
    static let PRACTICE = "Practice"
    static let GROUP_BTL = "Group Battle"
    static let RNDM_BTL = "Random Battle"
    
    static let CONTEST_PLAY_TEXT = "Contest Play"
    static let JOIN_NOW = "Join Now"
    
    //----colors-----
    static let SKY1 = "sky1"
    static let ORANGE1 = "orange1"
    static let PURPLE1 = "purple1"
    static let GREEN1 = "green1"
    static let BLUE1 = "blue1"
    static let PINK1 = "pink1"
    
    static let SKY2 = "sky2"
    static let ORANGE2 = "orange2"
    static let PURPLE2 = "purple2"
    static let GREEN2 = "green2"
    static let BLUE2 = "blue2"
    static let PINK2 = "pink2"
    
    static let GRP_BTL = "groupbattle"
    static let RNDM = "random"
    static let CONTEST_IMG = "contest"
    
    //strings to Translate
    static let APP_NAME = "Quiz (v7.0.0)"
    static var SHARE_MSG = "I have earned coins using this Quiz app. you can also earn coin by downloading app from below link and enter referral code while login - "
    static let NO_NOTIFICATION = "Notifications not available"
    static let COMPLETE_LEVEL = "Congratulations !! \n You have completed the level."
    static let NOT_COMPLETE_LEVEL = "Oops! Level not Completed.  Play again !"
    static let PLAY_AGAIN = "Play Again"
    static let NOT_ENOUGH_QUESTION_TITLE = "Not Enough Question"
    static let NO_ENOUGH_QUESTION_MSG = "This level does not have enough question to play quiz"
    static let COMPLETE_ALL_QUESTION = "You have Completed All Questions !!"
    static let LEVET_NOT_AVAILABEL = "Level not available"
    static let STATISTICS_NOT_AVAIL = "Data not available"
    static let SKIP_COINS = "SKIP"
    static let MSG_ENOUGH_COIN = "Not Enough Coins !"
    static let NEED_COIN_MSG1 = "You don't have enough coins. You need atleast"
    static let NEED_COIN_MSG2 = "coins to use this lifeline."
    static let NEED_COIN_MSG3 = "Watch a short video & get free coins."
    static let WATCH_VIDEO = "WATCH NOW"
    static let EXIT_APP_MSG = "Do you really want to quit?"
    static let EXIT_PLAY = "Do you want to exit the Quiz?"
    static let NO_INTERNET_TITLE = "No Internet!"
    static let NO_INTERNET_MSG = "Please check you internet connection!"
    static let LEVEL_LOCK = "This level in lock for you"
    static let LOGOUT_TITLE = "LOGOUT"
    static let LOGOUT_MSG = "Are you sure!! \n You really want to log out?"
    static let LIFELINE_ALREDY_USED_TITLE = "Life Line"
    static let LIFELINE_ALREDY_USED = "Already use"
    static let YES = "YES"
    static let NO = "NO"
    static let DONE = "Done"
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
    static let FROM_LIBRARY = "Gallery"
    static let TAKE_PHOTO = "Camera"
    static let NO_BOOKMARK = "Questions not available"
    static let LEAVE_MSG = "Are you sure , You want to leave ?"
    static let ERROR = "Error"
    static let ERROR_MSG = "Error while fetching data"
    static let MSG_NM = "Please Enter Name"
    static let MSG_ERR = "Error Creating User"
    static let PROFILE_UPDT = "Profile Update"
    static let WARNING = "Warning"
    static let WAIT = "Please wait...⏳"
    static let DISMISS = "Dismiss"
    static let OK = "OK"
    static let OKAY = "OKAY"
    static let HELLO = "Hello,"
    static let USER = "User"
    static let INVALID_QUE = "Invalid Question"
    static let INVALID_QUE_MSG = " This Question has wrong value."
    static let ENTER_MAILID = "Please enter email id."
    //---REVIEW---
    static let EXTRA_NOTE = "Extra Note"
    static let UN_ATTEMPTED = "Un-Attempted"
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
    static let ALERT_TITLE = "Select Number Of Questions"
    static let ALERT_TITLE1 = "Select Quiz Play time"
    static let BACK_MSG = "You haven't submitted this test yet."
    static let SUBMIT_TEST = "You want to submit this test?"
    static let RESULT_TXT = "you have completed challenge \n in"
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
    //--SHARE TEXT-SELF CHALLENGE---
    static let SELF_CHALLENGE_SHARE1 = "I have finished"
    static let SELF_CHALLENGE_SHARE2 = "minute self challenge in"
    static let SELF_CHALLENGE_SHARE3 = "minute in Quiz"
    //---SHARE QUIZ PLAY RESULT---
    static let SHARE1 = "I have completed level"
    static let SHARE2 = "with score"
    // apps update info string
    static let UPDATE_TITLE = "New Update Available!!"
    static let UPDATE_MSG = "New Update is available for App, to get more functionality and good experiance please Update App"
    static let UPDATE_BUTTON = "Update Now"
    static let UPDATE_SKIP = "SKIP"
    static let DAILY_QUIZ = "Daily Quiz"
    static let DAILY_QUIZ_TITLE = "Play Again"
    static let DAILY_QUIZ_MSG_SUCCESS = "Daily Quiz Completed"
    static let DAILY_QUIZ_MSG_FAIL = "Daily Quiz Fail"
    static let DAILY_QUIZ_SHARE_MSG = "I have completed daily quiz with score "
    static let RANDOM_QUIZ_MSG_SUCCESS = "Random Quiz Completed"
    static let RANDOM_QUIZ_MSG_FAIL = "Random Quiz Fail"
    static let RANDOM_QUIZ_SHARE_MSG = "I have completed Random quiz with score "
    static let TF_QUIZ_MSG_SUCCESS = "TRUE/FALSE Quiz Completed"
    static let TF_QUIZ_MSG_FAIL = "TRUE/FALSE Quiz Fail"
    static let TF_QUIZ_SHARE_MSG = "I have completed TRUE/FALSE Quiz with score "
    //leaderboard Filters / options
    static let ALL = "All"
    static let MONTHLY = "Monthly"
    static let DAILY = "Daily"
    //---CONTEST---
    static let SHARE_CONTEST = "I have completed Contest With Score"
    static let MSG_CODE = "Please Enter Code"
    static let NO_COINS_TTL = "You don't have enough coins"
    static let NO_COINS_MSG = "Earn Coin and Join Contest"
    static let PLAY_BTN_TITLE = "Play"
    static let LB_BTN_TITLE = "Leaderboard"
     //---MOBILE LOGIN---
    static let MSG_CC = "Please Enter Country Code in correct Format"
    static let MSG_NUM = "Please Enter Phone Number in correct Format"
    //---BATTLE MODES----
    static let ROOM_NAME = "OnlineUser"
    static let PRIVATE_ROOM_NAME = "PrivateRoom"
    static let PUBLIC_ROOM_NAME = "PublicRoom"
    
    static let GAMEROOM_DESTROY_MSG = "Are you sure? You want to destroy Gameroom?"
    static let GAMEROOM_EXIT_MSG = "Are you sure you want to exit the game?"
    static let USER_NOT_JOIN = "User has not joined yet, at least one user must join to get started"
    static let MAX_USER_REACHED = "Maximum User Reached"
    static let NO_PLYR_LEFT = "No Player Left in the Room"
    
    static let SELECT_CATGORY = "Select Category"
    static let NO_OFF_QSN = "Number of questions"
    static let TIMER = "Time"
    
    static let QSTN = "Questions"
    static let MINUTES = "Minutes"
    static let PLYR = "Player"
    static let BULLET = "●"
    
    static let BUSY = "busy"
    static let INVITE = "Invite"
    
    static let LANG = "en-US"
}
