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
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.locationManager.delegate = self
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        self.locationManager.requestWhenInUseAuthorization()
//        self.locationManager.startUpdatingLocation()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                println("Error: " + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                
                let pm = placemarks[0] as! CLPlacemark
                self.displayLocationInfo(pm)
                
            } else {
                
                println("Error with the data.")
                
            }
        })
    }

    func displayLocationInfo(placemark: CLPlacemark) {
        
        self.locationManager.stopUpdatingLocation()
        // Console messages
        println(placemark.locality)
        println(placemark.postalCode)
        println(placemark.administrativeArea)
        println(placemark.country)
        println(placemark.location.coordinate.latitude)
        println(placemark.location.coordinate.longitude)
        let lat: Double = placemark.location.coordinate.latitude;
        let long: Double = placemark.location.coordinate.longitude;
        
        // Alert messages
        let title = placemark.locality;
        let message = String(stringInterpolationSegment: placemark.location.coordinate.latitude);
        let okText = "OK";
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
        
        let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.Cancel, handler: nil);
        
        alert.addAction(okayButton);
        presentViewController(alert, animated: true, completion: nil);
        
        // Storing location data on parse
        let point = PFGeoPoint(latitude: lat, longitude: long)
        
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
        println("Error: " + error.localizedDescription)
    }

    @IBAction func NewChatButton_Click(sender: AnyObject) {
        
        PFUser.enableAutomaticUser();
        PFUser.currentUser()!.incrementKey("RunCount");
        PFUser.currentUser()!.saveInBackground();
        
//            let title = "Display title";
//            let message = "You just tapped 'Display Alert'.";
//            let okText = "OK";
//        
//            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert);
//        
//            let okayButton = UIAlertAction(title: okText, style: UIAlertActionStyle.Cancel, handler: nil);
//        
//            alert.addAction(okayButton);
//            presentViewController(alert, animated: true, completion: nil);

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
        
        
            
        
    }
}




































