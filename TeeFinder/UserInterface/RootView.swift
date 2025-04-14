//
//  ContentView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel = RootViewModel()
        
    @State private var searchQuery: String = ""
    @State private var searchSuggestion: String = ""
    @State private var comprehensiveSearch = false

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Image("BTGLogo")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 50, maxHeight: 50)
                        .padding()
                    AutocompleteTextField(searchQuery: $searchQuery,
                                          searchSuggestion: $searchSuggestion,
                                          suggest: { viewModel.autocomplete($0) },
                                          onChange: { search($0, comprehensive: false) },
                                          onSubmit: { search($0, comprehensive: true) })
                    Spacer()
                    if viewModel.syncing && comprehensiveSearch {
                        ProgressView()
                            .tint(AppColor.tertiaryForegroundColor) // bright color
                            .scaleEffect(1.5)
                            .padding()
                    }
                    CourseListView(viewModel: viewModel)
                }
                if let _ = viewModel.error {
//                    ErrorView(title: "Error", message: "Something went wrong") {
//                        viewModel.clearError()
//                    }
                }
            }
            .onChange(of: viewModel.syncing) {
                // This is the case that we are still performing a comprehensive
                // search when syncing finishes. If this is the case, we can
                // remove the progress view.
                if !viewModel.syncing && comprehensiveSearch {
                    withAnimation {
                        comprehensiveSearch = false
                    }
                }
            }
            .background {
                Color.black
                    .ignoresSafeArea()
            }
        }
    }
    
    private func search(_ query: String, comprehensive: Bool) {
        withAnimation {
            comprehensiveSearch = comprehensive
        }
        if comprehensive { searchSuggestion = "" }
        debounce(for: 0.25) {
            viewModel.search(query) { suggestions in
                guard !comprehensive else { return }
                searchSuggestion = viewModel.autocomplete(searchQuery)
            }
        }
    }
    
    // MARK: Debounce
    @State private var debounceWork: DispatchWorkItem? = nil
    private func debounce(for time: TimeInterval, _ closure: @escaping () -> Void) {
        debounceWork?.cancel()
        debounceWork = DispatchWorkItem { closure() }
        DispatchQueue.main.asyncAfter(deadline: .now() + time, execute: debounceWork!)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
