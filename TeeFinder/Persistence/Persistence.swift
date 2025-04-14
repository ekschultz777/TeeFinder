//
//  Persistence.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    private lazy var backgroundContext = {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return context
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "TeeFinder")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController {
    /// An internal convenience function to handle the logic of updating or creating a persistant item for the given models.
    /// - Parameters:
    ///   - items: The items to persist.
    ///   - context: The context to use to create items.
    ///   - completion: An optional completion handler to which all errors that occurred during processing will be passed.
    private func _persist(_ items: [CourseModel], in context: NSManagedObjectContext, completion: (([Error]) -> Void)?) {
        var errors: [Error] = []
        
        let request: NSFetchRequest<Course> = Course.fetchRequest()
        request.predicate = NSPredicate(format: "\(#keyPath(Course.apiId)) IN %@", NSArray(array: items.map { Int32($0.id) }))
        do {
            let results = try context.fetch(request)
            let idsSet = Set(results.map { Int($0.apiId) })
            let itemsToCreate = items.filter { !idsSet.contains($0.id) }
            let itemDicts: [[String: Any]] = itemsToCreate.compactMap { item in
                guard let data = try? JSONEncoder().encode(item) else { return nil }
                return [
                    #keyPath(Course.apiId): item.id,
                    #keyPath(Course.data): data
                ]
            }
            let request = NSBatchInsertRequest(entityName: "Course", objects: itemDicts)
            let _ = try context.execute(request) as? NSBatchInsertResult
        } catch {
            errors.append(error)
        }
        do { try context.save() } catch { errors.append(error) }
        completion?(errors)
    }
    
    /// This function updates or creates new items to be persisted in Core Data.
    /// - Parameters:
    ///   - items: The items to persist.
    ///   - synchronous: A flag used to denote whether this should occur synchronously or asynchronously.
    ///   - completion: An optional completion handler to which all errors that occurred during processing will be passed.
    public func persist(_ items: [CourseModel], synchronous: Bool = true, completion: (([Error]) -> Void)? = nil) {
        if synchronous {
            backgroundContext.performAndWait {
                _persist(items, in: backgroundContext, completion: completion)
            }
        } else {
            backgroundContext.perform { [weak self] in
                guard let self else { return }
                self._persist(items, in: self.backgroundContext, completion: completion)
            }
        }
    }
    
    /// Fetches courses from the persistent store based on id and returns their model representations.
    /// - Parameter ids: The identifiers to search the persistent store with a predicate using.
    /// - Returns: The model representations of all currently stored items.
    public func fetchCourses(from ids: [CourseID]) -> Result<[CourseModel], Error> {
        return backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<Course> = Course.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "\(#keyPath(Course.apiId)) IN %@", NSArray(array: ids))
            do {
                let courses = try backgroundContext.fetch(fetchRequest).compactMap { try? JSONDecoder().decode(CourseModel.self, from: $0.data) }
                return .success(courses)
            } catch {
                return .failure(error)
            }
        }
    }
    
    /// Fetches courses from the persistent store based on id and returns their model representations.
    /// - Parameter ids: The identifiers to search the persistent store with a predicate using.
    /// - Returns: The model representations of all currently stored items.
    public func fetchAllCourses() -> Result<[CourseModel], Error> {
        return backgroundContext.performAndWait {
            let fetchRequest: NSFetchRequest<Course> = Course.fetchRequest()
            do {
                let courses = try backgroundContext.fetch(fetchRequest).compactMap { try? JSONDecoder().decode(CourseModel.self, from: $0.data) }
                return .success(courses)
            } catch {
                return .failure(error)
            }
        }
    }

}
