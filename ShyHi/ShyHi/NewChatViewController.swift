//
//  NewChatViewController.swift
//  ShyHi
//
//  Created by Tae Hwan Lee on 4/26/15.
//  Copyright (c) 2015 ShyHi. All rights reserved.
//

import UIKit
import CoreLocation

class NewChatViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var NewChatButton: UIButton!
    @IBOutlet weak var ViewConversationsButton: UIButton!
    
    let locationManager = CLLocationManager()
    var point: PFGeoPoint = PFGeoPoint(latitude: 0, longitude: 0);
    var userArray = [PFUser]();
    var index = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PFUser.enableAutomaticUser();
        PFUser.currentUser()!.incrementKey("RunCount");
        PFUser.currentUser()!.saveInBackground();
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        var lat: Double = placemark.location.coordinate.latitude;
        var long: Double = placemark.location.coordinate.longitude;
        point = PFGeoPoint(latitude: lat, longitude: long);
        
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

    func showChatOverview() {
        let sb = UIStoryboard(name: "Main", bundle: nil);
        let overviewVC = sb.instantiateViewControllerWithIdentifier("ChatOverviewVC") as! OverviewTableViewController;
        overviewVC.navigationItem.setHidesBackButton(true, animated: false);
        self.navigationController?.pushViewController(overviewVC, animated: true);
    }
    
    func showAlert() {
        
        let title = "Error";
        let message = "No new user"
        let okText = "OK";
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        
        let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.Cancel, handler: nil);
        
        alert.addAction(okayButton);
        self.presentViewController(alert, animated: true, completion: nil);
    }
    
    @IBAction func ViewConversationsButton_Click(sender: AnyObject) {
        
        showChatOverview();
        
    }
    
    @IBAction func NewChatButton_Click(sender: AnyObject) {

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        var point2 = PFGeoPoint(latitude: 33.79, longitude: -117.85)
        
        var query = PFQuery(className: "_User")
        query.whereKey("Location", nearGeoPoint: point2, withinMiles: 50) // point2 is used for iOS simulator
        query.limit = 10;
        
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
            if (userArray[index].objectId != PFUser.currentUser()?.objectId) {
                
                var user1 = PFUser.currentUser();
                //                    var user2 = userArray[0] as PFUser;
                var user2 = userArray[index] as PFUser;
                var room = PFObject(className: "Room");
                
                // Setting up the MessageViewController
                let sb = UIStoryboard(name: "Main", bundle: nil)
                let messageVC = sb.instantiateViewControllerWithIdentifier("MessageViewController") as! MessageViewController;
                messageVC.navigationItem.setHidesBackButton(true, animated: false);
                let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1!, user2, user2, user1!);
                let roomQuery = PFQuery(className: "Room", predicate: pred);
                
                roomQuery.findObjectsInBackgroundWithBlock({ (results: [AnyObject]?, error: NSError?) -> Void in
                    if error == nil {
                        if results!.count == 0 { // room already exists
                            room["user1"] = user1;
                            room["user2"] = user2;
                            
                            room.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                                if error == nil {
                                    // Setup MessageViewController and Push to the MessageVC
                                    messageVC.room = room
                                    messageVC.incomingUser = user2
                                    self.navigationController?.pushViewController(messageVC, animated: true);
                                    ++self.index;
                                }
                            })
                        }
                        else {
                 
                            // self.showAlert();
                        }
                    }
                })
            }
            
        }
    }
}