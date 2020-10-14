//
//  Common.swift
//  QRReader
//
//  Created by administrator on 2017/11/13.
//  Copyright © 2017年 Akiko Shinozaki. All rights reserved.
//

import UIKit
import FMDB

struct SQLData {
    var QR_id:Int!
    var type:String = ""
    var entryDate:String = ""
    var updateDate:String = ""
    var uke_Type:String = ""
    var uke_CD:String = ""
    var syohinCD:String = ""
    var syohinName:String = ""
    var serialNo:String = ""
    var syainCD:String = ""
    var locate:String = ""
    var customerName:String = ""
    var count:Int!
}

struct SaveData {
    var QR_id:Int!
    var type:String = ""
    var entryDate:String = ""
    var updateDate:String = ""
    var uke_Type:String = ""
    var uke_CD:String = ""
    var syohinCD:String = ""
    var syohinName:String = ""
    var serialNo:String = ""
    var syainCD:String = ""
    var locate:String = ""
    var customerName:String = ""
    var IBM_res:String = ""
    var errorMSG:String = ""
    var timeStamp:String = ""
}

struct InputData {
    var id:Int!
    var type:String = ""
    var entryDate:String = ""
    var syainCD:String = ""
    var locate:String = ""
    var itemCD:String = ""
    var itemName:String = ""
    var rack:String = ""
    var floor:String = ""
    var seqNo:String = ""
    var qty:String = ""
    var uuid:String = ""
    var startTM:String = ""
    var endTM:String = ""
    var workTM:String = ""
    var postTM:String = ""
    var timeStamp:String = ""
    var err:Bool = false
}

//シリアルCD検索結果表示用
struct SerialList {
    var entryDate:String = ""
    var serialNo:String = ""
    var syainCD:String = ""
    var uke_Type:String = ""
    var uke_CD:String = ""
    var customerName:String = ""
}

struct GASURL {
    var id:String = ""
    var url : String = ""
}

//Date → String
extension Date {
    func toString(format:String) -> String{
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = TimeZone(identifier: "Asia/Tokyo")
        df.dateFormat = format
        return df.string(from: self)
    }
    
    func toString_la(format:String) -> String{
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = format
        return df.string(from: self)
    }
    
    var string: String {
        return toString_la(format: "yyyy-MM-dd")
    }
    var shortString: String {
        return toString_la(format: "MM/dd")
    }
    var shortTime: String {
        return toString_la(format: "HH:mm")
    }
    var timeStamp:String {
        let timeInterval = self.timeIntervalSince1970
        let myTimeInterval = TimeInterval(timeInterval)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
        
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"

        return df.string(from: time)
    }
    
    var entryDate:String {
        let timeInterval = self.timeIntervalSince1970
        let myTimeInterval = TimeInterval(timeInterval)
        let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return df.string(from: time)
    }
}

//String → Date
extension String {
    
    func toDate(format:String) -> Date?{
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.calendar = Calendar(identifier: .gregorian)
        df.timeZone = TimeZone(identifier: "Asia/Tokyo")
        df.dateFormat = format
        return df.date(from: self)
    }
    
    var date: Date {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyy-MM-dd"
        return df.date(from: self)!
    }
    
    var dateTime: Date {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.dateFormat = "yyyyMMddHHmmss"
        return df.date(from: self)!
    }

}

typealias CompletionClosure = ((_ resultString:String?,_ resultJson:NSDictionary?, _ err:Error?) -> Void)

//GAS APIのURL
//TEST
//let apiUrl = "https://script.google.com/macros/s/AKfycbzo7SQFMFqc6BXTvjxxiQgqUB08vT263oT-Df2WAWedb1lxEQU/exec"

//本番
let apiUrl = "https://script.google.com/macros/s/AKfycbw7BTNIdwXwyCZHi0IiHtLqIXioC4nQXfP228YflCxkgO55XKQ/exec"

//Japan
let SS_URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQkYoPN1G4Gi1wPy0lLK2paJaXREuHafv_wojeNQYRSZ4-I6rwdX0_sd9KZmJ8LxFbZp4y_7wh8g-cs/pub?gid="

//Japan (location,sheetIDのみ使用)
let parameter:GASURL = GASURL(id: "sheetID", url: apiUrl+"?operation=idList")


//var itemArray:[(cd:String,name:String,unit:String)] = [] //unit:単位
var locArray:[(cd:String,name:String)] = []

var idList:[(name:String, id:String, sheet:String)] = []
var fileName = ""
var sheetId:String = ""
var sheetName:String = ""

//共通のパラメーター
var iPadName:String = ""
var idfv:String = ""
var pingResponse:Bool = true
var IBMResponse:Bool!

let defaultLocate = [("IW01", "磐田ファートン工場"), ("IW04", "磐田物流センター"), ("KZ01", "小沢渡羽毛工場"), ("LA01", "ラオス工場"),  ("OK01", "大久保羊毛工場"), ("OK02", "大久保カーテン工場"), ("OK03", "大久保羊毛第一工場")]

var locateArr_ : [(String, String)] = []
var syainCD_:String = "" //社員CD
var syainName_:String = ""//社員名
var locateCD_:String = ""//場所CD
var locateName_:String = ""//製造場所
var QRdata_:String! //スキャンしたデータを格納
var itemCD_:String = "" //商品CD
var itemName_:String = "" //商品名

//var saveDate:String = ""
var saveTime:String = ""
var previousTime:String = ""

//起動時のViewControllerの情報を格納
var currentView:String = ""
var startUpCount = 0
var bundleVersion = ""
var isHostConnected:Bool = false

//FMDBの変数
let dbName = "entry.db"
var _path:URL!
var _db:FMDatabase!
let manager = FileManager.default
let defaults = UserDefaults.standard

var resultList:[SerialList] = []
var insertCount:Int = 0
var duplicateCount:Int = 0
var csvList:[String] = [""]
let xserverPath = "https://oktss03.xsrv.jp/QRBackUp/"
let hostURL = "https://maru8ibm.maruhachi.co.jp:4343/HTP2/WAH001CL.PGM?" //開発
//let hostURL = "https://maru8ibm.maruhachi.co.jp/HTP2/WAH001CL.PGM?" //本番
var dbInsertSuccess = false
var autoUpload:Bool = false
