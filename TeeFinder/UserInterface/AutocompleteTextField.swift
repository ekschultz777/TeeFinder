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
    public var suggest: (String) -> Void
    public var onChange: (String) -> Void
    public var onSubmit: (String) -> Void
    
    var body: some View {
        ZStack {
            // Autocomplete text field
            TextField("", text: $searchSuggestion)
                .foregroundColor(AppColor.quaternaryForegroundColor)
                .padding()
                .onChange(of: searchQuery) {
                    // Show possible autocompletion
                    if searchQuery == "" {
                        self.searchSuggestion = ""
                        return
                    }
                    suggest(searchQuery)
                }
                .onSubmit {
                    searchSuggestion = ""
                }
                .allowsHitTesting(false)
            TextField(
                "",
                text: $searchQuery,
                prompt: Text("Search Courses").foregroundColor(AppColor.quaternaryForegroundColor)
            )
            .foregroundColor(AppColor.primaryForegroundColor)
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
