//
//  Session.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 15.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import Foundation
import CoreData


class Session: NSManagedObject {
  
  @NSManaged var session_name: String
  @NSManaged var clothes: NSSet
  
}
