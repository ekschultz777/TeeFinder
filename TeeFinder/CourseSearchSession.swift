//
//  CourseSearchSession.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

class CourseSearchSession {
    static let shared = CourseSearchSession()
    func search(_ query: String, completion: @escaping (Result<CourseSearchResponse, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.golfcourseapi.com/v1/search?search_query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
        let key = "22FA7ADBN3NGJB5VNCYYPITCSI"
        request.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                let json = try JSONDecoder().decode(CourseSearchResponse.self, from: data!)
                completion(.success(json))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func course(_ id: Int, completion: @escaping (Result<CourseResponse, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.golfcourseapi.com/v1/courses/\(id)")!)
        let key = "22FA7ADBN3NGJB5VNCYYPITCSI"
        request.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                let json = try JSONDecoder().decode(CourseLookupResponse.self, from: data!)
                completion(.success(json.course))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
