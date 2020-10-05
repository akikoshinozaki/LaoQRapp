//
//  EntryDataBase.swift
//  QRReader
//
//  Created by administrator on 2017/11/14.
//  Copyright © 2017年 Akiko Shinozaki. All rights reserved.
//

import UIKit
import FMDB


class EntryDataBase: NSObject {
    
    /// Instance of the database connection.
    private let db :FMDatabase!

    /// Initialize the instance.
    ///
    /// - Parameter db: Instance of the database connection.

    init(db: FMDatabase) {
        self.db = db
        self.db.open()
        super.init()
    }
    
    deinit {
        self.db.close()
    }
  
    /// テーブル作成
    func create() {
        self.db.open()
/*
        let SQLCreate = "" +
            "CREATE TABLE IF NOT EXISTS entryList (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "type TEXT, " +
            "entryDate TEXT, " +
            "updateDate TEXT, " +
            "uke_Type TEXT, " +
            "uke_CD TEXT, " +
            "syohinCD TEXT, " +
            "syohinName TEXT, " +
            "serialNo TEXT, " +
            "syainCD TEXT, " +
            "locate TEXT, " +
            "customerName TEXT, " +
            "IBM_res TEXT, " +  //2019/5/1~追加
            "errorMSG TEXT, " +
            "timeStamp TEXT, " +
            "post TEXT DEFAULT ''" +
        ");"
        
        if (self.db.executeUpdate(SQLCreate, withArgumentsIn: [])){
            print("entryList create successfully")
        }
*/
        
        let SerialCreate = "" +
            "CREATE TABLE IF NOT EXISTS serialList (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "type TEXT, " +
            "entryDate TEXT, " +
            "updateDate TEXT, " +
            "uke_Type TEXT, " +
            "uke_CD TEXT, " +
            "syohinCD TEXT, " +
            "syohinName TEXT, " +
            "serialNo TEXT, " +
            "syainCD TEXT, " +
            "locate TEXT, " +
            "customerName TEXT, " +
            "IBM_res TEXT, " +  //2019/5/1~追加
            "errorMSG TEXT, " +
            "timeStamp TEXT, " +
            "post TEXT DEFAULT ''" +
        ");"
        
        if (self.db.executeUpdate(SerialCreate, withArgumentsIn: [])){
            print("serialList create successfully")
        }
        
        let inputCreate = "" +
            "CREATE TABLE IF NOT EXISTS inputList (" +
            "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
            "entryDate TEXT, " +
            "syain TEXT, " +
            "locate TEXT, " +
            "itemCD TEXT, " +
            "itemName TEXT, " +
            "rack TEXT, " +
            "floor TEXT, " +
            "seqNo TEXT, " +
            "qty TEXT, " +
            "uuid TEXT, " +
            "startTM TEXT, " +
            "endTM TEXT, " +
            "workTM TEXT, " +
            "postTM TEXT DEFAULT '', " +
            "timeStamp TEXT " +
        ");"
         
         if (self.db.executeUpdate(inputCreate, withArgumentsIn: [])){
             print("input create successfully")
         }


//        if bundleVersion=="1.83",startUpCount==0 {
            //初回起動だったらカラム追加
            //let addArr = ["IBM_res", "errorMSG", "timeStamp"]
//            var err = ""
//            //for str in addArr {
//                let addColumn = "" +
//                    "ALTER TABLE entryList ADD COLUMN " +
//                    "post TEXT " +
//                "DEFAULT '';"
//                if self.db.executeUpdate(addColumn, withArgumentsIn: []){
//                    print("add column successfully")
//                }else {
//                    print(db.lastErrorMessage())
//                    err += db.lastErrorMessage() + "\n"
//                }
                
            //}
            
//        }
        
    }

