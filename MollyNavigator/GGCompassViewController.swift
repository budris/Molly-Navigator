//
//  GGCompassViewController.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 14.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import UIKit
import CoreLocation

class GGCompassViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var compass : GGCompass!
    var compassView : GGCompassNavView!;
    var image: Image?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.compassView = GGCompassNavView.NewGGCompassNavView(self);
        
        self.view = compassView;
        self.compass = GGCompass();
        self.title = image?.clothe.name
        
        // For Debugging in the simulator
        // 1 Pine Street SF, CA
        let defaultDestination = CLLocation(latitude: 27.332334, longitude: 53);
        self.compass.destination = defaultDestination
        self.compassView.destinationName = "20200 Lucille Ave";
        
        startHeadAndLocationUpdates();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startHeadAndLocationUpdates() {
        if(locationManager == nil) {
            locationManager = CLLocationManager();
        }
        
        locationManager.delegate = self;
        
        NSLog("\(CLLocationManager.authorizationStatus())");
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            locationManager.requestAlwaysAuthorization();
        }
        
        locationManager.startUpdatingLocation();
        locationManager.startUpdatingHeading();
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first as CLLocation? {
            NSLog("Lat: \(location.coordinate.latitude), Long: \(location.coordinate.longitude)");
            
            var (newDirection, newDistance) = compass.directionAndDistanceToDestination(location);
            compassView.updateDirectionToDestination(newDirection);
            compassView.updateDistanceToDestination(newDistance);
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateHeading newHeading: CLHeading?) {
        if let heading = newHeading {
            NSLog("Heading: \(heading)");
            
            compassView.updateUsersDirection(heading.trueHeading);
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog(error.description);
    }
}

