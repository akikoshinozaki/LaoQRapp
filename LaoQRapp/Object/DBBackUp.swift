//
//  DBBackUp.swift
//  QRReader
//
//  Created by administrator on 2018/01/12.
//  Copyright © 2018年 Akiko Shinozaki. All rights reserved.
//
//  SQL_db ←→　csv の変換・Xserverへのアップロード・ダウンロード

import UIKit
import FMDB

var finishUpload:Bool = false
enum recieveData {
    case notConnection
    case success
    case None
}

var getRestoreList:recieveData = .None
var deleted:Bool!

class DBBackUp: NSObject {
    
    /* csvをアップロードする(handlerを使った処理) */
    func uploadCSV() {
        print(iPadName)
        //データベースからcsvを作成
        let csv = self.dbToCSV(fmdb: _db)
        let csvData: Data? = csv.data(using: .utf8)
        //バックアップファイルに日付を挿入するためにStringに変換
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let now = formatter.string(from: Date())
        
        let url = URL(string: "\(xserverPath)backUp.php")!
        var request = URLRequest(url:url)
        let boundary = "---------------------------168072824752491622650073"
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        if(csvData == nil){ return; }
        let body = NSMutableData()
        
        // テキスト部分の設定
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data;".data(using: .utf8)!)
        body.append("name=\"DeviceID\"\r\n\r\n".data(using: .utf8)!) //ディレクトリ名
        body.append("\(iPadName)\r\n".data(using: .utf8)!)
        // ファイル部分の設定
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data;".data(using: .utf8)!)
        body.append("name=\"uploadfile\";".data(using: .utf8)!) //ファイル名
        body.append("filename=\(now).csv\r\n".data(using: .utf8)!)
        body.append("Content-Type: text/csv\r\n\r\n".data(using: .utf8)!)
        body.append(csvData!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body as Data
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, err) -> Void in
            if err != nil {
                //エラーの時
                print("error=\(err!)")
                //errorString = err
                finishUpload = false
                NotificationCenter.default.post(name: Notification.Name(rawValue:"postCSV"), object: nil)
                return
            }
            DispatchQueue.main.async(execute: {
                // レスポンスを出力
                print("******* response = \(response!)")
                if let responseString = String(data: data!, encoding: .utf8) {
                    print("****** response data = \(responseString)")
                    //アップロード完了
                    if(responseString == "OK"){
                        finishUpload = true
                        print("responseString \(responseString)")
                    }
                    
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue:"postCSV"), object: nil)
            })
        })
        
        task.resume()
    }
    
    /* エラーログを送信 */
    func uploadErr() {
        //エラーログファイルのパス
        if let dir = manager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let errorpath = dir.appendingPathComponent("errorLog.txt")
            var err = ""
            do {
                err = try String(contentsOf: errorpath)
                print("Read from the file: \(err)")
                let errData: Data? = err.data(using: .utf8)
                
                //バックアップファイルに日付を挿入するためにStringに変換
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.dateFormat = "yyyyMMdd_HHmmss"
                let now = formatter.string(from: Date())
                
                let url = URL(string: "\(xserverPath)errlog.php")!
                var request = URLRequest(url:url)
                let boundary = "---------------------------168072824752491622650073"
                request.httpMethod = "POST"
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                
                if(errData == nil){ return; }
                let body = NSMutableData()
                
                // テキスト部分の設定
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data;".data(using: .utf8)!)
                body.append("name=\"DeviceID\"\r\n\r\n".data(using: .utf8)!) //ディレクトリ名
                body.append("\(iPadName)\r\n".data(using: .utf8)!)
                // ファイル部分の設定
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data;".data(using: .utf8)!)
                body.append("name=\"uploadfile\";".data(using: .utf8)!) //ファイル名
                body.append("filename=Errlog_\(now).txt\r\n".data(using: .utf8)!)
                body.append("Content-Type: text/csv\r\n\r\n".data(using: .utf8)!)
                body.append(errData!)
                body.append("\r\n".data(using: .utf8)!)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
                
                request.httpBody = body as Data
                
                let task = URLSession.shared.dataTask(with: request, completionHandler: {
                    (data, response, err) -> Void in
                    if err != nil {
                        //エラーの時
                        print("error=\(err!)")
                        //errorString = err
                        finishUpload = false
                        NotificationCenter.default.post(name: Notification.Name(rawValue:"postCSV"), object: nil)
                        return
                    }
                    DispatchQueue.main.async(execute: {
                        // レスポンスを出力
                        print("******* response = \(response!)")
                        if let responseString = String(data: data!, encoding: .utf8) {
                            print("****** response data = \(responseString)")
                            //アップロード完了
                            if(responseString == "OK"){
                                finishUpload = true
                                print("responseString \(responseString)")
                            }
                            
                        }
                        NotificationCenter.default.post(name: Notification.Name(rawValue:"postCSV"), object: nil)
                    })
                })
                
                task.resume()
            } catch {
                print("Failed reading from URL: \(errorpath), Error: " + error.localizedDescription)
                print("エラーはありません")
                let alert = UIAlertController(title: "エラーはありません", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                let navigation = window_.rootViewController as! UINavigationController
                let currentVC = navigation.visibleViewController
                if !autoUpload{
                    currentVC!.present(alert, animated: true, completion: nil)
                    autoUpload = false
                }
            }

        }
    }
    
    
    //SQLデータベースをcsvへ変換
    func dbToCSV(fmdb:FMDatabase) -> String {
        let entry = EntryDataBase(db: _db!)
        
        //var csv:String = "type, entryDate, updateDate, uke_Type, uke_CD, syohinCD, syohinName, serialNo, syainCD, locate, customerName"
        //2019/5/1(令和)〜
        var csv:String = "type, entryDate, updateDate, uke_Type, uke_CD, syohinCD, syohinName, serialNo, syainCD, locate, customerName, IBM_res, errorMSG, timeStamp"
        //entry.read(param: param)
        let arr:[SaveData] = entry.read(type: "enroll")
        print(arr.count)
        
        for m in arr {
            //print(m.errorMSG)
            let errMSG = m.errorMSG.trimmingCharacters(in: CharacterSet.newlines)
            //print(errMSG)
            csv.append("\n\(m.type),\(m.entryDate),\(m.updateDate),\(m.uke_Type),\(m.uke_CD),\(m.syohinCD),\(m.syohinName),\(m.serialNo),\(m.syainCD),\(m.locate),\(m.customerName),\(m.IBM_res),\(errMSG),\(m.timeStamp)")
        }
        let delarr:[SaveData] = entry.read(type: "delete")
        for m in delarr {
            let errMSG = m.errorMSG.trimmingCharacters(in: CharacterSet.newlines)
            csv.append("\n\(m.type),\(m.entryDate),\(m.updateDate),\(m.uke_Type),\(m.uke_CD),\(m.syohinCD),\(m.syohinName),\(m.serialNo),\(m.syainCD),\(m.locate),\(m.customerName),\(m.IBM_res),\(errMSG),\(m.timeStamp)")
        }
        
        return csv
    }
    
    /* Xserver上のファイル一覧を表示 */
    func getFileList() {
        getRestoreList = .None
        let url = URL(string: "\(xserverPath)getFileList.php")!
        //let url = URL(string: "https://oktss03.xsrv.jp/shinozaki/FileList.php")!
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        let postString = "name=\(iPadName)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, err) -> Void in
            //メインスレッドで実行
            DispatchQueue.main.async(execute: {
                if err != nil {
                    //エラーの時
                    print("error=\(err!)")
                    getRestoreList = .notConnection

                    NotificationCenter.default.post(name: Notification.Name(rawValue:"postCSV"), object: nil)
                    return
                }

                // レスポンスを出力
                print("******* response = \(response!)")
                
                if let responseString = String(data: data!, encoding: .utf8) {
                    print("****** response data = \(responseString)")
                    var list = responseString.components(separatedBy: "\n")
                    
                    list.removeLast()
                    csvList = list
                    
                    if(responseString != ""){
                        getRestoreList = .success
                    }
                }
                
                NotificationCenter.default.post(name: Notification.Name(rawValue:"postCSV"), object: nil)
            })
        })
        
        task.resume()
    }
    
    /* Xserver上のファイルを削除 */
    func deleteBackup(filename:String){
        deleted = false
        let url = URL(string: "\(xserverPath)deleteFile.php")!
        
        var request = URLRequest(url:url)
        request.httpMethod = "POST"
        //iPadName:フォルダ名、filename:tableViewで選択
        let postString = "name=\(iPadName)&file=\(filename)"
        
        request.httpBody = postString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: {
            (data, response, err) -> Void in
            //メインスレッドで実行
            DispatchQueue.main.async(execute: {
                if err != nil {
                    //エラーの時
                    print("error=\(err!)")

                } else {
                    
                    // レスポンスを出力
                    print("******* response = \(response!)")
                    
                    if let responseString = String(data: data!, encoding: .utf8) {
                        print("****** response data = \(responseString)")
                        
                        if(responseString == "OK"){
                            deleted = true
                        }
                    }
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue:"fileDeleted"), object: nil)

            })
        })
        
        task.resume()
        
    }
    
}