    /// Add the List.
    func add(data:SaveData){
        //重複チェック
        let SQLCheck = "SELECT * FROM serialList WHERE type = '\(data.type)' AND updateDate = '\(data.updateDate)' AND serialNo = '\(data.serialNo)' AND timeStamp = '\(data.timeStamp)' limit 1"
        
        //Insert
        let SQLInsert = "" +
            "INSERT INTO " +
            "serialList (type, entryDate, updateDate, uke_Type, uke_CD, syohinCD, syohinName, serialNo, syainCD, locate, customerName,IBM_res, errorMSG, timeStamp) " +
            "VALUES " +
        "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" +
        ";"
        
        if self.db.executeUpdate(SQLCheck, withArgumentsIn: []) {
            print("重複していません")
            
            if self.db.executeUpdate(SQLInsert, withArgumentsIn: [data.type, data.entryDate, data.updateDate, data.uke_Type, data.uke_CD, data.syohinCD, data.syohinName, data.serialNo, data.syainCD, data.locate, data.customerName, data.IBM_res, data.errorMSG, data.timeStamp]){
                insertCount += 1
                print("Insert success!")
                print(self.db.lastInsertRowId)
                dbInsertSuccess = true
                
            }else {
                //dbへの書き込みエラーのとき
                dbInsertSuccess = false
                
                print("Insert faild!")
                print("error=\(self.db.lastError())")
                
                /***** エラーログ採取開始 *****/
                let formatter = DateFormatter()
                formatter.calendar = Calendar(identifier: .gregorian)
                formatter.dateFormat = "yyyyMMdd_HHmmss"
                let now = formatter.string(from: Date())
                let errorMsg = "\(now),errorCode = \(self.db.lastErrorCode()),errormessage = \(self.db.lastErrorMessage()),"
                    + "商品CD=\(data.syohinCD),SN=\(data.serialNo)\n"
                
                if let dir = manager.urls(for: .documentDirectory, in: .userDomainMask).first{
                    let errorlog = dir.appendingPathComponent("errorLog.txt")
                    
                    if !manager.fileExists(atPath: errorlog.path){
                        manager.createFile(atPath: errorlog.path, contents: nil, attributes: nil)
                    }
                    
                    if self.errWrite(url: errorlog, text: errorMsg) {
                        print("エラーログ書き込み成功")
                    }else {
                        print("エラーログ書き込みエラー")
                    }
                    
                }
                /***** エラーログ採取おわり *****/
            }
            
            
        }else {
            duplicateCount += 1
            print("重複しています")
        }
        
    }
    
    //errorLogファイルに書き込み
    func errWrite(url: URL, text: String) -> Bool {
        guard let stream = OutputStream(url: url, append: true) else {
            return false
        }
        stream.open()
        
        defer {
            stream.close()
        }
        
        guard let data = text.data(using: .utf8) else { return false }
        
        let result = data.withUnsafeBytes {
            stream.write($0, maxLength: data.count)
        }
        return (result > 0)
    }
    /// Read a Data.　SQLからArrayへ
    func read(type:String) -> [SaveData] {

        let SQLSelect = "" +
            "SELECT * " +
            "FROM serialList WHERE " +
            "type = '\(type)'" +
            "order by " +
            "updateDate, syohinCD;"
        
        var serialList:[SaveData] = []
        
        if let results = self.db.executeQuery(SQLSelect, withArgumentsIn: []) {
            while results.next() {
                let qrdata = SaveData(QR_id: results.long(forColumn: "id"),
                                    type: results.string(forColumn: "type")!,
                                    entryDate: results.string(forColumn: "entryDate")!,
                                    updateDate: results.string(forColumn: "updateDate")!,
                                    uke_Type: results.string(forColumn: "uke_Type")!,
                                    uke_CD: results.string(forColumn: "uke_CD")!,
                                    syohinCD: results.string(forColumn: "syohinCD")!,
                                    syohinName: results.string(forColumn: "syohinName")!,
                                    serialNo: results.string(forColumn: "serialNo")!,
                                    syainCD: results.string(forColumn: "syainCD")!,
                                    locate: results.string(forColumn: "locate")!,
                                    customerName: results.string(forColumn: "customerName")!,
                                    IBM_res: results.string(forColumn: "IBM_res")!,
                                    errorMSG: results.string(forColumn: "errorMSG")!,
                                    timeStamp: results.string(forColumn: "timeStamp")!
                                    )
                serialList.append(qrdata)
            }
        }
        
        return serialList
    }

    //重複チェック用のリストを取得
    func serialDupChk(serial:String) -> [String] {
        
        let SQLSelect = "" +
            "SELECT * " +
            "FROM serialList WHERE " +
        "type = 'enroll' AND serialNo = '\(serial)';"
        
        var list:[String] = []
        
        if let results = self.db.executeQuery(SQLSelect, withArgumentsIn: []) {
            while results.next() {
                list.append(results.string(forColumn: "errorMSG")!)
            }
        }
        
        print(list)
        return list
    }
    
