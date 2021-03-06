//
//  OverviewTableViewController.swift
//  sampleChat
//
//  Created by Tae Hwan Lee on 4/3/15.
//  Copyright (c) 2015 Tae Hwan Lee. All rights reserved.
//

import UIKit

class OverviewTableViewController: UITableViewController {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var choosePartnerButton: UIBarButtonItem!
    
    var rooms = [PFObject]();
    var users = [PFUser]();
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.setLeftBarButtonItem(logoutButton, animated: false);
        self.navigationItem.setRightBarButtonItem(choosePartnerButton, animated: false);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if PFUser.currentUser() != nil {
            loadData()
        }
    }
    
    func loadData() {
        rooms = [PFObject]();
        users = [PFUser]();
        
        self.tableView.reloadData();
        
        let pred = NSPredicate(format: "user1 = %@ OR user2 = %@", PFUser.currentUser()!, PFUser.currentUser()!);
        
        let roomQuery = PFQuery(className: "Room", predicate: pred);
        roomQuery.orderByDescending("lastUpdate");
        roomQuery.includeKey("user1");
        roomQuery.includeKey("user2");
        
        roomQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                self.rooms = objects as! [PFObject]
                
                for room in self.rooms {
                    let user1 = room.objectForKey("user1") as! PFUser;
                    let user2 = room["user2"] as! PFUser;
                    
                    if user1.objectId != PFUser.currentUser()!.objectId {
                        self.users.append(user1);
                    }
                    
                    if user2.objectId != PFUser.currentUser()!.objectId {
                        self.users.append(user2);
                    }
                }
                
                self.tableView.reloadData();
            }
        }
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        // Return the number of sections.
        return 1;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return rooms.count;
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80;
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! OverviewTableViewCell

        let targetUser = users[indexPath.row];
        
        cell.nameLabel.text = targetUser.username;
        
        let user1 = PFUser.currentUser();
        let user2 = users[indexPath.row];
        
        let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2, user2, user1!);
        
        let roomQuery = PFQuery(className: "Room", predicate: pred);
        
        roomQuery.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                if objects!.count > 0 {
                    let messageQuery = PFQuery(className: "Message");
                    let room = objects!.last as! PFObject;
                    
                    messageQuery.whereKey("room", equalTo: room);
                    messageQuery.limit = 1;
                    messageQuery.orderByDescending("createdAt");
                    messageQuery.findObjectsInBackgroundWithBlock({ (results: [AnyObject]?, error: NSError?) -> Void in
                        if error == nil {
                            if results!.count > 0 {
                                let message = objects!.last as! PFObject;
                            
                                cell.lastMessageLabel.text = message["content"] as? String;
                            
                                let date = message.createdAt;
                                let interval = NSDate().daysAfterDate(date);
                                
                                var dateString = "";
                                
                                if interval == 0 {
                                    dateString = "Today";
                                }
                                else if interval == 1 {
                                    dateString == "Yesterday";
                                }
                                else if interval > 1 {
                                    let dateFormat = NSDateFormatter();
                                    dateFormat.dateFormat = "mm/dd/yyyy";
                                    dateString = dateFormat.stringFromDate(message.createdAt!);
                                }
                                
                                cell.dateLabel.text = dateString as String;
                            } else {
                                cell.lastMessageLabel.text = "No messages yet";
                            }
                            
                        }
                    })
                }
            }
        }
        return cell;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil);
        let messagesVC = sb.instantiateViewControllerWithIdentifier("MessagesViewController") as! MessagesViewController;
        let user1 = PFUser.currentUser();
        let user2 = users[indexPath.row];
        
        let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2, user2, user1!);
        
        let roomQuery = PFQuery(className: "Room", predicate: pred);
        
        roomQuery.findObjectsInBackgroundWithBlock { ( objects: [AnyObject]?, error: NSError?) -> Void in
            if error == nil {
                let room = objects!.last as! PFObject
                messagesVC.room = room;
                messagesVC.incomingUser = user2;
                
                self.navigationController?.pushViewController(messagesVC, animated: true);
            }
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        
        PFUser.logOut();
        
        self.navigationController?.popToRootViewControllerAnimated(true);
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
