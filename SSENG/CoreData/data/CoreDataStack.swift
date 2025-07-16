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
}
