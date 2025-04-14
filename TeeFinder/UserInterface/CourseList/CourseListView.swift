//
//  CourseListView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//

import Foundation
import SwiftUI
import CoreData

struct CourseListView<T: CourseListViewModel>: View {
    @StateObject var viewModel: T

    var body: some View {
        List {
            ForEach(viewModel.items) { course in
                CourseListItemView(viewModel: CourseListItemViewModel(model: course))
            }
        }
        .scrollContentBackground(.hidden)
        .listRowSeparator(.hidden)
        .listRowSpacing(8)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}

