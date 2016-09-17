//
//  InfoMessageCell.swift
//  ZendeskChatOnSlackDemo
//
//  Created by Knedle on 12/09/2016.
//  Copyright © 2016 Knedle. All rights reserved.
//

import UIKit

class InfoMessageCell: UITableViewCell {
    
    static let Identifier:String = "InfoMessageCell"
    static let Nib:String = "InfoMessageCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bodyLabel.lineBreakMode = .byWordWrapping
        selectionStyle = .none
    }

    
}
