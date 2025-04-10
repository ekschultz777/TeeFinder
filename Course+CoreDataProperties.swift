//
//  Course+CoreDataProperties.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/10/25.
//
//

import Foundation
import CoreData


extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged public var timestamp: Date?

}

extension Course : Identifiable {

}
