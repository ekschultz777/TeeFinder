//
//  CourseSearchSession.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

class CourseSearchSession {
    static let shared = CourseSearchSession()
    func search(_ query: String, completion: @escaping (CoursesResponse) -> Void) {
        var request = URLRequest(url: URL(string: "https://api.golfcourseapi.com/v1/search?search_query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")")!)
        let key = "22FA7ADBN3NGJB5VNCYYPITCSI"
        request.setValue("Key \(key)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            let json = try! JSONDecoder().decode(CoursesResponse.self, from: data!)
//            print(json.courses)
            completion(json)
        }.resume()
    }
}
