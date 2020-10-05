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
    var inq_PRODUCT_SN: String!

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //ツールバーの設定
        self.navigationController?.setToolbarHidden(false, animated: false)
        delButton = UIBarButtonItem(title: "削除", style: .plain, target: self, action: #selector(self.deleteData))
        
        let backButton = UIBarButtonItem(title: "戻る", style: .plain, target: self, action: #selector(self.goToMenu))
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.setToolbarItems([backButton, flexSpace, delButton], animated: true)
        
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
    
    func getData(data: String) {
        
        let param = ["PRODUCT_SN":data]
        
        rtnData.text = ""
        delButton.isEnabled = false
        delButton.setTitleTextAttributes(notDelete, for: .normal)
        
        IBM().hostRequest(type: "INQUIRY", param: param, completionClosure: {
            (str, json,err) in
            if err != nil {
                DispatchQueue.main.async {
                    //アラートを表示
                    let alert = UIAlertController(title: "エラー", message: err?.localizedDescription, preferredStyle: .alert)
                    //ボタン追加
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:nil))
                    print("err no nil")
                    self.present(alert,animated: true,completion:nil)
                }
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
                    
                    DispatchQueue.main.async {
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
        inq_PRODUCT_SN = json["PRODUCT_SN"]! as? String
        
        inq_SYAIN_CD = json["SYAIN_CD"]! as? String
        inq_SYAIN_NM = json["SYAIN_NM"]! as? String
        inq_LOCAT_CD = json["LOCAT_CD"]! as? String
        inq_LOCAT_NM = json["LOCAT_NM"]! as? String
        inq_SYOHIN_CD = json["SYOHIN_CD"]! as? String
        inq_SYOHIN_NM = json["SYOHIN_NM"]! as? String
        
        inq_ORDER_SPEC = json["ORDER_SPEC"]! as? String
        inq_CUSTOMER_NM = json["CUSTOMER_NM"]! as? String
        tourokuDate = String(describing: json["ENTRY_DATE"]!)
        str = "製造番号: \(inq_PRODUCT_SN!)\n" +
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
        let param = ["PRODUCT_SN":inq_PRODUCT_SN!]
        
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
                    //print(json!)
                    let json_ = json!
                    if json_["RTNCD"] as! String == "000" {
                        SimpleAlert.make(title: "削除完了", message: "")

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
            })
        }))
    
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(alert,animated: true)
        
    }
    
    @objc func delChk() {
        
        //Notificationを解除しておく
        NotificationCenter.default.removeObserver(self)
        //print(inquiryJson_)
        if IBMResponse {
            //エラーの時はエラーメッセージを表示
            if(inquiryJson_["RTNCD"] as! String != "000"){
                let rtnMSG = inquiryJson_["RTNMSG"]!
                var errMSG:String? = ""
                //エラーメッセージの内容を抽出
                for val in rtnMSG as! NSArray{
                    errMSG = errMSG?.appending("\n\(val)")
                }
                
                let alert = UIAlertController(title: "登録エラー", message: errMSG, preferredStyle: .alert)
                //ボタン追加
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{
                    (action) -> Void in
                    inquiryJson_ = nil
                    
                }))
                
                //アラートを表示
                self.present(alert,animated: true,completion:nil)
                
            }else{
                //削除成功
                //MARK: - 削除したらenrolltypeを変更

                let entry = EntryDataBase(db: _db!)
                entry.changeStatus(serial:self.inq_PRODUCT_SN!, type: "delete", msg: "削除完了")
                
                
                let alert = UIAlertController(title: "削除しました", message: nil, preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{
                    (action) -> Void in
                    inquiryJson_ = nil
                    self.rtnData.text = ""
                    self.delButton.isEnabled = false
                    self.delButton.setTitleTextAttributes(self.notDelete, for: .normal)
                    
                }))
                
                //アラートを表示
                self.present(alert,animated: true,completion:nil)
                
            }
        }else {
            let alert = UIAlertController(title: "ホストから応答がありません", message: "接続を確認してください", preferredStyle: .alert)
            //ボタン追加
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler:{
                (action) -> Void in
                inquiryJson_ = nil
                
            }))
            
            //アラートを表示
            self.present(alert,animated: true,completion:nil)
        }
        
    }
    

}
