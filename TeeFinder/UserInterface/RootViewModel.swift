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
    let searchTrie = Trie<CourseID>()
    @Published private(set) var items: [CourseModel] = []
    @Published private(set) var syncing: Bool
    @Published private(set) var error: Error?
    
    @Published /*private(set)*/ var searchQuery: String = ""
    @Published /*private(set)*/ var searchSuggestion: String = ""
    
    init() {
        syncing = true
        commonInit()
    }
    
    private func commonInit() {
        // Sync to the API on launch. This function will only sync pages that have
        // not already been synced.
        APISession.shared.iterateCourses(iteration: { [weak self] result in
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
              let city = course.location.city else { return }
        searchTrie.insert(key: address, value: id)
        searchTrie.insert(key: city, value: id)
    }
    
    /// Computes a difference between the currently shown items and the new list of items,
    /// and updates the stored array in-place.
    /// - Parameter updatedItems: The new collection of items to update the current collection with.
    public func updateCollection(with updatedItems: [CourseID]) {
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
                // Prevent us from inserting out of range
                let index = min(offset, updatedItems.count)
                updatedItems.insert(element, at: index)
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
    public func search(_ query: String, comprehensive: Bool, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            // If we have an empty query, then we will update the search results with nothing.
            if query.isEmpty {
                self.updateCollection(with: [])
                return
            }
            // Trie.suggestions() is synchronous and we don't want to block the main thread.
            // Ensure this is called on a background thread.
            assert(!Thread.isMainThread)
            let suggestions = searchTrie.suggestions(query)
            if !suggestions.isEmpty && !comprehensive {
                updateCollection(with: suggestions)
                completion()
                return
            }
            
            // Fetch items with prefix query. If we get results back, we can
            // Still proceed with the API call.
            let result = PersistenceController.shared.fetchItems(withPrefix: query)
            switch result {
            case .success(let courses):
                updateCollection(with: courses.map { $0.id })
                courses.forEach { self.updateTrie(with: $0) }
            default:
                break
            }
            
            // If we don't have any cache in the trie or Core Data,
            // then use the API to get results.
            APISession.shared.search(query) { [weak self] response in
                guard let self else { return }
                switch response {
                case .success(let searchResponse):
                    searchResponse.courses.forEach { self.updateTrie(with: $0) }
                    PersistenceController.shared.persist(searchResponse.courses, synchronous: true) { [weak self] errors in
                        guard let self else { return }
                        self.displayError(from: errors)
                    }
                    let mergedResult = merge(suggestions, with: searchResponse.courses.map { $0.id })
                    updateCollection(with: mergedResult)
                case .failure(let error):
                    displayError(from: [error])
                }
                completion()
            }
        }
    }
    
    /// Merges two arrays of hashable values using their hashes.
    ///
    /// This method has both a space and time complexity of O(n) where n is the count of items or other, whichever is larger.
    /// - Parameters:
    ///   - items: An array to merge.
    ///   - other: The array to consume into the first array.
    /// - Returns: The merged array.
    public func merge<T: Hashable>(_ items: [T], with other: consuming [T]) -> [T] {
        var hashMap: [Int: T] = [:]
        for item in items {
            hashMap[item.hashValue] = item
        }
        for item in other {
            hashMap[item.hashValue] = item
        }
        return Array(hashMap.values)
    }
    
    public func autocomplete(_ prefix: String) -> String {
        return searchTrie.autocomplete(prefix) ?? ""
    }
}
