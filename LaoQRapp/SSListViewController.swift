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
    //let entry = EntryDataBase(db: _db!)
    var backBtn:UIBarButtonItem!
    //var postBtn:UIBarButtonItem!
    //let param:GASURL = GASURL(id: "sheetID", url: apiUrl+"?operation=idList")
    var dataGetAlert:UIAlertController!
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
        self.navigationItem.title = "ບັນຊີລາຍຊື່ລົງທະບຽນ/登録済み一覧"

        backBtn = UIBarButtonItem(title: "＜Back(ກັບຄືນໄປບ່ອນ)", style: .plain, target: self, action: #selector(self.back))
        self.navigationItem.leftBarButtonItem = backBtn
        /*
        if idList.count == 0 {
            self.refreshBtnTap(self)
        }
        
        if sheetId != "", sheetName != "" {
            fileName = idList.first(where: {$0.id==sheetId})?.name ?? ""
            self.sheetLabel.text = fileName
            getGasList(select: 0)
        }*/
        
        sheetId = ""
        sheetName = ""
        fileName = ""
        sheetLabel.text = ""
        if idList.count == 1 {
            sheetId = idList[0].id
            sheetName = idList[0].sheet
            fileName = idList[0].name
            sheetLabel.text = fileName
            getGasList(select: 0)//リスト取得(当日分表示)
        }

        listSelector.selectedSegmentIndex = 0
        //segmentedControlのタイトルラベルの設定
        for list in listSelector.subviews {
            for li in list.subviews {
                if let label = li as? UILabel {
                    print(label.text!)
                    label.numberOfLines = 0
                    label.minimumScaleFactor = 0.5
                }
            }
        }

    }
    
    @IBAction func changeDate(_ sender: UISegmentedControl) {
        if sheetId == "" {
            let alert = UIAlertController(title: "ເລືອກເອກະສານ", message: "シートを選択してください", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        index = sender.selectedSegmentIndex
        dispTable(type: index)
//        if receivedData == 0 {
//            getGasList(select: index)
//        }else {
//            dispTable(type: index)
//        }
    }
    
    func getGasList(select:Int) {
            dataGetAlert = UIAlertController(title: "ຂໍ້ມູນ ກຳ ລັງໄດ້ຮັບ", message: "データ取得中", preferredStyle: .alert)
//        dataGetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
//            Void in
//            return
//        }))
            self.present(dataGetAlert, animated: true, completion: nil)
        
        var list:[GASList] = []
        receivedData = []
        let param = [
            "operation":"search",
            "sheetID":sheetId,
            "shName":sheetName,
//            "term":String(select)
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
//        config.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: config)
        
        var title = ""
        var msg = ""
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data,response,err) -> Void in
            let start = Date()
            
            DispatchQueue.main.async {
                
                if err == nil {
                    if data != nil {
                        //print(data!)
                        do{
                            if let _ = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary  {
                                //print(j)
                                //エラーメッセージ
                                self.dataGetAlert.title = "ຂໍ້ຜິດພາດ/Error"
                                self.dataGetAlert.message = "ຄວາມລົ້ມເຫລວໃນການຊອກຫາຂໍ້ມູນ\nデータ取得失敗"
                                self.dataGetAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                    Void in
                                    DispatchQueue.main.async {
                                        self.gasList = []
                                        self.tableView.reloadData()
                                        self.dataGetAlert = nil
                                    }
                                }))
                            }
                            
                            if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [NSDictionary] {
                                //print(json)
                                self.dataGetAlert.dismiss(animated: true, completion: {
                                    self.dataGetAlert = nil
                                })
                                
                                for j in json {
                                    var createDate = ""
                                    //var createMonth = ""
                                    
                                    //print(j["Create Date"] as? String)
                                    if let str = j["Create Date"] as? String {
                                        //print(str)
                                        if let date = str.toDate(format: "yyyy-MM-dd HH:mm:ss"){
                                            createDate = date.toString(format: "yyyy/MM/dd")
                                            //createMonth = date.toString(format: "yyyyMM")
                                            
                                        }else {
                                            createDate = str
                                        }
                                        
//                                    print(createDate)
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
                                    
                                }
                                //self.dsp(select: select, list: list)
                                
                                DispatchQueue.main.async {
                                    let time = Date().timeIntervalSince(start)
                                    //print(start.timeIntervalSince1970)
                                    print(time)
                                    //listを渡してtableView更新
                                    self.receivedData = list.sorted(by: {($0.date < $1.date)})
                                    self.dispTable(type:select)
                                }
                                                        
                            }
                            
                        }catch{
                            //スプレッドシートに接続できない
                            title = "Error:2003"
                            msg = "ບໍ່ສາມາດເຂົ້າເຖິງເອກະສານ\nスプレッドシートに接続できません"
                        }
                        
                    }else {
                        //GASからの戻りがない
                        title = "Error:2004"
                        msg = "ບໍ່ມີການຕອບຮັບຈາກເຊີເວີ\nサーバーから応答がありません"
                    }
                    
                }else {
                    title = "Error:2001"
                    msg = err!.localizedDescription
                }
                
                if title != "" { //エラーがあった場合の処理
                    DispatchQueue.main.async {
                        self.dataGetAlert.dismiss(animated: true, completion: {
                            self.dataGetAlert = nil
                        })
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
    

    func dispTable(type:Int) {
        
        if receivedData.count == 0 {
            //データがない時
            self.gasList = []
        }else {
            let calendar = Calendar(identifier: .gregorian)
            //比較用
            let year = calendar.component(.year, from: Date())//年
            let month = calendar.component(.month, from: Date())//月
            
            var list:[GASList] = []
            var _list:[[GASList]] = []
            var arr:[GASList] = []
            
            switch type {
            case 0://当日
                list = receivedData.filter{$0.date == Date().toString(format: "yyyy/MM/dd")}
            case 1://前日
                list = receivedData.filter{$0.date == (Date()-24*60*60).toString(format: "yyyy/MM/dd")}
            case 2://当月
                list = receivedData.filter{
                    let comp_s = $0.date.split(separator: "/")
                    let comp = comp_s.map{Int($0)!}
                    return Int(comp[0])*100+Int(comp[1])==year*100+month
                }
            //print(list)
            case 3://前月
                list = receivedData.filter{
                    let comp_s = $0.date.split(separator: "/")
                    let comp = comp_s.map{Int($0)!}
                    if month == 1 {//1月の場合は、前年の12月
                        return Int(comp[0])*100+Int(comp[1])==(year-1)*100+12
                    }else {
                        return Int(comp[0])*100+Int(comp[1])==year*100+month-1
                    }
                }
            //print(list)
            
            default:
                return
            }
            
            print("list.cnt= \(list.count)")
            if type == 0 || type == 1 { //当日・前日分は日付のソートはしない
                let groupArr = self.createGroup(arr: list)
                _list = [groupArr]
                
            }else {
                //日付ごとに配列に入れる
                var date = ""
                for obj in list {
                    if date != obj.date {
                        if arr.count > 0 {
                            let groupArr = self.createGroup(arr: arr)

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
                    _list.append(groupArr)
                    //groupArr = []
                }
                
            }

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
        var refreshAlert:UIAlertController!
        DispatchQueue.main.async {
            refreshAlert = UIAlertController(title: "ປັບປຸງລາຍຊື່", message: "リスト更新中", preferredStyle: .alert)
            self.present(refreshAlert, animated: true, completion: nil)
        }

        //self.listRefresh()
        let err = GetSSData.getCSV()
        if err == "" {
            print(idList.count)
            DispatchQueue.main.async {
                if idList.count == 1 {
                    sheetName = idList[0].sheet
                    sheetId = idList[0].id
                    self.sheetLabel.text = idList[0].name
                }
                refreshAlert.dismiss(animated: true, completion: {
                    refreshAlert = nil
                })
            }
            
        }else {
            DispatchQueue.main.async {
                refreshAlert.title = "エラー".loStr
                refreshAlert.message = err
                refreshAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    refreshAlert = nil
                }))
            }
        }
        
    }
    
    @IBAction func selectSheet(_ sender: Any) {
        let alert = UIAlertController(title: "ເລືອກເອກະສານ", message: "SelectSheet", preferredStyle: .alert)
        
        for id in idList{
            alert.addAction(UIAlertAction(title: id.name, style: .default, handler: {
                Void in
                DispatchQueue.main.async {
                    sheetName = id.sheet
                    sheetId = id.id
                    self.sheetLabel.text = id.name
                    
                    let i = self.listSelector.selectedSegmentIndex
                    self.getGasList(select: i)
//                    self.getGasList()
                }
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)

    }

    
    //前の画面へ戻る
    @objc func back() {
        gasList = []
        sheetId = ""
        sheetName = ""
        fileName = ""
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
        
        var storyboard:UIStoryboard!
        if is_iPhone {
            storyboard = UIStoryboard(name: "Main2", bundle: nil)
        }else {
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }
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
