//
//  GGCompassNavigatorController.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 15.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class GGCompassNavigatorController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var distnaceToGo: UILabel!
    @IBOutlet weak var compassPointerImage: UIImageView!
    
    var locationManager: CLLocationManager!
    var compass : GGCompass!
    var image: Image?
    var oldRad: Float?

    var destinationName : String = "No Where!" {
        didSet {
            destinationLabel.text? = destinationName;
        }
    };
    
    func updateDirectionToDestination(_ newDirection : CLLocationDirection) {
        let TO_RAD = Double.pi / 180;
        
        var direction = Float(newDirection)
        direction = direction - 180
        if direction > 180 {
            direction = 360 - direction
        } else {
            direction = 0 - direction
        }

        if let arrowImageView = self.compassPointerImage {
            UIView.animate(withDuration: 5, animations: { () -> Void in
                arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(direction) * CGFloat(TO_RAD))
            })
        }
 
    }
    
    func updateDistanceToDestination(_ newDistance : CLLocationDistance) {
        distnaceToGo.text? = String(format: "%0.0f mt", newDistance * 0.3048);
    }
    
    func updateUsersDirection(_ newDirection : CLLocationDirection) {
        updateDirectionToDestination(newDirection)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.compass = GGCompass();
        self.title = image?.clothe.name
        let defaultDestination = CLLocation(latitude: image?.longtitude as! Double, longitude: image?.latitude as! Double);
        self.compass.destination = defaultDestination
        self.destinationName = (image?.clothe.name)!;
        startHeadAndLocationUpdates();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startHeadAndLocationUpdates() {
        if(locationManager == nil) {
            locationManager = CLLocationManager();
        }
        locationManager.delegate = self;
        
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            locationManager.requestAlwaysAuthorization();
        }
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1
        locationManager.startUpdatingLocation();
        locationManager.startUpdatingHeading();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first as CLLocation? {
            let (newDirection, newDistance) = compass.directionAndDistanceToDestination(location);
            self.updateDirectionToDestination(newDirection);
            self.updateDistanceToDestination(newDistance);
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
            self.updateUsersDirection(newHeading.trueHeading);
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog(error.localizedDescription);
    }
    
    func someNewUnusedFunction() {
        let someDoIt = {
            print("Hello")
        }
        
        someDoIt()
    }

    
}
