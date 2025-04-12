//
//  TeeFinderApp.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import SwiftUI

@main
struct TeeFinderApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
