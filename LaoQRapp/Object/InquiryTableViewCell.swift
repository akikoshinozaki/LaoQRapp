//
//  InquiryTableViewCell.swift
//  LaoQRapp
//
//  Created by 篠崎 明子 on 2020/10/07.
//  Copyright © 2020 Akiko Shinozaki. All rights reserved.
//

import UIKit

class InquiryTableViewCell: UITableViewCell {

    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
