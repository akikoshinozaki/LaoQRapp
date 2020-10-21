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

var btnID:Int = 0
class EnrollViewController:  UIViewController, ZBarReaderDelegate, UINavigationControllerDelegate, QRScannerViewDelegate {
    
    @IBOutlet var ZBarScanButton: UIButton!
    @IBOutlet var QRScanButton: UIButton!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var syainLabel: UILabel!
    @IBOutlet var itemDataLabel: UILabel!
    @IBOutlet var serialDataLabel: UILabel!
    //@IBOutlet weak var label1: UILabel!
    @IBOutlet weak var settingBtn: UIButton!
    //@IBOutlet weak var dbBtn: UIButton!
    @IBOutlet weak var step4View: UIView!
    @IBOutlet weak var enrollBtn: UIButton!
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

    @IBOutlet weak var syainField: UITextField!
    @IBOutlet weak var itemField: UITextField!
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
    
    @IBOutlet weak var selectBtn: UIButton!
    @IBOutlet weak var sheetLabel: UILabel!
    var postAlert:UIAlertController!

    var serialNO:String = ""
    //var orderStr:String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        apd.enrollVC = self

        step4View.isHidden = true
        
        backButton_ = UIBarButtonItem(title: "＜Back(ກັບຄືນໄປບ່ອນ)", style: .plain, target: self, action: #selector(self.goToMenu))
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.title = "ລົງທະບຽນ/登　録"
        navigationItem.leftBarButtonItem = backButton_
        let btns:[UIButton] = [selectBtn,settingBtn,enrollBtn]
        
        for btn in btns {
            btn.layer.cornerRadius = 8
            btn.titleLabel?.numberOfLines = 0
        }
        
        for field in fields {
            field.delegate = self
        }
        syainField.delegate = self
        itemField.delegate = self
        
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
        
        self.setLocation()
        if locateArr_.count == 0 {
            locateArr_ = defaultLocate
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //QRdata選択済みだったらラベルに表示する
        setData()
    }
    
    func setLocation() {
        //社員CDとロケーションをユーザーデフォルトから取得
        syainCD_ = defaults.value(forKey: "syainCD") as? String ?? ""
        ibmUser = syainCD_
        if ibmUser.count == 6, syainCD_.hasPrefix("14") {
            ibmUser = ibmUser.replacingOccurrences(of: "14", with: "L")
        }
        syainName_ = defaults.value(forKey: "syainName") as? String ?? ""
        locateCD_ = defaults.value(forKey: "locateCD") as? String ?? ""
        locateName_ = defaults.value(forKey: "locateName") as? String ?? ""
        
        locationLabel.text = " "+locateName_
        syainLabel.text = " \(syainCD_): \(syainName_)"
    }

    
    func btnSetting(isEnabled:Bool) {
        backButton_.isEnabled = isEnabled
        enrollBtn.isEnabled = isEnabled
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
                    DispatchQueue.main.async {
                        self.sheetLabel.text = fileName
                    }
                    
                }))
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            DispatchQueue.main.async {
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    func setData(){ //バーコードをスキャンして、取得した情報をセット
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
            self.step4View.isHidden = (itemCD_ == "")
            
        }
    }
    
    
    //MARK: -SettingViewDelegate
    func removeView() {
        print(#function)
        //setUserDefaults()
        btnSetting(isEnabled: true)
    }
    
    func cancelLocation() {
        btnSetting(isEnabled: true)
    }
    
    @IBAction func selectLocation(_ sender: UIButton) {
        let alert = UIAlertController(title: "ກະລຸນາເລືອກສະຖານທີ່", message: "場所を選択してください", preferredStyle: .alert)
        for loc in locateArr_ {
            alert.addAction(UIAlertAction(title: loc.0+":"+loc.1, style: .default, handler: {
                Void in
                locateCD_ = loc.0
                locateName_ = loc.1
                //ユーザーデフォルトにセット
                defaults.set(locateCD_, forKey: "locateCD")
                defaults.set(locateName_, forKey: "locateName")
                DispatchQueue.main.async {
                    self.locationLabel.text = locateName_
                }
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func reset() {
        //取得したデータを初期化
        syainCD_ = ""
        syainName_ = ""
        ibmUser = ""
        itemCD_ = ""
        itemName_ = ""
        UKE_TYPE = ""
        UKE_CDD = ""
        SYOHIN_CD = ""
        CUSTOMER_NM = ""
        ORDER_SPEC = ""
        btnID = 0
        sheetId = ""
        sheetName = ""
        fileName = ""

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
    
    @objc func cancelButtonTapped(){
        dismiss(animated: true, completion: nil)
    }

    func readJANCode(result:String){
        //print(resultString)
        
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
                    //商品CDから商品名（英語表記）を取得
                    if let obj = itemArray.first(where: {$0.cd==UKE_CDD!}){
                        itemName_ = obj.name
                    }else {
                        itemName_ = json_["SYOHIN_NM"]! as! String
                    }
                    self.setData()
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }else {
                    //IBMからエラー戻り

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
    
    
    //MARK: - ScanView起動
    @IBAction func showScanView(_ sender: UIButton) {
        btnSetting(isEnabled: false)
        self.view.endEditing(true)
        btnID = sender.tag
        print(sender.tag)

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
        //QRコードを読んだ後の処理
        if type == "EAN13" {
            self.readJANCode(result: data)
        }else if type == "QR" {
            self.serialNO = data
            DispatchQueue.main.async {
                self.serialDataLabel.text = self.serialNO
            }
            /*
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
                        let rtnMSG = json_["RTNMSG"] as? [String] ?? []
                        let errStr =  errMsgFromIBM(rtnMSG: rtnMSG)
                        
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
             */
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
    
    @IBAction func postToSheet(_ sender:UIButton){
        self.view.endEditing(true)
        let errAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        errAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if sheetId == "" || sheetName == "" {
            DispatchQueue.main.async {
                errAlert.title = "ບໍ່ມີການຄັດເລືອກເອກະສານ"
                errAlert.message = "シートが選択されていません"
                self.present(errAlert, animated: true, completion: nil)
            }
            return
        }
        if serialNO == "" {
            DispatchQueue.main.async {
                errAlert.title = "ບໍ່ສາມາດອ່ານເລກ ລຳ ດັບ"
                errAlert.message = "シリアル番号を読み取れません"
                self.present(errAlert, animated: true, completion: nil)
            }
            return
        }

        let alert = UIAlertController(title: "ທ່ານຕ້ອງການລົງທະບຽນບໍ?\n登録してよろしいですか", message: "S/N:\(serialNO)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            Void in
            self.saveID()
            self.postSS()
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        //アラートを表示
        self.present(alert,animated: true)
 
    }
    
//    @IBAction func getSerial(_ sender:Any){
//        //MySQL().getID(serial: serialNO, completionClosure: {
//        MySQL().getID(serial: "123456789012345678", completionClosure: {
//            (str, json,err) in
//            if err == nil, json != nil {
//                print(json!)
//                let status = json!["status"] as? String ?? ""
//                if status == "success" {
//                    sheetId = json!["sheetID"] as? String ?? ""
//                    sheetName = json!["sheetName"] as? String ?? ""
//                    fileName = json!["fileName"] as? String ?? ""
//
//                }else {
//                    print(str!)
//                }
//            }
//        })
//    }
    
    func saveID(){
        let param:NSDictionary = [
            "serial":serialNO,
            "sheetID":sheetId,
            "sheetName":sheetName,
            "fileName":fileName,
            "staff":syainCD_,
            "date":Date().entryDate
        ]
        
        MySQL().insert(dic: param)
        
    }
    
    func postSS(){
        //登録
        postAlert = UIAlertController(title: "ຂໍ້ມູນ ກຳ ລັງລົງທະບຽນຢູ່", message: "データ登録中", preferredStyle: .alert)
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
        //orderStr = ""
        
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
        
        if textField.tag == 100 { //社員CDから社員名を取得
            syainLabel.text = ""
            syainCD_ = ""
            
            /*
             let str = textField.text!.uppercased()
             textField.text = str
            if str.count == 6, str.hasPrefix("14") {
                syainCD_ = str
                ibmUser = str.replacingOccurrences(of: "14", with: "L")
            }else if str.count == 5 {
                syainCD_ = str
                ibmUser = str
            }else {
                SimpleAlert.make(title: "桁数が正しくありません", message: "")
                textField.text = ""
            }
            
            if ibmUser.count == 5 {
                self.searchName()
            }*/
            
            if Int(textField.text!) != nil {
                let cd = textField.text!
                if cd.count == 6 {
                    self.searchName(cd:cd)
                }else {
                    SimpleAlert.make(title: "桁数が正しくありません", message: "")
                    textField.text = ""
                }
            }else {
                SimpleAlert.make(title: "数字で入力してください", message: "")
                textField.text = ""
            }
            
        }else if textField.tag == 101 { //商品CDから商品名を取得
            itemName_ = ""
            itemCD_ = ""
            let cd = textField.text!.uppercased()
            textField.text = cd
            self.searchItem(cd: cd)
            
        }else {
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
            
            print(textField.text!.count)
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    //textFieldに入力された社員CDから社員名を取得
    @objc func searchName(cd:String) {

        if let idx = employee.firstIndex(where: {$0.syainCD == cd}) {
            //print(idx)
            syainCD_ = employee[idx].syainCD
            syainName_ = employee[idx].name_en

            //ユーザーデフォルトにセット
            defaults.set(syainCD_, forKey: "syainCD")
            defaults.set(syainName_, forKey: "syainName")
            
        }else {
            SimpleAlert.make(title: "Error(ຂໍ້ຜິດພາດ)", message: "社員CDが存在しません".loStr)
            syainCD_ = ""
            syainName_ = ""
        }
        
        self.syainLabel.text = syainCD_+":"+syainName_
    }
    
    func searchItem(cd:String) {
        if let idx = itemArray.firstIndex(where: {$0.cd == cd}) {
            //print(idx)
            itemCD_ = itemArray[idx].cd
            itemName_ = itemArray[idx].name
           
        }else {
            SimpleAlert.make(title: "Error(ຂໍ້ຜິດພາດ)", message: "商品CDが存在しません".loStr)
            //print("cdが存在しません")
            itemCD_ = ""
            itemName_ = ""
        }
        
        DispatchQueue.main.async {
            self.itemDataLabel.text = "\(itemCD_) :\(itemName_)"
            self.step4View.isHidden = (itemCD_ == "")
        }
        
    }
    
}

extension EnrollViewController { //IBM関係のメソッド（後で使うかも・・・）
    /*
       @IBAction func postToIBM(_ sender:UIButton){
           self.view.endEditing(true)
           let errAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
           errAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           
           if sheetId == "" || sheetName == "" {
               DispatchQueue.main.async {
                   errAlert.title = "ບໍ່ມີການຄັດເລືອກເອກະສານ"
                   errAlert.message = "シートが選択されていません"
                   self.present(errAlert, animated: true, completion: nil)
               }
               return
           }
           if serialNO == "" {
               DispatchQueue.main.async {
                   errAlert.title = "ບໍ່ສາມາດອ່ານເລກ ລຳ ດັບ"
                   errAlert.message = "シリアル番号を読み取れません"
                   self.present(errAlert, animated: true, completion: nil)
               }
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
               "SYAIN_CD":ibmUser,
               "LOCAT_CD":locateCD_,
               "UKE_CD":itemCD_,
               "PRODUCT_SN":serialNO,
               "ORDER_SPEC":orderStr
           ]
           
           let alert = UIAlertController(title: "ທ່ານຕ້ອງການລົງທະບຽນບໍ?\n登録してよろしいですか", message: "S/N:\(serialNO)", preferredStyle: .alert)
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
                           
                               let alert = UIAlertController(title: "ລົງທະບຽນ ສຳ ເລັດ", message: "登録完了", preferredStyle: .alert)
                               alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {
                                   Void in
                                   //データリセット
                                   self.resetQR()
                               }))
                           
                               self.present(alert, animated: true, completion: nil)
                           }
                           
                       }else {
                           //IBMからエラー戻り
                           let rtnMSG = json_["RTNMSG"] as? [String] ?? []
                           let errStr =  errMsgFromIBM(rtnMSG: rtnMSG)
                           
                           let action = UIAlertAction(title: "OK", style: .default, handler: {
                               Void in
                               DispatchQueue.main.async {
                                   self.dismiss(animated: true, completion: nil)
                               }
                           })
                           SimpleAlert.make(title: "Error", message: errStr, action: [action])
                       }
                   }
               })
                           
           }))
           alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
           //アラートを表示
           self.present(alert,animated: true)
    
       }*/
}
