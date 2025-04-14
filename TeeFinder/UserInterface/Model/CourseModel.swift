//
//  GolfCourseAPIModel.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

typealias CourseID = Int

// MARK: - Course Model

struct CourseModel: Codable, Identifiable {
    /// GolfCourseAPI gives back some course names that have irrelevant information before a \t.
    /// In order to fix this, we only need the part of the information after the tab if one is present.
    /// - Parameter string: A string to format.
    /// - Returns: The formatted string.
    private static func format(_ string: String) -> String {
        let splitValue = string.split(separator: "\t")
        return String(splitValue.count > 1 ? splitValue[1] : splitValue[0])
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.clubName = Self.format(try container.decode(String.self, forKey: .clubName))
        self.courseName = Self.format(try container.decode(String.self, forKey: .courseName))
        self.id = try container.decode(CourseID.self, forKey: .id)
        self.location = try container.decode(CourseModel.Location.self, forKey: .location)
        self.tees = try container.decodeIfPresent(CourseModel.Tees.self, forKey: .tees)
    }
    
    let clubName: String
    let courseName: String
    let id: CourseID
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

extension CourseModel {
    struct Location: Codable {
        let address: String?
        let city: String?
        let state: String?
        let country: String?
        let latitude: Double?
        let longitude: Double?
    }
}

// MARK: - Tees Model

extension CourseModel {
    struct Tees: Codable {
        let female: [Tee]?
        let male: [Tee]?
    }
}

extension CourseModel.Tees {
    /// a method that finds an average tee and returns its course rating.
    /// - Parameter tees: The input tees to choose a course rating from.
    /// - Returns: Course rating as a double.
    public func commonTee() -> CourseModel.Tees.Tee? {
        guard let maleTees = self.male, !maleTees.isEmpty else { return nil }
        let middleIndex = maleTees.count / 2
        return maleTees[middleIndex]
    }

    struct Tee: Codable {
        let backBogeyRating: Double?
        let backCourseRating: Double?
        let backSlopeRating: Int?
        let bogeyRating: Double?
        let courseRating: Double?
        let frontBogeyRating: Double?
        let frontCourseRating: Double?
        let frontSlopeRating: Int?
        let holes: [Hole]?
        let numberOfHoles: Int?
        let parTotal: Int?
        let slopeRating: Int?
        let teeName: String?
        let totalMeters: Int?
        let totalYards: Int?
        
        enum CodingKeys: String, CodingKey {
            case backBogeyRating = "back_bogey_rating"
            case backCourseRating = "back_course_rating"
            case backSlopeRating = "back_slope_rating"
            case bogeyRating = "bogey_rating"
            case courseRating = "course_rating"
            case frontBogeyRating = "front_bogey_rating"
            case frontCourseRating = "front_course_rating"
            case frontSlopeRating = "front_slope_rating"
            case holes
            case numberOfHoles = "number_of_holes"
            case parTotal = "par_total"
            case slopeRating = "slope_rating"
            case teeName = "tee_name"
            case totalMeters = "total_meters"
            case totalYards = "total_yards"
        }
    }
}

extension CourseModel.Tees.Tee {
    struct Hole: Codable {
        let handicap: Int?
        let par: Int?
        let yardage: Int?
    }
}

// MARK: - Course Model Equatable Conformance

extension CourseModel: Equatable {
    static func == (lhs: CourseModel, rhs: CourseModel) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Course Model Hashable Conformance

extension CourseModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
