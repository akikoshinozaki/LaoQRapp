//
//  DataDownload.swift
//  QRReader
//
//  Created by 篠崎 明子 on 2020/06/24.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit



let DL = DataDownload()

class DataDownload: NSObject {
    
    public func getCSV(parameter:GASURL) -> (csv:String,err:String) {
   
        var csvStr = ""
        var errMsg = ""
        //サーバー上のcsvファイルのパス
        print(parameter.url)
        if let csvPath = URL(string: parameter.url) {
            do {
                //CSVファイルのデータを取得する。
                let str = try String(contentsOf: csvPath, encoding: .utf8)
                csvStr = str
                print(str)
                defaults.set(csvStr, forKey: parameter.id)
                print("csvの保存に成功")
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print("csv取得失敗")
                errMsg = error.localizedDescription
            }
        }else {
            print("csv取得できません")
            errMsg = "サーバー上のファイルにアクセスできません"
        }
        
        return(csvStr,errMsg)
        
    }
    
    public func getIdList() -> [(name: String, id: String, sheet: String)]{
        var arr:[[String]] = []
        var list:[(name: String, id: String, sheet: String)] = []

        if let array = defaults.object(forKey: "sheetID") as? String {
            //カンマ区切りでデータを分割して配列に格納する。
            array.enumerateLines { (line, stop) -> () in
                arr.append(line.components(separatedBy: ","))
            }
            print(arr)
            for item in arr {
                if item.count > 5 {
                    if item[5] == "ON" {
                        list.append((name:item[0], id:item[1], sheet:item[2]))
                    }
                }else {
                    list.append((name:item[0], id:item[1], sheet:item[2]))
                }
            }
            
        }else {
            let alert = UIAlertController(title: "リスト取得に失敗", message: "アプリを終了します", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                Void in
                exit(3)
            }))
            
        }
        
        return list
        
    }
    
    public func csvToArr(parameter:GASURL) -> (csv:String,err:String) {
             var csvStr = ""
         var errMsg = ""
         //サーバー上のcsvファイルのパス
         if let csvPath = URL(string: parameter.url) {
             do {
                 //CSVファイルのデータを取得する。
                 let str = try String(contentsOf: csvPath, encoding: .utf8)
                 csvStr = str
                 //print(str)
                 defaults.set(csvStr, forKey: parameter.id)
                 print("csvの保存に成功")
                 
             } catch let error as NSError {
                 print(error.localizedDescription)
                 print("csv取得失敗")
                 errMsg = error.localizedDescription
             }
         }else {
             print("csv取得できません")
             errMsg = "サーバー上のファイルにアクセスできません".loStr
         }
         
         return(csvStr,errMsg)
         
     }
     
    public func csvDL() {
        //print(parameters)
        for param in parameters {
            var array:[[String]] = []
            if let arr = defaults.object(forKey: param.id) as? String {
                //カンマ区切りでデータを分割して配列に格納する。
                arr.enumerateLines { (line, stop) -> () in
                    array.append(line.components(separatedBy: ","))
                }
                
                switch param.id {
                case "itemArr" ://LaosMaster
                                        var j:Int!
                    for (i,str) in array[1].enumerated() {
                        if str == "UNIT" {
                            j = i
                        }
                    }
                    array.removeFirst(2) //もう１行削除
                    itemArray = []
                    for item in array {
                        if item.count > 2 {
                            itemArray.append((cd:item[0],name:item[2],unit:item[j]))
                        }
                    }
                    //print(itemArray)
                case "employee":
                    var j:Int!
                    for (i,str) in array[0].enumerated() {
                        if str.contains("Laos Name") {
                            j = i
                        }
                    }
                    
                    array.removeFirst()
                    employee = []
                    for item in array {
                        let emp = Employee(syainCD: item[0], name_en: item[1], name_lo: item[j])
                        employee.append(emp)
                    }
                case "errMessage" :
                    array.removeFirst()
                    errFromIBM = []
                    for item in array {
                        if item.count > 3 {
                            errFromIBM.append((cd:item[0],jp:item[2],lo:item[3]))
                        }
                    }
                    //print(errFromIBM)
                case "translate" :
                    array.removeFirst()
                    translate = [:]
                    
                    for item in array {
                        translate[item[0]] = item[1]
                    }
                    //print(translate)
                default:
                    print("other")
                }
                
            }else {
                let alert = UIAlertController(title: "リスト取得に失敗".loStr, message: "アプリを終了します".loStr, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    exit(3)
                }))
                
            }
            
        }
        
    }
}

