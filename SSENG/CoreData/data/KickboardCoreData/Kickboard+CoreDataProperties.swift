//
//  Kickboard+CoreDataProperties.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//
//

import CoreData
import Foundation

public extension Kickboard {
  @nonobjc class func fetchRequest() -> NSFetchRequest<Kickboard> {
    NSFetchRequest<Kickboard>(entityName: "Kickboard")
  }

  @NSManaged var id: String? // 킥보드 고유값(UUID)
  @NSManaged var battery: Int16 // 킥보드 배터리 잔량(80)
  @NSManaged var batteryTime: String // 킥보드 배터리 남은 시간("약 120 분")
  @NSManaged var registerDate: String? // 킥보드 등록 날짜("2025-01-01 12:00:00")
  @NSManaged var lat: Double // 위도(123.456)
  @NSManaged var lng: Double // 경도(123.456) 경찰과 도둑...
  @NSManaged var detailLocation: String? // 킥보드 위치("약국 앞")
  @NSManaged var type: String // 킥보드 타입("1", "2")
  @NSManaged var isRented: Bool // 킥보드 대여 상태(true: 대여 불가, false: 대여 가능)
  @NSManaged var registerId: String // 킥보드 등록한 사람의 아이디
}

extension Kickboard: Identifiable {}

extension Kickboard {
    var kickboardType: KickboardType? {
      return KickboardType(rawValue: self.type)
    }
}
