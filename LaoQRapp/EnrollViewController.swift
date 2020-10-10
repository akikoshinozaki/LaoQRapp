//
//  EnrollViewController.swift
//  LaoQRapp
//
//  Created by administrator on 2020/10/02.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//


import UIKit
import AVFoundation
import ZBarSDK

class EnrollViewController:  UIViewController, ZBarReaderDelegate, UINavigationControllerDelegate, SettingViewDelegate, QRScannerViewDelegate {
    
    @IBOutlet var ZBarScanButton: UIButton!
    @IBOutlet var QRScanButton: UIButton!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var syainLabel: UILabel!
    @IBOutlet var itemDataLabel: UILabel!
    @IBOutlet var serialDataLabel: UILabel!
    //@IBOutlet weak var label1: UILabel!
    @IBOutlet weak var settingBtn: UIButton!
    //@IBOutlet weak var dbBtn: UIButton!
    @IBOutlet weak var step3View: UIView!
    var qrScanner:QRScannerView!
    
    let apd = UIApplication.shared.delegate as! AppDelegate
    var cautionLabel:UILabel! = UILabel(frame: CGRect(x: 0, y: 0, width: 250, height: 250))
    var nextButton_ : UIBarButtonItem!
    var backButton_ : UIBarButtonItem!
    //キーボードアクセサリ
    var toolBar:UIToolbar!
    var nextFieldBtn:UIButton!
    var backFieldBtn:UIButton!
    var activeField:UITextField!

//    var scrollView:UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet var fields:[UITextField]!
    @IBOutlet var views:[UIView]!
    
    @IBOutlet weak var UVField:UITextField!
    @IBOutlet weak var UHField:UITextField!
    @IBOutlet weak var LVField:UITextField!
    @IBOutlet weak var LHField:UITextField!
    @IBOutlet weak var WTField:UITextField!
    @IBOutlet weak var HTField:UITextField!
    
    
    
    var serialNO:String = ""
    var orderStr:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        apd.enrollVC = self

        step3View.isHidden = true
        
