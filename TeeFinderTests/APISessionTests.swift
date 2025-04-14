//
//  CourseSearchSessionTests.swift
//  TeeFinderTests
//
//  Created by Ted Schultz on 4/14/25.
//

import XCTest
@testable import TeeFinder

final class APISessionTests: XCTestCase {
    var session: APISession!

    override func setUpWithError() throws {
        super.setUp()
        session = APISession(apiKey: "API_KEY")
    }

    override func tearDownWithError() throws {
        session = nil
        super.tearDown()
    }

    /// Test URL generation for search queries
    func testSearchURLConstruction() {
        let url = session.searchURL(query: "golf")
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.scheme, "https")
        XCTAssertEqual(url?.host, "api.golfcourseapi.com")
        XCTAssertEqual(url?.path, "/v1/search")
        XCTAssertTrue(url?.query?.contains("search_query=golf") ?? false)
    }

    /// Test URL generation for course pagination
    func testCoursesURLConstruction() {
        let url = session.coursesURL(page: 2)
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.path, "/v1/courses")
        XCTAssertTrue(url?.query?.contains("page=2") ?? false)
        XCTAssertTrue(url?.query?.contains("page_size=100") ?? false)
        XCTAssertTrue(url?.query?.contains("sort=course_name") ?? false)
    }

    /// Test request adds correct API key to headers
    func testRequestAddsAuthorizationHeader() {
        let url = URL(string: "https://example.com")!
        let request = session.request(for: url)
        let authHeader = request.value(forHTTPHeaderField: "Authorization")
        XCTAssertEqual(authHeader, "Key API_KEY")
    }
}
