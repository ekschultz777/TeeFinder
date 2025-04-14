//
//  CourseSearchSession.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

class CourseSearchSession {
    static let shared = CourseSearchSession(apiKey: "53XC5WWWALENMVNI6DGKYOEXCY")
    
    private let apiKey: String
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    private let scheme = "https"
    private let host = "api.golfcourseapi.com"
    
    private func searchURL(query: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/v1/search"
        components.queryItems = [
            URLQueryItem(name: "search_query", value: query)
        ]
        return components.url
    }
    
    private func coursesURL(page: Int) -> URL? {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = "/v1/courses"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page_size", value: "\(100)"), // maximum items per page is 100
            URLQueryItem(name: "sort", value: "course_name"),
        ]
        return components.url
    }
    
    private func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    public func search(_ query: String, completion: @escaping (Result<CourseSearchResponse, Error>) -> Void) {
        guard let url = searchURL(query: query) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        let request = request(for: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            do {
                guard let data else { throw error ?? URLError(.badServerResponse) }
                let json = try JSONDecoder().decode(CourseSearchResponse.self, from: data)
                completion(.success(json))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
        
    public func iterateCourses(iteration: @escaping (Result<[CourseModel], Error>) -> Void, completion: @escaping () -> Void) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            // We can hardcode the number of pages we need to parse from the API. However, if we expect this to
            // change in the future, we can make this a variable which we retrieve from the courses response
            // metadata.
            let pages = 257
            let group = DispatchGroup()
            // Limit the number of concurrent API calls in order to prevent us from exceeding the rate limit.
            let maxConcurrentOperations = 1
            let semaphore = DispatchSemaphore(value: maxConcurrentOperations)
            let startPage = UserDefaults.standard.lastSavedPage ?? 1
            for page in startPage...pages {
                guard let url = coursesURL(page: page) else { continue }
                let request = request(for: url)
                group.enter()
                semaphore.wait()
                URLSession.shared.dataTask(with: request) { data, response, error in
                    semaphore.signal()
                    print("Syncing page \(page)")
                    do {
                        guard let data else { throw error ?? URLError(.badServerResponse) }
                        let json = try JSONDecoder().decode(CourseSearchResponse.self, from: data)
                        UserDefaults.standard.lastSavedPage = page
                        iteration(.success(json.courses))
                    } catch {
                        iteration(.failure(error))
                    }
                    group.leave()
                }.resume()
            }
            group.notify(queue: .main) {
                completion()
            }
        }
    }
}

extension UserDefaults {
    var lastSavedPage: Int? {
        get {
            UserDefaults.standard.value(forKey: "lastSavedPage") as? Int
        } set {
            UserDefaults.standard.setValue(newValue, forKey: "lastSavedPage")
        }
    }
}
