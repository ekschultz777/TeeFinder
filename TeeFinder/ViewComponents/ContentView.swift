//
//  ContentView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel = ContentViewModel()
    
    @State private var searchQuery: String = ""
    @State private var searchSuggestion: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Image("BTGLogo")
                    .resizable()
                    .aspectRatio(contentMode: ContentMode.fit)
                    .frame(maxWidth: 40, maxHeight: 40)
                    .padding()
                AutocompleteTextField(searchQuery: $searchQuery,
                                      searchSuggestion: $searchSuggestion,
                                      suggest: { viewModel.autocomplete($0) },
                                      onChange: { search($0) },
                                      onSubmit: { search($0) })
                Spacer()
                CourseListView(viewModel: viewModel)
            }
            .background {
                Color.black.opacity(0.9)
                    .ignoresSafeArea()
            }
        }
    }
    
    private func search(_ query: String) {
        debounce(for: 0.25) {
            guard !query.isEmpty else {
                self.viewModel.updateList(with: [])
                return
            }
            viewModel.search(query) { suggestions in
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