    //テーブル全削除
    func deleteList(listName:String) {
        self.db.open()
        let SQLDelete = "DROP TABLE \(listName);"
        if self.db.executeUpdate(SQLDelete, withArgumentsIn: []) {
            print("\(listName) delete successfully!")
        }else {
            print("\(listName) delete failed.")
        }
    }

    
    //日付を指定してリストを検索(countあり)
    func selectItem(updateDate: String, type: String, syohinCD: String) -> [SQLData] {
        var SQLSelect = ""
        if syohinCD != ""{
            SQLSelect = "SELECT * ,COUNT(*) FROM serialList WHERE " +
                "type = '\(type)'" +
                "AND updateDate = '\(updateDate)'" +
                "AND syohinCD = '\(syohinCD)'" +
                "AND IBM_res = ''" +
            "GROUP BY syohinCD"
            //"GROUP BY updateDate"
        }else {
            SQLSelect = "SELECT * ,COUNT(*) FROM serialList WHERE " +
                "type = '\(type)'" +
                "AND updateDate = '\(updateDate)'" +
                "AND IBM_res = ''" +
            "GROUP BY syohinCD"
        }

        var sqlList:[SQLData] = []
        if let results = self.db.executeQuery(SQLSelect, withArgumentsIn: []) {
            while results.next() {
                let data = SQLData(QR_id: results.long(forColumn: "id"),
                                   type: results.string(forColumn: "type")!,
                                   entryDate: results.string(forColumn: "entryDate")!,
                                   updateDate: results.string(forColumn: "updateDate")!,
                                   uke_Type: results.string(forColumn: "uke_Type")!,
                                   uke_CD: results.string(forColumn: "uke_CD")!,
                                   syohinCD: results.string(forColumn: "syohinCD")!,
                                   syohinName: results.string(forColumn: "syohinName")!,
                                   serialNo: results.string(forColumn: "serialNo")!,
                                   syainCD: results.string(forColumn: "syainCD")!,
                                   locate: results.string(forColumn: "locate")!,
                                   customerName: results.string(forColumn: "customerName")!,
                                    count: results.long(forColumn: "COUNT(*)"))
                sqlList.append(data)
            }
        }
        
        return sqlList
    }

    //日付と商品CDを指定してシリアル一覧を取得
    func getSerialList(updateDate: String, syohinCD:String, type: String) -> [SerialList] {

        
        let serialSQL = "SELECT entryDate,serialNo,syainCD,uke_Type,uke_CD,customerName FROM serialList WHERE updateDate = '\(updateDate)' AND type = '\(type)' AND syohinCD = '\(syohinCD)' AND IBM_res = '';"
        
        var list:[SerialList] = []
        if let results = self.db.executeQuery(serialSQL, withArgumentsIn: []) {
            while results.next() {
                let entDate = results.string(forColumn: "entryDate")!
                let date = (entDate.date).shortString

                let data:SerialList = SerialList(entryDate:date,
                                              serialNo: results.string(forColumn: "serialNo")!,
                                              syainCD: results.string(forColumn: "syainCD")!,
                                              uke_Type: results.string(forColumn: "uke_Type")!,
                                              uke_CD: results.string(forColumn: "uke_CD")!,
                                              customerName: results.string(forColumn: "customerName")!)
                list.append(data)
            }
        }
        
        return list
    }
    
    /// deleteした後にstatus変更
    func changeStatus(serial:String, type:String, msg:String){
        var idx:[String] = []
        let idSearch = "SELECT id FROM serialList WHERE serialNo=? AND IBM_res=''" + ";"
        
        if let results = self.db.executeQuery(idSearch, withArgumentsIn: [serial]) {
            while results.next() {
                idx.append(results.string(forColumn: "id")!)
            }
        }
        
        print(idx)

        if idx.count > 0 {
            let SQLChange = "UPDATE serialList " +
            "set type=?,timeStamp=?, updateDate=?, errorMSG=? " +
            "WHERE id = ?"+";"
            for id in idx {
                if self.db.executeUpdate(SQLChange, withArgumentsIn: [type, Date().timeStamp, Date().string, msg, id]){
                    
                }else {
                    print(self.db.lastError())
                }
            }
            
        }
    }

    //日付の古いデータは削除する
    func removeOldData(){
        let oldDate = (Date()-60*60*24*30).string //30日前の日付を求める
        let SQLDelete = "DELETE FROM serialList WHERE updateDate < '\(oldDate)';"
        self.db.executeUpdate(SQLDelete, withArgumentsIn: [])
        
    }
    
