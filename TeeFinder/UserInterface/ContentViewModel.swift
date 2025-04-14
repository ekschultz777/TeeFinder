//
//  CourseSearchController.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//

import Foundation
import SwiftUI
import CoreData

class ContentViewModel: ObservableObject {
    private let searchTrie = Trie<CourseID>()
    @Published private(set) var items: [CourseModel] = []
    @Published private(set) var syncing: Bool
    
    // FIXME: This class is doing two things: Storing trie info in Core Data and updating item list.
    // Change that to make this two separate classes within this class so we are SOLID
        
    init() {
        self.syncing = true
        CourseSearchSession.shared.iterateCourses(iteration: { [weak self] courses in
            // Update or create a new NSManagedObject
            self?.persist(courses)
            // Now update our trie with the new course // FIXME: Trie should be thread safe
            courses.forEach { self?.updateTrie(with: $0) }
        }, completion: { [weak self] in
            guard let self else { return }
            syncing = false
        })
    }
    
    func updateTrie(with course: CourseModel) {
        let id = course.id
        searchTrie.insert(key: course.clubName, value: id)
        searchTrie.insert(key: course.courseName, value: id)
        guard let address = course.location.address,
              let city = course.location.city,
              let state = course.location.state else { return }
        searchTrie.insert(key: address, value: id)
        searchTrie.insert(key: city, value: id)
        searchTrie.insert(key: state, value: id)
    }
    
    func fetchCourses(from ids: [CourseID]) -> [CourseModel] {
        let context = PersistenceController.shared.container.newBackgroundContext()
        return context.performAndWait {
            let fetchRequest: NSFetchRequest<Course> = Course.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id IN %@", NSArray(array: ids))
            do {
                let courses = try context.fetch(fetchRequest).compactMap { try? JSONDecoder().decode(CourseModel.self, from: $0.data) }
                return courses
            } catch {
                print("Fetch failed:", error)
                return []
            }
        }
    }

    public func updateList(with updatedItems: [CourseID]) {
        // Time complexity is O(n * m) for difference(from:), where
        // n is the count of the collection and m is parameter.count.
        let newItems = fetchCourses(from: updatedItems)
        let diff = newItems.difference(from: items)
        var updatedItems = items
        for change in diff {
            switch change {
            case let .remove(offset, _, _):
                updatedItems.remove(at: offset)
            case let .insert(offset, element, _):
                updatedItems.insert(element, at: offset)
            }
        }
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            withAnimation(.linear(duration: 0.25)) {
                self.items = updatedItems
            }
        }
    }
    
    public func search(_ query: String, completion: @escaping ([CourseID]) -> Void) {
        // If we have already searched this, then we have no need to update further.
        // In the future, this may need to be bypassed when a certain duration runs,
        // or this might implement a time based cache to determine if we should
        // fetch new data.
        var suggestions = searchTrie.suggestions(query)
        if !suggestions.isEmpty {
            guard items.map({ $0.id }) != suggestions else { return }
            updateList(with: suggestions)
            completion(suggestions)
            return
        }

        CourseSearchSession.shared.search(query) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let searchResponse):
                searchResponse.courses.forEach { self.updateTrie(with: $0) }
                persist(searchResponse.courses, synchronous: true)
                suggestions = searchTrie.suggestions(query)
                guard items.map({ $0.id }) != suggestions else { return }
                updateList(with: suggestions)
            case .failure(let error):
                print(error)
            }
            completion(suggestions)
        }
    }

    public func completeSearch(_ query: String) {
        // If we have already searched this, then we have no need to update further.
        // In the future, this may need to be bypassed when a certain duration runs,
        // or this might implement a time based cache to determine if we should
        // fetch new data.
        fatalError()
    }
    
    public func autocomplete(_ prefix: String) -> String {
        searchTrie.autocomplete(prefix) ?? ""
    }
    
    private func _persist(_ items: [CourseModel], in context: NSManagedObjectContext) {
        for item in items {
            let request: NSFetchRequest<Course> = Course.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", Int32(item.id))
            request.fetchLimit = 1
            do {
                let courseMO: Course = try context.fetch(request).first ?? {
                    let newCourseMO = Course(context: context)
                    newCourseMO.id = Int32(item.id)
                    return newCourseMO
                }()
                courseMO.data = try JSONEncoder().encode(item)
                
                let data = try JSONEncoder().encode(item)
                let result = try context.fetch(request)
                if let course = result.first {
                    course.data = data
                } else {
                    let course = Course(context: context)
                    course.id = Int32(item.id)
                    course.data = data
                }
            } catch {
                print("Failed to update Course with id \(item.id): \(error)")
            }
        }
        do { try context.save() } catch { print("Failed to update courses: \(error)") }
    }
    
    public func persist(_ items: [CourseModel], synchronous: Bool = true) {
        let context = PersistenceController.shared.container.newBackgroundContext()
        if synchronous {
            context.performAndWait {
                _persist(items, in: context)
            }
        } else {
            context.perform { [weak self] in
                guard let self else { return }
                _persist(items, in: context)
            }
        }
    }
}

