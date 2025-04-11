//
//  GolfCourseAPIModel.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

// MARK: - Main Model
struct CourseSearchResponse: Codable {
    let courses: [CourseResponse]
    
    enum CodingKeys: String, CodingKey {
        case courses
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.courses = try container.decode([CourseResponse].self, forKey: .courses)
    }
}

struct CourseLookupResponse: Codable {
    let course: CourseResponse
    
    enum CodingKeys: String, CodingKey {
        case course
    }
}

// MARK: - Course Model
struct CourseResponse: Codable, Identifiable {
    let clubName: String
    let courseName: String
    let id: Int
    let location: Location
    let tees: Tees?
    
    enum CodingKeys: String, CodingKey {
        case clubName = "club_name"
        case courseName = "course_name"
        case id
        case location
        case tees
    }
}

// MARK: - Location Model
struct Location: Codable {
    let address: String
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
    let state: String
}

// MARK: - Tees Model
struct Tees: Codable {
    let female: [Tee]?
    let male: [Tee]?
}

// MARK: - Tee Model
struct Tee: Codable {
//    let backBogeyRating: String?
//    let backCourseRating: String?
//    let backSlopeRating: Int?
//    let bogeyRating: String?
//    let courseRating: String?
//    let frontBogeyRating: String?
//    let frontCourseRating: String?
//    let frontSlopeRating: Int?
//    let holes: [Hole]?
//    let numberOfHoles: Int?
//    let parTotal: Int?
//    let slopeRating: Int?
//    let teeName: String?
//    let totalMeters: Int?
//    let totalYards: Int?

//    enum CodingKeys: String, CodingKey {
//        case backBogeyRating = "back_bogey_rating"
//        case backCourseRating = "back_course_rating"
//        case backSlopeRating = "back_slope_rating"
//        case bogeyRating = "bogey_rating"
//        case courseRating = "course_rating"
//        case frontBogeyRating = "front_bogey_rating"
//        case frontCourseRating = "front_course_rating"
//        case frontSlopeRating = "front_slope_rating"
//        case holes
//        case numberOfHoles = "number_of_holes"
//        case parTotal = "par_total"
//        case slopeRating = "slope_rating"
//        case teeName = "tee_name"
//        case totalMeters = "total_meters"
//        case totalYards = "total_yards"
//    }
}

// MARK: - Hole Model
struct Hole: Codable {
    let handicap: Int?
    let par: Int?
    let yardage: Int?
}
