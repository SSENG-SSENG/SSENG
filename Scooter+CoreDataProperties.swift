//
//  Scooter+CoreDataProperties.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//
//

import Foundation
import CoreData


extension Scooter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Scooter> {
        return NSFetchRequest<Scooter>(entityName: "Scooter")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var registerDate: String?
    @NSManaged public var location: String?
    @NSManaged public var isRented: Bool
    @NSManaged public var battery: Int16

}

extension Scooter : Identifiable {

}
