//
//  MotiCellViewController.swift
//  Weather
//
//  Created by Hektor Kastrati on 10/17/18.
//  Copyright © 2018 Hektor Kastrati. All rights reserved.
//

import UIKit

class MotiCellViewController: UITableViewCell {

    
    @IBOutlet weak var imgIkona: UIImageView!
    
    @IBOutlet weak var lblQyteti: UILabel!
    @IBOutlet weak var lblTemperatura: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