        backButton_ = UIBarButtonItem(title: "＜ 戻る", style: .plain, target: self, action: #selector(self.goToMenu))
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "登録"
        navigationItem.leftBarButtonItem = backButton_

        
        settingBtn.layer.borderWidth = 2
        settingBtn.layer.borderColor = standardBlue_.cgColor
        settingBtn.layer.cornerRadius = 8
        settingBtn.titleLabel?.numberOfLines = 0
        
        for field in fields {
            field.delegate = self
        }
        
        for v in views {
            v.layer.cornerRadius = 10
        }
        
        //キーボードのツールバーに表示するボタンの設定
        nextFieldBtn = UIButton(type: .custom)
        backFieldBtn = UIButton(type: .custom)
        
        let fieldBtns:[UIButton] = [nextFieldBtn, backFieldBtn]
        let images:[String] = ["arrow_next", "arrow_back"]
        
        for (i,btn) in fieldBtns.enumerated() {
            btn.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            btn.addTarget(self, action: #selector(moveField(_:)), for: .touchUpInside)
            btn.tag = 998+i
            btn.setImage(UIImage(contentsOfFile: Bundle.main.path(forResource: images[i], ofType: "png")!), for: .normal)
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        //self.btnSetting(isEnabled:isHostConnected)
        setUserDefaults()
        //QRdata選択済みだったらラベルに表示する
        setData()
    }
    
//    func btnSetting(isEnabled:Bool) {
//        nextButton_.isEnabled = isEnabled
//    }
    
    func setData(){
        print(itemCD_)
        var str = ""
        if itemCD_ != "" {
            
            if itemName_ != "" {
                if CUSTOMER_NM != "" {
                    itemDataLabel.text = "\(UKE_CDD!) :\(itemName_)\n\(CUSTOMER_NM!) 様\n\(ORDER_SPEC!)"
                }else{
                    str = "\(UKE_CDD!) :\(itemName_)"
                }
            }else{
                str = itemCD_
            }
        }else {
            str = ""
        }
        
        DispatchQueue.main.async {
            self.itemDataLabel.text = str
            self.step3View.isHidden = (itemCD_ == "")
            
        }
    }
    
    
    //MARK: -SettingViewDelegate
    func removeView() {
        setUserDefaults()
        backButton_.isEnabled = true
        //nextButton_.isEnabled = true
    }
    
    func cancelLocation() {
        backButton_.isEnabled = true
        //nextButton_.isEnabled = true
    }
    
    func setUserDefaults(){
        //社員CDとロケーションをユーザーデフォルトから取得
        syainCD_ = defaults.value(forKey: "syainCD") as? String ?? ""
        syainName_ = defaults.value(forKey: "syainName") as? String ?? ""
        locateCD_ = defaults.value(forKey: "locateCD") as? String ?? ""
        locateName_ = defaults.value(forKey: "locateName") as? String ?? ""
        
        locationLabel.text = "\(locateName_)"
        syainLabel.text = "\(syainCD_) \(syainName_)"
    }
        

    @IBAction func tapSetting(_ sender: UIButton) {
        let setting = SettingView(frame: self.view.frame)
        setting.delegate = self
        backButton_.isEnabled = false
        //nextButton_.isEnabled = false
        setting.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        self.view.addSubview(setting)

    }
    
    func reset() {
        //取得したデータを初期化
        syainCD_ = ""
        syainName_ = ""
        itemCD_ = ""
        itemName_ = ""
        UKE_TYPE = ""
        UKE_CDD = ""
        SYOHIN_CD = ""
        CUSTOMER_NM = ""
        ORDER_SPEC = ""

    }
    

    
    @objc func goToMenu() {
        let alert = UIAlertController(title: "入力内容を破棄して\n前のページに戻りますか？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action) in
            //取得したデータを初期化
            self.reset()
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //次へボタンを押した時の処理
    @objc func tapNextButton() {
        //シリアル番号スキャン画面に遷移する処理
        let nilCheck = ["社員CD":syainCD_,"製造場所":locateCD_,"商品CD":itemCD_]
        var errMSG:String = ""
        
        for val in nilCheck {
            if(val.value == ""){
                errMSG = errMSG.appending("\(val.key) ")
            }
            //print(errMSG)
        }
        
        if(errMSG == ""){
            let storyboard: UIStoryboard = self.storyboard!
            let serial = storyboard.instantiateViewController(withIdentifier: "serial")
            self.navigationController?.pushViewController(serial, animated: true)
        }else{
            let alert = UIAlertController(title: "未入力の項目があります", message: "\(errMSG)を入力してください", preferredStyle: .alert)
            //ボタン1
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            //アラートを表示
            self.present(alert,animated: true,completion:nil)
        }
    }
    /*
    @IBAction func tapQRScan(_ sender: UIButton) {
        //どのボタンを押したのか判別するためにタグを登録
        buttonTag_ = sender.tag
        //社員CD入力フィールドを空白にする
        //inputSyainCD.text = ""
        let storyboard: UIStoryboard = self.storyboard!
        let scan = storyboard.instantiateViewController(withIdentifier: "scan")
        scan.modalPresentationStyle = .fullScreen
        self.present(scan, animated: true, completion: nil)
    }
    */
    //スキャンボタンを押した時の処理(zbar)
    @IBAction func tapScanButton(_ sender: UIButton) {
        
        let addView:UIView! = UIView(frame: self.view.frame)
        addView.backgroundColor = UIColor.clear
        let label2:UILabel! = UILabel(frame: CGRect(x: 0, y: 0, width: addView.frame.width, height: 25))
        
        label2.backgroundColor = standardBlue_
        label2.text = "商品CDをスキャンしてください"
        label2.textColor = UIColor .white
        label2.textAlignment = .center
        label2.font = UIFont.boldSystemFont(ofSize: 20)
        
        addView.addSubview(label2)
        
        //ビューに重ねるラベルの定義
        cautionLabel.frame = CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: 60)
        cautionLabel.textColor = UIColor .yellow
        cautionLabel.textAlignment = .center
        cautionLabel.numberOfLines = 2
        cautionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cautionLabel.backgroundColor = UIColor .clear
        cautionLabel.text = "プライスカードのバーコード\nを読み取ってください"
        cautionLabel.isHidden = true
        
        addView.addSubview(cautionLabel)
        
        //ZBarReaderViewControllerのオブジェクトを生成
        let reader = ZBarReaderViewController()
        reader.readerDelegate = self
        reader.cameraOverlayView = addView
        let scanner:ZBarImageScanner = reader.scanner
        scanner.setSymbology(ZBAR_I25, config: ZBAR_CFG_ENABLE, to: 0)

        reader.modalPresentationStyle = .fullScreen
//        if #available(iOS 13.0, *) {
//            reader.isModalInPresentation = true
//        }
        
        self.present(reader, animated: true, completion: nil)
        reader.showsZBarControls = false
        reader.showsCameraControls = false
        
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height-44, width: self.view.frame.size.width, height: 44))
        let cancelButton = UIBarButtonItem(title: "キャンセル", style: .plain, target: self, action: #selector(self.cancelButtonTapped))
        toolbar.items = [cancelButton]
        addView.addSubview(toolbar)
        
    }
    
    @objc func cancelButtonTapped(){
        dismiss(animated: true, completion: nil)
    }
 
    //バーコードを読み取った後の処理(ZBar)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        //let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        var symbol : ZBarSymbol? = nil
        if let symbolset = info[UIImagePickerController.InfoKey(rawValue: "ZBarReaderControllerResults")] as? ZBarSymbolSet {
            print(symbolset)
            var iterator = NSFastEnumerationIterator(symbolset)
            
            while let value = iterator.next() {
                //print(value)
                if let sym = value as? ZBarSymbol {
                    symbol = sym
                    break
                }
            }
        }
        
        if symbol == nil {
            return
        }
        let resultString = symbol!.data as String
        //print(resultString)
        //商品コードを読み込んだらresultStringに格納
        if(symbol!.typeName! == "EAN-13"){
            self.readJANCode(result: resultString)
        }
        
    }
    
    func readItem(result:String) {
        itemName_ = ""
        itemCD_ = result
        
        let param = ["UKE_CD":itemCD_]
        IBM().hostRequest(type: "ENTCHK", param: param, completionClosure: {
            (str, json,err) in
            if err != nil {
                //エラーの処理
                let action = UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    self.dismiss(animated: true, completion: nil)
                })
                SimpleAlert.make(title: "エラー", message: err?.localizedDescription, action: [action])
                return
            }
            
            if json != nil {
                print(json!)
                let json_ = json!
                
                if json!["RTNCD"] as! String == "000" {
                    itemName_ = json_["SYOHIN_NM"]! as! String
                    ORDER_SPEC = json_["ORDER_SPEC"]! as? String
                    UKE_TYPE = json_["UKE_TYPE"]! as? String
                    UKE_CDD = json_["UKE_CDD"]! as? String
                    CUSTOMER_NM = json_["CUSTOMER_NM"]! as? String
                    SYOHIN_CD = json_["SYOHIN_CD"]! as? String
                    
                    self.setData()
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                    
                }else {
                    //IBMからエラー戻り
                    print(json_["RTNMSG"] as? [String] ?? [])
                    var errStr =  ""
                    for err in json_["RTNMSG"] as? [String] ?? [] {
                        errStr += err+"\n"
                    }
                    //print(errStr)
                    
                    let action = UIAlertAction(title: "OK", style: .default, handler: {
                        Void in
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                    SimpleAlert.make(title: "エラー", message: errStr, action: [action])
                }
            }
        })
    }

    func readJANCode(result:String){
        //print(resultString)
        cautionLabel.isHidden = true
        //読み込んだコードがプライスカードの書式かどうかチェックする(1,5,6文字目が「2,0,0」)
        let strArr = Array(result).map{String($0)}
        let check = strArr[0]+strArr[4]+strArr[5]
        print(check)
        
        if check == "200" || result.hasPrefix("2300") {
            //check:200 生産品, result:2300 リフレッシュのTAG
            AudioServicesPlaySystemSound(1106)
            AudioServicesPlaySystemSound(4095) //バイブ(iPhoneのみ)
            itemName_ = ""
            itemCD_ = result

            let param = ["UKE_CD":itemCD_]
            IBM().hostRequest(type: "ENTCHK", param: param, completionClosure: {
                (str, json,err) in
                if err != nil {
                    //エラーの処理
                    let action = UIAlertAction(title: "OK", style: .default, handler: {
                        Void in
                        self.dismiss(animated: true, completion: nil)
                    })
                    SimpleAlert.make(title: "エラー", message: err?.localizedDescription, action: [action])
                    return
                }
                
                if json != nil {
                    print(json!)
                    let json_ = json!

                    if json!["RTNCD"] as! String == "000" {
                        itemName_ = json_["SYOHIN_NM"]! as! String
                        ORDER_SPEC = json_["ORDER_SPEC"]! as? String
                        UKE_TYPE = json_["UKE_TYPE"]! as? String
                        UKE_CDD = json_["UKE_CDD"]! as? String
                        CUSTOMER_NM = json_["CUSTOMER_NM"]! as? String
                        SYOHIN_CD = json_["SYOHIN_CD"]! as? String
                        
                        self.setData()
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        
                    }else {
                        //IBMからエラー戻り
                        print(json_["RTNMSG"] as? [String] ?? [])
                        var errStr =  ""
                        for err in json_["RTNMSG"] as? [String] ?? [] {
                            errStr += err+"\n"
                        }
                        //print(errStr)
                        
                        let action = UIAlertAction(title: "OK", style: .default, handler: {
                            Void in
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                        SimpleAlert.make(title: "エラー", message: errStr, action: [action])
                    }
                }
            })
            
        }else{
            cautionLabel.text = "このバーコードは認識できません"
            cautionLabel.isHidden = false
        }
    }
    
    
    //MARK: - SerialInput
    @IBAction func showScanView(_ sender: Any) {
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
    
    func getData(type:String, data: String) {
        if type == "EAN13" {
            self.readJANCode(result: data)
        }else if type == "QR" {
            print(data)
            for field in fields {
                field.text = ""
            }
            //QRチェック
            let param = ["PRODUCT_SN":data]
            IBM().hostRequest(type: "INQUIRY", param: param, completionClosure: {
                (str, json,err) in
                if err != nil {
                    //エラーの処理
                    let action = UIAlertAction(title: "OK", style: .default, handler: {
                        Void in
                        self.dismiss(animated: true, completion: nil)
                    })
                    SimpleAlert.make(title: "エラー", message: err?.localizedDescription, action: [action])
                    return
                }
                
                if json != nil {
                    print(json!)
                    let json_ = json!
                    self.serialNO = ""
                    if json!["RTNCD"] as? String == "000" {
                        self.serialNO = data
                        if let order = json_["ORDER_SPEC"] as? String {
                            //ORDER_SPECの有無を確認
                            print(order)
                            self.qrInquiry(order: order)
                        }
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }else {
                        //IBMからエラー戻り
                        //                    print(json_["RTNMSG"] as? [String] ?? [])
                        var errStr =  ""
                        for err in json_["RTNMSG"] as? [String] ?? [] {
                            errStr += err+"\n"
                        }
                        
                        if errStr.contains("E0043") {
                            //E0043:未登録エラーはそのまま新規登録
                            self.serialNO = data
                            
                        }else {
                            //E0043:未登録エラー 以外はアラート表示
                            let action = UIAlertAction(title: "OK", style: .default, handler: {
                                Void in
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            })
                            SimpleAlert.make(title: "エラー", message: errStr, action: [action])
                        }
                    }
                    DispatchQueue.main.async {
                        self.serialDataLabel.text = self.serialNO
                    }
                    
                }
            })
        }
    }
    
    //MARK:-シリアル読み取った後の処理
    //serialNoを抽出できたら、登録
    
    func qrInquiry(order:String){
        //type:"insert" or "update"
        if order != "" {
            
            //UPDATE
            let arr = order.components(separatedBy: ";")
            print(arr)
            var dic:Dictionary<String, String> = [:]
            for val in arr {
                if val.contains("="){
                    let v = val.components(separatedBy: "=")
                    print(v)
                    dic[v[0]] = v[1]
                }
            }
            
            DispatchQueue.main.async {
                if let UV = dic["UV"] { self.UVField.text = UV }
                if let UH = dic["UH"] { self.UHField.text = UH }
                if let LV = dic["LV"] { self.LVField.text = LV }
                if let LH = dic["LH"] { self.LHField.text = LH }
                if let WT = dic["WT"] { self.WTField.text = WT }
                if let HT = dic["HT"] { self.HTField.text = HT }

            }

        }
    }
    
    @IBAction func postToIBM(_ sender:UIButton){
        self.view.endEditing(true)
        if serialNO == "" {
            SimpleAlert.make(title: "シリアル番号を読み取れません", message: "")
            return
        }
        orderStr = "UV=\(UVField.text!);" +
            "UH=\(UHField.text!);" +
            "LV=\(LVField.text!);" +
            "LH=\(LHField.text!);" +
            "WT=\(WTField.text!);" +
            "HT=\(HTField.text!)"
        
        print(orderStr)
        
        let param:[String:Any] = [
            "SYAIN_CD":syainCD_,
            "LOCAT_CD":locateCD_,
            "UKE_CD":itemCD_,
            "PRODUCT_SN":serialNO,
            "ORDER_SPEC":orderStr
        ]
        
        let alert = UIAlertController(title: "登録してよろしいですか", message: "S/N:\(serialNO)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            Void in
            IBM().hostRequest(type: "ENTRY", param: param, completionClosure: {
                (str, json,err) in
                if err != nil {
                    //エラーの処理
                    let action = UIAlertAction(title: "OK", style: .default, handler: {
                        Void in
                        //self.dismiss(animated: true, completion: nil)
                    })
                    SimpleAlert.make(title: "エラー", message: err?.localizedDescription, action: [action])
                    return
                }
                
                if json != nil {
                    print(json!)
                    let json_ = json!

                    if json!["RTNCD"] as! String == "000" {
                        DispatchQueue.main.async {
                        //スプレッドシート登録
                        self.postSS()
                        //FMDB登録
                        
                        
                        //登録完了
                        
                            let alert = UIAlertController(title: "登録完了", message: "", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                Void in
                                //データリセット
                                self.resetQR()
                            }))
                        
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }else {
                        //IBMからエラー戻り
                        print(json_["RTNMSG"] as? [String] ?? [])
                        var errStr =  ""
                        for err in json_["RTNMSG"] as? [String] ?? [] {
                            errStr += err+"\n"
                        }
                        //print(errStr)
                        
                        let action = UIAlertAction(title: "OK", style: .default, handler: {
                            Void in
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: nil)
                            }
                        })
                        SimpleAlert.make(title: "エラー", message: errStr, action: [action])
                    }
                }
            })
                        
        }))
        alert.addAction(UIAlertAction(title: "やり直す", style: .cancel, handler: nil))
        //アラートを表示
        self.present(alert,animated: true)
 
    }
    
    var postAlert:UIAlertController!
    func postSS(){
        //登録
        sheetId = "1Ps2oJPkjXp0F2VDEG-39H-DSJD1AFjB6Lhuka3vJu6w"
        sheetName = "detail"
        
        //新規登録
        postAlert = UIAlertController(title: "データ登録中", message: "", preferredStyle: .alert)
        self.present(postAlert, animated: true, completion: nil)
        
        let param = [
            "sheetid":sheetId,
            "sheetName":sheetName,
            "operation":"input",
            "loc":locateCD_,
            "itemCD":SYOHIN_CD,
            "itemName":itemName_,
            "uv":UVField.text!,
            "uh":UHField.text!,
            "lv":LVField.text!,
            "lh":LHField.text!,
            "wt":WTField.text!,
            "ht":HTField.text!,
            "serial":serialNO,
            "staff":syainCD_,
            "device":iPadName,
            "date":Date().entryDate
        ]

        var request = URLRequest(url: URL(string: apiUrl)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 20.0
        let session = URLSession(configuration: config)
        
        do{
            request.httpBody = try JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)
            
            let task = session.dataTask(with: request as URLRequest, completionHandler: {(data,response,err) -> Void in
                var str1 = ""
                var str2 = ""
                if err == nil {
                    if data != nil {
                        do{
                            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary ?? [:]
                            print(json)
                            let status = json["status"] as? String ?? ""
                            let rtnMsg = json["rtnMsg"] as? String ?? ""
                            let error = json["error"] as? String ?? ""
                            print(rtnMsg)
                            print(error)
                            
                            if status == "success" { //登録成功
                                str1 = "正常に登録できました"
                                self.resetQR()
//                                self.dbUpdate()
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
            }
            
            return
            
        }
        
    }
    
    func resetQR() {
        ORDER_SPEC = ""
        serialNO = ""
        orderStr = ""
        
        DispatchQueue.main.async {
            self.serialDataLabel.text = ""
            for field in self.fields {
                field.text = ""
            }
        }
    }

    
}

extension EnrollViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        activeField = textField
        // UIToolBarの設定
        toolBar = UIToolbar(frame: CGRect(x: 0, y: self.view.frame.size.height/6, width: self.view.frame.size.width, height: 40.0))
        toolBar.layer.position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-20.0)
        
        let doneBtn = UIBarButtonItem(title: "完了", style: .plain, target: self, action: #selector(keyboardCommit))
        
        let backBtn = UIBarButtonItem(customView: backFieldBtn)
        let nxtBtn = UIBarButtonItem(customView: nextFieldBtn)
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        //toolBar.items = [backBtn,nxtBtn, flexSpace]
        toolBar.items = [backBtn,nxtBtn, flexSpace, doneBtn]
        textField.inputAccessoryView = toolBar
        
        let tag = textField.tag
        if self.view.viewWithTag(tag+1) == nil {
            nxtBtn.isEnabled = false
        }
        if self.view.viewWithTag(tag-1) == nil {
            backBtn.isEnabled = false
        }
        
        return true
    }
    
    @objc func moveField(_ sender:UIButton) {
        print(sender.tag)
        
        let tag = activeField.tag
        var next:Int = 0
        if sender.tag == 999 {
            next = activeField.tag - 1
        }else {
            next = activeField.tag + 1
        }
        print(tag)
        if let move = self.view.viewWithTag(next) {
            move.becomeFirstResponder()
        }
        
    }
    
    @objc func keyboardCommit(){
        self.view.endEditing(true)
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //tag...201:UV, 202:UH, 203:LV, 204:LH, 205:WT, 206:HT
        if textField.text! == "" {return}
        
        if Double(textField.text!) == nil {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "入力エラー", message: "使用できない文字が入力されています", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                    Void in
                    textField.text = ""
                }))
                
                
                self.present(alert, animated: true, completion: nil)
            }
        }

        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    
}

