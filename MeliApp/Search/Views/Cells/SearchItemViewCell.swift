//
//  SearchItemViewCell.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 27/03/22.
//

import UIKit

class SearchItemViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitle: UILabel!
    @IBOutlet weak var itemPrice: UILabel!
    @IBOutlet weak var itemInstallments: UILabel!
    @IBOutlet weak var itemHasFreeShipping: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
