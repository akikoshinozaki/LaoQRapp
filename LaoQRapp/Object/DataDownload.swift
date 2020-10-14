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
            errMsg = "サーバー上のファイルにアクセスできません"
        }
        
        return(csvStr,errMsg)
        
    }
    
    public func getIdList() -> [(name: String, id: String, sheet: String)]{
        var arr:[[String]] = []
        var list:[(name: String, id: String, sheet: String)] = []
        //商品リスト
        if let array = defaults.object(forKey: "sheetID") as? String {
            //カンマ区切りでデータを分割して配列に格納する。
            array.enumerateLines { (line, stop) -> () in
                arr.append(line.components(separatedBy: ","))
            }
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
    

}
