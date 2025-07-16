//
//  User+CoreDataProperties.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: String?
    @NSManaged public var isRiding: Bool
    @NSManaged public var name: String?
    @NSManaged public var password: String?

}

extension User : Identifiable {

}
