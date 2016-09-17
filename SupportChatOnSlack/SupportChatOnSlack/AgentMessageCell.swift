//
//  AgentMessageCell.swift
//  ZendeskChatOnSlackDemo
//
//  Created by Knedle on 11/09/2016.
//  Copyright © 2016 Knedle. All rights reserved.
//

import UIKit

class AgentMessageCell: UITableViewCell {
    
    static let Identifier:String = "AgentMessageCell"
    static let Nib:String = "AgentMessageCell"
    
    static let avatarHeight:Float = 30.0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var thumbnail: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bodyLabel.lineBreakMode = .byWordWrapping
        selectionStyle = .none
    }
}
