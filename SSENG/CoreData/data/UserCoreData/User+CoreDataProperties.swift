//
//  User+CoreDataProperties.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//
//

import CoreData
import Foundation

public extension User {
  @nonobjc class func fetchRequest() -> NSFetchRequest<User> {
    NSFetchRequest<User>(entityName: "User")
  }

  @NSManaged var id: String? // 사용자 아이디("sseng")
  @NSManaged var password: String? // 사용자 비밀번호("1q2w3e4")
  @NSManaged var name: String? // 사용자 닉네임("쌩_관리자")
  @NSManaged var isRiding: Bool // 사용자 탑승중 여부(true: 탑승 상태, false: 하차 상태)
}

extension User: Identifiable {}
