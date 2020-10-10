//
//  ViewController.swift
//  LaoQRapp
//
//  Created by administrator on 2020/10/02.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var enroll: UIButton!
    @IBOutlet weak var inquiry: UIButton!
    @IBOutlet weak var listBtn: UIButton!
    @IBOutlet weak var inputBtn: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet var buttons:[UIButton]!
    
    let apd = UIApplication.shared.delegate as! AppDelegate
    var DL_errMsg = ""

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        apd.firstVC = self
        
        for btn in buttons {
            btn.addTarget(self, action: #selector(goToNext(_:)), for: .touchUpInside)
            btn.titleLabel?.numberOfLines = 0
        }
        //アプリのバージョンを取得
        versionLabel.text = "Ver. " + bundleVersion
        
        //ロケーションを取得しておく
        locateList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        print(isHostConnected)
        self.btnSetting(isEnabled: isHostConnected)
    }
    
    func btnSetting(isEnabled:Bool){
        enroll.isEnabled = isEnabled
        inquiry.isEnabled = isEnabled
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @objc func goToNext(_ sender: UIButton) {
        //次のページへ遷移
        var next:String = ""
        switch sender {
        case enroll:
            next = "enroll"
        case inquiry:
            next = "inquiry"
        case listBtn:
            next = "ssList"
        case inputBtn:
            next = "input"
        default:
            break
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: next)
        self.navigationController?.pushViewController(nextVC, animated: true)

    }
    
    func ibmtest(){
        //let param = ["PRODUCT_SN":"000085610170440356"] //登録のあるもの
        let param = ["PRODUCT_SN":"000085610170440000"]  //登録エラー
        IBM().hostRequest(type: "INQUIRY", param: param, completionClosure: {
            (str, json,err) in
            if err == nil, json != nil {
                if json!["RTNCD"] as! String == "000" {
                    print(json!)
                    ORDER_SPEC = json!["ORDER_SPEC"] as? String ?? ""
                }else {
                    print(json!)
                }
            }
        })
        
    }
    
    func locateList() {
        IBM().hostRequest(type: "LOCAT_LST", param: [:], completionClosure: {
            (str, json,err) in
            if err == nil, json != nil {
                var locDic:[(String,String)] = []
                if json!["RTNCD"] as! String == "000" {
                    //locateListを登録
                    let locates = json!["LOCAT_LST"]! as! [NSDictionary]

                    for locate in locates {
                        let cd = locate.value(forKey: "LOCAT_CD") as! String
                        let nm = locate.value(forKey: "LOCAT_NM") as! String
                        if cd != "" && nm != ""{
                            locDic.append((cd,nm))
                        }
                    }
                    locateArr_ = locDic
//                    print(locateArr_)
                }else {
                    //IBMから帰ってきた値がエラーだった時
                    let errMsg = json!["RTNMSG"] as? String ?? ""
                    SimpleAlert.make(title: "ロケーション取得エラー", message: errMsg)
                    locateArr_ = defaultLocate
                }
                
            }else {
                SimpleAlert.make(title: "ロケーション取得エラー", message: err?.localizedDescription)
                locateArr_ = defaultLocate
            }
        })
    }
    
    @IBAction func dataUpdate(_ sender: Any) {
        let alert = UIAlertController(title: "データ更新中", message: "しばらくお待ちください", preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //アラートが出なくなるので、遅延処理を入れる
            
            self.DL_errMsg = ""
            
            for param in parameters{
                let data = DL.getCSV(parameter: param)
                self.DL_errMsg += data.err
            }
            
            if self.DL_errMsg == ""{
                //更新できたら最終更新日を変更
                defaults.set(Date().string, forKey: "lastDataDownload")
                //self.updateLabel()
                alert.dismiss(animated: true, completion: nil)
            }else {
                alert.title = "更新に失敗しました"
                alert.message = self.DL_errMsg
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            }
            
            DL.csvToArr()
            //tableView.reloadData()
        }
    }


}

