//
//  AppDelegate.swift
//  LaoQRapp
//
//  Created by administrator on 2020/10/02.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit
import CoreData
import FMDB
import LUKeychainAccess


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, HostConnectDelegate {

    var window: UIWindow?
    let hostName = "maru8ibm.maruhachi.co.jp"
    var firstVC:ViewController!
    var enrollVC:EnrollViewController!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /* FMDB変数 */
        if let dir = manager.urls(for: .documentDirectory, in: .userDomainMask).first{
            _path = dir.appendingPathComponent(dbName)
            _db = FMDatabase(url: _path)
            print("path: \(_path!)")

        }
        /* iPadNameとidfvを取得して保存 */
        #if targetEnvironment(simulator)//シュミレーターの場合
        iPadName = "PADE48"
        #else
        iPadName = UIDevice.current.name.uppercased()
        #endif
        //キーチェーンからidfvを取得
        let keychain = LUKeychainAccess.standard()
        idfv = keychain.string(forKey: "idfv") ?? ""
        print("idfv="+idfv)
        //idfvが空の時（初回起動時）idfvを取得してセット
        if idfv == "" {
            let uuid = UIDevice.current.identifierForVendor
            idfv = uuid?.uuidString ?? ""
            //保存
            keychain.setString(idfv, forKey: "idfv")
        }
        print("idfv="+idfv)
        // このバンドルのバージョンを調べる
        bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        // ロードしたことあるバージョンを調べる
        var loadedVersion:String = ""
        
        if defaults.object(forKey: "version") != nil {
            loadedVersion =  defaults.object(forKey: "version") as! String
        }
        if defaults.object(forKey: "startUpCount") != nil {
            startUpCount = defaults.object(forKey: "startUpCount") as! Int
        }
        

        //entryListを作成
//        let entry = EntryDataBase(db: _db!)
//        entry.create()

        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        /* 起動中のViewControllerを取得 */
        let navi = self.window?.rootViewController as! UINavigationController
        let currentVC = navi.visibleViewController
        print(currentVC!.classForCoder)
        
        if(currentVC?.isKind(of: ViewController.classForCoder()))! {
            print("first")
            currentView = "firstView"
            
        }else if(currentVC?.isKind(of: EnrollViewController.classForCoder()))! {
            print("enrollView")
            currentView = "enrollView"
        }
        /*
         }else if(currentVC?.isKind(of: ListViewController.classForCoder()))! {
             //ListViewもオフラインの時に使用するので、"offline"としておく
             print("ListView")
             currentView = "offline"
         }else if(currentVC?.isKind(of: SerialViewController.classForCoder()))! {
             print("SerialView")
             currentView = "SerialView"
         }*/
        //IBMと通信可能かチェック
        hostConnect.delegate = self
        hostConnect.start(hostName: hostName)
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let top = SimpleAlert.getTopViewController()
        //print(top?.classForCoder)
        if top?.classForCoder == UIAlertController.classForCoder() {
            top?.dismiss(animated: false, completion: nil)
        }
    }

    //MARK: - HostConnectDelegate
    func complete(_: Any) {
        //接続成功した時
        print("接続成功")
        isHostConnected = true
        if currentView == "firstView", firstVC != nil {
            firstVC.btnSetting(isEnabled:isHostConnected)
        }
        if currentView == "enrollView", enrollVC != nil {
            //enrollVC.btnSetting(isEnabled:isHostConnected)
        }
    }
    
    func failed(status: ConnectionStatus) {
        isHostConnected = false
        
        if currentView == "firstView", firstVC != nil {
            firstVC.btnSetting(isEnabled:isHostConnected)
        }
        if currentView == "enrollView", enrollVC != nil {
            //enrollVC.btnSetting(isEnabled:isHostConnected)
        }
        
        var errStr = ""
        //ホストに接続できなかった時
        switch status {
        case .vpn_error:
            print("vpn_error")
            errStr = "E1002:VPNに接続してください"
        case .host_res_error:
            //VPNはつながっているが、サーバーから返事がない時の処理
            print("host_res_error")
            errStr = "E1003:ホストから応答がありません"
        case .notConnect:
            print("notConnect")
            errStr = "E1001:インターネット接続がありません"
        default:
            return
        }
        let action1 = UIAlertAction(title: "接続を確認", style: .default, handler: {
        (action) -> Void in
        self.openSetting()})
        let action2 = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)

        SimpleAlert.make(title: "サーバーに接続できません", message: errStr, action: [action1,action2])

    }
    
    //設定画面に遷移する処理
    func openSetting() {
        if let url = URL(string:"App-Prefs:root") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}

