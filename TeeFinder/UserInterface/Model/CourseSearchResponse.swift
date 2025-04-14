//
//  CourseSearchResponse.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/13/25.
//

import Foundation

// MARK: - Course Search Response Model

struct CourseSearchResponse: Codable {
    let courses: [CourseModel]
    let metadata: Metadata?
    
    enum CodingKeys: String, CodingKey {
        case courses
        case metadata
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.courses = try container.decode([CourseModel].self, forKey: .courses)
        self.metadata = try? container.decodeIfPresent(Metadata.self, forKey: .metadata)
    }
}

// MARK: - Metadata Model

extension CourseSearchResponse {
    struct Metadata: Codable {
        let currentPage: Int
        let firstPage: Int
        let lastPage: Int
        let pageSize: Int
        let totalRecords: Int
        
        enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case firstPage = "first_page"
            case lastPage = "last_page"
            case pageSize = "page_size"
            case totalRecords = "total_records"
        }
    }
}
