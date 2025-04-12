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
    private let searchTrie = LRUCache<Course>()
    @Published private(set) var items: [Course] = []
    
    // FIXME: This class is doing two things: Storing trie info in Core Data and updating item list.
    // Change that to make this two separate classes within this class so we are SOLID
    
    init() {
        // Build trie with cached searches.
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.perform {
            let request: NSFetchRequest<CourseMO> = CourseMO.fetchRequest()
            do {
                let courses = try context.fetch(request)
                // This will have time complexity O(n) where n is the number of cached courses.
                for courseMO in courses {
                    if let course = try? JSONDecoder().decode(Course.self, from: courseMO.data) {
                        self.searchTrie.insert(key: course.clubName, value: course)
                    }
                }
            } catch {
                print("Failed to fetch courses: \(error)")
            }
        }
    }

    public func updateList(with newItems: [Course]) {
        // Time complexity is O(n * m) for difference(from:), where
        // n is the count of the collection and m is parameter.count.
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
    
    public func search(_ query: String, completion: @escaping ([Course]) -> Void) {
        // If we have already searched this, then we have no need to update further.
        // In the future, this may need to be bypassed when a certain duration runs,
        // or this might implement a time based cache to determine if we should
        // fetch new data.
        var suggestions = searchTrie.suggestions(query)
        if !suggestions.isEmpty {
            guard items != suggestions else { return }
            updateList(with: suggestions)
            completion(suggestions)
            return
        }

        CourseSearchSession.shared.search(query) { [weak self] response in
            guard let self else { return }
            switch response {
            case .success(let searchResponse):
                searchResponse.courses.forEach {
                    self.searchTrie.insert(key: $0.clubName, value: $0)
                }
                suggestions = searchTrie.suggestions(query)
                guard items != suggestions else { return }
                updateList(with: suggestions)
            case .failure(let error):
                print(error)
            }
            completion(suggestions)
        }
    }
    
    public func autocomplete(_ prefix: String) -> String {
        searchTrie.autocomplete(prefix)?.clubName ?? ""
    }
    
    public func persist(_ item: Course) {
        let context = PersistenceController.shared.container.newBackgroundContext()
        context.perform {
            let request: NSFetchRequest<CourseMO> = CourseMO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", item.id)
            request.fetchLimit = 1
            
            do {
                let data = try JSONEncoder().encode(item)
                let result = try context.fetch(request)
                if let course = result.first {
                    course.data = data
                } else {
                    let course = CourseMO(context: context)
                    course.id = Int32(item.id)
                    course.data = data
                }
                try context.save()
            } catch {
                print("Failed to update Course with id \(item.id): \(error)")
            }
        }
    }
}

