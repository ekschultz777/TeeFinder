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
                    AutocompleteTextField(viewModel: viewModel,
                                          onChange: { search($0, comprehensive: false) },
                                          onSubmit: { search($0, comprehensive: true) })
                    Spacer()
                    if viewModel.syncing && comprehensiveSearch {
                        ProgressView()
                            .tint(AppColor.tertiaryForegroundColor) // bright color
                            .scaleEffect(1.5)
                            .padding()
                    } else if comprehensiveSearch {
                        ProgressView()
                            .tint(AppColor.tertiaryForegroundColor) // bright color
                            .scaleEffect(1.5)
                            .padding()
                            .onAppear {
                                // Optionally, for aesthetic, we can show a progress indicator to
                                // show that the user's request was noted.
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    guard !viewModel.syncing else { return }
                                    withAnimation {
                                        comprehensiveSearch = false
                                    }
                                }
                            }
                    }
                    CourseListView(viewModel: viewModel)
                }
                if let error = viewModel.error {
                    ErrorView(title: "Error", message: "\(error.localizedDescription)") {
                        viewModel.clearError()
                    }
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
    
    /// Convenience method of searching the database and setting comprehensiveSearch.
    private func search(_ query: String, comprehensive: Bool) {
        withAnimation {
            comprehensiveSearch = comprehensive
        }
        viewModel.search(query, comprehensive: comprehensive)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
