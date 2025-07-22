//
//  KickboardRepository.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//

import CoreData
import Foundation

enum KickboardType: String {
  case kickboard
  case bike
}

final class KickboardRepository {
  private let context = CoreDataStack.shared.context

  // 킥보드 등록
  func registKickboard(registerDate: String, lat: Double, lng: Double, detailLocation: String, type: KickboardType, registerId: String) -> String {
    let kb = Kickboard(context: context)
    let newID = UUID().uuidString
    kb.id = newID
    kb.registerDate = registerDate
    kb.lat = lat
    kb.lng = lng
    kb.detailLocation = detailLocation
    kb.type = type.rawValue
    kb.registerId = registerId // 유저의 아이디를 넣어주세요
    kb.battery = Int16(Int.random(in: 20 ... 100)) // 배터리 잔량 20~100 사이의 랜덤 값
    kb.batteryTime = String(format: "약 %.1f 분", round(Double(kb.battery) * 1.2))
    kb.isRented = false // 초기 상태는 대여 가능
    // 등록한 유저 아이디

    CoreDataStack.shared.saveContext()
    return newID
  }

  // 등록한 킥보드 조회

  func readRegistedKickboard(by registerId: String) -> [Kickboard] {
    let fetch = Kickboard.fetchRequest()
    fetch.predicate = NSPredicate(format: "registerId == %@", registerId)
    return (try? CoreDataStack.shared.context.fetch(fetch)) ?? []
  }

  // 킥보드 조회
  func readKickboard(by id: String) -> Kickboard? {
    let fetch = Kickboard.fetchRequest()
    fetch.predicate = NSPredicate(format: "id == %@", id)
    return (try? CoreDataStack.shared.context.fetch(fetch))?.first
  }

  // 모든 킥보드 조회
  func readAllKickboards() -> [Kickboard] {
    let fetch = Kickboard.fetchRequest()
    return (try? CoreDataStack.shared.context.fetch(fetch)) ?? []
  }

  // 킥보드 대여
  func rentKickboard(id: String) {
    guard let kb = readKickboard(by: id) else { return }

    kb.isRented = true
    CoreDataStack.shared.saveContext()
  }

  // 킥보드 반납
  func returnKickboard(id: String, lat: Double, lng: Double, detailLocation: String) {
    guard let kb = readKickboard(by: id) else { return }

    kb.isRented = false
    kb.lat = lat
    kb.lng = lng
    kb.detailLocation = detailLocation
    CoreDataStack.shared.saveContext()
  }

  func deleteKickboard(by id: String) {
    guard let kb = readKickboard(by: id) else { return }

    context.delete(kb)
    CoreDataStack.shared.saveContext()
  }
}
