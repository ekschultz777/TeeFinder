//
//  CourseSearchController.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//

import Foundation
import SwiftUI
import CoreData

class RootViewModel: ObservableObject, CourseListViewModel {
    private let searchTrie = Trie<CourseID>()
    @Published private(set) var items: [CourseModel] = []
    @Published private(set) var syncing: Bool
    @Published private(set) var error: Error?
    
    init() {
        syncing = true
        commonInit()
    }
    
    private func commonInit() {
//        DispatchQueue.global().async {
            // First, sync from Core Data
            let result = PersistenceController.shared.fetchAllCourses()
            if case .success(let courses) = result {
                courses.forEach { word in
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.updateTrie(with: word)
                    }
                }
            }
            // Second, get items from the API and store them so we can search using them.
            CourseSearchSession.shared.iterateCourses(iteration: { [weak self] result in
                switch result {
                case .success(let courses):
                    // Update or create a new NSManagedObject
                    PersistenceController.shared.persist(courses, synchronous: false) { errors in
                        self?.displayError(from: errors)
                    }
                    // Now update our trie with the new course
                    courses.forEach { self?.updateTrie(with: $0) }
                case .failure(let error):
                    self?.displayError(from: [error])
                }
            }, completion: { [weak self] in
                guard let self else { return }
                syncing = false
            })
//        }
    }
    
    /// A convenience method to throw an error from the main thread.
    /// This function handles error processing for display.
    /// - Parameter errors: The errors to handle and possibly display.
    private func displayError(from errors: [Error]) {
        // For now we will display the first error and use a generic
        // message to inform the user that something went wrong.
        guard let error = errors.first else { return }
        DispatchQueue.main.async { [weak self] in
            self?.error = error
        }
    }
    
    /// Clears the current error.
    public func clearError() {
        DispatchQueue.main.async { [weak self] in
            self?.error = nil
        }
    }
    
    /// Updates the trie data structure with the provided CourseModel object.
    /// This method inserts relevant information from the course into the trie to support prefix-based searching.
    /// - Parameter course: The course to inject relevant information from into the trie data structure.
    private func updateTrie(with course: CourseModel) {
        let id = course.id
        searchTrie.insert(key: course.clubName, value: id)
        searchTrie.insert(key: course.courseName, value: id)
        guard let address = course.location.address,
              let city = course.location.city,
              let state = course.location.state else { return }
        searchTrie.insert(key: address, value: id)
//        searchTrie.insert(key: city, value: id)
//        searchTrie.insert(key: state, value: id)
    }

    /// Computes a difference between the currently shown items and the new list of items,
    /// and updates the stored array in-place.
    /// - Parameter updatedItems: The new collection of items to update the current collection with.
    private func updateCollection(with updatedItems: [CourseID]) {
        // Time complexity is O(n * m) for difference(from:), where
        // n is the count of the collection and m is parameter.count.
        let result = PersistenceController.shared.fetchCourses(from: updatedItems)
        var newItems: [CourseModel] = []
        // We can ignore this error here, it won't give helpful information to the user.
        if case .success(let items) = result { newItems = items }
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
    
    /// A function that searches for courses matching the course name and club name.
    /// The currently used API has no documented way to search by location.
    /// - Parameters:
    ///   - query: The query by which to search.
    ///   - isValid: A check to ensure the current search is still valid after checking the trie.
    ///   - completion: A completion handler that will run once the search is complete.
    public func search(_ query: String, isValid: @escaping (String) -> Bool, completion: @escaping ([CourseID]) -> Void) {
        if query.isEmpty {
            self.updateCollection(with: [])
            return
        }
        // If we have already searched this, then we have no need to update further.
        // In the future, this may need to be bypassed when a certain duration runs,
        // or this might implement a time based cache to determine if we should
        // fetch new data.
        searchTrie.suggestions(query) { [weak self] suggestions in
            guard let self, isValid(query) else { return }
            var suggestions = suggestions
            if !suggestions.isEmpty {
                updateCollection(with: suggestions)
                completion(suggestions)
                return
            }
            
            CourseSearchSession.shared.search(query) { [weak self] response in
                guard let self else { return }
                switch response {
                case .success(let searchResponse):
                    searchResponse.courses.forEach { self.updateTrie(with: $0) }
                    PersistenceController.shared.persist(searchResponse.courses, synchronous: true) { [weak self] errors in
                        guard let self else { return }
                        self.displayError(from: errors)
                    }
                    // FIXME: Get suggestions from trie, not search result
//                    suggestions = searchTrie.suggestions(query)
                    updateCollection(with: searchResponse.courses.map { $0.id })
                case .failure(let error):
                    displayError(from: [error])
                }
                completion(suggestions)
            }
        }
    }
    
    public func autocomplete(_ prefix: String, completion: @escaping (String?) -> Void) {
        self.searchTrie.autocomplete(prefix, completion: completion)
    }
}
