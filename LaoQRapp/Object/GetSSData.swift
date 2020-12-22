//
//  GetSSData.swift
//  LaoQRapp
//
//  Created by administrator on 2020/10/16.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

class GetSSData: NSObject {
    
    //idListの最終更新日を調べる
    class func getUpdateDate2()->String {
        let url = apiUrl + "?upd=update"
        var str = ""
        
        //サーバー上のファイルのパス
        if let path = URL(string: url) {
            do {
                str = try String(contentsOf: path, encoding: .utf8)
                print(str)
                defaults.set(str, forKey: "lastUpdate")
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print("更新日取得失敗")
                //errMsg = error.localizedDescription
            }
        }
        return str
        
    }
    
    class func getUpdateDate()->String {
        //let url = apiUrl + "?upd=update"
        var update = ""
        var DL_errMsg = ""
        let url = URL(string: apiUrl + "?upd=update")!  //URLを生成
        var request = URLRequest(url: url)//Requestを生成
        request.timeoutInterval = 20
        
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
            if error != nil {
                print("更新日取得失敗")
                DL_errMsg = error!.localizedDescription
            }else if data != nil, let str = String(data: data!, encoding: .utf8) {
                print("success")
                defaults.set(str, forKey: "lastUpdate")
                update = str
            }else {
                print("更新日取得失敗")
                DL_errMsg += "サーバー上のファイルにアクセスできません".loStr+"(\(idListParam.id))\n"
            }
            
            semaphore.signal()
        }
        
        dataTask.resume()
        
        switch semaphore.wait(timeout: .now() + 3.0) {
        case .success:
            return update
        case .timedOut:
            dataTask.cancel()
            return "timeout"
        }
        
        //return update
    }

    
    class func getCSV() -> String {
        var DL_errMsg = ""
        let url = URL(string: idListParam.url)!  //URLを生成
        var request = URLRequest(url: url)//Requestを生成
        request.timeoutInterval = 20
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
            if error != nil {
                print("1..csv取得失敗")
                DL_errMsg = error!.localizedDescription
            }else if data != nil, let str = String(data: data!, encoding: .utf8) {
                
                var arr:[[String]] = []
                //カンマ区切りでデータを分割して配列に格納する。
                str.enumerateLines { (line, stop) -> () in
                    arr.append(line.components(separatedBy: ","))
                }
                
                if arr.count > 0 {
                    //取得成功
                    print("success")
                    defaults.set(arr, forKey: idListParam.id)
                }else {
                    //取得失敗
                    DL_errMsg += "\(idListParam.id) 取得失敗\n"
                }

            }else {
                print("2..csv取得失敗")
                DL_errMsg += "サーバー上のファイルにアクセスできません".loStr+"(\(idListParam.id))\n"
            }
            
            idList = []
            let array = defaults.object(forKey: "sheetID") as? [[String]] ?? []
            for item in array {
                if item.count > 5 {
                    if item[5] == "ON" {
                        idList.append((name:item[0], id:item[1], sheet:item[2]))
                    }
                }else {
                    idList.append((name:item[0], id:item[1], sheet:item[2]))
                }
            }
            
            if idList.count == 0 {
                DL_errMsg = "リスト取得失敗".loStr
            }
            
            semaphore.signal()
        }
        
        dataTask.resume()
        semaphore.wait()
        return DL_errMsg
    }
    
    
    class func getCSV2() -> String {
        var errMsg = ""
        //サーバー上のcsvファイルのパス
        if let csvPath = URL(string: idListParam.url) {
            do {
                //CSVファイルのデータを取得する。
                let str = try String(contentsOf: csvPath, encoding: .utf8)
                //csvStr = str
                print(str)
                var arr:[[String]] = []
                //カンマ区切りでデータを分割して配列に格納する。
                str.enumerateLines { (line, stop) -> () in
                    arr.append(line.components(separatedBy: ","))
                }
                
                if arr.count > 0 {
                    //取得成功
                    print("csvの保存に成功")
                    defaults.set(arr, forKey: idListParam.id)
                }else {
                    //取得失敗
                    errMsg = "\(idListParam.id) 取得失敗\n"
                }
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print("csv取得失敗")
                errMsg = error.localizedDescription
            }
        }else {
            print("csv取得できません")
            errMsg = "サーバー上のファイルにアクセスできません"
        }
        
        idList = []
        let array = defaults.object(forKey: "sheetID") as? [[String]] ?? []
        for item in array {
            if item.count > 5 {
                if item[5] == "ON" {
                    idList.append((name:item[0], id:item[1], sheet:item[2]))
                }
            }else {
                idList.append((name:item[0], id:item[1], sheet:item[2]))
            }
        }
        
        return(errMsg)
        
    }

    
    /*
    class func getupdate() -> String {
        //テスト
        let url = apiUrl + "?upd=update"
        var str = ""
        
        let tokenString = "ya29.a0AfH6SMCJcR3yYk1LOEed_bgjyHhy8Aq-Pb_dG92vgbbvpCuomCaSlTVNzJMTUcqyY0DmsLg3IwmSB608DRa57_115oE149ym0b3z8OOCXEIgkz0LmPx4IF8ffyPGJJ4TEM58mkenaQK3a4Aob4bBKyDt9XjhIiYjw3bzeIU8z9Y"
        var request = URLRequest(url: URL(string: url)!)
//        let header = ["Authorization":"Bearer"+tokenString]
//        request.addValue("application/json", forHTTPHeaderField: "Content-type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//        request.addValue("utf-8", forHTTPHeaderField: "Accept-Charset")
        request.addValue("Bearer"+tokenString, forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) {data, response, err in
            if (err == nil) {
                print("success")
                //let data: Data? = str.data(using: .utf8)
                if let str = String(data: data!, encoding: .utf8) {
                    print(str)
                }
                
            } else {
                print("error")
            }
        }.resume()
        
        return str
    }
    */
    

}
