//
//  SerialNumber.swift
//  SerialEnrollment
//
//  Created by administrator on 2019/05/28.
//  Copyright © 2019 Akiko Shinozaki. All rights reserved.
//

import UIKit

class SerialNumber: NSObject {

    class func make(_ str:String) -> (serialNo:String,isSerial:Bool) {
        var bool:Bool = false
        var serial:String = ""
        
        //if let range = str.range(of: "SN="), str.contains("sn.maruhachi.co.jp"){
        if let range = str.range(of: "SN="){
            let start = range.upperBound
            let str = str[start..<str.endIndex]
            if str.count>17{
                let end = str.index(start, offsetBy: 18)
                let str2 = str[start..<end]
                if Int(str2) != nil {
                    //18桁抜きだす
                    bool = true
                    serial = String(str2)
                    print(serial)
                }
            }
        }
        
        return (serial, bool)
    }
    
}
