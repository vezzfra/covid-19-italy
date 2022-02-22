//
//  TableViewCell_RegionDetail.swift
//  Sars-Cov-2
//
//  Created by Francesco Vezzoli on 22/03/2020.
//  Copyright © 2020 Co.v.er. Development. All rights reserved.
//

import UIKit

class TableViewCell_RegionDetail: UITableViewCell {
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var positiviLabel: UILabel!
    @IBOutlet weak var guaritiLabel: UILabel!
    @IBOutlet weak var decedutiLabel: UILabel!
    @IBOutlet weak var graviLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
