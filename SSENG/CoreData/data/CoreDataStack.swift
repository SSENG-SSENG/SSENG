//
//  CoreDataStack.swift
//  SSENG
//
//  Created by luca on 7/16/25.
//

import CoreData

final class CoreDataStack {
  static let shared = CoreDataStack()

  private init() {}

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "SSENG")
    container.loadPersistentStores { _, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    }
    return container
  }()

  var context: NSManagedObjectContext {
    persistentContainer.viewContext
  }

  func saveContext() {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError
        print("CoreData Save Error:", nserror, nserror.userInfo)
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }

  func deleteAllEntitiesLegacy(entityName: String) {
    let context = CoreDataStack.shared.context
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    do {
      let results = try context.fetch(fetchRequest) as! [NSManagedObject]
      for object in results {
        context.delete(object)
      }
      try context.save()
    } catch {
      print("Delete error: \(error)")
    }
  }

  func deleteAllData() {
    let entities = persistentContainer.managedObjectModel.entities

    for entity in entities {
      guard let name = entity.name else { continue }
      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
      let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      do {
        try context.execute(batchDeleteRequest)
      } catch {
        print("Failed to delete data for entity: \(name), error: \(error)")
      }
    }
<<<<<<< HEAD

    // 변경 사항 저장 (필요 시)
    saveContext()
  }

  func migrateKickboardLocation(in context: NSManagedObjectContext) {
    let fetchRequest = NSFetchRequest<Kickboard>(entityName: "Kickboard")
        do {
            let kickboards = try context.fetch(fetchRequest)
            for kb in kickboards {
                if !kb.location.isEmpty && kb.lat == 0 && kb.lng == 0 {
                    let parts = kb.location.split(separator: "/").map { String($0) }
                    if parts.count == 2,
                       let lat = Double(parts[0].trimmingCharacters(in: .whitespaces)),
                       let lng = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                        kb.lat = lat
                        kb.lng = lng
                    }
                }
            }
            try context.save()
            print("Kickboard location 마이그레이션 완료")
        } catch {
            print("마이그레이션 중 오류 발생: \(error)")
        }
  }

  func deleteCoreDataStore() {
    let storeName = "SSENG"
    let fileManager = FileManager.default

    let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
    guard let applicationSupportURL = urls.last else { return }

    let storeURL = applicationSupportURL.appendingPathComponent("\(storeName).sqlite")

    let files = [
      storeURL,
      storeURL.appendingPathExtension("-shm"),
      storeURL.appendingPathExtension("-wal"),
    ]

    for url in files {
      if fileManager.fileExists(atPath: url.path) {
        do {
          try fileManager.removeItem(at: url)
          print("Deleted: \(url.lastPathComponent)")
        } catch {
          print("Error deleting \(url.lastPathComponent): \(error)")
        }
      }
    }
=======

    // 변경 사항 저장 (필요 시)
    saveContext()
>>>>>>> develop
  }
}
