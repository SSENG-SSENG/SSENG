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

      // 변경 사항 저장 (필요 시)
      saveContext()
  }
}
