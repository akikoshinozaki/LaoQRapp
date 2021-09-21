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
//    @IBOutlet weak var inputBtn: UIButton!
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
        versionLabel.text = "Ver. " + appVersion
        //ロケーションを取得しておく
        //locateList()
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
        var storyboard:UIStoryboard!
        switch sender {
        case enroll:
            next = "enroll"
        case inquiry:
            next = "inquiry"
        case listBtn:
            next = "ssList"
//        case inputBtn:
//            next = "input"
        default:
            break
        }
        
        if is_iPhone {
            //iPhoneの時
            storyboard = UIStoryboard(name: "Main2", bundle: nil)
        }else {
            //iPadの時
            storyboard = UIStoryboard(name: "Main", bundle: nil)
        }

        let nextVC = storyboard.instantiateViewController(withIdentifier: next)
        self.navigationController?.pushViewController(nextVC, animated: true)

    }
    
    @IBAction func dataUpdate(_ sender: Any) {
        DL.dataDL()
    }
}

extension ViewController {
    /*
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
                    //print(locateArr_)
                }else {
                    //IBMから帰ってきた値がエラーだった時
                    let rtnMSG = json!["RTNMSG"] as? [String] ?? []
                    let errMsg =  errMsgFromIBM(rtnMSG: rtnMSG)
                    SimpleAlert.make(title: "ロケーション取得エラー", message: errMsg)
                    locateArr_ = defaultLocate
                }
                
            }else {
                SimpleAlert.make(title: "ロケーション取得エラー", message: err?.localizedDescription)
                locateArr_ = defaultLocate
            }
        })
    }
    */
}

