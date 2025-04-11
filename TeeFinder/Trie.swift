//
//  Trie.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

public class Trie: ObservableObject {
    private class TrieNode {
        var value: Character
        var children = [Character: TrieNode]()
        var end = false
        
        init(value: Character, children: [Character: TrieNode] = [Character: TrieNode](), end: Bool = false) {
            self.value = value
            self.children = children
            self.end = end
        }
    }

    private let head = TrieNode(value: "*")
}

public extension Trie {
    func insert(_ word: String) {
        var current = head
        for char in Array(word) {
            if let node = current.children[char] {
                current = node
            } else {
                let node = TrieNode(value: char)
                current.children[char] = node
                current = node
            }
        }
        current.end = true
    }

    func autocomplete(_ prefix: String) -> String? {
        // Find that the word exists in the Trie
        var current: TrieNode = head
        for char in Array(prefix) {
            guard let node = current.children[char] else { return nil }
            current = node
        }
        
        // Use Depth First Search to find the nearest node
        var stack = [(TrieNode, String)]()
        stack.append((current, prefix))
        while !stack.isEmpty {
            let (node, word) = stack.removeLast()
            guard !node.end else { return word }
            
            for child in node.children.values {
                stack.append((child, word + String(child.value)))
            }
        }
        return nil
    }
    
    func all() -> [String] {
        // Use Depth First Search
        var words: [String] = []
        var stack = [(TrieNode, String)]()
        stack.append((head, ""))
        while !stack.isEmpty {
            let (node, word) = stack.removeLast()
            if node.end {
                words.append(word)
            }
            
            for child in node.children.values {
                stack.append((child, word + String(child.value)))
            }
        }
        return words

    }
}
