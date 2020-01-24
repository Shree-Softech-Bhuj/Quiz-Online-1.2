import Foundation

//structure for store user default data
struct User:Codable{
    var UID:String
    var userID:String
    var name:String
    var email:String
    var phone:String
    var address:String
    var userType:String
    var image:String
    var status:String
    
//    var frnd_code:String
//    var ref_code:String    
}

// user score related structure
struct UserScore:Codable{
    var coins:Int
    var points:Int
}

//apps setting structure
struct  Setting:Codable {
    var sound:Bool
    var backMusic:Bool
    var vibration:Bool
}

struct QuestionWithE: Codable {
    var id:String
    var question:String
    var opetionA:String
    var opetionB:String
    var opetionC:String
    var opetionD:String
    var opetionE:String
    var correctAns:String
    var image:String
    var level:String
    var note:String
    
    var toDictionaryE: [String:String]{
    return [        "id":id,"question":question,"opetionA":opetionA,"opetionB":opetionB,"opetionC":opetionC,"opetionD":opetionD,"opetionE":opetionE,"correctAns":correctAns,"image":image,"level":level,"note":note
           ]
    }
}

struct Question: Codable {
    var id:String
    var question:String
    var opetionA:String
    var opetionB:String
    var opetionC:String
    var opetionD:String
    var correctAns:String
    var image:String
    var level:String
    var note:String
    
    var toDictionary: [String:String]{
        return [
            "id":id,"question":question,"opetionA":opetionA,"opetionB":opetionB,"opetionC":opetionC,"opetionD":opetionD,"correctAns":correctAns,"image":image,"level":level,"note":note
        ]
    }
}

struct ReQuestion {
    let id:String
    let question:String
    let opetionA:String
    let opetionB:String
    let opetionC:String
    let opetionD:String
    let correctAns:String
    let image:String
    let level:String
    let note:String
    let userSelect:String
}

struct ReQuestionWithE {
    let id:String
    let question:String
    let opetionA:String
    let opetionB:String
    let opetionC:String
    let opetionD:String
    let opetionE:String
    let correctAns:String
    let image:String
    let level:String
    let note:String
    let userSelect:String
}
