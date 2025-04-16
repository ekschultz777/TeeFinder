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
    @Published private(set) var syncing: Bool = false
    @Published private(set) var error: Error?
    @Published var searchQuery: String = ""
    @Published var searchSuggestion: String = ""
            
    private var debounceWork: DispatchWorkItem? = nil
    /// Simple debounce function.
    /// - Parameters:
    ///   - time: the amount of time to debounce for.
    ///   - closure: The work that should execute once the debouncer deems it valid to perform work.
    private func debounce(for time: TimeInterval, _ closure: @escaping () -> Void) {
        debounceWork?.cancel()
        debounceWork = DispatchWorkItem { closure() }
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: debounceWork!)
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
    private func updateTrie(with courses: [CourseModel]) {
        var courseData: [(key: String, value: CourseID)] = []
        for course in courses {
            let id = course.id
            courseData.append((key: course.clubName, value: id))
            courseData.append((key: course.courseName, value: id))
            guard let address = course.location.address,
                  let city = course.location.city else { continue }
            courseData.append((key: address, value: id))
            courseData.append((key: city, value: id))
        }
        searchTrie.insert(courseData)
    }
    
    /// Computes a difference between the currently shown items and the new list of items,
    /// and updates the stored array of items in-place.
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
    
    private func _search(_ query: String, comprehensive: Bool, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self else { return }
            // Trie.suggestions() is synchronous and we don't want to block the main thread.
            // Ensure this is called on a background thread.
            assert(!Thread.isMainThread)
            // 1. Update the collection from the trie
            var suggestions = searchTrie.suggestions(query)
            if !suggestions.isEmpty && !comprehensive {
                updateCollection(with: suggestions)
                completion()
                return
            }
            
            // 2. Fetch items with prefix query and merge them with the trie suggestions.
            let result = PersistenceController.shared.fetchItems(withPrefix: query)
            switch result {
            case .success(let courses):
                suggestions = merge(suggestions, with: courses.map { $0.id })
                self.updateTrie(with: courses)
            default:
                break
            }
            
            // 3. Fetch items from the API and merge them with the trie and Core Data cache.
            APISession.shared.search(query) { [weak self] response in
                guard let self else { return }
                switch response {
                case .success(let searchResponse):
                    self.updateTrie(with: searchResponse.courses)
                    PersistenceController.shared.persist(searchResponse.courses, synchronous: true) { errors in
                        // We don't need to alert the user of cache errors.
                        guard !errors.isEmpty else { return }
                        print(errors)
                    }
                    
                    if query == self.searchQuery {
                        let mergedResult = merge(suggestions, with: searchResponse.courses.map { $0.id })
                        updateCollection(with: mergedResult)
                    }
                case .failure(let error):
                    if comprehensive {
                        // We don't need to show an error when we are optionally
                        // showing suggestions.
                        displayError(from: [error])
                    }
                    print(error)
                }
                completion()
            }
        }
    }
    
    /// A function that searches for courses matching the course name and club name.
    /// The currently used API has no documented way to search by location.
    /// - Parameters:
    ///   - query: The query by which to search.
    ///   - isValid: A check to ensure the current search is still valid after checking the trie.
    ///   - completion: A completion handler that will run once the search is complete.
    public func search(_ query: String, comprehensive: Bool, completion: (() -> Void)? = nil) {
        if query.isEmpty {
            searchSuggestion = ""
            debounceWork?.cancel()
            updateCollection(with: [])
            completion?()
            return
        }
        if comprehensive {
            searchSuggestion = ""
        }
        debounce(for: 0.5) { [weak self] in
            guard let self else { return }
            _search(query, comprehensive: comprehensive) {
                completion?()
                guard !comprehensive else { return }
                self.suggestAutocompletion()
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

extension RootViewModel: AutocompleteViewModel {
    /// Suggests an autocompletion to the text field this is supplied to.
    public func suggestAutocompletion() {
        // Run suggestion lookup on a background queue, it will block the thread it is run on.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            let suggestion = autocomplete(searchQuery)
            // Update UI on the main thread
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                // Check that the suggestion still matches the current searchQuery
                if suggestion.hasPrefix(searchQuery) && !self.searchQuery.isEmpty {
                    searchSuggestion = suggestion
                } else {
                    // Clear the suggestion it if it's no longer valid
                    searchSuggestion = ""
                }
            }
        }
    }
}
