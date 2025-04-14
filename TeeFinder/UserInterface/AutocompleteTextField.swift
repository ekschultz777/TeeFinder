//
//  AutocompleteTextField.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//

import Foundation
import SwiftUI

struct AutocompleteTextField<T: AutocompleteViewModel>: View {
    @StateObject var viewModel: T
    public var onChange: (String) -> Void
    public var onSubmit: (String) -> Void
    
    var body: some View {
        ZStack {
            TextField("", text: $viewModel.searchSuggestion)
                .foregroundColor(AppColor.quaternaryForegroundColor)
                .padding()
                .onChange(of: viewModel.searchQuery) {
                    viewModel.suggestAutocompletion()
                }
                .onSubmit {
                    viewModel.searchSuggestion = ""
                }
                .allowsHitTesting(false)
            TextField(
                "",
                text: $viewModel.searchQuery,
                prompt: Text("Search Courses").foregroundColor(AppColor.quaternaryForegroundColor)
            )
            .foregroundColor(AppColor.primaryForegroundColor)
            .padding()
            .onChange(of: viewModel.searchQuery) { _,_ in
                onChange(viewModel.searchQuery)
            }
            .onSubmit {
                onSubmit(viewModel.searchQuery)
            }
        }
    }
}
