//
//  History+CoreDataProperties.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//
//

import CoreData
import Foundation

public extension History {
  @nonobjc class func fetchRequest() -> NSFetchRequest<History> {
    NSFetchRequest<History>(entityName: "History")
  }

  @NSManaged var userId: String? // 탑승했던 탑승자 아이디
  @NSManaged var duration: Int16 // 총 이용 시간
  @NSManaged var startTime: String? // 탑승 시간
  @NSManaged var type: Int16 // 킥보드 타입(1, 2)
}

extension History: Identifiable {}