    //DBにinsertして、idを返す
    func insert(data:SaveData) -> String {
        var id = ""
        
        //Insert
        let SQLInsert = "" +
            "INSERT INTO " +
            "serialList (type, entryDate, updateDate, uke_Type, uke_CD, syohinCD, syohinName, serialNo, syainCD, locate, customerName,IBM_res, errorMSG, timeStamp) " +
            "VALUES " +
            "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" +
        ";"
        
            if self.db.executeUpdate(SQLInsert, withArgumentsIn: [data.type, data.entryDate, data.updateDate, data.uke_Type, data.uke_CD, data.syohinCD, data.syohinName, data.serialNo, data.syainCD, data.locate, data.customerName, data.IBM_res, data.errorMSG, data.timeStamp]){
                insertCount += 1
                print("Insert success!")
                print(self.db.lastInsertRowId)
                id = String(self.db.lastInsertRowId)
                dbInsertSuccess = true
                
            }else {
                //dbへの書き込みエラーのとき
                dbInsertSuccess = false
                
                print("Insert faild!")
                print("error=\(self.db.lastError())")
                
                /***** エラーログ採取開始 *****/
                let errorMsg = "errorCode = \(self.db.lastErrorCode()),errormessage = \(self.db.lastErrorMessage()),"
                    + "商品CD=\(data.syohinCD),SN=\(data.serialNo)\n"
                
                self.errorLog(error: errorMsg)
                /***** エラーログ採取おわり *****/
            }
        
        return id
    }
    

    /// Update a List（変更、書き換え）
    func update(id:String, response:String, errMsg:String){
        
        let sqlUpdate = "UPDATE serialList set IBM_res=?, errorMSG=?, timeStamp=? where id = ?;"

        if self.db.executeUpdate(sqlUpdate, withArgumentsIn: [response,errMsg,Date().timeStamp,id]) {
            //update成功

            print("update")
            
        }else {
            print("error")
            /***** エラーログ採取開始 *****/
            let errorMsg = "errorCode = \(self.db.lastErrorCode()),errormessage = \(self.db.lastErrorMessage()),"
                + "id=\(id),IBM_res=\(response),errMSG=\(errMsg)\n"
            
            self.errorLog(error: errorMsg)
            /***** エラーログ採取おわり *****/
        }
        
    }
    
    //MARK: - InputListの操作
    //Insert
    func inputInsert(data:InputData) -> Bool {
        //var id = ""
        var status:Bool = false
        
        //Insert
        let insert = "" +
            "INSERT INTO " +
            "inputList (entryDate, syain, locate, itemCD, itemName, rack, floor, seqNo, qty, uuid, startTM, endTM, workTM, timeStamp) " +
            "VALUES " +
            "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)" +
        ";"
        
        if self.db.executeUpdate(insert, withArgumentsIn: [data.entryDate, data.syainCD, data.locate, data.itemCD, data.itemName, data.rack, data.floor, data.seqNo, data.qty, data.uuid, data.startTM, data.endTM, data.workTM, data.timeStamp]){

                print("Insert success!")
                //id = String(self.db.lastInsertRowId)
                status = true
                
            }else {
                //dbへの書き込みエラーのとき
                status = false
                
                print("Insert faild!")
                print("error=\(self.db.lastError())")
                
                /***** エラーログ採取開始 *****/
                let errorMsg = "errorCode = \(self.db.lastErrorCode()),errormessage = \(self.db.lastErrorMessage()),"
                    + "商品CD=\(data.itemCD),SN=\(data.uuid)\n"
                
                self.errorLog(error: errorMsg)
                /***** エラーログ採取おわり *****/
            }
        
        return status
    }
    
