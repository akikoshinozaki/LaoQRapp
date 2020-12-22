//
//  DataDownload.swift
//  LaoQRapp
//
//  Created by administrator on 2020/12/21.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

let DL = DataDownload()

class DataDownload: NSObject {
    var dlAlert:UIAlertController!
    //let dlAlert = UIAlertController(title: "データ更新中".loStr, message: "", preferredStyle: .alert)
    var progressView:UIProgressView!
    let dispatchGroup = DispatchGroup()
    var finishCnt:Float = 0
    var currentVC:UIViewController!
    var first:ViewController!
    var DL_errMsg = ""
    
    func dataDL() {
        finishCnt = 0
        currentVC = window_.rootViewController
        DispatchQueue.main.async {
            self.dlAlert = UIAlertController(title: "データ更新中".loStr,
                                        message: "ダウンロード済み".loStr+" 0/\(parameters.count)",
                preferredStyle: .alert)
            //self.dlAlert.message = "ダウンロード済み".loStr+" 0/\(parameters.count)"
            
            self.currentVC.present(self.dlAlert, animated: true, completion: {
                let margin:CGFloat = 8.0
                if self.dlAlert != nil {
                    self.progressView = UIProgressView(frame: CGRect(x: margin, y: 65.0, width: self.dlAlert.view.frame.width-margin*2, height: 2.0))
                    self.progressView.progress = 0.0
                    self.dlAlert.view.addSubview(self.progressView)
                }
            })
        }
        
        DL_errMsg = ""
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        for param in parameters{
            dispatchGroup.enter()
            dispatchQueue.async(group: dispatchGroup) {
                let start = Date()
                self.getCSV(start: start, parameter: param)
                //print(data.err)
                //self.DL_errMsg += data.err
            }
        }
        // 全ての非同期処理完了後にメインスレッドで処理
        dispatchGroup.notify(queue: .main) {
            print("All Process Done!")
            //更新できたら最終更新日を変更
            if self.DL_errMsg == "" {
                defaults.set(Date().string, forKey: "lastDataDownload")
                if self.first != nil {
                    //トップページが表示されていたら、ラベルを更新
                    //self.first.updateLabel()
                }
            }else {
                SimpleAlert.make(title: "データ更新に失敗".loStr, message: self.DL_errMsg)
            }
            
            DispatchQueue.main.async {
                if self.dlAlert != nil {
                    self.dlAlert.dismiss(animated: true, completion: {
                        if self.progressView != nil {
                            self.progressView.removeFromSuperview()
                        }
                    })
                    self.dlAlert = nil
                }
            }
            self.csvToArray()
        }
    }
    
    func getCSV(start:Date, parameter:GASURL){
        //サーバー上のcsvファイルのパス
        let url = URL(string: parameter.url)!  //URLを生成
        var request = URLRequest(url: url)//Requestを生成
        request.timeoutInterval = 20
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in  //非同期で通信を行う
            if error != nil {
                print("1..csv取得失敗")
                self.DL_errMsg = error!.localizedDescription
            }else if data != nil, let str = String(data: data!, encoding: .utf8) {
                self.dataChk(str: str, param: parameter.id)
                let time = Date().timeIntervalSince(start)
                //print("----\(i)番目------")
                print(start.timeIntervalSince1970)
                print(time)
                DispatchQueue.main.async {
                    if self.progressView != nil {
                        //プログレスバー
                        self.finishCnt += 1.0
                        self.progressView.progress = self.finishCnt/Float(parameters.count)
                        self.dlAlert.message = "ダウンロード済み".loStr +
                        "\(Int(self.finishCnt))/\(parameters.count)"
                        //self.labels[i].text = "経過時間:\(time)"
                    }
                }
            }else {
                print("2..csv取得失敗")
                self.DL_errMsg += "サーバー上のファイルにアクセスできません".loStr+"(\(parameter.id))\n"
            }
            
            self.dispatchGroup.leave()
        }
        
