//
//  UserRepository.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//

import CoreData

final class UserRepository {
  private let context = CoreDataStack.shared.context

  // 사용자 등록
  func createUser(id: String, name: String, password: String) {
    let user = User(context: context)
    user.id = id
    user.name = name
    user.password = password
    user.isRiding = false // 기본값은 false로 설정 (하차 상태)

    CoreDataStack.shared.saveContext()
  }

  // 사용자 조회
  func readUser(by id: String) -> User? {
    let fetch = User.fetchRequest()
    fetch.predicate = NSPredicate(format: "id == %@", id)
    return (try? CoreDataStack.shared.context.fetch(fetch))?.first
  }

  // 사용자 탑승 상태 변경(true <-> false)
  func updateUserRiding(id: String, isRiding: Bool) {
    guard let user = readUser(by: id) else { return }

    user.isRiding = isRiding
    CoreDataStack.shared.saveContext()
  }

  // 사용자 이름(닉네임) 변경
  func updateUserName(id: String, name: String) {
    guard let user = readUser(by: id) else { return }

    user.name = name
    CoreDataStack.shared.saveContext()
  }

  // 사용자 삭제(쓰일 일이 있을까)
  func deleteUser(by id: String) {
    guard let user = readUser(by: id) else { return }

    context.delete(user)
    CoreDataStack.shared.saveContext()
  }
}
