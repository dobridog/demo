//
//  UITableViewCell+Extension.swift
//  ZendeskChatOnSlackDemo
//
//  Created by Knedle on 11/09/2016.
//  Copyright © 2016 Knedle. All rights reserved.
//

import Foundation

class UITableViewCell_Extension {}

extension UITableViewCell {
    
    static func defaultFontSize() -> Float {
        var pointSize:Float = 16.0;
        
        let contentSizeCategory = UIApplication.shared.preferredContentSizeCategory
        pointSize += Float(SLKPointSizeDifferenceForCategory(contentSizeCategory.rawValue))
        
        return pointSize;
    }
    
    static func minHeight() -> CGFloat {
        return 50
    }
}
