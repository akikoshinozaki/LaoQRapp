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
    
    public func csvToArr() {
        //print(parameters)
        for (i,param) in parameters.enumerated() {
            var arr:[[String]] = []
            //商品リスト
            if let itemArr = defaults.object(forKey: param.id) as? String {
                //カンマ区切りでデータを分割して配列に格納する。
                itemArr.enumerateLines { (line, stop) -> () in
                    arr.append(line.components(separatedBy: ","))
                }
                
                if i == 0 { //location
                    arr.removeFirst()
                    locArray = []
                    for item in arr {
                        if item.count > 2 {
                            locArray.append((cd:item[0],name:item[1]))
                        }
                    }

                }else if i == 1 { //sheetID
                    //print(arr)
                    idList = []
                    for item in arr {
                        if item.count > 5 {
                            if item[5] == "ON" {
                                idList.append((name:item[0], id:item[1], sheet:item[2]))
                            }
                        }else {
                            idList.append((name:item[0], id:item[1], sheet:item[2]))
                        }
                    }
                }

            }else {
                let alert = UIAlertController(title: "リスト取得に失敗", message: "アプリを終了します", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    exit(3)
                }))
        
            }

        }
        
    }
    

}