    //SELECT
    func inputRead(select:Int) -> [InputData] {

        let inputSelect = "SELECT * FROM inputList; "
        var entrySelect = "SELECT * FROM serialList WHERE type='enroll' AND errorMSG='登録完了' AND post=''"

        if select == 0 { //当日分のみ
            entrySelect += " AND entryDate='\(Date().string)';"
        }else { //全選択
            entrySelect += ";"
        }

        var list:[InputData] = []
        
        if let results = self.db.executeQuery(inputSelect, withArgumentsIn: []) {
            while results.next() {
                
                let data = InputData(id: results.long(forColumn: "id"),
                                     type:"inputList",
                                     entryDate: results.string(forColumn: "entryDate") ?? "",
                                     syainCD: results.string(forColumn: "syain") ?? "",
                                     locate: results.string(forColumn: "locate") ?? "",
                                     itemCD: results.string(forColumn: "itemCD") ?? "",
                                     itemName: results.string(forColumn: "itemName") ?? "",
                                     rack: results.string(forColumn: "rack") ?? "",
                                     floor: results.string(forColumn: "floor") ?? "",
                                     seqNo: results.string(forColumn: "seqNo") ?? "",
                                     qty: results.string(forColumn: "qty") ?? "",
                                     uuid: results.string(forColumn: "uuid") ?? "",
                                     startTM: results.string(forColumn: "startTM") ?? "",
                                     endTM: results.string(forColumn: "endTM") ?? "",
                                     workTM: results.string(forColumn: "workTM") ?? "",
                                     //postTM: results.string(forColumn: "postTM") ?? "",
                                     timeStamp: results.string(forColumn: "timeStamp") ?? "")
                list.append(data)
                
            }
        }
        
        if let result2 = self.db.executeQuery(entrySelect, withArgumentsIn: []) {
            previousTime = saveTime  //最初の1項目目はアプリの初回起動時間をセット
            
            while result2.next() {
                var timestamp = result2.string(forColumn: "timeStamp") ?? Date().timeStamp
                timestamp = timestamp.trimmingCharacters(in: .newlines) //改行コードは消す
                //print(timestamp)

                let date = timestamp.dateTime
                let end = date.shortTime

                let data = InputData(id: result2.long(forColumn: "id"),
                                     type:"serialList",
                                     entryDate: result2.string(forColumn: "entryDate") ?? "",
                                     syainCD: result2.string(forColumn: "syainCD") ?? "",
                                     locate: result2.string(forColumn: "locate") ?? "",
                                     itemCD: result2.string(forColumn: "syohinCD") ?? "",
                                     itemName: result2.string(forColumn: "syohinName") ?? "",
                                     rack: "",
                                     floor: "",
                                     seqNo: "15", //固定
                                     qty: "1", //固定
                                     uuid: result2.string(forColumn: "serialNo") ?? "",
                                     startTM: previousTime, //1つ前のIBM登録時間
                                     endTM: end, //このアイテムのIBM登録時間
//                                     workTM: "",
//                                     postTM: "",
                                     timeStamp: result2.string(forColumn: "timeStamp") ?? "")
                list.append(data)
                //IBM登録時間を次の項目のstartTimeにセット
                previousTime = end
            }
        }
        
        return list
    }
    
    
    //削除
    //レコードを削除
    func inputDelete(deleteID:[Int]) -> Bool {
        var status:Bool = false
        var str = "\(deleteID)"
        str = str.replacingOccurrences(of: "[", with: "(")
        str = str.replacingOccurrences(of: "]", with: ")")
        print(str)

        var deleteSQL = ""
        
        if deleteID.count == 0 {
            deleteSQL = "DELETE FROM inputList;"
        }else {
            deleteSQL = "DELETE FROM inputList WHERE id IN \(str);"
        }

        if self.db.executeUpdate(deleteSQL, withArgumentsIn: []) {
            print("inputList Deleted")
            status = true
        }else{
            print("inputList Delete failed")
        }
        
        return status
    }
    
    //UPDATE
    func inputUpdate(id:[Int], post:String, tbName:String){
        var str:String = "\(id)"
        str = str.replacingOccurrences(of: "[", with: "(")
        str = str.replacingOccurrences(of: "]", with: ")")
        print(str)
        
        let inputUpdate = "UPDATE \(tbName) set post=\(post) where id in \(str);"

        if self.db.executeUpdate(inputUpdate, withArgumentsIn: []) {
            //update成功

            print("update")
            
        }else {
            print("error")
            /***** エラーログ採取開始 *****/
            let errorMsg = "errorCode = \(self.db.lastErrorCode()),errormessage = \(self.db.lastErrorMessage()),"
                + "id=\(id)\n"
            
            self.errorLog(error: errorMsg)
            /***** エラーログ採取おわり *****/
        }
        
    }
    
    //MARK: - エラーログ
    
    func errorLog(error:String) {
        /***** エラーログ採取開始 *****/
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        let now = formatter.string(from: Date())
        let errorMsg = "\(now),\(error)\n"
        
        if let dir = manager.urls(for: .documentDirectory, in: .userDomainMask).first{
            let errorlog = dir.appendingPathComponent("errorLog.txt")
            
            if !manager.fileExists(atPath: errorlog.path){
                manager.createFile(atPath: errorlog.path, contents: nil, attributes: nil)
            }
            
            if self.errWrite(url: errorlog, text: errorMsg) {
                print("エラーログ書き込み成功")
            }else {
                print("エラーログ書き込みエラー")
            }
            
        }
        /***** エラーログ採取おわり *****/
    }
    
}

