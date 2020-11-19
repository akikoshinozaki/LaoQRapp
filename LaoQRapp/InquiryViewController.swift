//
//  InquiryViewController.swift
//  QRReader
//
//  Created by administrator on 2017/09/15.
//  Copyright © 2017年 Akiko Shinozaki. All rights reserved.
//

import UIKit
import FMDB

class InquiryViewController: UIViewController, QRScannerViewDelegate {

    @IBOutlet var QRButton: UIButton!
    @IBOutlet var rtnData: UITextView!
    
    //@IBOutlet weak var selectBtn: UIButton!
    //@IBOutlet weak var sheetLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var qrScanner:QRScannerView!
    var serialNO:String = ""
    var postAlert:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let backButton = UIBarButtonItem(title: "＜ 戻る", style: .plain, target: self, action: #selector(self.goToMenu))
        //delButton = UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(self.deleteData))
        self.navigationItem.leftBarButtonItem = backButton
        //self.navigationItem.rightBarButtonItem = delButton
        self.navigationItem.title = "照会・削除"
        
        QRButton.addTarget(self, action: #selector(showScanView(_:)), for: .touchUpInside)
        rtnData.layer.borderColor = UIColor.gray.cgColor
        rtnData.layer.borderWidth = 2
        
        deleteBtn.layer.cornerRadius = 8
        deleteBtn.titleLabel?.numberOfLines = 0
        /*
        let btns:[UIButton] = [selectBtn, deleteBtn]
        for btn in btns {
            btn.layer.cornerRadius = 8
            btn.titleLabel?.numberOfLines = 0
        }*/
        
        self.deleteBtn.isHidden = true
        
        sheetId = ""
        sheetName = ""
        fileName = ""
        //sheetLabel.text = ""
        if idList.count == 1 {
            sheetId = idList[0].id
            sheetName = idList[0].sheet
            fileName = idList[0].name
            //sheetLabel.text = fileName
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goToMenu() {
        inquiryJson_ = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectSheet(_ sender: Any) {
        print(idList)
        if idList.count > 1 {
            let alert = UIAlertController(title: "ເລືອກສະຖານທີ່ລົງທະບຽນ", message: "Select Sheet", preferredStyle: .alert)
            
            for id in idList{
                alert.addAction(UIAlertAction(title: id.name, style: .default, handler: {
                    Void in
                    sheetId = id.id
                    sheetName = id.sheet
                    fileName = id.name
                    
                }))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    @objc func showScanView(_ sender: Any) {
        self.view.endEditing(true)
        btnID = 888 //Tagを追加
        qrScanner = QRScannerView(frame: self.view.frame)

        qrScanner.delegate = self
        qrScanner.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        qrScanner.frame = self.view.frame
        self.view.addSubview(qrScanner)

        //画面回転に対応
        qrScanner.translatesAutoresizingMaskIntoConstraints = false
        
        qrScanner.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        qrScanner.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        qrScanner.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        qrScanner.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true

    }
    
    func removeView() {
        print(#function)
    }
    
    func getData(type:String, data: String){
        serialNO = data
        MySQL().getID(serial: serialNO, type:"search", completionClosure: {
            (str, json,err) in
            if err == nil, json != nil {
                print(json!)
                let status = json!["status"] as? String ?? ""
                if status == "success" {
                    sheetId = json!["sheetID"] as? String ?? ""
                    sheetName = json!["sheetName"] as? String ?? ""
                    fileName = json!["fileName"] as? String ?? ""
                    
                }else {
                    //シートID取得できない
                    print(str!)
                }
            }else {
                //シートID取得できない
            }
            
            if sheetId != "" {
                //スプレッドシート検索
                self.searchSS(serial: self.serialNO)
                
            }else {
                 //シートID取得できないときの処理
                SimpleAlert.make(title: "エラー", message: "取得できません")
            }
        })
    }
       
    var getAlert = UIAlertController()
    func searchSS(serial: String) {
        DispatchQueue.main.async {
            self.deleteBtn.isHidden = true
            self.getAlert = UIAlertController(title: "ຂໍ້ມູນ ກຳ ລັງໄດ້ຮັບ", message: "データ取得中", preferredStyle: .alert)
            self.present(self.getAlert, animated: true, completion: nil)
        }
        
        let param = [
            "sheetID":sheetId,
            "shName":sheetName,
            "serial":serial
        ]
        
        var url = apiUrl+"?"
        for p in param {
            url += "\(p.key)=\(p.value)&"
        }
        
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
                                DispatchQueue.main.async {
                                    self.getAlert.title = "ຂໍ້ຜິດພາດ/Error"
                                    self.getAlert.message = "ຄວາມລົ້ມເຫລວໃນການຊອກຫາຂໍ້ມູນ\nデータ取得失敗"
                                    self.getAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                }
                            }
                            
                            if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                                self.display(json: json)
                                //print(json)
                                DispatchQueue.main.async {
                                    self.getAlert.dismiss(animated: true, completion: nil)
                                    self.deleteBtn.isHidden = false
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
                        self.getAlert.dismiss(animated: true, completion: nil)
                        SimpleAlert.make(title: title, message: msg)
                    }
                }
            }
        })
        
        task.resume()
    }
    
    func display(json:NSDictionary!){
        /*
        //日付を変換
        var createDate = ""
        if let str = json["Create Date"] as? String {
            if let date = str.toDate(format: "yyyy-MM-dd HH:mm:ss"){
                createDate = date.toString(format: "yyyy/MM/dd")
            }else {
                createDate = str
            }
        }*/
        
        let val = GASList(loc: json["Location"] as? String ?? "",
                          item: json["item"] as? String ?? "",
                          itemName: json["itemName"] as? String ?? "",
                          staff: json["staff"] as? String ?? "",
                          date: json["Create Date"] as? String ?? "",
                          serial: json["Serial"] as? String ?? "",
                          UV: json["UV"] as? String ?? "",
                          UH: json["UH"] as? String ?? "",
                          LV: json["LV"] as? String ?? "",
                          LH: json["LH"] as? String ?? "",
                          WT: json["WT"] as? String ?? "",
                          HT: json["HT"] as? String ?? "")

        //データ表示
        let str = "FileName: \(fileName)\n" +
            "SheetID: \(sheetId)\n" +
            "SheetName: \(sheetName)\n\n" +
            "SerialNumber: \(val.serial)\n" +
            //"製造場所: \(inq_LOCAT_NM!)\n" +
            "EntryDate: \(val.date)\n" +
            "Staff: \(val.staff)\n\n" +
            "ItemCD: \(val.item)\n" +
            "ItemName: \(val.itemName)\n" +
        "ORDER_SPEC: UV=\(val.UV), UH=\(val.UH),LV=\(val.LV),LH=\(val.LH),WT=\(val.WT),HT=\(val.HT)"
        
        DispatchQueue.main.async {
            self.rtnData.text = str
        }
        
    }
    
    @IBAction func deleteData() {
        //MySQLから削除
        
        MySQL().getID(serial: serialNO, type:"delete", completionClosure: {
            (str, json,err) in
            if err == nil, json != nil {
                print(json!)
                let status = json!["status"] as? String ?? ""
                if status == "success" {
                    //削除成功
                    self.ssDelete()
                }else {
                    //失敗
                    print(str!)
                    SimpleAlert.make(title: "削除失敗", message: "しばらくしてからやり直してください")
                }
            }else {
                //シートID取得できない
                SimpleAlert.make(title: "削除失敗", message: "しばらくしてからやり直してください")
            }
            
        })
    }

    func ssDelete() {
        if sheetId == ""||sheetName==""{return}
        //スプレッドシートから削除
        let param = [
            "operation":"delete",
            "sheetID":sheetId,
            "shName":sheetName,
            "serial":serialNO
        ]
        
        var url = apiUrl+"?"
        for p in param {
            url += "\(p.key)=\(p.value)&"
        }

        let request = URLRequest(url: URL(string: url)!)
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: config)

        //var json:NSDictionary!
        var title = ""
        var msg = ""
        let task = session.dataTask(with: request as URLRequest, completionHandler: {(data,response,err) -> Void in
            DispatchQueue.main.async {
                if err == nil {
                    if data != nil {
                        
                        do{
                            print(data!)
                            if let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                                title = "削除しました"
                                if json["value"] as? String != nil, json["value"] as? String == "error" {
                                    //IBMから削除したが、SSに存在しない場合
                                    msg = "スプレッドシートに存在しません"
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
                let okAction = UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    self.navigationController?.popViewController(animated: true)
                })
                SimpleAlert.make(title: title, message: msg, action: [okAction])
            }
        })
        task.resume()
    }

}

extension InquiryViewController { //IBM関連メソッド
    /*
    
    func getData(type:String, data: String) {
        serialNO = data
        let param = ["PRODUCT_SN":data]
        
        rtnData.text = ""
        IBM().hostRequest(type: "INQUIRY", param: param, completionClosure: {
            (str, json,err) in
            DispatchQueue.main.async {
                if err != nil {
                    //アラートを表示
                    let alert = UIAlertController(title: "エラー", message: err?.localizedDescription, preferredStyle: .alert)
                    //ボタン追加
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                    self.present(alert,animated: true,completion:nil)
                    
                    return
                }
                
                if json != nil {
                    print(json!)
                    let json_ = json!
                    if json_["RTNCD"] as! String == "000" {
                        self.display(json: json_)
                        self.deleteBtn.isHidden = false
                        
                    }else {
                        self.deleteBtn.isHidden = true
                        //IBMからエラー戻り
                        let rtnMSG = json_["RTNMSG"] as? [String] ?? []
                        let errStr =  errMsgFromIBM(rtnMSG: rtnMSG)
                        
                        //アラートを表示
                        let alert = UIAlertController(title: "エラー", message: errStr, preferredStyle: .alert)
                        //ボタン追加
                        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                        self.present(alert,animated: true,completion:nil)
                        
                    }
                }
            }
        })
        
    }
    
    func ibmDelete(){
        let param = ["PRODUCT_SN":serialNO]
        let alert = UIAlertController(title: "ຕ້ອງການລຶບອອກແມ່ນບໍ່" , message: "削除してよろしいですか？", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ລົບ/削除", style: .destructive, handler: {
            Void in
            
            IBM().hostRequest(type: "DELETE", param: param, completionClosure: {
                (str, json,err) in
                if err != nil {
                    SimpleAlert.make(title: "Error", message: err?.localizedDescription)
                    return
                }
                
                if json != nil {
                    let json_ = json!
                    DispatchQueue.main.async {
                        if json_["RTNCD"] as! String == "000" {
                            SimpleAlert.make(title: "ການລຶບ ສຳ ເລັດແລ້ວ", message: "削除完了")
                            //スプレッドシートからも削除
                            if sheetId != "" {
                                self.ssDelete()
                            }
                        }else {
                            //IBMからエラー戻り
                            let rtnMSG = json_["RTNMSG"] as? [String] ?? []
                            let errStr =  errMsgFromIBM(rtnMSG: rtnMSG)
                            let alert = UIAlertController(title: "登録エラー", message: errStr, preferredStyle: .alert)
                            //ボタン追加
                            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                            
                            //アラートを表示
                            self.present(alert,animated: true,completion:nil)
                        }
                    }
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "ຍົກເລີກ/Cancel", style: .cancel, handler: nil))
        self.present(alert,animated: true)
    }
 */
}
