//
//  Trie.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

// FIXME: Make this thread safe
public class Trie<Object>: ObservableObject {
    private class TrieNode<T> {
        var value: Character
        var children = [Character: TrieNode]()
        var end: T?
        
        init(value: Character, children: [Character: TrieNode] = [Character: TrieNode](), end: T? = nil) {
            self.value = value
            self.children = children
            self.end = end
        }
    }
    private let head = TrieNode<Object>(value: "*")
}

public extension Trie {
    func insert(key: String, value: Object) {
        var current = head
        for char in Array(key) {
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
    
    func get(key: String) -> Object? {
        // Find that the word exists in the Trie
        var current: TrieNode = head
        for char in Array(key) {
            guard let node = current.children[char] else { return nil }
            current = node
        }
        return current.end
    }
    
    func remove(key: String) {
        var current = head
        for char in Array(key) {
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

    func autocomplete(_ prefix: String) -> Object? {
        // Find that the word exists in the Trie
        var current: TrieNode = head
        for char in Array(prefix) {
            guard let node = current.children[char] else { return nil }
            current = node
        }
        
        // Use Depth First Search to find the nearest node
        var stack = [(TrieNode<Object>, String)]()
        stack.append((current, prefix))
        while !stack.isEmpty {
            let (node, word) = stack.removeLast()
            guard node.end == nil else { return node.end }
            for child in node.children.values {
                stack.append((child, word + String(child.value)))
            }
        }
        return nil
    }
    
    func suggestions(_ prefix: String) -> [Object] {
        // Find that the word exists in the Trie
        var current: TrieNode = head
        for char in Array(prefix) {
            guard let node = current.children[char] else { return [] }
            current = node
        }
        
        // Use Depth First Search to find the nearest node
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

public class LRUCache<Object>: ObservableObject {
    private var nodeCache: [String: Node] = [:]
    private let trie = Trie<Object>()

    class Node {
        var key: String
        var next: Node?
        var prev: Node?
        init(key: String, next: Node? = nil, prev: Node? = nil) {
            self.key = key
            self.next = next
            self.prev = prev
        }
    }
    private var head: Node
    private var tail: Node
    
    let capacity: Int = 100

    init() {
        head = Node(key: "head")
        tail = Node(key: "tail")
        tail.next = head
        head.prev = tail
    }
}

public extension LRUCache {
    private func unlink(_ node: Node) {
        // Remove node from current location
        node.prev?.next = node.next
        node.next?.prev = node.prev
    }
    
    private func moveToHead(_ node: Node) {
        unlink(node)
        // Insert node behind head
        node.prev = head.prev
        node.next = head
        head.prev?.next = node
        head.prev = node
    }

    func insert(key: String, value: Object) {
        if nodeCache.values.count >= capacity {
            if let last = tail.next, last !== head {
                remove(key: last.key)
            }
        }
        let node = nodeCache[key] ?? Node(key: key)
        nodeCache[key] = node
        moveToHead(node)
        trie.insert(key: key, value: value)
    }
    
    func remove(key: String) {
        guard let node = nodeCache[key] else { return }
        unlink(node)
        nodeCache[key] = nil
        trie.remove(key: key)
    }

    func autocomplete(_ prefix: String) -> Object? {
        trie.autocomplete(prefix)
    }
    
    func suggestions(_ prefix: String) -> [Object] {
        trie.suggestions(prefix)
    }
}
