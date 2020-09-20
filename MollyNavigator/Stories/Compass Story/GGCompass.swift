//
//  GGCompass.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 14.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import Foundation
import CoreLocation
import Darwin

class GGCompass : NSObject {
  
  var destination : CLLocation?
  
  override init() {
    super.init()
  }
  
  init(destination : CLLocation) {
    super.init();
    self.destination = destination
  }
  
  func directionAndDistanceToDestination(_ userLocation : CLLocation) ->
  (CLLocationDegrees, CLLocationDistance) {
    var heading = 0.0;
    var distance = 0.0;
    
    if let destPosition = destination?.coordinate {
      // Helpful constants
      distance = distanceBetweenPoints(userLocation.coordinate, point2: destPosition);
      heading = headingFromPointToPoint(userLocation.coordinate, to : destPosition);
    }
    
    return (heading, distance);
  }
  
  func distanceBetweenPoints(_ point1 : CLLocationCoordinate2D,
                             point2 : CLLocationCoordinate2D) -> Double {
    let TO_RAD = Double.pi / 180;
    let R = 3959.0 * 5280.0 // Radius of the earth in feet
    
    let lat1 = point1.latitude;
    let long1 = point1.longitude;
    let lat2 = point2.latitude;
    let long2 = point2.longitude;
    
    // Calculate distance between two lat, long points
    let phi1 = lat1 * TO_RAD;
    let phi2 = lat2 * TO_RAD;
    
    let dPhi = (lat2 - lat1) * TO_RAD;
    let dLambda = (long2 - long1) * TO_RAD;
    
    let a = pow(sin(dPhi/2), 2.0) + cos(phi1) * cos(phi2) *
      pow(sin(dLambda/2), 2.0);
    let c = 2 * atan2(sqrt(a), sqrt(1-a));
    
    return R * c;
  }
  
  
  func headingFromPointToPoint(_ from : CLLocationCoordinate2D, to : CLLocationCoordinate2D) -> CLLocationDirection {
    let TO_RAD = Double.pi / 180;
    let TO_DEG = 180 / Double.pi;
    
    // Set up constants in mathemtical form
    let phi1 = from.latitude * TO_RAD;
    let phi2 = to.latitude * TO_RAD;
    
    let lambda1 = from.longitude * TO_RAD;
    let lambda2 = to.longitude * TO_RAD;
    
    let y = sin(lambda2 - lambda1) * cos(phi2);
    let x = cos(phi1)*sin(phi2) - sin(phi1)*cos(phi2)*cos(lambda2 - lambda1);
    
    return atan2(y, x) * TO_DEG;
  }
  
}
