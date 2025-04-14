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
    let key = "DEZHN2ROT3URAJFTMXFZO6GDEM" // somerandomemail
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
    
    func iterateCourses(iteration: @escaping ([CourseModel]) -> Void, completion: @escaping () -> Void) {
//        let pages = 257 // FIXME: Hardcoded. Get this from a response first
        let pages = 2
        let pageSize = 100 // 100 is the maximum size per page
        let group = DispatchGroup()
        for page in 1...pages {
            print(page)
            let urlString = "https://api.golfcourseapi.com/v1/courses?page=\(page)&page_size=\(pageSize)&sort=course_name"
            var request = URLRequest(url: URL(string: urlString)!)
            request.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
            group.enter()
            URLSession.shared.dataTask(with: request) { data, response, error in
                do {
                    let json = try JSONDecoder().decode(CourseSearchResponse.self, from: data!)
                    iteration(json.courses)
                } catch {
                    // FIXME: Don't have fatalErrors
                    fatalError("\(error)")
                }
                group.leave()
            }.resume()
        }
        group.notify(queue: .main) {
            completion()
        }
    }
}
