//
//  Clothe.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 15.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import Foundation
import CoreData


class Clothe: NSManagedObject {
  
  @NSManaged var name: String
  @NSManaged var image: NSSet
  @NSManaged var session: Session
  
}
