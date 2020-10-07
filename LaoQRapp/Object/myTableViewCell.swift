//
//  myTableViewCell.swift
//  QRReader
//
//  Created by administrator on 2017/11/09.
//  Copyright © 2017年 Akiko Shinozaki. All rights reserved.
//

import UIKit

class myTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tourokuDateLabel: UILabel!
    @IBOutlet weak var itemCDLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var serialNOLabel: UILabel!
    @IBOutlet weak var syainCDLabel: UILabel!
    @IBOutlet weak var customerNMLabel: UILabel!
    @IBOutlet weak var dataCountLabel: UILabel!
    @IBOutlet weak var uke_typeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
