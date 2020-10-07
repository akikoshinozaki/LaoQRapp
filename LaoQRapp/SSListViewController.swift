//
//  SSListViewController.swift
//  QRReader
//
//  Created by administrator on 2020/06/30.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

struct GASList {
    var loc:String = ""
    var item:String = ""
    var staff:String = ""
    
    
}

class SSListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sheetLabel: UILabel!
    @IBOutlet weak var listSelector: UISegmentedControl!

    
    var gasList:[GASList] = []
    let entry = EntryDataBase(db: _db!)
    var backBtn:UIBarButtonItem!
    //var postBtn:UIBarButtonItem!
    let param:GASURL = GASURL(id: "sheetID", url: apiUrl+"?operation=idList")
    var alert1 = UIAlertController()
    //var postAlert = UIAlertController()
    
    var index = 0
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var refreshBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        selectBtn.layer.cornerRadius = 5
        //list = entry.inputRead(select:index)
        self.navigationController?.setToolbarHidden(false, animated: false)
        
        backBtn = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(self.back))
        //postBtn = UIBarButtonItem(title: "送信", style: .plain, target: self, action: #selector(self.post))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.setToolbarItems([backBtn, flexSpace], animated: true)

        sheetId = ""
        sheetName = ""
        sheetLabel.text = ""
        
        self.getList()
        
        if idList.count == 0 {
            self.listRefresh()
        }
        
        listSelector.selectedSegmentIndex = 0
        getGasList(select: 0)

    }
    
    @IBAction func changeDate(_ sender: UISegmentedControl) {
        index = sender.selectedSegmentIndex
        //list = entry.inputRead(select: index)
        getGasList(select: index)
        //self.tableView.reloadData()
    }
    
    func getGasList(select: Int) {
        var list:[GASList] = []
        let param = [
            "operation":"search",
            "sheetID":sheetId,
            "shName":sheetName,
            "device":iPadName,
            "term":String(select)
//            "date1":"",
//            "date2":"",
//            "location":""
        ]
        
        var url = apiUrl+"?"
        for p in param {
            url += "\(p.key)=\(p.value)&"
        }
        
        print(url)
        let request = URLRequest(url: URL(string: url)!)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: config)
        
        var title = ""
        var msg = ""
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data,response,err) -> Void in
            DispatchQueue.main.async {
                if err == nil {
                    if data != nil {
                        print(data!)
                        do{
                            if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [NSDictionary] {
                                print(json)
                                
                                for j in json {
                                
                                let l = GASList(loc: j["loc"] as? String ?? "",
                                                item: j["item"] as? String ?? "",
                                                staff: j["staff"] as? String ?? "")
                                    
                                    list.append(l)
                                }
                                
                                DispatchQueue.main.async {
                                    //listを渡してtableView更新
                                    self.gasList = list
                                    self.tableView.reloadData()
                                }
                                                        
                            }
                            
                        }catch{
                            //スプレッドシートに接続できない
                            title = "Error:2003"
                            msg = "スプレッドシートに接続できません"
                        }
                        
                    }else {
                        //GASからの戻りがない
                        title = "Error:2004"
                        msg = "サーバーから応答がありません"
                    }
                    
                }else {
                    title = "Error:2001"
                    msg = err!.localizedDescription
                }
                
                if title != "" {
                    SimpleAlert.make(title: title, message: msg)
                }
            }
        })
        
        task.resume()
    }
    
    
    @IBAction func refreshBtnTap(_ sender: Any) {
        alert1 = UIAlertController(title: "リスト更新中", message: "", preferredStyle: .alert)
        self.present(alert1, animated: true, completion: nil)
        self.listRefresh()
    }
    
    @objc func listRefresh() {
        print(#function)
        
        var csvStr = ""
        //var errMsg = ""
        //サーバー上のcsvファイルのパス
        if let csvPath = URL(string: param.url) {
            do {
                //CSVファイルのデータを取得する。
                let str = try String(contentsOf: csvPath, encoding: .utf8)
                csvStr = str
                defaults.set(csvStr, forKey: param.id)
                print("csvの保存に成功")
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print("csv取得失敗")
                //errMsg = error.localizedDescription
            }
        }else {
            print("csv取得できません")
            //errMsg = "サーバー上のファイルにアクセスできません"
        }
        
        self.getList()
    }
    
    @IBAction func selectSheet(_ sender: Any) {
        let alert = UIAlertController(title: "登録先選択", message: "", preferredStyle: .alert)
        
        for id in idList{
            alert.addAction(UIAlertAction(title: id.name, style: .default, handler: {
                Void in
                DispatchQueue.main.async {
                    sheetName = id.sheet
                    sheetId = id.id
                    self.sheetLabel.text = id.name
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

    }
    
    func getList(){
        //idList取得
        var arr:[[String]] = []
        if let itemArr = defaults.object(forKey: param.id) as? String {
            //カンマ区切りでデータを分割して配列に格納する。
            itemArr.enumerateLines { (line, stop) -> () in
                arr.append(line.components(separatedBy: ","))
            }
        }
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
        print(idList)
        
        if idList.count == 1 {
            sheetName = idList[0].sheet
            sheetId = idList[0].id
            self.sheetLabel.text = idList[0].name
        }
        
        DispatchQueue.main.async {
            self.alert1.dismiss(animated: true, completion: nil)
        }
    }

    // MARK: - TableViewDelegate
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gasList.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! myTableViewCell
        let data = gasList[indexPath.row]
        print(data)
        //cell.textLabel?.text = data.uuid
        cell.itemCDLabel.text = data.loc
        cell.itemNameLabel.text = data.item
//        cell.dataCountLabel.text = data.qty
        /*
        if data.err {
            cell.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.8409949541, blue: 0.8371030092, alpha: 1)
        }else {
            cell.contentView.backgroundColor = .none
        }*/
        
        return cell
     }
    /*
    //削除
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if list[indexPath.row].type == "inputList" {
            return true
        }else {
            return false
        }
    }

    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if list[indexPath.row].type == "inputList" {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                let id = list[indexPath.row].id!
                if self.entry.inputDelete(deleteID: [id]) {
                    list = self.entry.inputRead(select:index)
                    self.tableView.reloadData()
                }else {
                    SimpleAlert.make(title: "削除失敗しました", message: "")
                }
            }
        }
    }
*/
    //前の画面へ戻る
    @objc func back() {
        gasList = []
        self.navigationController?.popViewController(animated: true)
    }
    /*
    @objc func post() {
        if sheetId=="" || sheetName=="" {
            SimpleAlert.make(title: "登録するシートを選択してください", message: "")
            return
        }
        
        self.backBtn.isEnabled = false
        self.postBtn.isEnabled = false
        
        let alert = UIAlertController(title: "登録してよろしいですか", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            Void in
            self.sendData()
        }))
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: {
            Void in
            self.backBtn.isEnabled = true
            self.postBtn.isEnabled = true
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

    func sendData(){
        //登録
//        sheetId = "1HBz1HDS-aUMkPnFwYOuV7DSyxUIu6VeKI08J_L4S_Ag"
//        sheetName = "iPad"
        print(sheetId)
        print(sheetName)
       
        //新規登録
        postAlert = UIAlertController(title: "データ登録中", message: "", preferredStyle: .alert)
        self.present(postAlert, animated: true, completion: nil)
        let url = apiUrl
        
        var params:[String:Any] = ["element":list.count, "sheetid":sheetId, "sheetName":sheetName]
        
        for (i,item) in list.enumerated() {
            print(item)
            
            let param:[String:Any] = [
                "date": Date().entryDate,
                "loc": item.locate,
                "rack": item.rack,
                "floor": item.floor,
                "cd": item.itemCD,
                "name": item.itemName,
                "qty": item.qty,
                "unit": "",
                "seq": item.seqNo,
                "staff": item.syainCD,
                "uuid": item.uuid,
                "start":item.startTM,
                "end":item.endTM,
                "work":item.workTM
            ]
            params["object\(i)"] = param
        }
        

        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: config)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {(data,response,err) -> Void in
                var str1 = ""
                var str2 = ""
                if err == nil {
                    if(data != nil){
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary ?? [:]
                            print(json)
                            let status = json["status"] as? String ?? ""
                            let rtnMsg = json["rtnMsg"] as? String ?? ""
                            let errNO = json["errNO"] as? [Int] ?? []
                            let error = json["error"] as? String ?? ""
                            print(rtnMsg)
                            print(error)
                            if errNO.count > 0 { //重複エラー
                                str1 = "登録完了"
                                str2 = "重複しているデータは登録されません"
                                self.tableReload(arr: errNO)
                                self.dbUpdate()
//                                DispatchQueue.main.async {
//                                    self.back()
//                                }
                                
                            }else if status == "success" { //登録成功
                                str1 = "正常に登録できました"
                                self.dbUpdate()
                                DispatchQueue.main.async {
                                    self.back()
                                }
                            }else { //その他のエラー
                                str1 = "Error:2002"
                                str2 = rtnMsg
                            }
                            
                        }catch{
                            //スプレッドシートに接続できない
                            str1 = "Error:2003"
                            str2 = "スプレッドシートに登録できません"
                            
                        }
                        
                    }else {
                        //GASからの戻りがない
                        str1 = "Error:2004"
                        str2 = "スプレッドシートに接続できませんでした"
                    }
                }else {
                    //接続エラー
                    str1 = "Error"
                    str2 = err!.localizedDescription
                }
                DispatchQueue.main.async {
                    self.postAlert.title = str1
                    self.postAlert.message = str2
                    self.postAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    self.backBtn.isEnabled = true
                    self.postBtn.isEnabled = true
                }
                
            })
            task.resume()
        }catch{
            //json解析エラー
            print("Error:\(error)")
            DispatchQueue.main.async {
                self.postAlert.title = "Error"
                self.postAlert.message = error.localizedDescription
                self.postAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.backBtn.isEnabled = true
                self.postBtn.isEnabled = true
            }
            
            return
            
        }
        
    }
    
    func tableReload(arr:[Int]) {
        //重複エラーを受け取ったセルを色付け
        var updID:[Int] = [] //entry
        var updID2:[Int] = [] //input
        for i in arr {
            list[i].err = true
            if list[i].type == "serialList" {
                updID.append(list[i].id)
            }else {
                updID2.append(list[i].id)
            }
        }
        
        self.entry.inputUpdate(id: updID, post: Date().timeStamp, tbName:"entryList")
        if self.entry.inputDelete(deleteID: updID2) {
            print("削除完了")
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func dbUpdate() {
        //inputListはDELETE
        if entry.inputDelete(deleteID: []) {
            print("inputList削除成功")
        }
        //entryListは更新
        var updID:[Int] = []
        for item in list {
            if item.type == "serialList" {
                updID.append(item.id)
            }
        }
        
        self.entry.inputUpdate(id: updID, post: Date().timeStamp, tbName:"serialList")
        
    }
    */
}
