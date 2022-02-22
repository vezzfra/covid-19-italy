//
//  TableViewCell_Province.swift
//  Sars-Cov-2
//
//  Created by Francesco Vezzoli on 22/03/2020.
//  Copyright © 2020 Co.v.er. Development. All rights reserved.
//

import UIKit

class TableViewCell_Province: UITableViewCell {
    
    @IBOutlet weak var totalCases: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
