//
//  InfoMessageCell.swift
//  Messenger
//
//  Created by Knedle on 31/07/2016.
//

import UIKit

class VisitorMessageCell: UITableViewCell {
    
    static let Identifier:String = "VisitorMessageCell"
    static let Nib:String = "VisitorMessageCell"
    
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
