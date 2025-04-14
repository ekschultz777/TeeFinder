//
//  CourseListViewModel.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation

protocol CourseListViewModel: ObservableObject {
    var items: [CourseModel] { get }
}
