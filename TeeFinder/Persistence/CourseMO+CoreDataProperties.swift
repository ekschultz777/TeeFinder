//
//  Course+CoreDataProperties.swift
//  TeeFinder
//
//  Created by Ted Schultz on 4/11/25.
//
//

import Foundation
import CoreData


extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    // TODO: Remove data and add properties
    @NSManaged public var data: Data
    @NSManaged public var id: Int32
}

extension Course : Identifiable {

}
