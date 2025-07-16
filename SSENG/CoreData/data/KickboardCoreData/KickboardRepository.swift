//
//  KickboardRepository.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//

import CoreData

final class KickboardRepository {
  private let context = CoreDataStack.shared.context

  // 킥보드 등록
  func registKickboard(registerDate: String, location: String, detailLocation: String, type: String) {
    let kb = Kickboard(context: context)
    kb.id = UUID().uuidString
    kb.registerDate = registerDate
    kb.location = location
    kb.detailLocation = detailLocation
    kb.type = type
    kb.battery = Int.random(in: 80 ... 100) // 배터리 잔량 50~100 사이의 랜덤 값
    kb.batteryTime = "약 \(round(Double(kb.battery)) * 1.2) 분"
    kb.isRented = false // 초기 상태는 대여 가능

    CoreDataStack.shared.saveContext()
  }

  // 킥보드 조회(위치 기반)
  func readKickboard(by id: String) -> Kickboard? {
    let fetch = Kickboard.fetchRequest()
    fetch.predicate = NSPredicate(format: "id == %@", id)
    return (try? CoreDataStack.shared.context.fetch(fetch))?.first
  }

  // 킥보드 대여
  func rentKickboard(id: String) {
    guard let kb = readKickboard(by: id) else { return }

    kb.isRented = true
    CoreDataStack.shared.saveContext()
  }

  // 킥보드 반납
  func returnKickboard(id: String, newLocation: String, detailLocation: String) {
    guard let kb = readKickboard(by: id) else { return }

    kb.isRented = false
    kb.location = newLocation
    kb.detailLocation = detailLocation
    CoreDataStack.shared.saveContext()
  }

  func deleteKickboard(by id: String) {
    guard let kb = readKickboard(by: id) else { return }

    context.delete(kb)
    CoreDataStack.shared.saveContext()
  }
}
