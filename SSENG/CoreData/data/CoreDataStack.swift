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

    saveContext()
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
    saveContext()
  }
}
