# TeeFinder

Built to 

## Features

- Browse a list of golf courses by search
- View detailed information for each course  
- In-app search functionality for fast querying

## Requirements

- macOS with [Xcode](https://developer.apple.com/xcode/) installed  
- Xcode 15.0 or later recommended  
- iOS 17.0 or later

## Getting Started

1. Clone the repository:
   git clone https://github.com/yourusername/TeeFinder.git
   cd TeeFinder

2. Open the project in Xcode
open TeeFinder.xcodeproj
Build and run the app on a simulator or physical iOS device.

# Data Handling and API Limitations
TeeFinder relies on a third-party API, __GolfCourseAPI__, to retrieve golf course data. At present, the API does not support querying courses by geographic location or other filters. As a result, the application implements a workaround by loading the entire database of courses upon the first launch.

This approach allows the app to:

- Search and filter courses on the client-side
- Provide a responsive user experience during search where searches are cached persistently between launches
- Avoid repeated API calls for each query

Trade-Offs
While this method improves search performance, it introduces a significant upfront cost in terms of network usage and initial load time. In a production environment, this would not be considered a scalable or user-friendly solution. Ideally, the API should provide endpoints that support location-based queries.

Implementation Notes
The app is built using native Swift and SwiftUI, and utilizes URLSession for networking.

All course queries are stored locally in memory after the initial load to facilitate fast search operations.

Contact
Please feel free to submit a pull request.
