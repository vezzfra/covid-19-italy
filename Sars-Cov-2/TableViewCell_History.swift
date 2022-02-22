//
//  TableViewCell_History.swift
//  Sars-Cov-2
//
//  Created by Francesco Vezzoli on 21/03/2020.
//  Copyright © 2020 Co.v.er. Development. All rights reserved.
//

import UIKit

class TableViewCell_History: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var guaritiLabel: UILabel!
    @IBOutlet weak var graviLabel: UILabel!
    @IBOutlet weak var positiviLabel: UILabel!
    @IBOutlet weak var decedutiLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.backgroundColor = UIColor.white
    }

}
