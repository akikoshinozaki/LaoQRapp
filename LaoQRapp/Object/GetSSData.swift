//
//  GetSSData.swift
//  LaoQRapp
//
//  Created by administrator on 2020/10/16.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

class GetSSData: NSObject {
    
    //idListの最終更新日を調べる
    class func getUpdateDate()->String {
        let url = apiUrl + "?upd=update"
        var str = ""
        //サーバー上のファイルのパス
        if let path = URL(string: url) {
            do {
                str = try String(contentsOf: path, encoding: .utf8)
                //print(str)
                defaults.set(str, forKey: "lastUpdate")
                
            } catch let error as NSError {
                print(error.localizedDescription)
                print("更新日取得失敗")
                //errMsg = error.localizedDescription
            }
        }
        return str
    }
    
    class func dataUpdate() {
        var DL_errMsg = ""
        let alert = UIAlertController(title: "データ更新中".loStr, message: "しばらくお待ちください".loStr, preferredStyle: .alert)
        SimpleAlert.getTopViewController()?.present(alert, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //アラートが出なくなるので、遅延処理を入れる
            
            DL_errMsg = ""
            for param in parameters{
                let data = DL.csvToArr(parameter: param)
                DL_errMsg += data.err
            }
            
            if DL_errMsg == ""{
                //更新できたら最終更新日を変更
                defaults.set(Date().string, forKey: "lastDataDownload")
                alert.dismiss(animated: true, completion: nil)
            }else {
                alert.title = "更新に失敗しました".loStr
                alert.message = DL_errMsg
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            }
            
            DL.csvDL()

        }
    }

}
