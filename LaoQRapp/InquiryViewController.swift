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
    
    var delButton:UIBarButtonItem!
    
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
        delButton = UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(self.deleteData))
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.rightBarButtonItem = delButton
        self.navigationItem.title = "照会・削除"
        
        QRButton.addTarget(self, action: #selector(showScanView(_:)), for: .touchUpInside)
        rtnData.layer.borderColor = UIColor.gray.cgColor
        rtnData.layer.borderWidth = 2

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func goToMenu() {
        inquiryJson_ = nil
        self.navigationController?.popViewController(animated: true)
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
    
    func getData(type:String, data: String) {
        serialNO = data
        let param = ["PRODUCT_SN":data]
        
        rtnData.text = ""
        delButton.isEnabled = false
        delButton.setTitleTextAttributes(notDelete, for: .normal)
        
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
                        
                    }else {
                        //IBMからエラー戻り
                        //print(json_["RTNMSG"] as? [String] ?? [])
                        var errStr =  ""
                        for err in json_["RTNMSG"] as? [String] ?? [] {
                            errStr += err+"\n"
                        }
                        
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
            
            self.delButton.isEnabled = true
            self.delButton.setTitleTextAttributes(self.canDelete, for: .normal)
        }
        
    }
    

    @objc func deleteData() {
        //print("削除")
        let param = ["PRODUCT_SN":serialNO]
        let alert = UIAlertController(title: "削除してよろしいですか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "削除", style: .destructive, handler: {
            Void in

            IBM().hostRequest(type: "DELETE", param: param, completionClosure: {
                (str, json,err) in
                if err != nil {
                    SimpleAlert.make(title: "エラー", message: err?.localizedDescription)
                    return
                }
                
                if json != nil {
                    let json_ = json!
                    DispatchQueue.main.async {
                        if json_["RTNCD"] as! String == "000" {
                            SimpleAlert.make(title: "削除完了", message: "")
                            //スプレッドシートからも削除
                            self.ssDelete()
                            //削除成功
                            //MARK: - 削除したらenrolltypeを変更
                            
                            //let entry = EntryDataBase(db: _db!)
                            //entry.changeStatus(serial:self.inq_PRODUCT_SN!, type: "delete", msg: "削除完了")
                            
                        }else {
                            //IBMからエラー戻り
                            print(json_["RTNMSG"] as? [String] ?? [])
                            var errStr =  ""
                            for err in json_["RTNMSG"] as? [String] ?? [] {
                                errStr += err+"\n"
                            }
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
    
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(alert,animated: true)
        
    }

    func ssDelete() {
//        postAlert = UIAlertController(title: "削除中", message: "", preferredStyle: .alert)
//        self.present(postAlert, animated: true, completion: nil)
        
        //スプレッドシートから削除
        sheetId = "1Ps2oJPkjXp0F2VDEG-39H-DSJD1AFjB6Lhuka3vJu6w"
        sheetName = "detail"
        
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
                                //json = dic
//                                print(dic)
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
