//
//  AutocompleteViewModel.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/14/25.
//

import Foundation

protocol AutocompleteViewModel: ObservableObject {
    var searchQuery: String { get set }
    var searchSuggestion: String { get set }
    func suggestAutocompletion()
}
