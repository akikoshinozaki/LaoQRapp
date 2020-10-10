//
//  DetailListViewController.swift
//  LaoQRapp
//
//  Created by 篠崎 明子 on 2020/10/07.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

var detailList:[GASList] = []

class DetailListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.isNavigationBarHidden = false
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        //tableView.separatorStyle = .none

        //setupTableView()
        
        dateLabel.text = detailList[0].date
        itemLabel.text = detailList[0].item
        itemNameLabel.text = detailList[0].itemName
    }
    
    
    @IBAction func closeView(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    

}


// MARK: - TableViewDelegate
extension DetailListViewController:UITableViewDelegate, UITableViewDataSource {
     //カスタムヘッダ-
    /*
     func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
         //let header = tableView.dequeueReusableHeaderFooterView(withClass: SectionHeaderView.self)
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeaderView") as! SectionHeaderView
         header.setup(titleText: "Section title")
         return header
     }
     
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return SectionHeaderView.height
     }
     
//     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//         return CGFloat.leastNormalMagnitude
//     }
    
    */
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myTableViewCell", for: indexPath) as! myTableViewCell
        let data = detailList[indexPath.row]
        //print(data)
//        cell.dateLabel.text = data.date
        cell.locLabel.text = data.loc
//        cell.itemLabel.text = data.item

        cell.serialLabel.text = data.serial
        cell.staffLabel.text = data.staff
        
        cell.UVLabel.text = data.UV
        cell.UHLabel.text = data.UH
        cell.LVLabel.text = data.LV
        cell.LHLabel.text = data.LH
        cell.WTLabel.text = data.WT
        cell.HTLabel.text = data.HT
        
        

        return cell
    }
    
    
    /*
    //削除
    //セルの編集許可
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool
    {
        if list[indexPath.row].type == "inputList" {
            return true
        }else {
            return false
        }
    }
    
    //スワイプしたセルを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if list[indexPath.row].type == "inputList" {
            if editingStyle == UITableViewCell.EditingStyle.delete {
                let id = list[indexPath.row].id!
                if self.entry.inputDelete(deleteID: [id]) {
                    list = self.entry.inputRead(select:index)
                    self.tableView.reloadData()
                }else {
                    SimpleAlert.make(title: "削除失敗しました", message: "")
                }
            }
        }
    }
    */
    
}