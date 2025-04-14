//
//  CourseSearchSession.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//

import Foundation

/// A session responsible for handling course search and lookup requests using GolfCourseAPI.
class APISession {
    static let shared = APISession(apiKey: "QWRBJBHA5NSULIE473NTLUDZ2A")
    
    private let scheme = "https"
    private let host = "api.golfcourseapi.com"
    private let apiKey: String

    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    /// Constructs a search URL for querying courses by name.
    /// - Parameter query: The search term used to find courses.
    /// - Returns: A `URL` for the search endpoint, or `nil` if construction fails.
    public func searchURL(query: String) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = "/v1/search"
        components.queryItems = [
            URLQueryItem(name: "search_query", value: query)
        ]
        return components.url
    }
    
    /// Constructs a paginated URL for retrieving a list of courses.
    /// - Parameter page: The page number to request.
    /// - Returns: A `URL` for the paginated courses endpoint, or `nil` if construction fails.
    public func coursesURL(page: Int) -> URL? {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = "/v1/courses"
        components.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page_size", value: "\(100)"), // Max allowed page size
            URLQueryItem(name: "sort", value: "course_name"),
        ]
        return components.url
    }
    
    /// Creates a `URLRequest` with the appropriate authorization headers for a given URL.
    /// - Parameter url: The URL to request.
    /// - Returns: A configured `URLRequest` with API key authentication.
    public func request(for url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.setValue("Key \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    /// Performs a course search using a keyword query.
    /// - Parameters:
    ///   - query: The search string used to find courses.
    ///   - completion: A completion handler returning either the decoded `CourseSearchResponse` or an error.
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
                Self.debugPrint(data)
                completion(.failure(error))
            }
        }.resume()
    }
    
    /// Iterates through all available course pages and returns the courses from each page in sequence.
    /// Designed to process a large dataset over multiple paginated API requests, with control over
    /// concurrent requests to avoid hitting rate limits. Saves the last successfully synced page
    /// in UserDefaults in an effort to reduce unnecessary API calls.
    /// - Parameters:
    ///   - iteration: A closure called after each page is fetched and parsed. Returns an array of `CourseModel`s or an error.
    ///   - completion: A closure called after all pages have been fetched.
    public func iterateCourses(
        iteration: @escaping (Result<[CourseModel], Error>) -> Void,
        completion: @escaping () -> Void
    ) {
        DispatchQueue.global().async { [weak self] in
            guard let self else { return }
            let pages = 257 // Total pages to iterate
            let group = DispatchGroup()
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
                        Self.debugPrint(data)
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
    
    private static func debugPrint(_ data: Data?) {
        guard let data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
        print(json)
    }
}
