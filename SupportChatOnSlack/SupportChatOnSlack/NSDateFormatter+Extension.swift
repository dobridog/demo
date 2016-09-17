//
//  NSDateFormatter+Extension.swift
//  ZendeskChatOnSlackDemo
//
//  Created by Knedle on 14/09/2016.
//  Copyright © 2016 Knedle. All rights reserved.
//

import Foundation


class NSDateFormatter_Extension {
    
}

extension DateFormatter {
    
    func stringFromDate(eventdate date: NSDate) -> String {
        self.dateFormat = "HH:mm a"
        self.amSymbol = "am"
        self.pmSymbol = "pm"
        self.timeZone = NSTimeZone.local
        
        return self.string(from: date as Date)
    }
}
