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

struct Employee {
    var syainCD:String = ""
    var name_en:String = ""
    var name_lo:String = ""
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
    
    var loStr:String {
        if let lao = translate[self], lao != "", language == "lo" {
            return lao
        }else {
            return self
        }
    }
}


typealias CompletionClosure = ((_ resultString:String?,_ resultJson:NSDictionary?, _ err:Error?) -> Void)

//typealias CompletionClosure = ((_ result:NSDictionary?, _ err:Error?) -> Void)
//GAS APIのURL
//TEST
//https://docs.google.com/spreadsheets/d/1tkfxMdZ4jA3xbSeWOJCFEQ4CSns4noPMMtXGscCaPCw/edit
//let apiUrl = "https://script.google.com/macros/s/AKfycbzo7SQFMFqc6BXTvjxxiQgqUB08vT263oT-Df2WAWedb1lxEQU/exec"

//本番
//https://docs.google.com/spreadsheets/d/1LCFgc2UBEGT0QCWqoH87n2jcjV9QWOgDI_L-3b6VOgE/edit
let apiUrl = "https://script.google.com/macros/s/AKfycbw7BTNIdwXwyCZHi0IiHtLqIXioC4nQXfP228YflCxkgO55XKQ/exec"

var translate:Dictionary<String, String> = [:]
let SS_URL = "https://docs.google.com/spreadsheets/d/e/2PACX-1vSYsk2S-W-gH9usc2qC0qtBTch8VnFxp1gn1Kmt4_5gSRKj7gHxRge9Q9rjmDn2n8Pl99Garq9sJ55N/pub?gid="
/*
let parameters:[GASURL] = [
    GASURL(id: "itemArr", url: SS_URL+"1270331495&single=true&output=csv"),
    GASURL(id: "employee", url: SS_URL+"1920248299&single=true&output=csv"),
    GASURL(id: "errMessage", url: "https://docs.google.com/spreadsheets/d/e/2PACX-1vT_VIqCdRpHyjvV3dDyLRn9eonLWqDIHjYaiHQAxqe27SXXKUBH-t0CEOd4w7KGWbELl3KIYVEsphaU/pub?gid=1456474335&single=true&output=csv"),
    GASURL(id: "translate", url: SS_URL+"550904518&single=true&output=csv")
]
*/
let parameters:[GASURL] = [
    GASURL(id: "sheetID", url: apiUrl+"?operation=idList"),
    GASURL(id: "itemArr", url: apiUrl+"?operation=csv&shName=MASTER"),
    GASURL(id: "employee", url: apiUrl+"?operation=csv&shName=Employee"),
    GASURL(id: "errMessage", url: apiUrl+"?operation=csv&shName=IBM_error"),
    GASURL(id: "translate", url: apiUrl+"?operation=csv&shName=translate")
]


//idList
let idListParam:GASURL = GASURL(id: "sheetID", url: apiUrl+"?operation=idList")

//var itemArray:[(cd:String,name:String,unit:String)] = [] //unit:単位
var locArray:[(cd:String,name:String)] = []
var itemArray:[(cd:String,name:String,unit:String)] = [] //unit:単位
var employee:[Employee] = []
var errFromIBM:[(cd:String,jp:String,lo:String)] = []
var idList:[(name:String, id:String, sheet:String)] = []
var fileName = ""
var sheetId:String = ""
var sheetName:String = ""

//共通のパラメーター
var iPadName:String = ""
var idfv:String = ""
var pingResponse:Bool = true
var IBMResponse:Bool!
var language = ""
let defaultLocate = [("LA01", "ＬＡＯＳ")]

var locateArr_ : [(String, String)] = []
var syainCD_:String = "" //社員CD
var syainName_:String = ""//社員名
var locateCD_:String = ""//場所CD
var locateName_:String = ""//製造場所
var QRdata_:String! //スキャンしたデータを格納
var itemCD_:String = "" //商品CD
var itemName_:String = "" //商品名
var ibmUser:String = ""

//var saveDate:String = ""
var saveTime:String = ""
var previousTime:String = ""

//起動時のViewControllerの情報を格納
var currentView:String = ""
var startUpCount = 0
var appVersion = ""
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
//let hostURL = "https://maru8ibm.maruhachi.co.jp:4343/HTP2/WAH001CL.PGM?" //開発
let hostURL = "https://maru8ibm.maruhachi.co.jp/HTP2/WAH001CL.PGM?" //本番
var dbInsertSuccess = false
var autoUpload:Bool = false
var is_iPhone:Bool = false


//var errID:[(id:Int,cd:String)] = []
func errMsgFromIBM(rtnMSG:[String]) -> String {
    var str = ""
    //errID = []
    for msg in rtnMSG{
        print(msg)
        //エラーメッセージを分解する
        let err = msg.components(separatedBy: [":","【","】"])
        let errCode = err[0]
        //let errMSG = err[1].trimmingCharacters(in: .whitespaces) //エラーメッセージ
        /*
        var errNo = ""
        //データNO.が含まれているときは抽出
        if err.count > 2, err[2].contains("No.") {
            errNo = err[2].components(separatedBy: "：")[1]
            print(errNo)
            //errID.append(Int(errNo)!-1)
            errID.append((id:Int(errNo)!,cd:err[0]))
        }*/
        var msg_jp = ""
        var msg_lo = ""
        if let idx = errFromIBM.firstIndex(where: {$0.cd == errCode}) {
            //errCode = errFromIBM[idx].cd
            msg_jp = errFromIBM[idx].jp
            msg_lo = errFromIBM[idx].lo
        }else {
            msg_jp = err[1]
            msg_lo = err[1]
        }

        if language == "lo" {//ラオ語エラーメッセージ表示
            str += "\(errCode):\(msg_lo)"
        }else {
            str += "\(errCode):\(msg_jp)"
        }
        /*
        if errNo != "" {
            str += "【No.\(errNo)】"
        }*/
        print(str)
        str += "\n"
    }
    
    return str
}
