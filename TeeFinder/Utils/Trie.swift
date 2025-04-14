//
//  Trie.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

public class Trie<Object> {
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
    private let queue = DispatchQueue(label: "com.TeeFinder.Trie")
}

public extension Trie {
    func insert(key: String, value: Object) {
        queue.async { [unowned self] in
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
    }
    
//    func get(key: String) -> Object? {
//        queue.sync {
//            // Find that the word exists in the Trie
//            var current: TrieNode = head
//            for char in Array(key) {
//                guard let node = current.children[char] else { return nil }
//                current = node
//            }
//            return current.end
//        }
//    }
    
    func remove(key: String) {
        queue.async { [unowned self] in
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
    }

    func autocomplete(_ prefix: String, completion: @escaping (String?) -> Void) {
        queue.async { [unowned self] in
            // Find that the word exists in the Trie
            var current: TrieNode<Object> = head
            for char in Array(prefix) {
                guard let node = current.children[char] else { completion(nil); return }
                current = node
            }
            
            // Use Depth First Search to find the nearest node
            var stack = [(TrieNode<Object>, String)]()
            stack.append((current, prefix))
            while !stack.isEmpty {
                let (node, word) = stack.removeLast()
                guard node.end == nil else { completion(word); return }
                for child in node.children.values {
                    stack.append((child, word + String(child.value)))
                }
            }
            completion(nil)
        }
    }
    
    func suggestions(_ prefix: String, completion: @escaping ([Object]) -> Void) {
        queue.async { [unowned self] in
            // Find that the word exists in the Trie
            var current: TrieNode = head
            for char in Array(prefix) {
                guard let node = current.children[char] else { completion([]); return }
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
            completion(suggestions)
        }
    }
}
