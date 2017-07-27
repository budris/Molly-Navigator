//
//  Image.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 15.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import Foundation
import CoreData


class Image: NSManagedObject {
    @NSManaged var image: Data
    @NSManaged var latitude: NSNumber?
    @NSManaged var longtitude: NSNumber?
    @NSManaged var date: Date?
    @NSManaged var price: NSNumber?
    @NSManaged var clothe: Clothe
}
