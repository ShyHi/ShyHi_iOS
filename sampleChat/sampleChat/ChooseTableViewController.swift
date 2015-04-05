//
//  ChooseTableViewController.swift
//  sampleChat
//
//  Created by Tae Hwan Lee on 4/3/15.
//  Copyright (c) 2015 Tae Hwan Lee. All rights reserved.
//

import UIKit

class ChooseTableViewController: PFQueryTableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchString = "";
    var searchInProgress = false;
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "User";
        self.textKey = "username";
        self.pullToRefreshEnabled = true;
        self.paginationEnabled = true;
        self.objectsPerPage = 25;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self;
    }

    override func queryForTable() -> PFQuery! {
        let query = PFUser.query();
        query.whereKey("objectId", notEqualTo: PFUser.currentUser().objectId);
        
        if searchInProgress {
            query.whereKey("username", containsString: searchString)
        }
        
        if self.objects.count == 0 {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork;
        }
        
        query.orderByAscending("username");
        
        return query
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchString = searchText;
        searchInProgress = true;
        self.loadObjects();
        searchInProgress = false;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if PFUser.currentUser() != nil {
            var user1 = PFUser.currentUser();
            var user2 = self.objects[indexPath.row] as PFUser;
            
            var room = PFObject(className: "Room");
            
            // Setup the MessageViewController
            let sb = UIStoryboard(name: "Main", bundle: nil);
            let messagesVC = sb.instantiateViewControllerWithIdentifier("MessagesViewController") as MessagesViewController;
            
            let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1, user2, user2, user1);
            
            let roomQuery = PFQuery(className: "Room", predicate: pred);
            
            roomQuery.findObjectsInBackgroundWithBlock({ (results: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    if results.count > 0 {
                        room = results.last as PFObject;
                        // Setup MessageViewController and Push to the MessageVC
                        messagesVC.room = room;
                        messagesVC.incomingUser = user2;
                    }
                    else {
                        room["user1"] = user1;
                        room["user2"] = user2;
                        
                        room.saveInBackgroundWithBlock({ (success: Bool!, error: NSError!) -> Void in
                            if error == nil {
                                // Setup MessageViewController and Push to the MessageVC
                                messagesVC.room = room;
                                messagesVC.incomingUser = user2;
                                self.navigationController?.pushViewController(messagesVC, animated: true);
                            }
                        })
                    }
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
