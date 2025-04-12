//
//  CourseListView.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//

import Foundation
import SwiftUI
import CoreData

typealias CourseListViewModel = ContentViewModel

struct CourseListView: View {
    @ObservedObject var viewModel: CourseListViewModel

    var body: some View {
        List {
            ForEach(viewModel.items) { item in
                NavigationLink(item.clubName) {
                    VStack {
                        VStack {
                            Text(item.clubName)
                                .foregroundStyle(Color.white)
                                .padding()
                            Text(item.courseName)
                                .foregroundStyle(Color.white)
                                .padding()
                            Text(item.location.address)
                                .foregroundStyle(Color.white)
                                .padding()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background {
                        Color.black.opacity(0.9)
                            .ignoresSafeArea()
                    }
                    .onAppear {
                        // If we check out a course we should persist it in the future.
                        viewModel.persist(item)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
