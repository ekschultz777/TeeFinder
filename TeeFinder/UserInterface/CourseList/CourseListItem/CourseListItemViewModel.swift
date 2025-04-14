//
//  CourseListItemViewModel.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation

class CourseListItemViewModel: ObservableObject {
    let model: CourseModel
    
    init(model: CourseModel) {
        self.model = model
    }
    
    var clubName: String {
        model.clubName
    }
    var courseName: String {
        model.courseName
    }
    var address: String? {
        model.location.address
    }
    var tees: CourseModel.Tees? {
        model.tees
    }
}
