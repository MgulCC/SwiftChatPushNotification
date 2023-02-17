//
//  TableChatCell.swift
//  ChatAppProjectMiguelCC
//
//  Created by Escuela de Tecnologías Aplicadas on 6/2/23.
//

import UIKit
import QuartzCore

class TableChatCell: UITableViewCell {
    
    @IBOutlet weak var textMessage: UILabel!
    
    @IBOutlet weak var textArrow: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
