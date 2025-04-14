//
//  RootViewModelTests.swift
//  TeeFinderTests
//
//  Created by Ted Schultz on 4/14/25.
//

import XCTest
@testable import TeeFinder

final class RootViewModelTests: XCTestCase {
    
    var viewModel: RootViewModel!
    
    let mockData: [String: Any] = [
        "id": 1,
        "course_name": "Pebble Beach Golf Course",
        "club_name": "Pebble Beach Club",
        "location": [
            "address": "1700 17-Mile Dr",
            "city": "Pebble Beach",
            "state": "CA"
        ]
    ]
    
    override func setUp() {
        super.setUp()
        viewModel = RootViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testUpdateTrieInsertsExpectedKeys() {
        let course = CourseModel.mock(from: mockData)!
        viewModel.searchQuery = "Peb"
        viewModel.searchSuggestion = ""
        
        viewModel.searchTrie.insert(key: course.courseName, value: course.id)
        let result = viewModel.autocomplete("Peb")
        
        XCTAssert(result.hasPrefix("Peb"))
    }
    
    func testMergeDeduplicatesValues() {
        let merged = viewModel.merge([1, 2, 3], with: [2, 3, 4, 5])
        XCTAssertEqual(Set(merged), Set([1, 2, 3, 4, 5]))
    }

    func testUpdateCollectionWithEmptyListClearsItems() {
        let expectation = XCTestExpectation(description: "Items updated on main thread")
        DispatchQueue.main.async {
            self.viewModel.updateCollection(with: [])
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                XCTAssertEqual(self.viewModel.items.count, 0)
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 1.0)
    }

    func testSearchQueryUpdatesSearchSuggestion() {
        let course: CourseModel = CourseModel.mock(from: mockData)!
        let id: CourseID = course.id
        viewModel.searchTrie.insert(key: "Torrey", value: id)
        let result = viewModel.autocomplete("Tor")
        XCTAssertEqual(result, "Torrey")
    }
}

extension CourseModel {
    // Mock initializer using JSONDecoder
    static func mock(from json: [String: Any]) -> CourseModel? {
        // Convert the dictionary to JSON Data
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            print("Failed to convert dictionary to JSON data")
            return nil
        }
        
        // Decode using JSONDecoder
        let decoder = JSONDecoder()
        do {
            let courseModel = try decoder.decode(CourseModel.self, from: jsonData)
            return courseModel
        } catch {
            print("Failed to decode CourseModel from JSON: \(error)")
            return nil
        }
    }
}
