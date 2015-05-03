//
//  OverviewTableViewController.swift
//  ShyHi
//
//  Created by Tae Hwan Lee on 4/28/15.
//  Copyright (c) 2015 ShyHi. All rights reserved.
//

import UIKit
import CoreLocation

class OverviewTableViewController: UITableViewController, CLLocationManagerDelegate {

    @IBOutlet weak var NewChatButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var lat: Double = 0;
    var long: Double = 0;
    var count = 1;
    
    var userArray = [PFUser]();
    
    // Arrays of rooms and users
    var rooms = [PFObject]();
    var users = [PFUser]();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setRightBarButtonItem(NewChatButton, animated: false);
        
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    //load controller data if user is present
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated);
        
        if PFUser.currentUser() != nil {
            loadData();
        }
    }
    
    //establish conversations from Parse room/users
    func loadData(){
        rooms = [PFObject]()
        users = [PFUser]()
        
        self.tableView.reloadData()
        
        let pred = NSPredicate(format: "user1 = %@ OR user2 = %@", PFUser.currentUser()!, PFUser.currentUser()!)
        
        let roomQuery = PFQuery(className: "Room", predicate: pred)
        roomQuery.orderByDescending("lastUpdate")
        roomQuery.includeKey("user1")
        roomQuery.includeKey("user2")
        
        
        roomQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                self.rooms = results as! [PFObject]
                
                for room in self.rooms {
                    let user1 = room.objectForKey("user1") as! PFUser
                    let user2 = room["user2"] as! PFUser
                    
                    if user1.objectId != PFUser.currentUser()!.objectId {
                        self.users.append(user1)
                    }
                    
                    if user2.objectId != PFUser.currentUser()!.objectId {
                        self.users.append(user2)
                    }
                }
                
                self.tableView.reloadData()
                
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Error: " + error.localizedDescription);
                return
            }
            
            if placemarks.count > 0 {
                
                let pm = placemarks[0] as! CLPlacemark;
                self.displayLocationInfo(pm);
                
            } else {
                
                println("Error with the data.");
                
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        
        self.locationManager.stopUpdatingLocation();
        // Console messages
        println(placemark.locality);
        println(placemark.postalCode);
        println(placemark.administrativeArea);
        println(placemark.country);
        println(placemark.location.coordinate.latitude);
        println(placemark.location.coordinate.longitude);
        
        // Storing location data on parse
        self.lat = placemark.location.coordinate.latitude;
        self.long = placemark.location.coordinate.longitude;
        var point = PFGeoPoint(latitude: lat, longitude: long);
        
        if let updateObject = PFUser.currentUser() as PFObject? {
            updateObject["Location"] = point;
            updateObject.saveEventually();
        } else {
            var updateObject = PFObject(className: "_User");
            updateObject["Location"] = point;
            updateObject.saveEventually();
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error: " + error.localizedDescription);
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
        
        let targetUser = users[indexPath.row]
        
//        cell.nameLabel.text = targetUser.username
//        cell.nameLabel.text = "Anonymous \(count)";
        let user1 = PFUser.currentUser()
        let user2 = users[indexPath.row]
        
        let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2, user2, user1!)
        
        let roomQuery = PFQuery(className: "Room", predicate: pred)
        
        roomQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                if results!.count > 0 {
                    let messageQuery = PFQuery(className: "Message")
                    let room = results!.last as! PFObject
                    
                    messageQuery.whereKey("Room", equalTo: room)
                    messageQuery.limit = 1
                    messageQuery.orderByDescending("createdAt")
                    messageQuery.findObjectsInBackgroundWithBlock({ (results:[AnyObject]?, error:NSError?) -> Void in
                        if error == nil {
                            if results!.count > 0 {
                                let message = results!.last as! PFObject
                                
                                cell.lastMessageLabel.text = message["content"] as? String
                                
                                let date = message.createdAt
                                let interval = NSDate().daysAfterDate(date)
                                
                                var dateString = ""
                                
                                if interval == 0 {
                                    dateString = "Today"
                                } else if interval == 1{
                                    dateString = "Yesterday"
                                }else if interval > 1 {
                                    let dateFormat = NSDateFormatter()
                                    dateFormat.dateFormat = "mm/dd/yyyy"
                                    dateString = dateFormat.stringFromDate(message.createdAt!)
                                }
                                
                                cell.dateLabel.text = dateString as String
                            }else{
                                cell.lastMessageLabel.text = "No messages yet"
                            }
                        }
                    })
                }
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let messageVC = sb.instantiateViewControllerWithIdentifier("MessageViewController") as! MessageViewController
        
        let user1 = PFUser.currentUser()
        let user2 = users[indexPath.row]
        
        let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2, user2, user1!)
        
        let roomQuery = PFQuery(className: "Room", predicate: pred)
        
        roomQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]?, error:NSError?) -> Void in
            if error == nil {
                let room = results!.last as! PFObject
                messageVC.room = room
                messageVC.incomingUser = user2
                
                self.navigationController?.pushViewController(messageVC, animated: true)
                
            }
        }
    }

    @IBAction func NewChatButton_Click(sender: AnyObject) {
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        var point2 = PFGeoPoint(latitude: self.lat, longitude: self.long)
//        var point2 = PFGeoPoint(latitude: 37.3, longitude: -122.0)
        var query = PFQuery(className: "_User")
        query.whereKey("Location", nearGeoPoint: point2, withinMiles: 50)
        query.limit = 30;
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil) {
                println("Found something");
                for object in objects! {
                    self.userArray.append(object as! PFUser);
                    println(object.objectId);
                }
            }
            else {
                println("%@", error)
            }
        }
        
        if (PFUser.currentUser() != nil && userArray.isEmpty == false) {
            
            //let randomIndex = Int(arc4random_uniform(UInt32(userArray)));
            var user1 = PFUser.currentUser();
            var user2 = userArray[0] as PFUser;
            var room = PFObject(className: "Room");
            
            // Setting up the MessageViewController
            let sb = UIStoryboard(name: "Main", bundle: nil)
            let messageVC = sb.instantiateViewControllerWithIdentifier("MessageViewController") as! MessageViewController
            let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2, user2, user1!);
            let roomQuery = PFQuery(className: "Room", predicate: pred);
            
            roomQuery.findObjectsInBackgroundWithBlock({ (results: [AnyObject]?, error: NSError?) -> Void in
                if error == nil {
                    if results!.count > 0 { // room already exists
                        let title = "Error";
                        let message = "No new user"
                        let okText = "OK";
                        
                        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
                        
                        let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.Cancel, handler: nil);
                        
                        alert.addAction(okayButton);
                        self.presentViewController(alert, animated: true, completion: nil);
                    }
                    else {
                        room["user1"] = user1;
                        room["user2"] = user2;
                        
                        room.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                            if error == nil {
                                // Setup MessageViewController and Push to the MessageVC
                                messageVC.room = room
                                messageVC.incomingUser = user2
                                self.navigationController?.pushViewController(messageVC, animated: true)
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