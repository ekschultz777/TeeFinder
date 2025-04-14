//
//  Course+CoreDataProperties.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/14/25.
//
//

import Foundation
import CoreData


extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged public var apiId: Int32
    @NSManaged public var data: Data
    @NSManaged public var courseName: String
    @NSManaged public var clubName: String
    @NSManaged public var address: String?
    @NSManaged public var state: String?
    @NSManaged public var city: String?

}

extension Course : Identifiable {

}
