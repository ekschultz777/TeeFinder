//
//  TeeDetailViewModel.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation

class TeeDetailViewModel: ObservableObject {
    typealias Hole = CourseModel.Tees.Tee.Hole
    let courseRating: Double?
    let holes: [Hole]?
    let parTotal: Int?
    let slopeRating: Int?
    let teeName: String?
    let totalYards: Int?
    
    init(model: CourseModel.Tees.Tee) {
        self.courseRating = model.courseRating
        self.holes = model.holes
        self.parTotal = model.parTotal
        self.slopeRating = model.slopeRating
        self.teeName = model.teeName
        self.totalYards = model.totalYards
    }
}
