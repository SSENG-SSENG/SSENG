//
//  Kickboard+CoreDataProperties.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//
//

import Foundation
import CoreData


extension Kickboard {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Kickboard> {
        return NSFetchRequest<Kickboard>(entityName: "Kickboard")
    }

    @NSManaged public var battery: Int16
    @NSManaged public var id: UUID?
    @NSManaged public var isRented: Bool
    @NSManaged public var location: String?
    @NSManaged public var registerDate: String?
    @NSManaged public var type: String?

}

extension Kickboard : Identifiable {

}
