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
                CourseListItemView(viewModel: viewModel, 
                                   course: item,
                                   clubName: item.clubName,
                                   location: item.location.address,
                                   rating: 71)
            }
        }
        .scrollContentBackground(.hidden)
        .listRowSeparator(.hidden)
        .listRowSpacing(8)
    }
}

struct CourseListItemView: View {
    typealias CourseListItemViewModel = CourseListViewModel
    let viewModel: CourseListItemViewModel
    let course: Course
    let clubName: String
    let location: String
    let rating: Double
    var body: some View {
        NavigationLink(destination: {
            GolfCourseDetailView(courseName: clubName)
                .onAppear {
                    // If we check out a course we should persist it in the future.
                    viewModel.persist(course)
                }
        }, label: {
            HStack(alignment: .top, spacing: 8) {
                // Optional image or icon
                Image(systemName: "flag.circle.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black.opacity(0.9))
                VStack(alignment: .leading, spacing: 8) {
                    Text(clubName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(location)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
            }
            .padding()
        })
    }
}


struct GolfCourseDetailView: View {
    var courseName: String

    var body: some View {
        Text("Welcome to \(courseName)")
            .font(.largeTitle)
            .padding()
    }
}
