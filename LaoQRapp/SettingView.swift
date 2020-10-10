//
//  SettingView.swift
//  QRReader
//
//  Created by administrator on 2020/06/25.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

protocol SettingViewDelegate{
    func removeView()
    func cancelLocation()
}
var locationString = ""

class SettingView: UIView, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    var delegate:SettingViewDelegate?

    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var syainLabel: UILabel!
    @IBOutlet weak var syainCDField: UITextField!
    let ud = UserDefaults.standard
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        cancelBtn.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        closeBtn.addTarget(self, action: #selector(closeView), for: .touchUpInside)

        baseView.layer.cornerRadius = 10
        baseView.clipsToBounds = true
        
        syainCDField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        self.setLocation()
        if locateArr_.count == 0 {
            locateArr_ = defaultLocate
        }
        
        tableView.reloadData()
        
        /* 数字キーボードにEnterキーがないので、完了項目をツールバーに設置 */
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 40))
        kbToolBar.barStyle = UIBarStyle.default  // スタイルを設定
        kbToolBar.sizeToFit()  // 画面幅に合わせてサイズを変更
        
        // スペーサー
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        // 完了ボタン
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(self.keyboardCommitButton))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(self.keyboardCancelButton))
        
        kbToolBar.items = [cancelButton,spacer, commitButton]
        
        syainCDField.inputAccessoryView = kbToolBar
    }
    
    //コードから生成したときに通る初期化処理
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibInit()
    }
    
    // ストーリーボードで配置した時の初期化処理
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibInit()
    }
    
    // xibファイルを読み込んでviewに重ねる
    fileprivate func nibInit() {
        // File's OwnerをXibViewにしたので ownerはself になる
        guard let view = UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        view.frame = self.bounds
        self.addSubview(view)
        
    }

    
    func setLocation() {
        //社員CDとロケーションをユーザーデフォルトから取得
        syainCD_ = ud.value(forKey: "syainCD") as? String ?? ""
        syainName_ = ud.value(forKey: "syainName") as? String ?? ""
        locateCD_ = ud.value(forKey: "locateCD") as? String ?? ""
        locateName_ = ud.value(forKey: "locateName") as? String ?? ""
        
        locationLabel.text = " 製造場所：\(locateName_)"
        syainCDField.text = "\(syainCD_)"
        syainLabel.text = " \(syainName_)"
    }
    
    //MARK: -TableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locateArr_.count
    }
    
    //セクションタイトルを返す
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "製造場所を選択"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        //セルの設定
        let key = locateArr_[indexPath.row].0
        let value = locateArr_[indexPath.row].1
        cell.textLabel?.text = "\(key) \(value)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        locateCD_ = locateArr_[indexPath.row].0
        locateName_ = locateArr_[indexPath.row].1
        locationLabel.text = " 製造場所：\(locateName_)"
        
    }
    
    @objc func closeView() {
        //閉じる時に、場所と社員をセット
        if syainCD_ == "" {
            SimpleAlert.make(title: "社員が選択されていません", message: nil)
        }else {
            self.ud.set(syainCD_, forKey: "syainCD")
            self.ud.set(syainName_, forKey: "syainName")
            self.ud.set(locateCD_, forKey: "locateCD")
            self.ud.set(locateName_, forKey: "locateName")
            delegate?.removeView()
            self.removeFromSuperview()

        }
    }
    
    @objc func cancel() {
        delegate?.cancelLocation()
        self.removeFromSuperview()
    }
    
  //MARK: -TextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        self.keyboardCommitButton()
        return true
    }
    
    //キーボードのcancelボタンを押した時の処理
    @objc func keyboardCancelButton(){
        self.syainCDField.resignFirstResponder()
    }
    
    //自作した完了ボタンを押した時の処理
    @objc func keyboardCommitButton (){
        //5桁の数字が入力されたら、社員CDと認識
        syainLabel.text = ""
        syainCD_ = ""
        if(syainCDField.text?.count == 5){
            IBM().entCHK(param: "SYAIN_CD", value: syainCDField.text!)
            //urlSessionでデータ受信が完了したら通知を受け取る
            NotificationCenter.default.addObserver(self, selector: #selector(self.searchName), name: Notification.Name(rawValue:"loadJSON"), object: nil)
            syainCD_ = syainCDField.text!
        }else{
            //OKボタン　一旦入力項目をクリアする
            let action = UIAlertAction(title: "OK", style: .default, handler:{(action) -> Void in
                self.syainCDField.text = ""
                self.syainLabel.text = ""
            })

            //アラートを表示
            SimpleAlert.make(title: "社員CDエラー", message: "5桁の社員CDを入力してください", action: [action])
        }
        
        self.endEditing(true)
    }
    
    //textFieldに入力された社員CDから社員名を取得
    @objc func searchName() {
        //Notificationを解除しておく
        NotificationCenter.default.removeObserver(self)
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
            if IBMResponse {
                
                let rtnCD:String = json_["RTNCD"]! as! String
                let rtnMSG = json_["RTNMSG"]!
                var errMSG:String? = ""
                
                if(rtnCD == "000"){
                    syainName_ = (json_["SYAIN_NM"]! as? String)!
                    self.syainLabel.text = " \(syainName_)"
                    
                    return
                }else{ //IBMから帰ってきた値がエラーだった時
                    //エラーメッセージの内容を抽出
                    for val in rtnMSG as! NSArray{
                        errMSG = errMSG?.appending("\n\(val)")
                    }
                    //アラートを表示
                    alert.title = "社員CD取得エラー"
                    alert.message = errMSG!
                    //AppDelegateのsyainCDを削除
                    syainCD_ = ""
                    self.syainLabel.text = ""
                }
            }else{
                //IBMからのレスポンスがなかったら
                alert.title =  "ホストから応答がありません"
                alert.message = "接続を確認してください"
            }
            //エラーメッセージ表示
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            SimpleAlert.getTopViewController()!.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
}
