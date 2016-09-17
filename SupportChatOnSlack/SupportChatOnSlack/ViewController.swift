//
//  ViewController.swift
//  ZendeskChatOnSlackDemo
//

import UIKit
import ZDCChatAPI

class ViewController: SLKTextViewController {
    
    let chat = ZDCChatAPI.instance()!
    var messages = OrderedDictionary<String, MessageEvent>()
    var greetingLabel:UILabel?
    
    // always unwrap optional we know is there
    override var tableView: UITableView {
        get {
            return super.tableView!
        }
    }
    
    required init(coder decoder: NSCoder) {
        super.init(tableViewStyle: .plain)
    }
    
    func initializeNibs() {
        // register Nibs:
        self.tableView.register(UINib(nibName: VisitorMessageCell.Nib, bundle: nil), forCellReuseIdentifier: VisitorMessageCell.Identifier)
        self.tableView.register(UINib(nibName: AgentMessageCell.Nib, bundle: nil), forCellReuseIdentifier: AgentMessageCell.Identifier)
        self.tableView.register(UINib(nibName: InfoMessageCell.Nib, bundle: nil), forCellReuseIdentifier: InfoMessageCell.Identifier)
    }
    
    func initializeGreetingLabel() -> UILabel {
        let rect = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height)
        let greetingLabel = UILabel(frame: rect)
        greetingLabel.text             = "How can we help you today?"
        greetingLabel.textColor        = UIColor.black
        greetingLabel.textAlignment    = .center
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        greetingLabel.transform = self.tableView.transform
        
