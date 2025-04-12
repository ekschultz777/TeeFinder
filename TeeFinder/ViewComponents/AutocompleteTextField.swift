//
//  AutocompleteTextField.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//

import Foundation
import SwiftUI

struct AutocompleteTextField: View {
    @Binding private(set) var searchQuery: String
    @Binding private(set) var searchSuggestion: String
    public var suggest: (String) -> String
    public var onChange: (String) -> Void
    public var onSubmit: (String) -> Void
    
    var body: some View {
        ZStack {
            // Autocomplete text field
            TextField("", text: $searchSuggestion)
                .foregroundColor(.gray)
                .padding()
                .onChange(of: searchQuery) {
                    // Show possible autocompletion
                    if searchQuery == "" {
                        self.searchSuggestion = ""
                        return
                    }
                    searchSuggestion = suggest(searchQuery)
                }
                .onSubmit {
                    searchSuggestion = ""
                }
                .allowsHitTesting(false)
            TextField(
                "",
                text: $searchQuery,
                prompt: Text("Search Courses").foregroundColor(.gray)
            )
            .foregroundColor(.white)
            .padding()
            .onChange(of: searchQuery) { _,_ in
                onChange(searchQuery)
            }
            .onSubmit {
                onSubmit(searchQuery)
            }
        }
    }
}
