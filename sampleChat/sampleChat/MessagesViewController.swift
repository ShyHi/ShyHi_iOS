//
//  MessagesViewController.swift
//  sampleChat
//
//  Created by Tae Hwan Lee on 4/4/15.
//  Copyright (c) 2015 Tae Hwan Lee. All rights reserved.
//

import UIKit

class MessagesViewController: JSQMessagesViewController {

    var room: PFObject!
    var incomingUser: PFUser!
    var users = [PFUser]()
    
    var messages = [JSQMessage]()
    var messagingObjects = [PFObject]()
    
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    
    var selfAvatar: JSQMessagesAvatarImage!;
    var incomingAvatar: JSQMessagesAvatarImage!;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Messages";
        self.senderId = PFUser.currentUser().objectId;
        self.senderDisplayName = PFUser.currentUser().username;
        
        let selfUsername = PFUser.currentUser().username as NSString;
        let incomingUsername = incomingUser.username as NSString;
        
        selfAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(selfUsername.substringWithRange(NSMakeRange(0, 2)), backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault));
        
        incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(incomingUsername.substringWithRange(NSMakeRange(0, 2)), backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault));
        
        let bubbleFactory = JSQMessagesBubbleImageFactory();
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor());
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.grayColor());
        
        loadMessages();
    }
    
    // MARK: - LOAD MESSAGES
    func loadMessages() {
        
        var lastMessage: JSQMessage? = nil;
        
        if messages.last != nil {
            lastMessage = messages.last
        }
        
        let messageQuery = PFQuery(className: "Message");
        messageQuery.whereKey("room", equalTo: room);
        messageQuery.orderByAscending("createdAt");
        messageQuery.limit = 500;
        messageQuery.includeKey("user");
        
        if lastMessage != nil {
            messageQuery.whereKey("createdAt", greaterThan: lastMessage!.date);
        }
        
        messageQuery.findObjectsInBackgroundWithBlock { (results: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                let messages = results as [PFObject]
                
                for message in messages {
                    self.messagingObjects.append(message);
                    
                    let user = message["user"] as PFUser;
                    self.users.append(user);
                    
                    let chatMessage = JSQMessage(senderId: user.objectId, senderDisplayName: user.username, date: message.createdAt, text: message["content"] as String);
                    self.messages.append(chatMessage);
                }
                
                if results.count != 0 {
                    self.finishReceivingMessage();
                }
            }
        }
    }
    
    // MARK: - SEND MESSAGES
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        let message = PFObject(className: "Message");
        message["content"] = text;
        message["room"] = room;
        message["user"] = PFUser.currentUser();
        
        message.saveInBackgroundWithBlock { (success: Bool!, error: NSError!) -> Void in
            if error == nil {
                self.loadMessages();
                self.room["lastUpdate"] = NSDate();
                self.room.saveInBackgroundWithBlock(nil);
            }
            else {
                println("eeror sending message \(error.localizedDescription)");
            }
        }
        self.finishSendingMessage();
    }

    // MARK: - DELEGATE METHODS
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row];
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row];
        
        if message.senderId == self.senderId {
            return outgoingBubbleImage;
        }
        
        return incomingBubbleImage;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row];
        
        if message.senderId == self.senderId {
            return selfAvatar;
        }
        
        return incomingAvatar;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = messages[indexPath.item]
            
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date);
        }
        
        return nil;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault;
        }
        
        return 0;
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as JSQMessagesCollectionViewCell;
        
        let message = messages[indexPath.row];
        
        if message.senderId == self.senderId {
            cell.textView.textColor = UIColor.blackColor();
        }
        else {
            cell.textView.textColor = UIColor.whiteColor();
        }
        
        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName: cell.textView.textColor];
        
        return cell
    }
        
    // MAKR: - DATASOURCE
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
