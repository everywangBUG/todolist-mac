import CoreData
import Foundation

class CoreDataManager {
    static let shared = CoreDataManager()

    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let bundle = Bundle.main
        
        guard let modelURL = bundle.url(forResource: "TodoList", withExtension: "momd") ??
              bundle.url(forResource: "TodoList", withExtension: "mom") else {
            fatalError("Core Data model not found in bundle: \(bundle.bundlePath)")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load Core Data model from \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: "TodoList", managedObjectModel: model)
        
        let storeURL = Self.applicationSupportDirectory.appendingPathComponent("TodoList.sqlite")
        
        let description = NSPersistentStoreDescription(url: storeURL)
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        
        container.persistentStoreDescriptions = [description]
        
        var loadError: Error?
        
        container.loadPersistentStores { desc, error in
            if let error = error {
                loadError = error
                print("Core Data load error: \(error.localizedDescription)")
            }
        }
        
        if loadError != nil {
            print("Falling back to temporary directory for storage")
            let fallbackURL = Self.temporaryDirectory.appendingPathComponent("TodoList.sqlite")
            
            let fallbackContainer = NSPersistentContainer(name: "TodoList", managedObjectModel: model)
            let fallbackDescription = NSPersistentStoreDescription(url: fallbackURL)
            fallbackDescription.shouldMigrateStoreAutomatically = true
            fallbackDescription.shouldInferMappingModelAutomatically = true
            
            fallbackContainer.persistentStoreDescriptions = [fallbackDescription]
            
            fallbackContainer.loadPersistentStores { desc, error in
                if let error = error {
                    fatalError("Unable to load persistent stores: \(error.localizedDescription)")
                }
            }
            
            fallbackContainer.viewContext.automaticallyMergesChangesFromParent = true
            fallbackContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            return fallbackContainer
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    private static var applicationSupportDirectory: URL {
        let paths = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportDir = paths.first!
        let appDir = appSupportDir.appendingPathComponent("TodoList")
        
        do {
            try FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create app support directory: \(error.localizedDescription)")
        }
        
        return appDir
    }

    private static var temporaryDirectory: URL {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("TodoList")
        
        do {
            try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create temporary directory: \(error.localizedDescription)")
        }
        
        return tempDir
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Error saving context: \(error.localizedDescription)")
            }
        }
    }
}
