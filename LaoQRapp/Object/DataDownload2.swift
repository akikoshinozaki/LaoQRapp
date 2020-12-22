//
//  DataDownload2.swift
//  QRReader
//
//  Created by 篠崎 明子 on 2020/06/24.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit



let DL2 = DataDownload()

class DataDownload2: NSObject {
    
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
    
    
         
    func csvDL() {
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
    
    class func dataUpdate() {
        var DL_errMsg = ""
        let alert = UIAlertController(title: "データ更新中".loStr, message: "しばらくお待ちください".loStr, preferredStyle: .alert)
        SimpleAlert.topViewController()?.present(alert, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //アラートが出なくなるので、遅延処理を入れる
            
            DL_errMsg = ""
            for param in parameters{
                let data = DL.getCSV(parameter: param)
                DL_errMsg += data.err
            }
            
            if DL_errMsg == ""{
                //更新できたら最終更新日を変更
                defaults.set(Date().string, forKey: "lastDataDownload")
                alert.dismiss(animated: true, completion: nil)
            }else {
                alert.title = "更新に失敗しました".loStr
                alert.message = DL_errMsg
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            }
            
            DL.csvDL()

        }
    }
}

