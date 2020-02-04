//
//  PingResultTableViewCell.swift
//  iOSPingerApp
//
//  Created by Mantas Paškevičius on 01/02/2020.
//  Copyright © 2020 Mantas Paškevičius. All rights reserved.
//

import UIKit

class PingResultTableViewCell: UITableViewCell {

    @IBOutlet weak var ipAddressLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