        return greetingLabel
    }
    
    func configureVisitor() {
        let visitor = ZDCVisitorInfo()
        visitor.name = "Dick Dastardly"
        visitor.email = "customer@example.com"
        
        chat.visitorInfo = visitor
    }
    
    /*
     Helper function that verifies that an account is configured
     Once the account is configured this function can be removed
     */
    func verifyAccountKey() {
        if AccountKey.key.isEmpty {
            let alertController = UIAlertController(title: "Missing Account Key", message:
                "AccountKey.swift is not configured!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Okay, I'll configure it", style: UIAlertActionStyle.default,handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override class func tableViewStyle(for decoder: NSCoder) -> UITableViewStyle {
        return .plain
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeNibs()
        configureVisitor()
        
        self.tableView.separatorColor = UIColor.clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // start chat session
        chat.startChat(withAccountKey: AccountKey.key)
        // register listeners
        chat.addObserver(self, forChatLogEvents: #selector(onChatLogEvent))
        chat.addObserver(self, forAgentEvents: #selector(onAgentEvent))
        chat.addObserver(self, forTimeoutEvents: #selector(onTimeoutEvent))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        verifyAccountKey()
        greetingLabel = initializeGreetingLabel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // unregister listeners
        chat.removeObserver(forChatLogEvents: self)
        chat.removeObserver(forAgentEvents: self)
        chat.removeObserver(forTimeoutEvents: self)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    // MARK: - Chat Events
    
    func onTimeoutEvent() {
        let timestamp = NSDate().timeIntervalSince1970 * 1000
        
        let infoMessage = InfoMessage(eventId: String(timestamp))
        infoMessage.text = "Your session has timed out."
        add(message: infoMessage)
        
        self.setTextInputbarHidden(true, animated: true)
    }
    
    func onAgentEvent() {
        for agent in chat.agents.values {
            if agent.typing {
                self.typingIndicatorView!.insertUsername(agent.displayName)
            } else {
                self.typingIndicatorView!.removeUsername(agent.displayName)
            }
        }
    }
    
    func onChatLogEvent() {
        var updateIndexes: [NSIndexPath] = []
        
        for event in chat.livechatLog {
            
            if let message = self.messages[event.eventId] {
                
                // update message
                switch event.type {
                case .agentMessage:
                    if let agentMessage = message as? AgentMessage {
                        agentMessage.text = event.message
                        agentMessage.username = event.displayName
                        if let agent = chat.agents[event.nickname] {
                            agentMessage.agentUrl = agent.avatarURL
                        }
                        self.messages[event.eventId] = agentMessage
                    }
                    
                case .visitorMessage:
                    if let visitorMessage = message as? VisitorMessage {
                        visitorMessage.text = event.message
                        visitorMessage.username = event.displayName
                        visitorMessage.verified = event.verified
                        self.messages[event.eventId] = visitorMessage
                    }
                    
                case .systemMessage:
                    fallthrough
                case .triggerMessage:
                    if let infoMessage = message as? InfoMessage {
                        infoMessage.text = event.message
                    }
                    
                case .memberJoin:
                    if let infoMessage = message as? InfoMessage {
                        infoMessage.text = event.displayName + " joined"
                    }
                    
                case .memberLeave:
                    if let infoMessage = message as? InfoMessage {
                        infoMessage.text = event.displayName + " left"
                    }
                    
                default:
                    print("\(event.type) not supported yet.")
                }
                
                let updateIndex = messages.indexFor(key: event.eventId)
                let indexPath = NSIndexPath(row: updateIndex, section: 0)
                updateIndexes.append(indexPath)
                
            } else {
                // create new message
                switch event.type {
                case .agentMessage:
                    let agentMessage = AgentMessage(eventId: event.eventId)
                    agentMessage.text = event.message
                    agentMessage.username = event.displayName
                    if let agent = chat.agents[event.nickname] {
                        agentMessage.agentUrl = agent.avatarURL
                    }
                    add(message: agentMessage)
                    
                case .visitorMessage:
                    let visitorMessage = VisitorMessage(eventId: event.eventId)
                    visitorMessage.text = event.message
                    visitorMessage.username = event.displayName
                    visitorMessage.verified = event.verified
                    add(message: visitorMessage)
                    
                case .systemMessage:
                    fallthrough
                case .triggerMessage:
                    let infoMessage = InfoMessage(eventId: event.eventId)
                    infoMessage.text = event.message
                    add(message: infoMessage)
                    
                case .memberJoin:
                    let infoMessage = InfoMessage(eventId: event.eventId)
                    infoMessage.text = event.displayName + " joined"
                    add(message: infoMessage)
                    
                case .memberLeave:
                    let infoMessage = InfoMessage(eventId: event.eventId)
                    infoMessage.text = event.displayName + " left"
                    add(message: infoMessage)
                    
                default:
                    print("\(event.type) not supported yet.")
                }
            }
        }
        
        // reload updated messages
        self.tableView.reloadRows(at: updateIndexes as [IndexPath], with: UITableViewRowAnimation.none)
    }
    
}

extension ViewController {
    // MARK: - actions
    
    override func didPressRightButton(_ sender: Any?) {
        // This little trick validates any pending auto-correction or auto-spelling just after hitting the 'Send' button
        self.textView.refreshFirstResponder()
        
        // send message to an agent
        chat.sendChatMessage(self.textView.text)
        
        super.didPressRightButton(sender)
    }
}

extension ViewController {
    
    // MARK: - TableView Data
    func add(message: MessageEvent) {
        let indexPath = NSIndexPath(row: 0, section: 0)
        let rowAnimation: UITableViewRowAnimation = self.isInverted ? .bottom : .top
        let scrollPosition: UITableViewScrollPosition = self.isInverted ? .bottom : .top
        
        self.tableView.beginUpdates()
        self.messages[message.eventId] = message
        self.tableView.insertRows(at: [indexPath as IndexPath], with: rowAnimation)
        self.tableView.endUpdates()
        
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: scrollPosition, animated: true)
        
        // Fixes the cell from blinking (because of the transform, when using translucent cells)
        // See https://github.com/slackhq/SlackTextViewController/issues/94#issuecomment-69929927
        self.tableView.reloadRows(at: [indexPath as IndexPath], with: .automatic)
    }
    
    
    // MARK: - UITableViewDataSource Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Presents the greeting message before the conversations starts
        if messages.count == 0 {
            tableView.backgroundView = greetingLabel
        } else {
            tableView.backgroundView = nil
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView == self.tableView {
            return self.messages.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.tableView {
            
            // reverse lookup of the element because table view is inverted
            let index = messages.lastIndex - indexPath.row
            switch self.messages[index] {
                
            case let visitorMessage as VisitorMessage:
                return self.visitorMessageCellForRowAtIndexPath(visitorMessage: visitorMessage)
                
            case let agentMessage as AgentMessage:
                return self.agentMessageCellForRowAtIndexPath(agentMessage: agentMessage)
                
            case let infoMessage as InfoMessage:
                return self.infoMessageCellForRowAtIndexPath(infoMessage: infoMessage)
                
            default:
                // unexpected message type
                print("Unexpected message type \(messages[indexPath.row])")
                return UITableViewCell()
            }
            
        } else {
            // TODO can it be handled like this
            return UITableViewCell()
        }
    }
    
    func visitorMessageCellForRowAtIndexPath(visitorMessage: VisitorMessage) -> VisitorMessageCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: VisitorMessageCell.Identifier) as! VisitorMessageCell
        
        cell.titleLabel.text = visitorMessage.username
        cell.bodyLabel.text = visitorMessage.text
        cell.thumbnail.image = UIImage(named: "user_avatar")
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = self.tableView.transform
        
        return cell
    }
    
    func agentMessageCellForRowAtIndexPath(agentMessage: AgentMessage) -> AgentMessageCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: AgentMessageCell.Identifier) as! AgentMessageCell
        
        cell.titleLabel.text = agentMessage.username
        cell.bodyLabel.text = agentMessage.text
        if agentMessage.agentUrl != nil {
            cell.thumbnail.downloadedFrom(link: agentMessage.agentUrl!)
        }
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = self.tableView.transform
        
        return cell
    }
    
    func infoMessageCellForRowAtIndexPath(infoMessage: InfoMessage) -> InfoMessageCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: InfoMessageCell.Identifier) as! InfoMessageCell
        
        cell.titleLabel.text = infoMessage.text
        let timestamp = Double(infoMessage.eventId)! / 1000
        let date = NSDate(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        cell.bodyLabel.text = dateFormatter.stringFromDate(eventdate: date)
        
        // Cells must inherit the table view's transform
        // This is very important, since the main table view may be inverted
        cell.transform = self.tableView.transform
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if tableView == self.tableView {
            let message = self.messages[indexPath.row]
            
            if message is InfoMessage {
                return UITableViewCell.minHeight()
            }
            
            if let message = message as? VisitorMessage {
                return calculateHeight(title: message.username!, body: message.text!)
            }
            
            if let message = message as? AgentMessage {
                return calculateHeight(title: message.username!, body: message.text!)
            }
            
            return UITableViewCell.minHeight()
            
        }
        else {
            return UITableViewCell.minHeight()
        }
    }
    
    func calculateHeight(title: String, body: String) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.alignment = .left
        
        let pointSize = UITableViewCell.defaultFontSize()
        
        let attributes = [
            NSFontAttributeName : UIFont.systemFont(ofSize: CGFloat(pointSize)),
            NSParagraphStyleAttributeName : paragraphStyle
        ]
        
        let width = tableView.frame.width - 25.0
        
        let titleBounds = (title as NSString).boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        let bodyBounds = body.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        var height = titleBounds.height
        height += bodyBounds.height
        height += 40
        
        if height < CGFloat(UITableViewCell.minHeight()) {
            height = CGFloat(UITableViewCell.minHeight())
        }
        
        return height
        
    }
}

