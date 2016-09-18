//
//  GGCompassNavView.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 14.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

class GGCompassNavView: UIView {
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var distnaceToGo: UILabel!
    @IBOutlet weak var compassCenterImage: UIImageView!
    @IBOutlet weak var compassPointerImage: UIImageView!
    
    var destinationName : String = "No Where!" {
        didSet {
            destinationLabel.text? = destinationName;
        }
    };
    
    // Convience Instantiator for GGCompassNavView
    class func NewGGCompassNavView(owner : AnyObject) -> GGCompassNavView {
        let newView: AnyObject? = NSBundle.mainBundle().loadNibNamed("GGCompassNavView", owner: owner, options: nil).first;
        return (newView as! GGCompassNavView);
    }
    
    func updateDirectionToDestination(newDirection : CLLocationDirection) {
        let radius = 70.0;
        let TO_RAD = M_PI/180;
        
        var newX : Double;
        var newY : Double;
        var newRotation : Double = newDirection;
        
        let width = Double(compassPointerImage.frame.width);
        let height = Double(compassPointerImage.frame.height);
        
        let centerX = compassCenterImage.frame.origin.x;
        let centerY = compassCenterImage.frame.origin.y;
        
        let currentX = Double(compassPointerImage.frame.origin.x);
        let currentY = Double(compassPointerImage.frame.origin.y);
        
        newX = cos(newDirection * TO_RAD) * radius + Double(centerX);
        newY = sin(newDirection * TO_RAD) * radius + Double(centerY);
        
        let theta = atan2(compassPointerImage.transform.b, compassPointerImage.transform.a);
        var dTheta = newDirection - Double(theta);
        
        let pointer : UIImageView = compassPointerImage;
        
        UIView.animateWithDuration(0.5, animations: {
            //            pointer.frame = CGRectMake(CGFloat(newX), CGFloat(newY), CGFloat(width), CGFloat(height));
            let transform : CGAffineTransform = pointer.transform;
            CGAffineTransformTranslate(transform, CGFloat(newX - currentX), CGFloat(newY - currentY));
            CGAffineTransformRotate(transform, (CGFloat(newDirection) * CGFloat(TO_RAD)));
            pointer.transform = transform;
            
            return ();
        });
    }
    
    func updateDistanceToDestination(newDistance : CLLocationDistance) {
        distnaceToGo.text? = String(format: "%0.0f ft", newDistance);
    }
    
    func updateUsersDirection(newDirection : CLLocationDirection) {
        
    }
    
}
