//
//  IBM.swift
//  QRReader
//
//  Created by administrator on 2017/07/10.
//  Copyright © 2017年 Akiko Shinozaki. All rights reserved.
//

import UIKit


var buttonTag_:Int!
var json_:NSDictionary!
var inquiryJson_:NSDictionary!

let standardBlue_ = UIColor(red: 0.0, green: 0.478431, blue: 1.0, alpha: 1.0)

//IBMのレスポンスから取り出すデータ
var UKE_TYPE:String! = "" //受付タイプ
var UKE_CDD:String! = "" //受付CD表示用
var SYOHIN_CD:String! = "" //商品CD
var CUSTOMER_NM:String! = "" //顧客名
var ORDER_SPEC:String! = "" //オーダー仕様

let semaphore = DispatchSemaphore(value: 0)

class IBM: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    func hostRequest(type:String, param:[String:Any], completionClosure:@escaping CompletionClosure){

        IBMResponse = false
        var json:NSDictionary!
        var errMsg = ""
        var parameter = "COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HFJ001&PROC_TYPE=\(type)&"
        
        for p in param {
            parameter += "\(p.key)=\(p.value)&"
        }
        
        if parameter.last == "&" {
            parameter = String(parameter.dropLast())
            print(parameter)
        }
        
        let url = URL(string: hostURL)!
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        // POSTを指定
        request.httpMethod = "POST"
        // POSTするデータをBodyとして設定
        request.httpBody = parameter.data(using: .utf8)
        // 通信のタスクを生成.
        let task = session.dataTask(with:request, completionHandler: {
            (data, response, err) in
            if (err == nil){
                if(data != nil){
                    //戻ってきたデータを解析
                    do{
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        IBMResponse = true
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
            completionClosure(nil,json, err)

        })
        
        // タスクの実行.
        task.resume()
        
    }
    
    
    //登録用
    func entry(syainCD:String, QRdata:String, locate:String, serial:String){
        IBMResponse = false
        //URLにパラメーターをセット
        let url = URL(string: "\(hostURL)COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HFJ001&PROC_TYPE=ENTRY&SYAIN_CD=\(syainCD)&LOCAT_CD=\(locate)&UKE_CD=\(QRdata)&PRODUCT_SN=\(serial)")!
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        //session.configuration.timeoutIntervalForRequest = 1
        
        // 通信のタスクを生成.
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, err) in
            if (err == nil){
                if(data != nil){
                    //戻ってきたデータを解析
                    do{
                        json_ = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        IBMResponse = true
                    }catch{
                        print("Jsonが返ってこない")
                    }
                }else{
                    print("レスポンスがない")
                }
                
            } else {
                print("error : \(err!)")
            }
            
            semaphore.signal()
            
            // メインスレッドでNotificationの受け渡し
            DispatchQueue.main.async{
                
                NotificationCenter.default.post(name: Notification.Name(rawValue:"loadJSON"), object: nil)
            }
            
        })
        
        // タスクの実行.
        task.resume()
        self.timeout(task: task, semaphore: semaphore, minute: 10.0)
        
    }
    

    //登録前チェック
    func entCHK(param:String, value:String) {
        IBMResponse = false
        //URLにパラメーターをセット
        var url:URL!
        if value == "" {
            url = URL(string: "\(hostURL)COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HFJ001&PROC_TYPE=\(param)")!
        }else {
            url = URL(string: "\(hostURL)COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HFJ001&PROC_TYPE=ENTCHK&\(param)=\(value)")!
        }
        
        print(url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.configuration.timeoutIntervalForRequest = 5
        
        // 通信のタスクを生成.
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, err) in
            if(err == nil){
                if(data != nil){
                    do{
                        json_ = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        IBMResponse = true
                    }catch{
                        print("Jsonが返ってこない")
                    }
                }else{
                    print("レスポンスがない")
                }
                
            } else {
                print("error : \(err!)")
            }
            
            semaphore.signal()
            
            // メインスレッドでNotificationの受け渡し
            DispatchQueue.main.async{
                NotificationCenter.default.post(name: Notification.Name(rawValue:"loadJSON"), object: nil)
            }
            
        })
        
        // タスクの実行.
        task.resume()
        self.timeout(task: task, semaphore: semaphore, minute: 3.0)
        
    }
    
    // type->照会は"INQUIRY"削除は"DELETE"印刷は"PRINTING"
    func checkDetail(type:String, serialNo:String) {
        IBMResponse = false
        // URLにパラメーターをセット
        let url = URL(string: "\(hostURL)COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HFJ001&PROC_TYPE=\(type)&PRODUCT_SN=\(serialNo)")!
        let session = URLSession(configuration: URLSessionConfiguration.default)
        // 通信のタスクを生成.
        let task = session.dataTask(with: url, completionHandler: {
            (data, response, err) in
            if (err == nil){
                if(data != nil){
                    do{
                        inquiryJson_ = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        IBMResponse = true
                        
                    }catch{
                        print("Jsonが返ってこない")
                    }
                }else{
                    print("レスポンスがない")
                }
                
            } else {
                print("error : \(err!)")
            }
            
            semaphore.signal()
            
            // メインスレッドでNotificationの受け渡し
            DispatchQueue.main.async{
                
                NotificationCenter.default.post(name: Notification.Name(rawValue:"loadJSON"), object: nil)
            }
        })
        
        // タスクの実行.
        task.resume()
        self.timeout(task: task, semaphore: semaphore, minute: 3.0)
    }
    
    func timeout(task: URLSessionTask, semaphore: DispatchSemaphore, minute:Double) {
        let result = semaphore.wait(timeout: DispatchTime.now() + minute)
        if result == .timedOut {
            task.cancel()
            print("timeout")
        }
    }

    func itemSearch(cd:String,completionClosure:@escaping CompletionClosure){
        var json:NSDictionary!
        var errMsg = ""
        
        let parameter = "COMPUTER=\(iPadName)&IDENTIFIER=\(idfv)&PRCID=HFL002&PROC_TYPE=SYOCHK&SYOHIN_CD=\(cd)"
        
        let url = URL(string: hostURL)! //開発

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5.0
        let session = URLSession(configuration: config)
        
        var request = URLRequest(url: url)
        // POSTを指定
        request.httpMethod = "POST"
        // POSTするデータをBodyとして設定
        request.httpBody = parameter.data(using: .utf8)
        // 通信のタスクを生成.
        let task = session.dataTask(with:request, completionHandler: {
            (data, response, err) in
            if (err == nil){
                if(data != nil){
                    //戻ってきたデータを解析
                    do{
                        json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary
                        //jsonFromIBM = json
                        //print(json)
                        //self.setUserData(json: json!)
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
            completionClosure(nil,json, err)

        })
        
        // タスクの実行.
        task.resume()
        
        
    }
    
}
