//
//  CourseSearchSession.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

// TODO: Clean up this class
class CourseSearchSession {
    static let shared = CourseSearchSession()
    //        let key = "22FA7ADBN3NGJB5VNCYYPITCSI" // tedkschultz
    let key = "WGBXN7EY33SHFHP2AC6BZIXVDA" // somerandomemail
    func search(_ query: String, completion: @escaping (Result<CourseSearchResponse, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.golfcourseapi.com/v1/search?search_query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
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
    
    func course(_ id: Int, completion: @escaping (Result<Course, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.golfcourseapi.com/v1/courses/\(id)")!)
        request.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                let json = try JSONDecoder().decode(CourseLookupResponse.self, from: data!)
                let encodedCourse = try! JSONEncoder().encode(json.course)
                let course = try! JSONDecoder().decode(Course.self, from: encodedCourse)
                print(course)
                completion(.success(json.course))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func courses(completion: @escaping (Result<CourseSearchResponse, Error>) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.golfcourseapi.com/v1/courses")!)
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
}