        dataTask.resume()
    }
    
    //取得したテキストがcsvに変換できるか確認
    //OKだったらユーザーデフォルトに保存
    func dataChk(str:String,param:String){
        //for (i,param) in parameters.enumerated() {
        var arr:[[String]] = []
        //カンマ区切りでデータを分割して配列に格納する。
        str.enumerateLines { (line, stop) -> () in
            arr.append(line.components(separatedBy: ","))
        }
        //print(arr.count)
        //商品リスト
        switch param {
        case "itemArr":
            print(param)
            print(arr[0][0])
            if arr[0][0] == "IBM 品番マスタ" {
                //取得成功
                print("success")
                defaults.set(arr, forKey: param)
            }else {
                //取得失敗
                DL_errMsg += "\(param) 取得失敗\n"
            }
            
        case "location":
            print(param)
            print(arr[0][0])
            if arr[0][0] == "locCD" {
                //取得成功
                print("success")
                defaults.set(arr, forKey: param)
            }else {
                //取得失敗
                DL_errMsg += "\(param) 取得失敗\n"
            }
            
        case "errMessage":
        print(param)
        print(arr[0][0])
        if arr[0][0] == "CD" {
            //取得成功
            print("success")
            defaults.set(arr, forKey: param)
        }else {
            //取得失敗
            DL_errMsg += "\(param) 取得失敗\n"
        }
        case "translate":
            print(param)
            print(arr[0][0])
            if arr[0][0] == "Japanese" {
                //取得成功
                print("success")
                defaults.set(arr, forKey: param)
            }else {
                //取得失敗
                DL_errMsg += "\(param) 取得失敗\n"
            }
        case "employee":
            print(param)
            print(arr[0][0])
            if arr[0][0] == "StaffCode" {
                //取得成功
                print("success")
                defaults.set(arr, forKey: param)
            }else {
                //取得失敗
                DL_errMsg += "\(param) 取得失敗\n"
            }
        case "sheetID":
            //このスクリプトだけ２行目から取得する様になっているので、
            //1行目の値でチェックする方法が使えない。
            //２行目以降は可変なため、とりあえずチェックしない。
            //（変更するとラオスアプリに影響あるため）
            
            print(param)
            print(arr[0][0])
            
            if arr.count > 0 {
                //取得成功
                print("success")
                defaults.set(arr, forKey: param)
            }else {
                //取得失敗
                DL_errMsg += "\(param) 取得失敗\n"
            }
            
        default:
            print(param)
            print(str)
        }
    }
    
    //ユーザーデフォルトからテキストを取り出し、配列へ変換
    func csvToArray() {
        var errStr = ""
        for param in parameters {
            var array = defaults.object(forKey: param.id) as? [[String]] ?? []
            print("\(param.id) count=\(array.count)")
            //商品リスト
            print(array.count)
            if array.count > 2 {
                switch param.id {
                case "itemArr"://LaosMaster
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
                            //print(item[j])
                        }
                    }
                    
                case "location": //location
                    array.removeFirst()
                    locArray = []
                    for item in array {
                        if item.count > 2 {
                            locArray.append((cd:item[0],name:item[2]))
                        }
                    }
                    
                case "errMessage": //errorMessage
                    array.removeFirst()
                    errFromIBM = []
                    for item in array {
                        if item.count > 3 {
                            errFromIBM.append((cd:item[0],jp:item[2],lo:item[3]))
                        }
                    }
                    
                case "translate": //translate
                    array.removeFirst()
                    translate = [:]
                    
                    for item in array {
                        translate[item[0]] = item[1]
                    }
                    
                case "employee": //employee
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
                    
                case "sheetID": //sheetID
                    //print(arr)
                    idList = []
                    for item in array {
                        if item.count > 5 {
                            if item[5] == "ON" {
                                idList.append((name:item[0], id:item[1], sheet:item[2]))
                            }
                        }else {
                            idList.append((name:item[0], id:item[1], sheet:item[2]))
                        }
                        
                    }
                default:
                    print(param.id)
                    
                }
            }else {
                errStr += "(\(param.id))未取得\n"
            }
        }
        print(errStr)
        
        if errStr != "" {
            DispatchQueue.main.async {
                var vc = SimpleAlert.topViewController()
                //print(vc?.classForCoder)
                if vc?.classForCoder==UIAlertController.classForCoder(){
                    vc = vc?.presentingViewController
                    //print(vc?.classForCoder)
                }
                
                let alert = UIAlertController(title: "リスト取得に失敗", message: "マスターを取得してください", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    //exit(3)
                }))
                vc!.present(alert, animated: true, completion: nil)
            }
            
        }
    }
    /*
    func getIdList() -> [(name: String, id: String, sheet: String)]{
        var list:[(name: String, id: String, sheet: String)] = []
        let array = defaults.object(forKey: "sheetID") as? [[String]] ?? []
        for item in array {
            if item.count > 5 {
                if item[5] == "ON" {
                    list.append((name:item[0], id:item[1], sheet:item[2]))
                }
            }else {
                list.append((name:item[0], id:item[1], sheet:item[2]))
            }
        }
        
        /*
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
        */
        return list
        
    }
*/
    
}
