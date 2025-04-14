//
//  AutocompleteTextField.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//

import Foundation
import SwiftUI

struct AutocompleteTextField: View {
    @Binding var searchQuery: String
    @Binding var searchSuggestion: String
    public var suggest: (String) -> String
    public var onChange: (String) -> Void
    public var onSubmit: (String) -> Void
    
    var body: some View {
        ZStack {
            // Autocomplete text field
            TextField("", text: $searchSuggestion)
                .foregroundColor(AppColor.quaternaryForegroundColor)
                .padding()
                .onChange(of: searchQuery) {
                    if searchQuery == "" {
                        self.searchSuggestion = ""
                        return
                    }
                    // FIXME: Do this logic in the view model rather than in the view
                    // Run suggestion lookup on a background queue, it will block the thread it is run on.
                    DispatchQueue.global(qos: .userInitiated).async {
                        let suggestion = suggest(searchQuery)
                        // Update UI on the main thread
                        DispatchQueue.main.async {
                            // Check that the suggestion still matches the current searchQuery
                            if suggestion.hasPrefix(searchQuery) {
                                self.searchSuggestion = suggestion
                            } else {
                                // Clear the suggestion it if it's no longer valid
                                self.searchSuggestion = ""
                            }

                        }
                    }
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
