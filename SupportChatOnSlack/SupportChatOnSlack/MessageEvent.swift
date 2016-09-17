//
//  MessageEvent.swift
//  Messenger
//
//  Created by Knedle on 09/09/2016.
//  Copyright © 2016 Slack Technologies, Inc. All rights reserved.
//

import Foundation

class MessageEvent {

    var eventId: String!
    
    init(eventId: String) {
        self.eventId = eventId
    }

}
