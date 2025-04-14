//
//  Trie.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

/// A thread-safe generic trie (prefix tree) implementation for storing and retrieving
/// key-value pairs where keys are strings and values are a generic.
///
/// The trie supports efficient insertion, exact key lookup, removal, prefix-based autocompletion,
/// and fetching all suggestions for a given prefix.
public class Trie<Object> {

    /// Internal node class used to represent each character in the trie.
    private class TrieNode<T> {
        /// The character value stored at this node.
        var value: Character
        /// A dictionary of child nodes keyed by their character.
        var children = [Character: TrieNode]()
        /// The value associated with a complete key ending at this node.
        var end: T?
        
        /// Initializes a trie node.
        /// - Parameters:
        ///   - value: The character this node represents.
        ///   - children: Child relations.
        ///   - end: The value if this node completes a key, nil otherwise.
        init(value: Character, children: [Character: TrieNode] = [Character: TrieNode](), end: T? = nil) {
            self.value = value
            self.children = children
            self.end = end
        }
    }

    /// The root node of the trie. Unused other than to begin search..
    private let head = TrieNode<Object>(value: "*")

    /// A serial dispatch queue to ensure thread-safe access.
    private let queue = DispatchQueue(label: "com.TeeFinder.Trie")
}

public extension Trie {
    /// Inserts a key-value pair into the trie.
    /// - Parameters:
    ///   - key: The string key to insert.
    ///   - value: The value to associate with the key.
    func insert(key: String, value: Object) {
        queue.async { [unowned self] in
            var current = head
            for char in key {
                if let node = current.children[char] {
                    current = node
                } else {
                    let node = TrieNode<Object>(value: char)
                    current.children[char] = node
                    current = node
                }
            }
            current.end = value
        }
    }

    /// Retrieves the value associated with an exact key.
    /// - Parameter key: The key to look up.
    /// - Returns: The associated value if the key exists, or nil.
    func get(key: String) -> Object? {
        queue.sync {
            var current = head
            for char in key {
                guard let node = current.children[char] else { return nil }
                current = node
            }
            return current.end
        }
    }

    /// Removes the value associated with a given key from the trie.
    /// - Parameter key: The key to remove.
    func remove(key: String) {
        queue.async { [unowned self] in
            var current = head
            for char in key {
                if let node = current.children[char] {
                    current = node
                } else {
                    let node = TrieNode<Object>(value: char)
                    current.children[char] = node
                    current = node
                }
            }
            current.end = nil
        }
    }

    /// Attempts to find the first complete word in the trie that starts with the given prefix.
    /// - Parameter prefix: The prefix to search for.
    /// - Returns: A string representing the first autocompleted word, or nil if none found.
    func autocomplete(_ prefix: String) -> String? {
        queue.sync { [unowned self] in
            var current = head
            for char in prefix {
                guard let node = current.children[char] else { return nil }
                current = node
            }
            
            var stack = [(TrieNode<Object>, String)]()
            stack.append((current, prefix))
            
            while !stack.isEmpty {
                let (node, word) = stack.removeLast()
                if node.end != nil { return word }
                for child in node.children.values {
                    stack.append((child, word + String(child.value)))
                }
            }
            return nil
        }
    }

    /// Retrieves all values whose keys start with the given prefix.
    /// - Parameter prefix: The prefix to search for.
    /// - Returns: An array of values whose prefix matches the given prefix.
    func suggestions(_ prefix: String) -> [Object] {
        queue.sync { [unowned self] in
            var current = head
            for char in prefix {
                guard let node = current.children[char] else { return [] }
                current = node
            }

            var stack = [(TrieNode<Object>, String)]()
            stack.append((current, prefix))
            var suggestions: [Object] = []
            
            while !stack.isEmpty {
                let (node, word) = stack.removeLast()
                if let value = node.end {
                    suggestions.append(value)
                }
                for child in node.children.values {
                    stack.append((child, word + String(child.value)))
                }
            }
            return suggestions
        }
    }
}
