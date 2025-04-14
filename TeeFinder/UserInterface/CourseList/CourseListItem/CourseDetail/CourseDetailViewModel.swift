//
//  CourseDetailViewModel.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation

class CourseDetailViewModel: ObservableObject {
    let clubName: String
    let courseName: String
    let address: String?
    let tees: CourseModel.Tees?
    
    init(_ course: CourseModel) {
        clubName = course.clubName
        courseName = course.courseName
        address = course.location.address
        tees = course.tees
    }
}
