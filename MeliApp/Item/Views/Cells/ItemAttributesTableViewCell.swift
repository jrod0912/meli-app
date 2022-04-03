//
//  ItemAttributesTableViewCell.swift
//  MeliApp
//
//  Created by Jorge Rodríguez on 30/03/22.
//

import UIKit

class ItemAttributesTableViewCell: UITableViewCell {

    @IBOutlet weak var attributeKeyView: UIView!
    @IBOutlet weak var attributeKeyLabel: UILabel!
    @IBOutlet weak var attributeValueView: UIView!
    @IBOutlet weak var attributeValueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(with key: String, value: String, oddStyle: Bool){
        attributeKeyView.backgroundColor = (oddStyle) ? .systemGray4 : .systemGray6
        attributeValueView.backgroundColor = (oddStyle) ? .systemGray6 : .white
        attributeKeyLabel.text = key
        attributeValueLabel.text = value
    }
    
}
