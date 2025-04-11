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
    @EnvironmentObject var searchTrie: Trie
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Course.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Course>
    @State private var courses: [CourseResponse] = []
    
    @State var searchQuery: String = ""

    var body: some View {
        VStack {
            Image(systemName: "square.and.arrow.up")
                .padding()
                .foregroundStyle(Color.white)
            TextField("Search Courses", text: $searchQuery)
                .foregroundColor(.white)
                .padding()
                .onChange(of: searchQuery) { _, _ in
                    guard searchQuery != "" else {
                        self.courses = []
                        return
                    }
                    guard let possibleSearch = searchTrie.autocomplete(searchQuery) else { return }
                    CourseSearchSession.shared.search(possibleSearch) { response in
                        guard case .success(let searchResponse) = response else { return }
                        self.courses = searchResponse.courses
                    }
                }
                .onSubmit {
                    CourseSearchSession.shared.search(searchQuery) { response in
                        guard case .success(let searchResponse) = response else { return }
                        self.courses = searchResponse.courses
                        self.courses.forEach { searchTrie.insert($0.courseName) }
                    }
                }
            Spacer()
            List {
                ForEach(courses) { item in
                    NavigationLink(item.location.address) {
                        Text(item.location.address)
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .background {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
        }
    }

    private func addItem() {
//        withAnimation {
//            let newItem = Course(context: viewContext)
//            newItem.timestamp = Date()
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
    }

//    private func deleteItems(offsets: IndexSet) {
//        withAnimation {
//            offsets.map { items[$0] }.forEach(viewContext.delete)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
