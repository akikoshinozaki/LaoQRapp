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
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var sheetLabel: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var inq_UKE_TYPE: String!
    var inq_UKE_CDD: String!
    var inq_SYAIN_CD: String!
    var inq_SYAIN_NM: String!
    var inq_LOCAT_CD: String!
    var inq_LOCAT_NM: String!
    var inq_SYOHIN_CD: String!
    var inq_SYOHIN_NM: String!
    var inq_ORDER_SPEC: String!
    var inq_CUSTOMER_NM: String!
    
    //var delButton:UIBarButtonItem!
    
    var tourokuDate: String!
    //削除ボタンに設定するAttribute
    let canDelete:[NSAttributedString.Key : Any] = [
        .foregroundColor: UIColor.red,
        .font: UIFont.boldSystemFont(ofSize: 18.0)
    ]
    let notDelete:[NSAttributedString.Key : Any] = [
        .foregroundColor: UIColor.gray,
        .font: UIFont.systemFont(ofSize: 18.0)
    ]
    
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
        
        let btns:[UIButton] = [selectBtn, deleteBtn]
        for btn in btns {
            btn.layer.cornerRadius = 8
            btn.titleLabel?.numberOfLines = 0
        }
        
        self.deleteBtn.isHidden = true
        
        sheetId = ""
        sheetName = ""
        fileName = ""
        sheetLabel.text = ""
        if idList.count == 1 {
            sheetId = idList[0].id
            sheetName = idList[0].sheet
            fileName = idList[0].name
            sheetLabel.text = fileName
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
                    DispatchQueue.main.async {
                        self.sheetLabel.text = id.name
                    }
                    
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
    
    @IBAction func test(_ sender: Any) {
        self.getData(type:"", data: "53604221619170005")
    }
    
    func getData(type:String, data: String){
        serialNO = data
        MySQL().getID(serial: serialNO, completionClosure: {
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
                SimpleAlert.make(title: "エラー", message: "")
            }
        })
    }
       
    var getAlert = UIAlertController()
    func searchSS(serial: String) {
        DispatchQueue.main.async {
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
                                //print(json)
                                DispatchQueue.main.async {
                                    self.getAlert.dismiss(animated: true, completion: nil)
                                }
                                //日付を変換
                                var createDate = ""
                                if let str = json["Create Date"] as? String {
                                    if let date = str.toDate(format: "yyyy-MM-dd HH:mm:ss"){
                                        createDate = date.toString(format: "yyyy/MM/dd")
                                    }else {
                                        createDate = str
                                    }
                                }
                                
                                let val = GASList(loc: json["Location"] as? String ?? "",
                                                  item: json["item"] as? String ?? "",
                                                  itemName: json["itemName"] as? String ?? "",
                                                  staff: json["staff"] as? String ?? "",
                                                  date: createDate,
                                                  serial: json["Serial"] as? String ?? "",
                                                  UV: json["UV"] as? String ?? "",
                                                  UH: json["UH"] as? String ?? "",
                                                  LV: json["LV"] as? String ?? "",
                                                  LH: json["LH"] as? String ?? "",
                                                  WT: json["WT"] as? String ?? "",
                                                  HT: json["HT"] as? String ?? "")
                                
                                DispatchQueue.main.async {
                                    //データ表示
                                    let str = "SerialNumber: \(val.serial)\n" +
                                        //"製造場所: \(inq_LOCAT_NM!)\n" +
                                        "entryDate: \(createDate)\n" +
                                        "staff: \(val.staff)\n\n" +
                                        "itemCD: \(val.item)\n" +
                                        "itemName: \(val.itemName)\n" +
                                    "ORDER_SPEC: UV=\(val.UV), UH=\(val.UH),LV=\(val.LV),LH=\(val.LH),WT=\(val.WT),HT=\(val.HT)"
                                    self.rtnData.text = str
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
    
    @IBAction func deleteData() {
        ssDelete()
        /*
        //print("削除")
        if sheetId == "" {
            let alert = UIAlertController(title: "ບໍ່ມີການຄັດເລືອກເອກະສານ", message: "スプレッドシートが選択されていません", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ສືບຕໍ່/続ける", style: .default, handler: {
                Void in
                self.ibmDelete()
            }))
            alert.addAction(UIAlertAction(title: "ຍົກເລີກ/Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }else {
            ibmDelete()
        }
*/
        
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
    func display(json:NSDictionary!){
        var str = ""
        inq_UKE_TYPE = json["UKE_TYPE"]! as? String
        inq_UKE_CDD = json["UKE_CDD"]! as? String
        serialNO = json["PRODUCT_SN"]! as? String ?? ""
        
        inq_SYAIN_CD = json["SYAIN_CD"]! as? String
        inq_SYAIN_NM = json["SYAIN_NM"]! as? String
        inq_LOCAT_CD = json["LOCAT_CD"]! as? String
        inq_LOCAT_NM = json["LOCAT_NM"]! as? String
        inq_SYOHIN_CD = json["SYOHIN_CD"]! as? String
        inq_SYOHIN_NM = json["SYOHIN_NM"]! as? String
        
        inq_ORDER_SPEC = json["ORDER_SPEC"]! as? String
        inq_CUSTOMER_NM = json["CUSTOMER_NM"]! as? String
        tourokuDate = String(describing: json["ENTRY_DATE"]!)
        str = "製造番号: \(serialNO)\n" +
            "製造場所: \(inq_LOCAT_NM!)\n" +
            "登録日: \(tourokuDate!)\n" +
            "登録者: \(inq_SYAIN_CD!) \(inq_SYAIN_NM!)\n\n" +
            "受付タイプ：\(inq_UKE_TYPE!)　\(inq_UKE_CDD!)\n商品CD: \(inq_SYOHIN_CD!)\n" +
        "商品名: \(inq_SYOHIN_NM!)"
        
        if inq_CUSTOMER_NM != "" {
            str += "\nお客様名: \(inq_CUSTOMER_NM!) 様"
        }
        if inq_ORDER_SPEC != "" {
            str += "\nオーダー仕様: \(inq_ORDER_SPEC!)"
        }
        
        DispatchQueue.main.async {
            self.rtnData.text = str
        }
        
    }
    
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
