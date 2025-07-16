//
//  HistoryRepository.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//

import CoreData

final class HistoryRepository {
  private let context = CoreDataStack.shared.context

  // 내역 등록
  func createHistory(userId: String, duration: Int, startTime: String, type: Int) {
    let history = History(context: context)
    history.userId = userId
    history.duration = duration
    history.startTime = startTime
    history.type = type

    CoreDataStack.shared.saveContext()
  }

  // 내역 조회
  func readHistory(by userId: String) -> History? {
    let fetch = History.fetchRequest()
    fetch.predicate = NSPredicate(format: "userId == %@", userId)
    return (try? CoreDataStack.shared.context.fetch(fetch))?.first
  }
}
