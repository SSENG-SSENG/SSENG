//
//  Kickboard+CoreDataProperties.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//
//

import CoreData
import Foundation

extension Kickboard {
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Kickboard> {
    return NSFetchRequest<Kickboard>(entityName: "Kickboard")
  }

  @NSManaged var id: UUID? // 킥보드 고유값(UUID)
  @NSManaged var battery: Int16 // 킥보드 배터리 잔량(80)
  @NSManaged var registerDate: String? // 킥보드 등록 날짜("2025-01-01 12:00:00")
  @NSManaged var location: String? // 킥보드 위치("lat/lng")
  @NSManaged var type: String? // 킥보드 타입("1", "2")
  @NSManaged var isRented: Bool // 킥보드 대여 상태(true, false)
  // true: 대여 불가(탑승자 있음), false: 대여 가능(탑승자 없음)
}

extension Kickboard: Identifiable {}
