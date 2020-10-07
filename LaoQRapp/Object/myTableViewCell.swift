//
//  myTableViewCell.swift
//  QRReader
//
//  Created by administrator on 2017/11/09.
//  Copyright © 2017年 Akiko Shinozaki. All rights reserved.
//

import UIKit

class myTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var staffLabel: UILabel!
    @IBOutlet weak var locLabel: UILabel!
    @IBOutlet weak var UVLabel: UILabel!
    @IBOutlet weak var UHLabel: UILabel!
    @IBOutlet weak var LVLabel: UILabel!
    @IBOutlet weak var LHLabel: UILabel!
    @IBOutlet weak var WTLabel: UILabel!
    @IBOutlet weak var HTLabel: UILabel!
    @IBOutlet weak var serialLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
