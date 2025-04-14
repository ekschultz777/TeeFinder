//
//  TrieTests.swift
//  TeeFinderTests
//
//  Created by Ted Schultz on 4/14/25.
//

import XCTest
@testable import TeeFinder

final class TrieTests: XCTestCase {
    var trie: Trie<String>!

    override func setUpWithError() throws {
        super.setUp()
        trie = Trie<String>()
    }

    override func tearDownWithError() throws {
        trie = nil
        super.tearDown()
    }

    /// Test inserting and retrieving a key
    func testInsertAndGet() {
        trie.insert(key: "abc", value: "123")
        let result = trie.get(key: "abc")
        XCTAssertEqual(result, "123", "Should retrieve the value for 'abc'")
    }

    /// Test getting a non-existent key
    func testGetNonExistentKey() {
        trie.insert(key: "abc", value: "123")
        let result = trie.get(key: "abcd")
        XCTAssertNil(result, "Should return nil for a key that doesn't exist")
    }

    /// Test removing a key from the trie
    func testRemoveKey() {
        trie.insert(key: "abc", value: "123")
        trie.remove(key: "abc")

        // Wait for async remove to complete
        let expectation = XCTestExpectation(description: "Wait for async remove")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let result = self.trie.get(key: "abc")
            XCTAssertNil(result, "Value should be nil after removal")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    /// Test autocomplete returns a valid result
    func testAutocomplete() {
        trie.insert(key: "abc", value: "123")
        trie.insert(key: "abd", value: "456")
        trie.insert(key: "abe", value: "789")

        let result = trie.autocomplete("ab")

        XCTAssertNotNil(result)
        XCTAssertTrue(["abc", "abd", "abe"].contains(result!), "Should return a valid autocomplete for 'ab'")
    }

    /// Test suggestions return multiple matching results
    func testSuggestions() {
        trie.insert(key: "a", value: "1")
        trie.insert(key: "ab", value: "2")
        trie.insert(key: "abc", value: "3")
        trie.insert(key: "b", value: "4")

        let results = trie.suggestions("a")

        XCTAssertEqual(results.count, 3, "Should return 3 suggestions starting with 'a'")
        XCTAssertTrue(results.contains("1"))
        XCTAssertTrue(results.contains("2"))
        XCTAssertTrue(results.contains("3"))
    }
}
