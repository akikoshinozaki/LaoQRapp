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
    var itemName:String = ""
    var staff:String = ""
    var date:String = ""
    var serial:String = ""
    var UV:String = ""
    var UH:String = ""
    var LV:String = ""
    var LH:String = ""
    var WT:String = ""
    var HT:String = ""
    var count:Int = 0
}


class SSListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sheetLabel: UILabel!
    @IBOutlet weak var listSelector: UISegmentedControl!
    var receivedData:[GASList] = []
    
    var gasList:[[GASList]] = []
    let entry = EntryDataBase(db: _db!)
    var backBtn:UIBarButtonItem!
    //var postBtn:UIBarButtonItem!
    let param:GASURL = GASURL(id: "sheetID", url: apiUrl+"?operation=idList")
    var refreshAlert = UIAlertController()
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
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.title = "登録済み一覧"

        backBtn = UIBarButtonItem(title: "＜ 戻る", style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backBtn

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
        refreshAlert = UIAlertController(title: "データ取得中", message: "", preferredStyle: .alert)
        
        self.present(refreshAlert, animated: true, completion: nil)
        
        var list:[GASList] = []
        let param = [
            "operation":"search",
            "sheetID":sheetId,
            "shName":sheetName,
            "term":String(select)
//            "device":iPadName,
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
                            if let j = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary  {
                                print(j)
                                //エラーメッセージ
                                self.refreshAlert.title = "エラー"
                                self.refreshAlert.message = "データ取得できません"
                                self.refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                    Void in
                                    DispatchQueue.main.async {
                                        self.gasList = []
                                        self.tableView.reloadData()
                                    }
                                }))
                            }
                            
                            if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [NSDictionary] {
                                //print(json)
                                self.refreshAlert.dismiss(animated: true, completion: nil)
                                for j in json {
                                    var createDate = ""
                                    //print(j["Create Date"])
                                    if let str = j["Create Date"] as? String {
                                        //print(str)
                                        if let date = str.toDate(format: "yyyy-MM-dd HH:mm:ss"){
                                            createDate = date.toString(format: "yyyy/MM/dd")
                                        }else {
                                            createDate = str
                                        }
                                    }
                                    //print(createDate)
                                    let val = GASList(loc: j["Location"] as? String ?? "",
                                                      item: j["item"] as? String ?? "",
                                                      itemName: j["itemName"] as? String ?? "",
                                                      staff: j["staff"] as? String ?? "",
                                                      date: createDate,
                                                      serial: j["Serial"] as? String ?? "",
                                                      UV: j["UV"] as? String ?? "",
                                                      UH: j["UH"] as? String ?? "",
                                                      LV: j["LV"] as? String ?? "",
                                                      LH: j["LH"] as? String ?? "",
                                                      WT: j["WT"] as? String ?? "",
                                                      HT: j["HT"] as? String ?? "")
                                    
                                    list.append(val)
                                }
                                
                                DispatchQueue.main.async {
                                    //listを渡してtableView更新
                                    list = list.sorted(by: {($0.date < $1.date)})
                                    self.dispTable(type:select, list:list)
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
                
                if title != "" { //エラーがあった場合の処理
                    DispatchQueue.main.async {
                        self.refreshAlert.dismiss(animated: true, completion: nil)
                        SimpleAlert.make(title: title, message: msg)
                        
                        //listを渡してtableView更新
                        self.gasList = []
                        self.tableView.reloadData()
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func dispTable(type:Int,list:[GASList]) {
        receivedData = list
        if list.count == 0 {
            //データがない時
            self.gasList = []
        }else {
            var _list:[[GASList]] = []
            var arr:[GASList] = []
            
            //print("list.cnt= \(list.count)")
            if type == 0 || type == 1 { //当日・前日分は日付のソートはしない
                var groupArr = self.createGroup(arr: list)
/*
                arr = list.sorted(by: {$0.item<$1.item})
                print(arr.count)
                var groupArr:[GASList] = []
                var item = ""
                for a in arr {
                    if a.item != item {
                        item = a.item
                        let group = arr.filter{$0.item == item} //item別の数量出す
                        groupArr.append(GASList(loc: a.loc,
                                                item: a.item,
                                                itemName: a.itemName,
                                                date: a.date,
                                                count: group.count))
                    }
                }*/
                _list = [groupArr]
                
            }else {
                //日付ごとに配列に入れる
                var date = ""
                for obj in list {
                    if date != obj.date {
                        if arr.count > 0 {
                            let groupArr = self.createGroup(arr: arr)
                            /*
                            arr = arr.sorted(by: {$0.item<$1.item})
                            var groupArr:[GASList] = []
                            var item = ""
                            for a in arr {
                                if a.item != item {
                                    item = a.item
                                    let group = arr.filter{$0.item == item}
                                    groupArr.append(GASList(loc: a.loc,
                                                            item: a.item,
                                                            itemName: a.itemName,
                                                            date: a.date,
                                                            count: group.count))
                                }
                                
                            }*/
                            _list.append(groupArr)
                            //groupArr = []
                            arr = []
                        }
                        
                        arr.append(obj)
                        date = obj.date
                    }else {
                        arr.append(obj)
                    }
                    
                }
                //最後の要素を配列に入れる
                if arr.count > 0 {
                    //arr = arr.sorted(by: {$0.item<$1.item})
                    let groupArr:[GASList] = self.createGroup(arr: arr)
//                    var item = ""
//                    for a in arr {
//                        if a.item != item {
//                            item = a.item
//                            let group = arr.filter{$0.item == item}
//                            groupArr.append(GASList(loc: a.loc,
//                                                    item: a.item,
//                                                    itemName: a.itemName,
//                                                    date: a.date,
//                                                    count: group.count))
//                        }
//
//                    }
                    _list.append(groupArr)
                    //groupArr = []
                }
                
            }
            /*
             var cnt = 0
             for li in _list {
             for l in li {
             cnt += l.count
             }
             }
             print(cnt)
             */
            self.gasList = _list
        }
        
        self.tableView.reloadData()
    }
    
    func createGroup(arr:[GASList])->[GASList]{
        let array = arr.sorted(by: {$0.item<$1.item})
        var gArray:[GASList] = []
        var item = ""
        for a in array {
            if a.item != item {
                item = a.item
                let group = array.filter{$0.item == item}
                gArray.append(GASList(loc: a.loc,
                                        item: a.item,
                                        itemName: a.itemName,
                                        date: a.date,
                                        count: group.count))
            }
            
        }
        return gArray
    }
    
    
    @IBAction func refreshBtnTap(_ sender: Any) {
        refreshAlert = UIAlertController(title: "リスト更新中", message: "", preferredStyle: .alert)
        self.present(refreshAlert, animated: true, completion: nil)
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
        //print(idList)
        
        if idList.count == 1 {
            sheetName = idList[0].sheet
            sheetId = idList[0].id
            self.sheetLabel.text = idList[0].name
        }
        
        DispatchQueue.main.async {
            self.refreshAlert.dismiss(animated: true, completion: nil)
        }
    }


    //前の画面へ戻る
    @objc func back() {
        gasList = []
        self.navigationController?.popViewController(animated: true)
    }

    
}

// MARK: - TableViewDelegate
extension SSListViewController:UITableViewDelegate, UITableViewDataSource {
    /*
    //カスタムヘッダ-
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withClass: SectionHeaderView.self)
        header.setup(titleText: "Section title")
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SectionHeaderView.height
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    */
    func numberOfSections(in tableView: UITableView) -> Int {
        return gasList.count
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gasList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InquiryTableViewCell", for: indexPath) as! InquiryTableViewCell
        let data = gasList[indexPath.section][indexPath.row]
        //print(data)
        cell.dateLabel.text = data.date
        cell.locLabel.text = data.loc
        cell.itemLabel.text = data.item
        cell.itemNameLabel.text = data.itemName
        cell.countLabel.text = String(data.count)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //セルをタップしたときの処理（詳細表示）
        let obj = gasList[indexPath.section][indexPath.row]
        print(obj)
        
        detailList = receivedData.filter{$0.date==obj.date && $0.item==obj.item}
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detail = storyboard.instantiateViewController(withIdentifier: "detail")
        //self.navigationController?.pushViewController(detail, animated: true)
        self.present(detail, animated: true, completion: nil)
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
    
}
