//
//  MySQL.swift
//  LaoQRapp
//
//  Created by 篠崎 明子 on 2020/10/21.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

class MySQL: NSObject {

    let serverURL = "https://oktss03.xsrv.jp/Laos/"
    func insert(dic:NSDictionary) { //upsert
        var errMsg = ""

        var param = ""
        for item in dic {
            param += "\(item.key)=\(item.value)&"
        }
        if param.last=="&" {
            param = String(param.dropLast())
        }
        print(param)
        
        let url = URL(string: serverURL+"serial_insert.php")!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: config)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = param.data(using: .utf8)
        // 通信のタスクを生成.
        
        let task = session.dataTask(with:request, completionHandler: {
            (data, response, err) in
            if (err == nil){
                if(data != nil){
                    //戻ってきたデータを解析
                    do{
                        if let str = String(data: data!, encoding: .utf8) {
                            //Stringの場合
                            print(str)
                        }
                        if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                            //Jsonの場合
                            if json["status"] as! String == "success" {
                                //insert成功
                            }
                        }
                    }catch{
                        print("json error")
                        errMsg += "E3001:json error"
                    }
                }else{
                    print("レスポンスがない")
                    errMsg += "E3001:No Response"
                }
            } else {
                print("error : \(err!)")
                if (err! as NSError).code == -1001 {
                    print("timeout")
                }
                
                errMsg += "E3003:\(err!.localizedDescription)"
            }

        })
        // タスクの実行.
        task.resume()
    }
    
    func getID(serial:String,completionClosure:@escaping CompletionClosure) {
        var json:NSDictionary!
        var errMsg = ""
        let param = "serial=\(serial)"
        print(param)
        
        let url = URL(string: serverURL+"serial_getID.php")!
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: config)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = param.data(using: .utf8)
        // 通信のタスクを生成.
        
        let task = session.dataTask(with:request, completionHandler: {
            (data, response, err) in
            if (err == nil){
                if(data != nil){
                    //戻ってきたデータを解析
                    do{
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        
                    }catch{
                        print("json error")
                        errMsg += "E3001:json error"
                    }
                }else{
                    print("レスポンスがない")
                    errMsg += "E3001:No Response"
                }
            } else {
                print("error : \(err!)")
                if (err! as NSError).code == -1001 {
                    print("timeout")
                }
                
                errMsg += "E3003:\(err!.localizedDescription)"
            }
            
            completionClosure(errMsg,json, err)

        })
        // タスクの実行.
        task.resume()
    }
    
}
